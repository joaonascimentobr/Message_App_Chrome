import 'models.dart';

final User user_0 = User(
  name: const Name(first: 'Me', last: ''),
  avatarUrl: 'assets/avatar_1.png',
  lastActive: DateTime.now(),
);

final User user_1 = User(
  name: const Name(first: 'Cris', last: 'Moner'),
  avatarUrl: 'assets/avatar_2.png',
  lastActive: DateTime.now().subtract(const Duration(minutes: 10)),
);

final User user_2 = User(
  name: const Name(first: 'So', last: 'Duri'),
  avatarUrl: 'assets/avatar_3.png',
  lastActive: DateTime.now().subtract(const Duration(minutes: 20)),
);

final User user_3 = User(
  name: const Name(first: 'Jane', last: 'Smith'),
  avatarUrl: 'assets/avatar_4.png',
  lastActive: DateTime.now().subtract(const Duration(hours: 2)),
);

final User user_4 = User(
  name: const Name(first: 'Ziad', last: 'Aouad'),
  avatarUrl: 'assets/avatar_5.png',
  lastActive: DateTime.now().subtract(const Duration(hours: 6)),
);

final List<Email> emails = [
  Email(
    sender: user_1,
    recipient: [],
    subject: 'Koée Mané',
    content: 'Qual a boa!?',
  ),
  Email(
    sender: user_2,
    recipient: [],
    subject: 'Bora Jantar',
    content: 'Vamos jantar hoje à noite?',
  ),
  Email(
    sender: user_3,
    recipient: [],
    subject: 'Dá uma olhada nisso',
    content: 'Acho que ´você vai gostar dessa comida',
    attachments: [const Attachment(url: 'assets/thumbnail_1.png')],
  ),
  Email(
    sender: user_4,
    recipient: [],
    subject: 'Vamos nos voluntariar??',
    content:
        'O que você acha de nos voluntariarmos para ajudar no evento da comunidade?',
  ),
];

final List<Email> replies = [
  Email(
    sender: user_2,
    recipient: [user_3, user_2],
    subject: 'Bora Jantar',
    content: 'Claro! Que horas?',
  ),
];
