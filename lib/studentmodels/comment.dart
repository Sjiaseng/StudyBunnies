import 'reply.dart';

class Comment {
  final String commentID;
  final String commentContent;
  final DateTime generationDate;
  final String username;
  final List<Reply> replies;
  final String profileImgUrl; 

  Comment({
    required this.commentID,
    required this.commentContent,
    required this.generationDate,
    required this.username,
    required this.replies,
    required this.profileImgUrl, 
  });
}
