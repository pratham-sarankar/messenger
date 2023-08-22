class Vacancy {
  const Vacancy({
    required this.id,
    required this.title,
    this.blocks = const [],
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<VacancyBlock> blocks;
}

class VacancyBlock {
  const VacancyBlock({
    this.title,
    required this.description,
  });

  final String? title;
  final String description;
}

class Vacancies {
  static const List<Vacancy> all = [
    // Vacancy(
    //   id: 'freelance',
    //   title: 'Фрилансерам',
    //   description: '...',
    // ),
    Vacancy(
      id: 'freelance',
      title: 'Freelance',
      subtitle: '4 tasks available',
    ),
    Vacancy(
      id: 'dart',
      title: 'Frontend Developer',
      subtitle: 'Flutter',
    ),
    Vacancy(
      id: 'backend',
      title: 'Backend Developer',
      subtitle: 'Rust',
    ),
//     Vacancy(
//       id: 'rust',
//       title: 'Rust Developer',
//       description: '''Обязанности:

// - проектирование, разработка, тестирование и поддержка бэкендов веб-проектов;
// - разработка высокопроизводительных низкоуровневых элементов ПО;
// - проектирование структур баз данных;
// - разработка модулей к существующим проектам.

// Требования:

// - опыт использования и понимание языка Rust;
// - приветствуется опыт работы с языками C, C++;
// - понимание FFI и UB;
// - опыт оптимизации программ и умение использовать профилировщик;
// - понимание принципов работы клиент-серверных web-приложений;
// - опыт и понимание принципов проектирования структур баз данных;
// - понимание принципов DDD и слоенной архитектуры;
// - опыт написания модульных и функциональных тестов;
// - опыт работы с Git;
// - умение использовать операционные системы типа *nix;
// - приветствуется опыт работы по CQRS+ES парадигме;
// - приветствуется опыт работы с технологиями Memcached, Redis, RabbitMQ, MongoDB, Cassandra, Kafka;
// - приветствуется опыт работы с другими языками Java, Go, Python, Ruby, TypeScript, JavaScript;

// Условия:

// - полная занятость;
// - начальная ставка заработной платы от 2000 EUR в месяц;
// - ежедневное зачисление заработной платы;
// - удалённое сотрудничество;
// - предусмотрен учёт рабочего времени;
// - рабочее время: с 11:30 по 13:00 UTC находиться онлайн обязательно, остальное время выбирается самостоятельно по согласованию с тимлидом.

// Дополнительно:

// - оказывается помощь при переезде в одну из штаб-квартир компании.''',
//     ),
//     Vacancy(
//       id: 'media',
//       title: 'Media Streaming Developer',
//       description: '...',
//     ),
//     Vacancy(
//       id: 'devops',
//       title: 'DevOps Инженер',
//       description: '...',
//     ),
//     Vacancy(
//       id: 'ui',
//       title: 'UI/UX Designer',
//       description: '''Обязанности:
// - разработка дизайна приложения на Flutter;

// Требования:
// - понимание принципов работы приложений с точки зрения эстетики и юзабилити.
// - навык написания анимированных элементов

// Условия:

// - полная занятость;
// - начальная ставка заработной платы от 1000 EUR в месяц;
// - ежедневное зачисление заработной платы;
// - удалённое сотрудничество;
// - предусмотрен учёт рабочего времени;
// - рабочее время: с 14:00 по 16:00 UTC находиться онлайн обязательно, остальное время выбирается самостоятельно по согласованию с тимлидом.

// Дополнительно:

// - оказывается помощь при переезде в одну из штаб-квартир компании.''',
//     ),
//     Vacancy(
//       id: 'neuro',
//       title: 'Специалист по нейросетям / оператор нейросетей',
//       description: '...',
//     ),
//     Vacancy(
//       id: 'smm',
//       title: 'SMM менеджер',
//       description: '...',
//     ),
//     Vacancy(
//       id: 'secretary',
//       title: 'Секретарь со знанием английского языка',
//       description: '...',
//     ),
//     Vacancy(
//       id: 'growth',
//       title: 'Менеджер по развитию',
//       description: '...',
//     ),
//     Vacancy(
//       id: 'parner',
//       title: 'Контент провайдерам',
//       description: '...',
//     ),
//     Vacancy(
//       id: 'promoter',
//       title: 'Промоутерам',
//       description: '...',
//     ),
  ];
}
