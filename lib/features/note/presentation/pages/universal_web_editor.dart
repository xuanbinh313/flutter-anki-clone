import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'editor_html.dart'; // Import chuỗi HTML

class UniversalWebEditor extends StatelessWidget {
  const UniversalWebEditor({super.key});

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isWindows) {
      return const _WindowsEditor();
    } else {
      // macOS, Android, iOS dùng cái này
      return const _MacMobileEditor();
    }
  }
}

// ==========================================
// 1. PHIÊN BẢN MACOS / MOBILE (InAppWebView)
// ==========================================
class _MacMobileEditor extends StatefulWidget {
  const _MacMobileEditor();

  @override
  State<_MacMobileEditor> createState() => _MacMobileEditorState();
}

class _MacMobileEditorState extends State<_MacMobileEditor> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editor (macOS/Mobile)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              // Gọi hàm JS: sendDataToFlutter()
              await _webViewController?.evaluateJavascript(
                source: "sendDataToFlutter();",
              );
            },
          ),
        ],
      ),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(data: kQuillHtmlContent),
        initialSettings: InAppWebViewSettings(
          isInspectable: true, // Cho phép debug chuột phải trên Mac
          javaScriptEnabled: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;

          // Đăng ký Handler để nhận dữ liệu từ JS gửi về
          controller.addJavaScriptHandler(
            handlerName: 'onSave', // Trùng với tên trong file HTML
            callback: (args) {
              final String htmlContent = args[0];
              print("MACOS RECEIVED: $htmlContent");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã lưu trên macOS!")),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 2. PHIÊN BẢN WINDOWS (Code cũ của bạn)
// ==========================================
class _WindowsEditor extends StatefulWidget {
  const _WindowsEditor();

  @override
  State<_WindowsEditor> createState() => _WindowsEditorState();
}

class _WindowsEditorState extends State<_WindowsEditor> {
  final WebviewController _controller = WebviewController();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    initWindowsWebView();
  }

  Future<void> initWindowsWebView() async {
    try {
      await _controller.initialize();
      _controller.webMessage.listen((msg) {
        print("WINDOWS RECEIVED: $msg");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đã lưu trên Windows!")));
      });
      _controller.loadingState.listen((event) {
        if (event == LoadingState.navigationCompleted) {
          if (mounted) setState(() => _isReady = true);
        }
      });
      await _controller.loadStringContent(kQuillHtmlContent);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editor (Windows)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_isReady) _controller.executeScript("sendDataToFlutter()");
            },
          ),
        ],
      ),
      body: _isReady
          ? Webview(_controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
