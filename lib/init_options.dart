const _kDefaultTickDuration = Duration(seconds: 30);
const _kMaxBatchLength = 25;

/// Additional options for initializing the Aptabase SDK.
class InitOptions {
  const InitOptions({
    this.host,
    this.tickDuration = _kDefaultTickDuration,
    this.batchLength = _kMaxBatchLength,
    this.printDebugMessages = false,
  }) : assert(batchLength <= _kMaxBatchLength, "Maximum is $_kMaxBatchLength");

  final String? host;
  final Duration tickDuration;
  final int batchLength;
  final bool printDebugMessages;
}
