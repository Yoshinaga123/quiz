import 'package:equatable/equatable.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

class PushFeedDto extends Equatable {
  const PushFeedDto({
    required this.deliveryId,
    required this.quizId,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.channel,
  });

  final int deliveryId;
  final int quizId;
  final String title;
  final String body;
  final DateTime sentAt;
  final String channel;

  factory PushFeedDto.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const QuizParseFailure(message: 'Push feed must be a JSON object.');
    }

    final deliveryId = value['deliveryId'];
    final quizId = value['quizId'];
    final title = value['title'];
    final body = value['body'];
    final sentAt = value['sentAt'];
    final channel = value['channel'];

    if (deliveryId is! int || deliveryId < 1) {
      throw const QuizParseFailure(message: 'Invalid deliveryId.');
    }
    if (quizId is! int || quizId < 1) {
      throw const QuizParseFailure(message: 'Invalid quizId.');
    }
    if (title is! String || title.isEmpty) {
      throw const QuizParseFailure(message: 'Invalid title.');
    }
    if (body is! String || body.isEmpty) {
      throw const QuizParseFailure(message: 'Invalid body.');
    }
    if (sentAt is! String || sentAt.isEmpty) {
      throw const QuizParseFailure(message: 'Invalid sentAt.');
    }
    if (channel is! String || channel.isEmpty) {
      throw const QuizParseFailure(message: 'Invalid channel.');
    }

    final parsedSentAt = DateTime.tryParse(sentAt);
    if (parsedSentAt == null) {
      throw const QuizParseFailure(message: 'sentAt must be an ISO date-time.');
    }

    return PushFeedDto(
      deliveryId: deliveryId,
      quizId: quizId,
      title: title,
      body: body,
      sentAt: parsedSentAt,
      channel: channel,
    );
  }

  @override
  List<Object?> get props => [
        deliveryId,
        quizId,
        title,
        body,
        sentAt,
        channel,
      ];
}
