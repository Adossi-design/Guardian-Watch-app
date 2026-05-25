import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/invite_datasource.dart';
import '../../data/models/invite_model.dart';

sealed class InviteState {
  const InviteState();
}

final class InviteIdle extends InviteState {
  const InviteIdle();
}

final class InviteLoading extends InviteState {
  const InviteLoading();
}

final class InviteCreated extends InviteState {
  const InviteCreated(this.invite);
  final InviteModel invite;
}

final class InviteAccepted extends InviteState {
  const InviteAccepted();
}

final class InviteError extends InviteState {
  const InviteError(this.message);
  final String message;
}

class InviteNotifier extends AsyncNotifier<InviteState> {
  @override
  Future<InviteState> build() async => const InviteIdle();

  Future<void> createInvite(String householdId) async {
    state = const AsyncData(InviteLoading());
    try {
      final ds = ref.read(inviteDataSourceProvider);
      final invite = await ds.createInvite(householdId);
      state = AsyncData(InviteCreated(invite));
    } catch (e) {
      state = AsyncData(InviteError(e.toString()));
    }
  }

  Future<void> acceptInvite(String inviteId, String monitorName) async {
    state = const AsyncData(InviteLoading());
    try {
      final ds = ref.read(inviteDataSourceProvider);
      await ds.acceptInvite(inviteId, monitorName);
      state = const AsyncData(InviteAccepted());
    } catch (e) {
      state = AsyncData(InviteError(e.toString()));
    }
  }

  void reset() => state = const AsyncData(InviteIdle());
}

final inviteNotifierProvider =
    AsyncNotifierProvider<InviteNotifier, InviteState>(InviteNotifier.new);

final inviteDataSourceProvider = Provider<InviteDataSource>((ref) {
  throw UnimplementedError('Override with get_it instance');
});
