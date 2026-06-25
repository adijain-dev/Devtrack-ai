import '../entities/dsa_topic.dart';

abstract class DsaRepository {
  /// Fetch all DSA topics for the current user.
  Future<List<DsaTopic>> getAll();

  /// Create a new DSA topic entry.
  Future<DsaTopic> create(DsaTopic topic);

  /// Update an existing DSA topic (e.g. mark as solved).
  Future<DsaTopic> update(DsaTopic topic);

  /// Delete a DSA topic by its id.
  Future<void> delete(String id);
}
