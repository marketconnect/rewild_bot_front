// ignore_for_file: avoid_print

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

    // Обновлённые стили для спиннера с неподвижным изображением
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
  /* Стили для сплэш-экрана */
  #splash {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: #fef7ff;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    flex-direction: column;
  }
  
  .spinner {
    width: 60px;
    height: 60px;
    border: 5px solid #EADDFF;
    border-top: 5px solid #6650a3; 
    border-radius: 50%;
    box-sizing: border-box; 
    animation: spin .5s linear infinite;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
  }
  /* image inside the spinner */
  .spinner img {
    width: 50px;
    height: 50px;
    animation: counter-spin .5s linear infinite;
  }
  @keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
  @keyframes counter-spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(-360deg); }
  }
  /* Text */
  .loading-text {
    margin-top: 20px;
    font-size: 18px;
    color: #555555;
  }
</style>

    ''';
    content = content.replaceFirst('</head>', '$styleTag\n</head>');

    const splashHtml = '''
    <body>
      <div id="splash">
        <div class="spinner">
          <img src="assets/assets/images/logo_for_loading.png" alt="Loading" />
        </div>
        <div class="loading-text">Загрузка...</div>
      </div>
    ''';
    content = content.replaceFirst('<body>', splashHtml);

    const hideSplashScript = '''
    <script>
      window.addEventListener('flutter-first-frame', function () {
        document.getElementById('splash').style.display = 'none';
      });
    </script>
    ''';
    content = content.replaceFirst('</body>', '$hideSplashScript\n</body>');

    file.writeAsStringSync(content);

    print('index.html успешно обновлен.');
  } else {
    print('index.html не найден.');
  }
}
