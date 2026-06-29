import 'package:flutter/material.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fullscreen Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FullscreenDemoPage(),
    );
  }
}

class FullscreenDemoPage extends StatefulWidget {
  const FullscreenDemoPage({super.key});

  @override
  State<FullscreenDemoPage> createState() => _FullscreenDemoPageState();
}

class _FullscreenDemoPageState extends State<FullscreenDemoPage> {
  bool _isFullscreen = false;

  Future<void> _toggleFullscreen() async {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    await FullScreenWindow.setFullScreen(_isFullscreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: const Text('Fullscreen Demo'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              _isFullscreen ? '全屏模式' : '窗口模式',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _isFullscreen ? '按 Esc 或点击按钮退出全屏' : '点击按钮进入全屏',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _toggleFullscreen,
              icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
              label: Text(_isFullscreen ? '退出全屏' : '进入全屏'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
