import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

import '../lib/cron_parser.dart';

void main() {
  DateTime normalizedDate(
      [DateTime dateTime, String locationName = "Europe/Berlin"]) {
    var location = getLocation(locationName);
    TZDateTime date = dateTime == null ? TZDateTime.now(location) : dateTime;
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

  group("Cron().parse() delivers", () {
    test('correct locations', () {
      TZDateTime date = normalizedDate();
      var cronIterator = Cron().parse("* * * * *", "Africa/Gaborone");
      expect(cronIterator.next().location.name, equals("Africa/Gaborone"));
      expect(date.location.name, equals("Europe/Berlin"));
      expect(date.add(Duration(minutes: 1)).location.name,
          equals("Europe/Berlin"));
    });

    test('next minutes starting from date', () {
      TZDateTime date = normalizedDate();
      var cronIterator = Cron().parse("* * * * *", "Europe/Berlin");
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
      expect(cronIterator.current(), equals(date.add(Duration(minutes: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
      expect(cronIterator.current(), equals(date.add(Duration(minutes: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
      expect(cronIterator.current(), equals(date.add(Duration(minutes: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 4))));
      expect(cronIterator.current(), equals(date.add(Duration(minutes: 4))));
    });

    test('next hours starting from date', () {
      DateTime date = normalizedDate();
      date = normalizedDate().subtract(Duration(minutes: date.minute));
      var cronIterator = Cron().parse("0 * * * *", "Europe/Berlin");
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 4))));
    });

    test('next days starting from date', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * *", "Europe/Berlin");
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(days: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(days: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(days: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(days: 4))));
    });

    test('next month starting from date', () {
      DateTime date = normalizedDate();
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

    test('next weekday starting from monday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 1", "Europe/Berlin");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(1));
      var next = cronIterator.next();
      expect(next.weekday, equals(1));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from sunday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 0", "Europe/Berlin");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(7));
      var next = cronIterator.next();
      expect(next.weekday, equals(7));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from sunday with 7', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 7", "Europe/Berlin");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(7));
      var next = cronIterator.next();
      expect(next.weekday, equals(7));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from saturday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 6", "Europe/Berlin");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(6));
      var next = cronIterator.next();
      expect(next.weekday, equals(6));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from friday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 5", "Europe/Berlin");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(5));
      var next = cronIterator.next();
      expect(next.weekday, equals(5));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next minutes range starting from date', () {
      DateTime date = normalizedDate(
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

    test('next minutes selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator = Cron().parse("0,1,2,3 * * * *", "Europe/Berlin", date);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 60))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 61))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 62))));
    });

    test('next hours range starting from date', () {
      DateTime date = normalizedDate(
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

    test('next hours selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator = Cron().parse("0 0,1,2,3 * * *", "Europe/Berlin", date);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 24))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 25))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 26))));
    });

    test('next days range starting from date', () {
      DateTime date = normalizedDate(
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

    test('next days selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator = Cron().parse("0 0 1,2,3 * *", "Europe/Berlin", date);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 2)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 05, 1)));
    });

    test('next month range starting from date', () {
      DateTime date = normalizedDate(
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

    test('next month selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator = Cron().parse("0 0 4 1,2,3 *", "Europe/Berlin", date);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 01, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 02, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 03, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2022, 01, 4)));
    });

    test('next weekdays range starting from date', () {
      DateTime date = normalizedDate(
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

    test('next weekdays selection starting from date', () {
      DateTime date = normalizedDate(
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

    test('next minutes interval starting from date', () {
      DateTime date = normalizedDate(
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

    test('next hours interval starting from date', () {
      initializeTimeZone();
      TZDateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator = Cron().parse("0 */2 * * *", "Europe/Berlin", date);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 4))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 6))));
    });

    test('next days interval starting from date', () {
      DateTime date = normalizedDate(
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

    test('next month interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator = Cron().parse("0 0 1 */2 *", "Europe/Berlin", date);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 6, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 8, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 10, 1)));
    });

    test('next weekdays interval starting from date', () {
      DateTime date = normalizedDate(
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

  group("Cron().parse() handles timezone correctly", () {
    test('when provided timezone is Europe/London', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator = Cron().parse("0 0 * * *", "Europe/London", date);
      date = TZDateTime.from(date, getLocation("Europe/London"));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
      expect(
          cronIterator.next(), equals(date.add(Duration(days: 1, hours: 1))));
      expect(
          cronIterator.next(), equals(date.add(Duration(days: 2, hours: 1))));
    });
    test(
        'when provided timezone is in the middle of DST change for America/New_York',
        () {
      DateTime date = normalizedDate(
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
  });

  group("Cron().parse() handles timezone DST changes correctly", () {
    test(
        'when provided timezone is in the middle of DST change for Europe/London',
        () {
      DateTime date = normalizedDate(
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
      var cronIterator = Cron().parse("0 * * * *", "Europe/London", startDate);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 4, 01, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 4, 01, 2)));
      print(cronIterator.next());
    });
  });
}
