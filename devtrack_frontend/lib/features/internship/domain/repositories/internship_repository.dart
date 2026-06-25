import '../entities/internship.dart';

abstract class InternshipRepository {
  Future<List<Internship>> getAll();
  Future<Internship> create(Internship internship);
  Future<Internship> update(Internship internship);
  Future<void> delete(String id);
}
