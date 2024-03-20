const _kDefaultTickDuration = Duration(seconds: 30);
const _kDefaultBatchLength = 25;

/// Additional options for initializing the Aptabase SDK.
class InitOptions {
  const InitOptions({
    this.host,
    this.tickDuration = _kDefaultTickDuration,
    this.batchLength = _kDefaultBatchLength,
    this.printDebugMessages = false,
  });

  final String? host;
  final Duration tickDuration;
  final int batchLength;
  final bool printDebugMessages;
}
