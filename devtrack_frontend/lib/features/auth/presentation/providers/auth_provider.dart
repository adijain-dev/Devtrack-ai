import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/auth_notifier.dart';
import 'auth_state.dart';

/// Provider for the AuthNotifier, exposing AuthState.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
