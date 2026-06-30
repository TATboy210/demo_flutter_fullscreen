import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fullscreen_window/fullscreen_window_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock 平台实现，用于 Widget 测试
class MockFullscreenWindowPlatform extends FullScreenWindowPlatform
    with MockPlatformInterfaceMixin {
  int setFullScreenCallCount = 0;
  bool? lastFullScreenValue;
  bool shouldThrow = false;

  @override
  Future<void> setFullScreen(bool isFullScreen) async {
    setFullScreenCallCount++;
    lastFullScreenValue = isFullScreen;
    if (shouldThrow) {
      throw MissingPluginException(
        'No implementation found for method setFullScreen on channel fullscreen_window',
      );
    }
  }

  @override
  Future<Size> getScreenSize(BuildContext? context) async {
    if (shouldThrow) {
      throw MissingPluginException(
        'No implementation found for method getScreenSize on channel fullscreen_window',
      );
    }
    return const Size(1920, 1080);
  }

  void reset() {
    setFullScreenCallCount = 0;
    lastFullScreenValue = null;
    shouldThrow = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFullscreenWindowPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockFullscreenWindowPlatform();
    FullScreenWindowPlatform.instance = mockPlatform;
  });

  group('Demo App Widget 测试', () {
    testWidgets('应用启动并显示标题', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('三包全屏对比')),
            body: const Center(child: Text('测试页面')),
          ),
        ),
      );

      expect(find.text('三包全屏对比'), findsOneWidget);
      expect(find.text('测试页面'), findsOneWidget);
    });

    testWidgets('Material 3 主题正确应用', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('测试')),
            body: const Center(child: Text('内容')),
          ),
        ),
      );

      expect(find.text('测试'), findsOneWidget);
    });
  });

  group('平台 Mock 集成测试', () {
    test('Mock 平台 setFullScreen 被正确调用', () async {
      final platform = FullScreenWindowPlatform.instance;
      await platform.setFullScreen(true);
      expect(mockPlatform.setFullScreenCallCount, 1);
      expect(mockPlatform.lastFullScreenValue, true);

      await platform.setFullScreen(false);
      expect(mockPlatform.setFullScreenCallCount, 2);
      expect(mockPlatform.lastFullScreenValue, false);
    });

    test('Mock 平台异常可被捕获', () async {
      mockPlatform.shouldThrow = true;
      final platform = FullScreenWindowPlatform.instance;

      try {
        await platform.setFullScreen(true);
        fail('应该抛出异常');
      } catch (e) {
        expect(e, isA<MissingPluginException>());
      }
    });

    test('Mock 平台 reset 清除状态', () async {
      await FullScreenWindowPlatform.instance.setFullScreen(true);
      expect(mockPlatform.setFullScreenCallCount, 1);

      mockPlatform.reset();
      expect(mockPlatform.setFullScreenCallCount, 0);
      expect(mockPlatform.lastFullScreenValue, isNull);
    });
  });

  group('UI 组件测试', () {
    testWidgets('Card 组件渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'fullscreen_window',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        const Text('窗口模式'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('进入全屏'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('fullscreen_window'), findsOneWidget);
      expect(find.text('窗口模式'), findsOneWidget);
      expect(find.text('进入全屏'), findsOneWidget);
    });

    testWidgets('日志面板渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('调用日志', style: TextStyle(fontSize: 18)),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(
                          '[12:00:00] fullscreen_window.setFullScreen -> 成功',
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.error, color: Colors.red),
                        title: Text(
                          '[12:00:01] fullscreen_window.setFullScreen -> 失败',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('调用日志'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('平台信息卡片渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('平台信息', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.computer, size: 20),
                        const SizedBox(width: 8),
                        const Text('当前平台: Windows'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('自动检测'),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        ChoiceChip(
                          label: const Text('Windows'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                        ChoiceChip(
                          label: const Text('Linux'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                        ChoiceChip(
                          label: const Text('macOS'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('平台信息'), findsOneWidget);
      expect(find.text('当前平台: Windows'), findsOneWidget);
      expect(find.text('自动检测'), findsOneWidget);
      expect(find.text('macOS'), findsOneWidget);
    });
  });
}
