import 'dart:io';

void main() {
  const filePath = 'build/web/index.html';
  final file = File(filePath);

  if (file.existsSync()) {
    String content = file.readAsStringSync();

    // Заменяем <base href="/">
    content = content.replaceFirst('<base href="/">', '<base href="/webapp/">');

    // Добавляем скрипт Telegram Web App API перед закрывающим тегом </head>
    const scriptTag =
        '<script src="https://telegram.org/js/telegram-web-app.js"></script>';
    content = content.replaceFirst('</head>', '$scriptTag\n</head>');

    // Добавляем CSS-стили для обеспечения 100% высоты
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
    </style>
    ''';
    content = content.replaceFirst('</head>', '$styleTag\n</head>');

    file.writeAsStringSync(content);
    // ignore: avoid_print
    print('index.html успешно обновлен.');
  } else {
    // ignore: avoid_print
    print('index.html не найден.');
  }
}
