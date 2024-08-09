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

    file.writeAsStringSync(content);
    print('index.html успешно обновлен.');
  } else {
    print('index.html не найден.');
  }
}
