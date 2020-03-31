# A cron parser

Spits out next cron dates starting from now or a specific date.

## Usage

A simple usage example:

    import 'package:cron/cron.dart';

    main() {
      var cronIterator = Cron().parse("0 0 1 */2 *");
      DateTime nextDate = cronIterator.next();
      DateTime afterNextDate = cronIterator.next();
    }

## Links

- [source code][source]
- contributors: [Ronny Bubke][rbubke]

[source]: https://github.com/rbubke/cron-parser