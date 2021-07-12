import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

import '../lib/cron_parser.dart';

void main() {
  DateTime normalizedDate(
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

  group("Cron().parse() delivers", () {
    test('correct locations', () {
      TZDateTime date = normalizedDate() as TZDateTime;
      var cronIterator = Cron().parse("* * * * *", "Africa/Gaborone");
      expect(cronIterator.next().location.name, equals("Africa/Gaborone"));
      expect(date.location.name, equals("Europe/Berlin"));
      expect(date.add(Duration(minutes: 1)).location.name,
          equals("Europe/Berlin"));
    });

    test('next minutes starting from date', () {
      TZDateTime date = normalizedDate() as TZDateTime;
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

    test('previous minutes starting from date', () {
      TZDateTime date = normalizedDate() as TZDateTime;
      var cronIterator = Cron().parse("* * * * *", "Europe/Berlin");
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(minutes: 1))));
      expect(
          cronIterator.current(), equals(date.subtract(Duration(minutes: 1))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(minutes: 2))));
      expect(
          cronIterator.current(), equals(date.subtract(Duration(minutes: 2))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(minutes: 3))));
      expect(
          cronIterator.current(), equals(date.subtract(Duration(minutes: 3))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(minutes: 4))));
      expect(
          cronIterator.current(), equals(date.subtract(Duration(minutes: 4))));
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

    test('previous hours starting from date', () {
      DateTime date = normalizedDate();
      date = normalizedDate().subtract(Duration(minutes: date.minute));
      var cronIterator = Cron().parse("0 * * * *", "Europe/Berlin");
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 0))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 1))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 2))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 3))));
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

    test('previous days starting from date', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * *", "Europe/Berlin");
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.previous(), equals(date.subtract(Duration(days: 0))));
      expect(cronIterator.previous(), equals(date.subtract(Duration(days: 1))));
      expect(cronIterator.previous(), equals(date.subtract(Duration(days: 2))));
      expect(cronIterator.previous(), equals(date.subtract(Duration(days: 3))));
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

    test('previous month starting from date', () {
      DateTime date = normalizedDate();
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

    test('previous weekday starting from monday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 1", "Europe/Berlin");
      var next = cronIterator.previous();
      expect(next.weekday, equals(1));
      var previous = cronIterator.previous();
      expect(previous.weekday, equals(1));
      expect(previous, equals(next.subtract(Duration(days: 7))));
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

    test('previous weekday starting from sunday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 0", "Europe/Berlin");
      var next = cronIterator.previous();
      expect(next.weekday, equals(7));
      var previous = cronIterator.previous();
      expect(previous.weekday, equals(7));
      expect(previous, equals(next.subtract(Duration(days: 7))));
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

    test('previous weekday starting from sunday with 7', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 7", "Europe/Berlin");
      var next = cronIterator.previous();
      expect(next.weekday, equals(7));
      var previous = cronIterator.previous();
      expect(previous.weekday, equals(7));
      expect(previous, equals(next.subtract(Duration(days: 7))));
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

    test('previous weekday starting from saturday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 6", "Europe/Berlin");
      var next = cronIterator.previous();
      expect(next.weekday, equals(6));
      var previous = cronIterator.previous();
      expect(previous.weekday, equals(6));
      expect(previous, equals(next.subtract(Duration(days: 7))));
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

    test('previous weekday starting from friday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 5", "Europe/Berlin");
      var previous = cronIterator.previous();
      expect(previous.weekday, equals(5));
      var next = cronIterator.previous();
      expect(next.weekday, equals(5));
      expect(next, equals(previous.subtract(Duration(days: 7))));
    });

    test('next minutes range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator =
          Cron().parse("0-3 * * * *", "Europe/Berlin", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 60))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 61))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 62))));
    });

    test('previous minutes range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator =
          Cron().parse("0-3 * * * *", "Europe/Berlin", date as TZDateTime);
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

    test('next minutes selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator =
          Cron().parse("0,1,2,3 * * * *", "Europe/Berlin", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 60))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 61))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 62))));
    });

    test('previous minutes selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator =
          Cron().parse("0,1,2,3 * * * *", "Europe/Berlin", date as TZDateTime);
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

    test('next hours range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator =
          Cron().parse("0 0-3 * * *", "Europe/Berlin", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 24))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 25))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 26))));
    });

    test('previous hours range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator =
          Cron().parse("0 0-3 * * *", "Europe/Berlin", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 21))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 22))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 23))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 24))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 45))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 46))));
    });

    test('next hours selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 31));
      var cronIterator =
          Cron().parse("0 0,1,2,3 * * *", "Europe/Berlin", date as TZDateTime);
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
      var cronIterator =
          Cron().parse("0 0,1,2,3 * * *", "Europe/Berlin", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 21))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 22))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 23))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 24))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 45))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 46))));
    });

    test('next days range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 1-3 * *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 2)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 05, 1)));
    });

    test('previous days range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 1-3 * *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 3)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 2)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 1)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 3)));
    });

    test('next days selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 1,2,3 * *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 2)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 05, 1)));
    });

    test('previous days selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 1,2,3 * *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 3)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 2)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 1)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 3)));
    });

    test('next month range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 4 1-3 *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 01, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 02, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 03, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2022, 01, 4)));
    });

    test('previous month range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 4 1-3 *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 4)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 4)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 01, 4)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 03, 4)));
    });

    test('next month selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 4 1,2,3 *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 01, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 02, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2021, 03, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2022, 01, 4)));
    });

    test('previous month selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 29));
      var cronIterator =
          Cron().parse("0 0 4 1,2,3 *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 4)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 02, 4)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 01, 4)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 03, 4)));
    });

    test('next weekdays range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 * * 0-5", "Europe/Berlin", date as TZDateTime);
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

    test('previous weekdays range starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 * * 0-5", "Europe/Berlin", date as TZDateTime);
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

    test('next weekdays selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator = Cron()
          .parse("0 0 * * 0,1,2,3,4,5", "Europe/Berlin", date as TZDateTime);
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

    test('previous weekdays selection starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator = Cron()
          .parse("0 0 * * 0,1,2,3,4,5", "Europe/Berlin", date as TZDateTime);
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

    test('next minutes interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("*/5 * * * *", "Europe/Berlin", date as TZDateTime);
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

    test('previous minutes interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("*/5 * * * *", "Europe/Berlin", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(minutes: 5))));
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

    test('next hours interval starting from date', () {
      initializeTimeZone();
      TZDateTime date =
          normalizedDate(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01))
              as TZDateTime;
      var cronIterator = Cron().parse("0 */2 * * *", "Europe/Berlin", date);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 4))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 6))));
    });

    test('previous hours interval starting from date', () {
      initializeTimeZone();
      TZDateTime date =
          normalizedDate(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01))
              as TZDateTime;
      var cronIterator = Cron().parse("0 */2 * * *", "Europe/Berlin", date);
      date = TZDateTime.from(date, getLocation("Europe/Berlin"));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 2))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 4))));
      expect(
          cronIterator.previous(), equals(date.subtract(Duration(hours: 6))));
    });

    test('next days interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 */3 * *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 3)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 6)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 9)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 12)));
    });

    test('previous days interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 */3 * *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 30)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 27)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 24)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 03, 21)));
    });

    test('next month interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 1 */2 *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 6, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 8, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 10, 1)));
    });

    test('previous month interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 1 */2 *", "Europe/Berlin", date as TZDateTime);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2020, 2, 1)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 12, 1)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/Berlin"), 2019, 10, 1)));
    });

    test('next weekdays interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 * * */2", "Europe/Berlin", date as TZDateTime);
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

    test('previous weekdays interval starting from date', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 * * */2", "Europe/Berlin", date as TZDateTime);
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

  group("Cron().parse() handles timezone correctly", () {
    test('when provided timezone is Europe/London (next)', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 * * *", "Europe/London", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/London"));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
      expect(
          cronIterator.next(), equals(date.add(Duration(days: 1, hours: 1))));
      expect(
          cronIterator.next(), equals(date.add(Duration(days: 2, hours: 1))));
    });

    test('when provided timezone is Europe/London (previous)', () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 0 * * *", "Europe/London", date as TZDateTime);
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
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 19 * * *", "America/New_York", date as TZDateTime);
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
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/Berlin"), 2020, 04, 01));
      var cronIterator =
          Cron().parse("0 19 * * *", "America/New_York", date as TZDateTime);
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

  group("Cron().parse() handles timezone DST changes correctly", () {
    test(
        'when provided timezone is in the middle of DST change for Europe/London (next)',
        () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 1));
      var cronIterator =
          Cron().parse("0 * * * *", "Europe/London", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/London"));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 3)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 4)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 5)));
    });

    test(
        'when provided timezone is in the middle of DST change for Europe/London (previous)',
        () {
      DateTime date = normalizedDate(
          TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 1));
      var cronIterator =
          Cron().parse("0 * * * *", "Europe/London", date as TZDateTime);
      date = TZDateTime.from(date, getLocation("Europe/London"));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 29, 0)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 28, 23)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 28, 22)));
    });

    test('test (next)', () {
      TZDateTime startDate =
          TZDateTime(getLocation("Europe/London"), 2020, 4, 01);
      var cronIterator = Cron().parse("0 * * * *", "Europe/London", startDate);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 4, 01, 1)));
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 4, 01, 2)));
      print(cronIterator.next());
    });

    test('test (previous)', () {
      TZDateTime startDate =
          TZDateTime(getLocation("Europe/London"), 2020, 4, 01);
      var cronIterator = Cron().parse("0 * * * *", "Europe/London", startDate);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 31, 23)));
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 3, 31, 22)));
      print(cronIterator.previous());
    });
  });

  group('Smoke tests', () {
    test('0 19 7 8 * (previous)', () {
      TZDateTime startDate =
          TZDateTime(getLocation("Europe/London"), 2021, 7, 12);
      var cronIterator = Cron().parse("0 19 7 8 *", "Europe/London", startDate);
      expect(cronIterator.previous(),
          equals(TZDateTime(getLocation("Europe/London"), 2020, 8, 7, 19)));
    });

    test('0 19 7 8 * (next)', () {
      TZDateTime startDate =
          TZDateTime(getLocation("Europe/London"), 2021, 7, 12);
      var cronIterator = Cron().parse("0 19 7 8 *", "Europe/London", startDate);
      expect(cronIterator.next(),
          equals(TZDateTime(getLocation("Europe/London"), 2021, 8, 7, 19)));
    });
  });
}
