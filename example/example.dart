import 'package:cron_parser/cron_parser.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

void main() {
  // by default next cron dates are starting from the current date
  var cronIterator = Cron().parse("0 * * * *", "Europe/London");
  TZDateTime nextDate = cronIterator.next();
  TZDateTime afterNextDate = cronIterator.next();

  //specify a start date to get cron dates after this date
  TZDateTime startDate = TZDateTime(getLocation("Europe/London"), 2020, 4, 01);
  cronIterator = Cron().parse("0 * * * *", "Europe/London", startDate);
  nextDate = cronIterator.next(); // 2020-04-01 01:00:00.000+0100
  var currentDate = cronIterator.current(); // 2020-04-01 01:00:00.000+0100
  afterNextDate = cronIterator.next(); // 2020-04-01 02:00:00.000+0100
}
