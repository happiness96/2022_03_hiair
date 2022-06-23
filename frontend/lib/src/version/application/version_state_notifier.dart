import 'package:frontend/src/core/domain/entities/failure.dart';
import 'package:frontend/src/version/application/version_event.dart';
import 'package:frontend/src/version/domain/usecases/fetch_local_version.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:frontend/src/version/application/version_state.dart';
import 'package:frontend/src/version/domain/usecases/fetch_latest_version.dart';

class VersionStateNotifier extends StateNotifier<VersionState> {
  VersionStateNotifier({
    required FetchLatestVersion fetchLatest,
    required FetchLocalVersion fetchLocal,
  })  : _fetchLatest = fetchLatest,
        _fetchLocal = fetchLocal,
        super(const VersionState.init());

  final FetchLatestVersion _fetchLatest;
  final FetchLocalVersion _fetchLocal;

  Future<void> mapEventToState(VersionEvent event) async {
    event.when(
      fetchLatestVersion: () async {
        state = const VersionState.checking();

        final localVersion = await _fetchLocal();
        final failureOrRemoteVersion = await _fetchLatest();

        failureOrRemoteVersion.fold(
          (l) => state = VersionState.failure(mapFailureToString(l)),
          (r) {
            if (localVersion == r) {
              state = const VersionState.upToDate();
            } else {
              state = const VersionState.outdated();
            }
          },
        );
      },
    );
  }
}
