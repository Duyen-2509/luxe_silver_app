import '../repository/comment_repository.dart';

class CommentController {
  final CommentRepository repository;
  CommentController(this.repository);

  Future<String?> addComment(Map<String, dynamic> data) {
    return repository.addComment(data);
  }

  Future<String?> editComment(int idBl, Map<String, dynamic> data) {
    return repository.editComment(idBl, data);
  }

  Future<String?> deleteComment(int idBl, int idKh) {
    return repository.deleteComment(idBl, idKh);
  }

  Future<String?> replyComment(int idBl, Map<String, dynamic> data) {
    return repository.replyComment(idBl, data);
  }

  Future<List<Map<String, dynamic>>> fetchComments(int idSp) {
    return repository.fetchComments(idSp);
  }

  Future<Map<String, dynamic>> fetchStatistic(int idSp) {
    return repository.fetchStatistic(idSp);
  }

  Future<String?> deleteReply(int idCtbl, int idNv) {
    return repository.deleteReply(idCtbl, idNv);
  }
}
