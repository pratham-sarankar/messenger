import 'package:get/get.dart';
import 'package:messenger/domain/service/auth.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/util/platform_utils.dart';
import 'package:mutex/mutex.dart';

class VacancyBodyController extends GetxController {
  VacancyBodyController(this._authService);

  final RxList<GitHubIssue> issues = RxList();
  final Rx<RxStatus> status = Rx(RxStatus.empty());

  final AuthService _authService;

  bool get authorized => _authService.status.value.isSuccess;

  final Mutex _issuesGuard = Mutex();

  Future<void> useLink() async {
    router.useLink(
      'HR-Gapopa',
//       welcome: '''

// Собеседования проводятся с 00:00 по 00:00.

// ''',
      welcome: '''Добрый день.
Пожалуйста, отправьте Ваше резюме в формате PDF. В течение 24 часов Вам будет отправлена дата и время интервью.''',
    );
  }

  void fetchIssues() async {
    await _issuesGuard.protect(() async {
      status.value = RxStatus.loading();

      if (issues.isNotEmpty) {
        return;
      }

      final response = await (await PlatformUtils.dio).get(
        'https://api.github.com/repos/team113/messenger/issues',
      );

      if (response.statusCode == 200) {
        issues.value = (response.data as List<dynamic>).map((e) {
          return GitHubIssue(
            title: e['title'],
            description: e['body'],
            url: e['html_url'],
          );
        }).toList();

        status.value = RxStatus.success();
      } else {
        status.value = RxStatus.error(response.statusMessage);
      }
    });
  }
}

class GitHubIssue {
  const GitHubIssue({
    required this.title,
    this.description,
    this.status = GitHubStatus.todo,
    this.url = '',
  });

  final String title;
  final String? description;
  final GitHubStatus status;
  final String url;
}

enum GitHubStatus { todo, wip, done }
