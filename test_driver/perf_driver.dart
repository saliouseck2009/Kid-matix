// Driver of the performance test: writes the timeline of the quiz to
// build/quiz_perf.timeline_summary.json. Run on a real phone:
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test/quiz_perf_test.dart -d <device>

import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (Map<String, dynamic>? data) async {
      if (data == null) return;
      final driver.Timeline timeline = driver.Timeline.fromJson(
        data['quiz'] as Map<String, dynamic>,
      );
      await driver.TimelineSummary.summarize(
        timeline,
      ).writeTimelineToFile('quiz_perf', pretty: true, includeSummary: true);
    },
  );
}
