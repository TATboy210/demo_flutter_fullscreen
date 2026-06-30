import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();
  runApp(const MyApp());
}

class LogEntry {
  final DateTime timestamp;
  final String packageName;
  final String methodName;
  final bool success;
  final String? errorMessage;

  const LogEntry({
    required this.timestamp,
    required this.packageName,
    required this.methodName,
    required this.success,
    this.errorMessage,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '双包全屏对比',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DualFullscreenPage(),
    );
  }
}

class DualFullscreenPage extends StatefulWidget {
  const DualFullscreenPage({super.key});

  @override
  State<DualFullscreenPage> createState() => _DualFullscreenPageState();
}

class _DualFullscreenPageState extends State<DualFullscreenPage> {
  // fullscreen_window 状态
  bool _fwFullscreen = false;
  bool _fwToggling = false;

  // flutter_fullscreen 状态
  bool _ffFullscreen = false;
  bool _ffToggling = false;
  late final FullScreenListener _ffListener;

  // 日志状态
  final List<LogEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _ffListener = _FfFullscreenListener(
      onEnterFullScreen: () {
        if (mounted) {
          setState(() {
            _ffFullscreen = true;
            _ffToggling = false;
          });
        }
      },
      onLeaveFullScreen: () {
        if (mounted) {
          setState(() {
            _ffFullscreen = false;
            _ffToggling = false;
          });
        }
      },
    );
    FullScreen.addListener(_ffListener);
  }

  @override
  void dispose() {
    FullScreen.removeListener(_ffListener);
    super.dispose();
  }

  void _addLog(String packageName, String methodName, bool success, [String? errorMessage]) {
    setState(() {
      _logs.insert(0, LogEntry(
        timestamp: DateTime.now(),
        packageName: packageName,
        methodName: methodName,
        success: success,
        errorMessage: errorMessage,
      ));
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  Future<void> _toggleFwFullscreen() async {
    if (_fwToggling) return;
    _fwToggling = true;
    final previous = _fwFullscreen;
    setState(() => _fwFullscreen = !_fwFullscreen);
    try {
      await FullScreenWindow.setFullScreen(_fwFullscreen);
      _addLog('fullscreen_window', 'setFullScreen', true);
      // 退出全屏后强制布局重建（Windows 布局修复）
      if (!_fwFullscreen && mounted) {
        // 延迟确保窗口完全退出全屏
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          setState(() {});
          // 再次延迟重建，确保布局完全恢复
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fwFullscreen = previous);
        _addLog('fullscreen_window', 'setFullScreen', false, e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('fullscreen_window 失败: $e')),
        );
      }
    } finally {
      _fwToggling = false;
    }
  }

  void _toggleFfFullscreen() {
    if (_ffToggling) return;
    _ffToggling = true;
    _addLog('flutter_fullscreen', 'setFullScreen', true);
    FullScreen.setFullScreen(!_ffFullscreen);
    // 超时机制：如果 listener 没有在 3 秒内触发，手动更新状态
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _ffToggling) {
        setState(() {
          _ffFullscreen = !_ffFullscreen;
          _ffToggling = false;
        });
        _addLog('flutter_fullscreen', 'setFullScreen (timeout fallback)', true);
      }
    });
  }

  bool get _isAnyFullscreen => _fwFullscreen || _ffFullscreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isAnyFullscreen
          ? null
          : AppBar(
              title: const Text('双包全屏对比'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
      body: ListView(
        children: [
          // 包控制区
          SizedBox(
            height: 400,
            child: Row(
              children: [
                // fullscreen_window 控制区
                Expanded(
                  child: _buildPackageCard(
                    title: 'fullscreen_window',
                    isFullscreen: _fwFullscreen,
                    onToggle: _toggleFwFullscreen,
                    apiInfo: 'Future<void> setFullScreen(bool)\n无状态查询\n无监听器',
                  ),
                ),
                const VerticalDivider(width: 1),
                // flutter_fullscreen 控制区
                Expanded(
                  child: _buildPackageCard(
                    title: 'flutter_fullscreen',
                    isFullscreen: _ffFullscreen,
                    onToggle: _toggleFfFullscreen,
                    apiInfo: 'void setFullScreen(bool)\nisFullScreen 属性\nFullScreenListener 监听器',
                  ),
                ),
              ],
            ),
          ),
          // API 对比面板
          _buildApiComparisonPanel(),
          // 依赖信息面板
          _buildDependencyPanel(),
          // 日志面板
          _buildLogPanel(),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required bool isFullscreen,
    required VoidCallback onToggle,
    required String apiInfo,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Icon(
                isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                isFullscreen ? '全屏中' : '窗口模式',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onToggle,
                icon: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                label: Text(isFullscreen ? '退出全屏' : '进入全屏'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'API 差异:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                apiInfo,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  // API 对比面板
  Widget _buildApiComparisonPanel() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: const Text('API 对比', style: TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: false,
        children: [
          _buildSectionTitle('方法签名对比'),
          _buildSignatureTable(),
          _buildSectionTitle('返回值差异'),
          _buildReturnValueTable(),
          _buildSectionTitle('平台支持矩阵'),
          _buildPlatformMatrix(),
          _buildSectionTitle('架构差异'),
          _buildArchitectureTable(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSignatureTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('维度')),
          DataColumn(label: Text('fullscreen_window')),
          DataColumn(label: Text('flutter_fullscreen')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('设置全屏')),
            DataCell(Text('Future<void> setFullScreen(bool)', style: TextStyle(fontSize: 12))),
            DataCell(Text('void setFullScreen(bool)', style: TextStyle(fontSize: 12))),
          ]),
          DataRow(cells: [
            DataCell(Text('查询状态')),
            DataCell(Text('无', style: TextStyle(color: Colors.red))),
            DataCell(Text('bool isFullScreen', style: TextStyle(fontSize: 12))),
          ]),
          DataRow(cells: [
            DataCell(Text('监听变化')),
            DataCell(Text('无', style: TextStyle(color: Colors.red))),
            DataCell(Text('FullScreenListener (4 回调)', style: TextStyle(fontSize: 12))),
          ]),
          DataRow(cells: [
            DataCell(Text('屏幕尺寸')),
            DataCell(Text('Future<Size> getScreenSize(BuildContext?)', style: TextStyle(fontSize: 12))),
            DataCell(Text('无', style: TextStyle(color: Colors.red))),
          ]),
          DataRow(cells: [
            DataCell(Text('初始化')),
            DataCell(Text('无需初始化', style: TextStyle(color: Colors.green))),
            DataCell(Text('await FullScreen.ensureInitialized()', style: TextStyle(fontSize: 12))),
          ]),
        ],
      ),
    );
  }

  Widget _buildReturnValueTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('维度')),
          DataColumn(label: Text('fullscreen_window')),
          DataColumn(label: Text('flutter_fullscreen')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('setFullScreen 返回值')),
            DataCell(Text('Future<void>（可 await）')),
            DataCell(Text('void（fire-and-forget）')),
          ]),
          DataRow(cells: [
            DataCell(Text('状态确认方式')),
            DataCell(Text('无（需手动跟踪）')),
            DataCell(Text('listener 回调确认')),
          ]),
          DataRow(cells: [
            DataCell(Text('错误处理')),
            DataCell(Text('try-catch 捕获异常')),
            DataCell(Text('无法捕获（void 返回）')),
          ]),
          DataRow(cells: [
            DataCell(Text('外部变化检测')),
            DataCell(Text('不支持')),
            DataCell(Text('支持（listener 通知）')),
          ]),
        ],
      ),
    );
  }

  Widget _buildPlatformMatrix() {
    Widget statusIcon(bool supported) {
      return Icon(
        supported ? Icons.check_circle : Icons.cancel,
        color: supported ? Colors.green : Colors.red,
        size: 20,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('平台')),
          DataColumn(label: Text('fullscreen_window')),
          DataColumn(label: Text('flutter_fullscreen')),
        ],
        rows: [
          DataRow(cells: [
            const DataCell(Text('Windows')),
            DataCell(statusIcon(true)),
            DataCell(statusIcon(true)),
          ]),
          DataRow(cells: [
            const DataCell(Text('Linux')),
            DataCell(statusIcon(true)),
            DataCell(statusIcon(true)),
          ]),
          DataRow(cells: [
            const DataCell(Text('macOS')),
            DataCell(statusIcon(false)),
            DataCell(statusIcon(true)),
          ]),
          DataRow(cells: [
            const DataCell(Text('Web')),
            DataCell(statusIcon(true)),
            DataCell(statusIcon(true)),
          ]),
          DataRow(cells: [
            const DataCell(Text('Android')),
            DataCell(statusIcon(true)),
            DataCell(statusIcon(true)),
          ]),
          DataRow(cells: [
            const DataCell(Text('iOS')),
            DataCell(statusIcon(true)),
            DataCell(statusIcon(true)),
          ]),
        ],
      ),
    );
  }

  Widget _buildArchitectureTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('维度')),
          DataColumn(label: Text('fullscreen_window')),
          DataColumn(label: Text('flutter_fullscreen')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('插件类型')),
            DataCell(Text('联邦插件（原生）')),
            DataCell(Text('纯 Dart + 委托')),
          ]),
          DataRow(cells: [
            DataCell(Text('原生代码')),
            DataCell(Text('C++ (Win), C (Linux)')),
            DataCell(Text('无（使用 window_manager）')),
          ]),
          DataRow(cells: [
            DataCell(Text('平台分发')),
            DataCell(Text('MethodChannel')),
            DataCell(Text('条件导入')),
          ]),
          DataRow(cells: [
            DataCell(Text('状态模型')),
            DataCell(Text('无状态（fire-and-forget）')),
            DataCell(Text('有状态（观察者模式）')),
          ]),
          DataRow(cells: [
            DataCell(Text('依赖深度')),
            DataCell(Text('1 层（直接）')),
            DataCell(Text('2 层（→ window_manager）')),
          ]),
        ],
      ),
    );
  }

  // 依赖信息面板
  Widget _buildDependencyPanel() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: const Text('依赖信息', style: TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: false,
        children: [
          _buildSectionTitle('依赖树'),
          _buildDependencyTree(),
          _buildSectionTitle('体积差异'),
          _buildSizeComparison(),
          _buildSectionTitle('已知陷阱'),
          _buildPitfallsList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDependencyTree() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('fullscreen_window', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('├── flutter (SDK)'),
                const Text('├── flutter_web_plugins (SDK)'),
                const Text('├── plugin_platform_interface ^2.0.2'),
                const Text('└── web ^1.0.0'),
                const SizedBox(height: 4),
                Text('传递依赖: 0', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('flutter_fullscreen', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('├── flutter (SDK)'),
                const Text('├── web ^1.1.0'),
                const Text('└── window_manager ^0.5.0'),
                const Text('    ├── screen_retriever'),
                const Text('    ├── gtk (Linux)'),
                const Text('    └── 原生代码 (Win/Mac/Linux)'),
                const SizedBox(height: 4),
                Text('传递依赖: 3+', style: TextStyle(color: Colors.orange[700], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeComparison() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSizeRow('fullscreen_window', '轻量', '仅 platform_interface + web 互操作', Colors.green),
          const SizedBox(height: 8),
          _buildSizeRow('flutter_fullscreen', '较重', '包含 window_manager 及其传递依赖（screen_retriever、GTK 绑定、原生代码）', Colors.orange),
          const SizedBox(height: 8),
          Text(
            '注意: flutter_fullscreen 的 window_manager 依赖会增加构建时间和二进制体积，但对演示项目可接受。',
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRow(String package, String label, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withAlpha(76)),
          ),
          child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              children: [
                TextSpan(text: '$package: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPitfallsList() {
    final pitfalls = [
      {'id': 1, 'title': '状态不同步', 'severity': 'CRITICAL', 'package': '两者'},
      {'id': 2, 'title': '缺少初始化', 'severity': 'HIGH', 'package': 'flutter_fullscreen'},
      {'id': 3, 'title': 'Windows 布局异常', 'severity': 'HIGH', 'package': 'fullscreen_window'},
      {'id': 4, 'title': '全局可变状态', 'severity': 'MEDIUM', 'package': 'fullscreen_window'},
      {'id': 5, 'title': 'WS_EX_TOPMOST 残留', 'severity': 'MEDIUM', 'package': 'fullscreen_window'},
      {'id': 6, 'title': '传递依赖复杂', 'severity': 'MEDIUM', 'package': 'flutter_fullscreen'},
      {'id': 7, 'title': 'Async vs Void 混淆', 'severity': 'MEDIUM', 'package': '两者'},
      {'id': 8, 'title': 'macOS 动画行为', 'severity': 'MEDIUM', 'package': 'fullscreen_window'},
      {'id': 9, 'title': '无平台能力检测', 'severity': 'MEDIUM', 'package': '两者'},
      {'id': 10, 'title': '监听器内存泄漏', 'severity': 'MEDIUM', 'package': 'flutter_fullscreen'},
      {'id': 11, 'title': '字符串异常', 'severity': 'LOW', 'package': 'flutter_fullscreen'},
      {'id': 12, 'title': 'Web 浏览器限制', 'severity': 'MEDIUM', 'package': '两者'},
      {'id': 13, 'title': 'getScreenSize 差异', 'severity': 'LOW', 'package': 'fullscreen_window'},
      {'id': 14, 'title': '快速切换竞态', 'severity': 'MEDIUM', 'package': '两者'},
      {'id': 15, 'title': '命名约定问题', 'severity': 'LOW', 'package': 'fullscreen_window'},
      {'id': 16, 'title': 'window_manager 副作用', 'severity': 'MEDIUM', 'package': 'flutter_fullscreen'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: pitfalls.map((p) => _buildPitfallItem(p)).toList(),
      ),
    );
  }

  Widget _buildPitfallItem(Map<String, dynamic> pitfall) {
    Color severityColor;
    switch (pitfall['severity']) {
      case 'CRITICAL':
        severityColor = Colors.red;
        break;
      case 'HIGH':
        severityColor = Colors.orange;
        break;
      case 'MEDIUM':
        severityColor = Colors.amber[700]!;
        break;
      case 'LOW':
        severityColor = Colors.grey;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text('#${pitfall['id']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: severityColor.withAlpha(25),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: severityColor.withAlpha(76)),
            ),
            child: Text(
              pitfall['severity'],
              style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                children: [
                  TextSpan(text: '${pitfall['title']} ', style: const TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(
                    text: '(${pitfall['package']})',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 日志面板
  Widget _buildLogPanel() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('调用日志', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: '清空日志',
                  onPressed: _logs.isEmpty ? null : _clearLogs,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 300,
            child: _logs.isEmpty
                ? const Center(child: Text('暂无调用记录', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    reverse: true,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final time = '${log.timestamp.hour.toString().padLeft(2, '0')}:'
                          '${log.timestamp.minute.toString().padLeft(2, '0')}:'
                          '${log.timestamp.second.toString().padLeft(2, '0')}';
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          log.success ? Icons.check_circle : Icons.error,
                          color: log.success ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        title: Text(
                          '[$time] ${log.packageName}.${log.methodName} -> '
                          '${log.success ? "成功" : "失败"}'
                          '${log.errorMessage != null ? " (${log.errorMessage})" : ""}',
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FfFullscreenListener with FullScreenListener {
  final VoidCallback onEnterFullScreen;
  final VoidCallback onLeaveFullScreen;

  _FfFullscreenListener({
    required this.onEnterFullScreen,
    required this.onLeaveFullScreen,
  });

  @override
  void onWindowEnterFullScreen(SystemUiMode? systemUiMode) {
    onEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen(SystemUiMode? systemUiMode) {
    onLeaveFullScreen();
  }
}
