// Driver of the marketing scenarios, used by tool/marketing/record.sh:
//   flutter drive --profile --driver=tool/marketing/driver.dart \
//     --target=integration_test/marketing/<scenario>_test.dart -d <device>

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
