import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/offline_cache_service.dart';
import '../../domain/entities/internship.dart';
import '../../domain/repositories/internship_repository.dart';
import '../../data/providers/internship_repository_provider.dart';

/// State for the internship list.
class InternshipState {
  final List<Internship> internships;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const InternshipState({
    this.internships = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  /// Filtered list based on searchQuery.
  List<Internship> get filtered {
    if (searchQuery.isEmpty) return internships;
    final q = searchQuery.toLowerCase();
    return internships.where((i) {
      return i.companyName.toLowerCase().contains(q) ||
          i.role.toLowerCase().contains(q) ||
          (i.location?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  InternshipState copyWith({
    List<Internship>? internships,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return InternshipState(
      internships: internships ?? this.internships,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier managing the full CRUD lifecycle of internships.
class InternshipNotifier extends Notifier<InternshipState> {
  late final InternshipRepository _repo;

  @override
  InternshipState build() {
    _repo = ref.read(internshipRepositoryProvider);
    Future.microtask(() async {
      final cached = await OfflineCacheService().getCachedInternships();
      if (cached.isNotEmpty) {
        state = state.copyWith(internships: cached, isLoading: false);
      }
      await fetchAll(silent: cached.isNotEmpty);
    });
    return const InternshipState(isLoading: true);
  }

  Future<void> fetchAll({bool silent = false}) async {
    if (!silent && state.internships.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final list = await _repo.getAll();
      state = state.copyWith(internships: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: state.internships.isEmpty ? e.toString().replaceFirst('Exception: ', '') : null,
      );
    }
  }

  Future<bool> create(Internship internship) async {
    try {
      final created = await _repo.create(internship);
      state = state.copyWith(
        internships: [...state.internships, created],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> update(Internship internship) async {
    try {
      final updated = await _repo.update(internship);
      state = state.copyWith(
        internships: state.internships
            .map((i) => i.id == updated.id ? updated : i)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
      state = state.copyWith(
        internships: state.internships.where((i) => i.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final internshipNotifierProvider =
    NotifierProvider<InternshipNotifier, InternshipState>(InternshipNotifier.new);
