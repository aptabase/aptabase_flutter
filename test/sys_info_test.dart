import "package:aptabase_flutter/sys_info.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("falls back to platform OS info when device metadata fails", () async {
    final osInfo = await SystemInfo.getOsInfoForTesting(
      resolveOsInfo: (_) => throw StateError("device info unavailable"),
      fallbackOsInfo: () => (name: "Windows", version: "10.0.26200"),
    );

    expect(osInfo.name, "Windows");
    expect(osInfo.version, "10.0.26200");
  });
}
