const String kQuillHtmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">
  <script src="https://cdn.quilljs.com/1.3.6/quill.min.js"></script>
  <style>
    body { margin: 0; padding: 0; height: 100vh; display: flex; flex-direction: column; }
    #editor-container { flex: 1; overflow-y: auto; }
  </style>
</head>
<body>
  <div id="editor-container"></div>

  <script>
    var quill = new Quill('#editor-container', {
      theme: 'snow',
      modules: {
        toolbar: [
           [{ 'header': [1, 2, false] }],
           ['bold', 'italic', 'underline'],
           ['image', 'video'], // Youtube chạy mượt trên cả Mac/Win
        ]
      }
    });

    // --- HÀM GỬI DATA VỀ FLUTTER (CROSS-PLATFORM) ---
    function sendDataToFlutter() {
      var html = document.querySelector(".ql-editor").innerHTML;
      
      // 1. Kiểm tra nếu là Windows (Edge WebView2)
      if (window.chrome && window.chrome.webview) {
        window.chrome.webview.postMessage(html);
      } 
      // 2. Kiểm tra nếu là macOS/Mobile (InAppWebView)
      else if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onSave', html);
      }
    }
    
    // Hàm nhận Data từ Flutter (Load nội dung cũ)
    function setContent(html) {
      quill.clipboard.dangerouslyPasteHTML(html);
    }
  </script>
</body>
</html>
''';
