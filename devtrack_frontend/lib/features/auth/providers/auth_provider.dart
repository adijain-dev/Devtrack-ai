// This file re-exports the canonical auth provider so that any feature
// importing from 'features/auth/providers/auth_provider.dart' still compiles.
// The actual Notifier + State live in the presentation/providers/ layer.
export '../presentation/providers/auth_provider.dart';
export '../presentation/providers/auth_state.dart';
