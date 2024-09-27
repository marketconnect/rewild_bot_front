import 'dart:io';

void main() {
  const filePath = 'build/web/index.html';
  final file = File(filePath);

  if (file.existsSync()) {
    String content = file.readAsStringSync();

    // Replace <base href="/">
    content = content.replaceFirst('<base href="/">', '<base href="/webapp/">');

    // Add Telegram Web App API script before </head>
    const telegramScript =
        '<script src="https://telegram.org/js/telegram-web-app.js"></script>';
    content = content.replaceFirst('</head>', '$telegramScript\n</head>');

    // Add closeTelegramApp function before </head>
    const closeAppScript = '''
    <script>
      function closeTelegramApp() {
        if (window.Telegram && window.Telegram.WebApp) {
          window.Telegram.WebApp.close();
        }
      }
    </script>''';
    content = content.replaceFirst('</head>', '$closeAppScript\n</head>');

    // Add CSS styles for 100% height and splash screen before </head>
    const styleTag = '''
    <style>
      html, body {
        margin: 0;
        padding: 0;
        height: 100%;
        min-height: 100vh;
        overflow: hidden;
      }
      body > * {
        height: 100%;
      }
      /* Splash Screen Styles */
      #splash {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: #fef7ff; /* Set your background color */
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        flex-direction: column;
      }
      /* Spinner Styles */
      .spinner {
        width: 80px;
        height: 80px;
        border: 10px solid #f3f3f3;
        border-top: 10px solid #3498db; /* Blue color */
        border-radius: 50%;
        animation: spin 1.5s linear infinite;
      }
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      /* Optional: Loading Text */
      .loading-text {
        margin-top: 20px;
        font-size: 18px;
        color: #555555;
      }
    </style>
    ''';
    content = content.replaceFirst('</head>', '$styleTag\n</head>');

    // Add Splash Screen HTML immediately after <body>
    const splashHtml = '''
    <body>
      <div id="splash">
        <div class="spinner"></div>
        <div class="loading-text">Загрузка...</div>
      </div>
    ''';
    content = content.replaceFirst('<body>', splashHtml);

    // Add JavaScript to hide splash screen after Flutter loads
    const hideSplashScript = '''
    <script>
      window.addEventListener('flutter-first-frame', function () {
        document.getElementById('splash').style.display = 'none';
      });
    </script>
    ''';
    content = content.replaceFirst('</body>', '$hideSplashScript\n</body>');

    // Write the updated content back to index.html
    file.writeAsStringSync(content);

    print('index.html успешно обновлен.');
  } else {
    print('index.html не найден.');
  }
}
