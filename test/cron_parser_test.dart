import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

import '../lib/cron_parser.dart';

void main() {
  group('Cron().parse()', () {
    TZDateTime normalizedDate(
        [DateTime? dateTime, String locationName = "Europe/Berlin"]) {
      var location = getLocation(locationName);
      TZDateTime date =
          dateTime == null ? TZDateTime.now(location) : dateTime as TZDateTime;
      return TZDateTime.from(
          date.subtract(Duration(
              microseconds: date.microsecond,
              milliseconds: date.millisecond,
              seconds: date.second)),
          location);
    }

    test('Cron().parse() throws exception for invalid cron string', () {
      expect(() => Cron().parse("", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("*", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("-1 * * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("60 * * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* -1 * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* 24 * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * 0 * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * 32 * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * 0 *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * 13 *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * * -1", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * * 8", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("-1-2 * * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* -1-2 * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * -1-2 * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * -1-2 *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * * -1-2", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test(
        'Cron().parse() throws exception if current has been called before first next call',
        () {
      var cronIterator = Cron().parse("* * * * *", "Europe/Berlin");
      expect(
          () => cronIterator.current(), throwsA(TypeMatcher<AssertionError>()));
    });

    test('throws exception for invalid cron string', () {
      expect(() => Cron().parse("", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("*", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("-1 * * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("60 * * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* -1 * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* 24 * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * 0 * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * 32 * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * 0 *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * 13 *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * * -1", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * * 8", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("-1-2 * * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* -1-2 * * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * -1-2 * *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * -1-2 *", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => Cron().parse("* * * * -1-2", "Europe/Berlin"),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test(
        'Cron().parse() throws exception if current has been called before first next or previous call',
        () {
      var cronIterator = Cron().parse("* * * * *", "Europe/Berlin");
      expect(
          () => cronIterator.current(), throwsA(TypeMatcher<AssertionError>()));
    });

    group("delivers", () {
      test('correct locations', () {
        TZDateTime date = normalizedDate();
        var cronIterator = Cron().parse("* * * * *", "Africa/Gaborone");
        expect(cronIterator.next().location.name, equals("Africa/Gaborone"));
        expect(date.location.name, equals("Europe/Berlin"));
        expect(date.add(Duration(minutes: 1)).location.name,
            equals("Europe/Berlin"));
      });

      group('next', () {
        test('minutes starting from date', () {
          TZDateTime date = normalizedDate();
          var cronIterator = Cron().parse("* * * * *", "Europe/Berlin");
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
          expect(
              cronIterator.current(), equals(date.add(Duration(minutes: 1))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
          expect(
              cronIterator.current(), equals(date.add(Duration(minutes: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
          expect(
              cronIterator.current(), equals(date.add(Duration(minutes: 3))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 4))));
          expect(
              cronIterator.current(), equals(date.add(Duration(minutes: 4))));
        });

        test('hours starting from date', () {
          TZDateTime date = normalizedDate();
          date = normalizedDate().subtract(Duration(minutes: date.minute));
          var cronIterator = Cron().parse("0 * * * *", "Europe/Berlin");
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 4))));
        });

        test('days starting from date', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * *", "Europe/Berlin");
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(days: 1))));
          expect(cronIterator.next(), equals(date.add(Duration(days: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(days: 3))));
          expect(cronIterator.next(), equals(date.add(Duration(days: 4))));
        });

        test('month starting from date', () {
          TZDateTime date = normalizedDate();
          var cronIterator = Cron().parse("0 0 1 * *", "Europe/Berlin");
          expect(
              cronIterator.next(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month + 1, 1)));
          expect(
              cronIterator.next(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month + 2, 1)));
          expect(
              cronIterator.next(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month + 3, 1)));
          expect(
              cronIterator.next(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month + 4, 1)));
          expect(
              cronIterator.next(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month + 5, 1)));
        });

        test('weekday starting from monday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 1", "Europe/Berlin");
          var previous = cronIterator.next();
          expect(previous.weekday, equals(1));
          var next = cronIterator.next();
          expect(next.weekday, equals(1));
          expect(next, equals(previous.add(Duration(days: 7))));
        });

        test('weekday starting from sunday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 0", "Europe/Berlin");
          var previous = cronIterator.next();
          expect(previous.weekday, equals(7));
          var next = cronIterator.next();
          expect(next.weekday, equals(7));
          expect(next, equals(previous.add(Duration(days: 7))));
        });

        test('weekday starting from sunday with 7', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 7", "Europe/Berlin");
          var previous = cronIterator.next();
          expect(previous.weekday, equals(7));
          var next = cronIterator.next();
          expect(next.weekday, equals(7));
          expect(next, equals(previous.add(Duration(days: 7))));
        });

        test('weekday starting from saturday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 6", "Europe/Berlin");
          var previous = cronIterator.next();
          expect(previous.weekday, equals(6));
          var next = cronIterator.next();
          expect(next.weekday, equals(6));
          expect(next, equals(previous.add(Duration(days: 7))));
        });

        test('weekday starting from friday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 5", "Europe/Berlin");
          var previous = cronIterator.next();
          expect(previous.weekday, equals(5));
          var next = cronIterator.next();
          expect(next.weekday, equals(5));
          expect(next, equals(previous.add(Duration(days: 7))));
        });

        test('minutes range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator = Cron().parse("0-3 * * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 60))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 61))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 62))));
        });

        test('minutes selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator =
              Cron().parse("0,1,2,3 * * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 60))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 61))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 62))));
        });

        test('hours range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator = Cron().parse("0 0-3 * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 24))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 25))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 26))));
        });

        test('hours selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator =
              Cron().parse("0 0,1,2,3 * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 24))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 25))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 26))));
        });

        test('hours selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator =
              Cron().parse("0 0,1,2,3 * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 21))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 22))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 23))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 24))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 45))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 46))));
        });

        test('days range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator = Cron().parse("0 0 1-3 * *", "Europe/Berlin", date);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 1)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 2)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 05, 1)));
        });

        test('days selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator =
              Cron().parse("0 0 1,2,3 * *", "Europe/Berlin", date);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 1)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 2)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 05, 1)));
        });

        test('month range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator = Cron().parse("0 0 4 1-3 *", "Europe/Berlin", date);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 01, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 02, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 03, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2022, 01, 4)));
        });

        test('month selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator =
              Cron().parse("0 0 4 1,2,3 *", "Europe/Berlin", date);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 01, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 02, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 03, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2022, 01, 4)));
        });

        test('weekdays range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 * * 0-5", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 2)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 5)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 6)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 7)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 8)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 9)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 10)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 12)));
        });

        test('weekdays selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator =
              Cron().parse("0 0 * * 0,1,2,3,4,5", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 2)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 5)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 6)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 7)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 8)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 9)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 10)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 12)));
        });

        test('minutes interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("*/5 * * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 5))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 10))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 15))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 20))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 25))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 30))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 35))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 40))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 45))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 50))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 55))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 60))));
          expect(cronIterator.next(), equals(date.add(Duration(minutes: 65))));
        });

        test('hours interval starting from date', () {
          initializeTimeZone();
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 */2 * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 4))));
          expect(cronIterator.next(), equals(date.add(Duration(hours: 6))));
        });

        test('days interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 */3 * *", "Europe/Berlin", date);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 6)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 9)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 12)));
        });

        test('month interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 1 */2 *", "Europe/Berlin", date);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 6, 1)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 8, 1)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 10, 1)));
        });

        test('weekdays interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 * * */2", "Europe/Berlin", date);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 4, 2)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 4, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 4, 5)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 4, 7)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 4, 9)));
        });
      });

      group('previous', () {
        test('minutes starting from date', () {
          TZDateTime date = normalizedDate();
          var cronIterator = Cron().parse("* * * * *", "Europe/Berlin");
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 1))));
          expect(cronIterator.current(),
              equals(date.subtract(Duration(minutes: 1))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 2))));
          expect(cronIterator.current(),
              equals(date.subtract(Duration(minutes: 2))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 3))));
          expect(cronIterator.current(),
              equals(date.subtract(Duration(minutes: 3))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 4))));
          expect(cronIterator.current(),
              equals(date.subtract(Duration(minutes: 4))));
        });

        test('hours starting from date', () {
          TZDateTime date = normalizedDate();
          date = normalizedDate().subtract(Duration(minutes: date.minute));
          var cronIterator = Cron().parse("0 * * * *", "Europe/Berlin");
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 0))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 1))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 2))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 3))));
        });

        test('days starting from date', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * *", "Europe/Berlin");
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(days: 0))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(days: 1))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(days: 2))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(days: 3))));
        });

        test('month starting from date', () {
          TZDateTime date = normalizedDate();
          var cronIterator = Cron().parse("0 0 1 * *", "Europe/Berlin");
          expect(
              cronIterator.previous(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month - 0, 1)));
          expect(
              cronIterator.previous(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month - 1, 1)));
          expect(
              cronIterator.previous(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month - 2, 1)));
          expect(
              cronIterator.previous(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month - 3, 1)));
          expect(
              cronIterator.previous(),
              equals(TZDateTime(
                  getLocation("Europe/Berlin"), date.year, date.month - 4, 1)));
        });

        test('weekday starting from monday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 1", "Europe/Berlin");
          var next = cronIterator.previous();
          expect(next.weekday, equals(1));
          var previous = cronIterator.previous();
          expect(previous.weekday, equals(1));
          expect(previous, equals(next.subtract(Duration(days: 7))));
        });

        test('weekday starting from sunday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 0", "Europe/Berlin");
          var next = cronIterator.previous();
          expect(next.weekday, equals(7));
          var previous = cronIterator.previous();
          expect(previous.weekday, equals(7));
          expect(previous, equals(next.subtract(Duration(days: 7))));
        });

        test('weekday starting from sunday with 7', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 7", "Europe/Berlin");
          var next = cronIterator.previous();
          expect(next.weekday, equals(7));
          var previous = cronIterator.previous();
          expect(previous.weekday, equals(7));
          expect(previous, equals(next.subtract(Duration(days: 7))));
        });

        test('weekday starting from saturday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 6", "Europe/Berlin");
          var next = cronIterator.previous();
          expect(next.weekday, equals(6));
          var previous = cronIterator.previous();
          expect(previous.weekday, equals(6));
          expect(previous, equals(next.subtract(Duration(days: 7))));
        });

        test('weekday starting from friday', () {
          TZDateTime date = normalizedDate();
          date =
              date.subtract(Duration(minutes: date.minute, hours: date.hour));
          var cronIterator = Cron().parse("0 0 * * 5", "Europe/Berlin");
          var previous = cronIterator.previous();
          expect(previous.weekday, equals(5));
          var next = cronIterator.previous();
          expect(next.weekday, equals(5));
          expect(next, equals(previous.subtract(Duration(days: 7))));
        });

        test('minutes range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator = Cron().parse("0-3 * * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 57))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 58))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 59))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 60))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 117))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 118))));
        });

        test('minutes selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator =
              Cron().parse("0,1,2,3 * * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 57))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 58))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 59))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 60))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 117))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 118))));
        });

        test('hours range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
          var cronIterator = Cron().parse("0 0-3 * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 21))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 22))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 23))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 24))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 45))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 46))));
        });

        test('days range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator = Cron().parse("0 0 1-3 * *", "Europe/Berlin", date);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 3)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 2)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 1)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 3)));
        });

        test('days selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator =
              Cron().parse("0 0 1,2,3 * *", "Europe/Berlin", date);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 3)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 2)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 1)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 3)));
        });

        test('month range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator = Cron().parse("0 0 4 1-3 *", "Europe/Berlin", date);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 4)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 4)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 01, 4)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 03, 4)));
        });

        test('month selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
          var cronIterator =
              Cron().parse("0 0 4 1,2,3 *", "Europe/Berlin", date);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 4)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 4)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 01, 4)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 03, 4)));
        });

        test('weekdays range starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 * * 0-5", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 30)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 27)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 26)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 25)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 24)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 23)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 22)));
        });

        test('weekdays selection starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator =
              Cron().parse("0 0 * * 0,1,2,3,4,5", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 30)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 27)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 26)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 25)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 24)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 23)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 22)));
        });

        test('minutes interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("*/5 * * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 5))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 10))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 15))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 20))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 25))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 30))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 35))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 40))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 45))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 50))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 55))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 60))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(minutes: 65))));
        });

        test('hours interval starting from date', () {
          initializeTimeZone();
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 */2 * * *", "Europe/Berlin", date);
          date = TZDateTime.from(date, getLocation("Europe/Berlin"));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 2))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 4))));
          expect(cronIterator.previous(),
              equals(date.subtract(Duration(hours: 6))));
        });

        test('days interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 */3 * *", "Europe/Berlin", date);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 30)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 27)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 24)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 21)));
        });

        test('month interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 1 */2 *", "Europe/Berlin", date);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 2, 1)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 12, 1)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 10, 1)));
        });

        test('weekdays interval starting from date', () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
          var cronIterator = Cron().parse("0 0 * * */2", "Europe/Berlin", date);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 3, 31)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 3, 29)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 3, 28)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 3, 26)));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 3, 24)));
        });
      });
    });

    group('handles timezone correctly', () {
      test('when provided timezone is Europe/London (next)', () {
        TZDateTime date = normalizedDate(
            TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
        var cronIterator = Cron().parse("0 0 * * *", "Europe/London", date);
        date = TZDateTime.from(date, getLocation("Europe/London"));
        expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
        expect(
            cronIterator.next(), equals(date.add(Duration(days: 1, hours: 1))));
        expect(
            cronIterator.next(), equals(date.add(Duration(days: 2, hours: 1))));
      });

      test('when provided timezone is Europe/London (previous)', () {
        TZDateTime date = normalizedDate(
            TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
        var cronIterator = Cron().parse("0 0 * * *", "Europe/London", date);
        date = TZDateTime.from(date, getLocation("Europe/London"));
        expect(cronIterator.previous(),
            equals(date.subtract(Duration(days: 1, hours: -1))));
        expect(cronIterator.previous(),
            equals(date.subtract(Duration(days: 2, hours: -1))));
        expect(cronIterator.previous(),
            equals(date.subtract(Duration(days: 3, hours: -2))));
      });

      test(
          'when provided timezone is in the middle of DST change for America/New_York (next)',
          () {
        TZDateTime date = normalizedDate(
            TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
        var cronIterator = Cron().parse("0 19 * * *", "America/New_York", date);
        expect(
            cronIterator.next(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 03, 31, 19)));
        expect(
            cronIterator.next(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 04, 01, 19)));
        expect(
            cronIterator.next(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 04, 02, 19)));
        expect(
            cronIterator.next(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 04, 03, 19)));
      });

      test(
          'when provided timezone is in the middle of DST change for America/New_York (previous)',
          () {
        TZDateTime date = normalizedDate(
            TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
        var cronIterator = Cron().parse("0 19 * * *", "America/New_York", date);
        expect(
            cronIterator.previous(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 03, 30, 19)));
        expect(
            cronIterator.previous(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 03, 29, 19)));
        expect(
            cronIterator.previous(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 03, 28, 19)));
        expect(
            cronIterator.previous(),
            equals(
                TZDateTime(getLocation("America/New_York"), 2020, 03, 27, 19)));
      });
    });

    group('handles timezone DST changes correctly', () {
      group('.next()', () {
        test(
            'when provided timezone is in the middle of DST change for Europe/London',
            () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 1));
          var cronIterator = Cron().parse("0 * * * *", "Europe/London", date);
          date = TZDateTime.from(date, getLocation("Europe/London"));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 3)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 4)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 5)));
        });

        test('test', () {
          TZDateTime startDate =
              TZDateTime(getLocation("Europe/London"), 2020, 4, 01);
          var cronIterator =
              Cron().parse("0 * * * *", "Europe/London", startDate);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/London"), 2020, 4, 01, 1)));
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/London"), 2020, 4, 01, 2)));
          print(cronIterator.next());
        });
      });

      group('.previous()', () {
        test(
            'when provided timezone is in the middle of DST change for Europe/London',
            () {
          TZDateTime date = normalizedDate(
              TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 1));
          var cronIterator = Cron().parse("0 * * * *", "Europe/London", date);
          date = TZDateTime.from(date, getLocation("Europe/London"));
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 0)));
          expect(
              cronIterator.previous(),
              equals(
                  TZDateTime(getLocation("Europe/London"), 2020, 3, 28, 23)));
          expect(
              cronIterator.previous(),
              equals(
                  TZDateTime(getLocation("Europe/London"), 2020, 3, 28, 22)));
        });

        test('test', () {
          TZDateTime startDate =
              TZDateTime(getLocation("Europe/London"), 2020, 4, 01);
          var cronIterator =
              Cron().parse("0 * * * *", "Europe/London", startDate);
          expect(
              cronIterator.previous(),
              equals(
                  TZDateTime(getLocation("Europe/London"), 2020, 3, 31, 23)));
          expect(
              cronIterator.previous(),
              equals(
                  TZDateTime(getLocation("Europe/London"), 2020, 3, 31, 22)));
          print(cronIterator.previous());
        });
      });
    });

    group('Smoke tests', () {
      group('.next()', () {
        test('0 19 7 8 *', () {
          TZDateTime startDate =
              TZDateTime(getLocation("Europe/London"), 2021, 7, 12);
          var cronIterator =
              Cron().parse("0 19 7 8 *", "Europe/London", startDate);
          expect(cronIterator.next(),
              equals(TZDateTime(getLocation("Europe/London"), 2021, 8, 7, 19)));
        });

        test('0 11 * * *', () {
          TZDateTime startDate =
              TZDateTime(getLocation("Europe/London"), 2019, 11, 23, 12);
          var cronIterator =
              Cron().parse("0 11 * * *", "Europe/London", startDate);
          expect(
              cronIterator.next(),
              equals(
                  TZDateTime(getLocation("Europe/London"), 2019, 11, 24, 11)));
        });
      });

      group('.previous()', () {
        test('0 19 7 8 *', () {
          TZDateTime startDate =
              TZDateTime(getLocation("Europe/London"), 2021, 7, 12);
          var cronIterator =
              Cron().parse("0 19 7 8 *", "Europe/London", startDate);
          expect(cronIterator.previous(),
              equals(TZDateTime(getLocation("Europe/London"), 2020, 8, 7, 19)));
        });

        test('0 11 * * *', () {
          TZDateTime startDate =
              TZDateTime(getLocation("Europe/London"), 2019, 11, 23, 12);
          var cronIterator =
              Cron().parse("0 11 * * *", "Europe/London", startDate);
          expect(
              cronIterator.previous(),
              equals(
                  TZDateTime(getLocation("Europe/London"), 2019, 11, 23, 11)));
        });
      });
    });
  });
}
