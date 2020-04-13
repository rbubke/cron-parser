# A cron parser

Spits out next cron dates starting from now or a specific date.
Please notice that the timezone of the resulting dates are in the
same timezone provided with Cron().parse(...)

## Usage

A simple usage example:

    import 'package:cron_parser/cron_parser.dart';

    main() {
      // by default next cron dates are starting from the current date
      var cronIterator =  Cron().parse("0 * * * *", "Europe/London");
      TZDateTime nextDate = cronIterator.next();
      TZDateTime afterNextDate = cronIterator.next();
    }

Another example this time with a specific start date:

    import 'package:cron_parser/cron_parser.dart';

    main() {
      TZDateTime startDate = TZDateTime(getLocation("Europe/London"), 2020, 4, 01);
      var cronIterator =  Cron().parse("0 * * * *", "Europe/London", startDate);
      TZDateTime nextDate = cronIterator.next(); // 2020-04-01 01:00:00.000+0100
      TZDateTime afterNextDate = cronIterator.next(); // 2020-04-01 02:00:00.000+0100
    }

## Links

- [source code][source]
- contributors: [Ronny Bubke][rbubke]

[source]: https://github.com/rbubke/cron-parser