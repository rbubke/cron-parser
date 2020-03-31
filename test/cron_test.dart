import 'package:test/test.dart';

import '../lib/cron.dart';

void main() {
  test('Cron().parse() throws exception for invalid cron string', () {
    expect(() => Cron().parse(""), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("*"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("-1 * * * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("60 * * * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* -1 * * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* 24 * * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * 0 * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * 32 * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * * 0 *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * * 13 *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * * * -1"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * * * 8"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("-1-2 * * * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* -1-2 * * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * -1-2 * *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * * -1-2 *"), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Cron().parse("* * * * -1-2"), throwsA(TypeMatcher<AssertionError>()));
  });

  DateTime normalizedDate([DateTime dateTime = null]) {
    DateTime date = dateTime == null ? DateTime.now() : dateTime;
    return date
        .subtract(Duration(microseconds: date.microsecond, milliseconds: date.millisecond, seconds: date.second));
  }

  group("Cron().parse() delivers", () {
    test('next minutes starting from date', () {
      DateTime date = normalizedDate();
      var cronIterator = Cron().parse("* * * * *");
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 4))));
    });

    test('next hours starting from date', () {
      DateTime date = normalizedDate();
      date = normalizedDate().subtract(Duration(minutes: date.minute));
      var cronIterator = Cron().parse("0 * * * *");
      expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 4))));
    });

    test('next days starting from date', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * *");
      expect(cronIterator.next(), equals(date.add(Duration(days: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(days: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(days: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(days: 4))));
    });

    test('next month starting from date', () {
      DateTime date = normalizedDate();
      var cronIterator = Cron().parse("0 0 1 * *");
      expect(cronIterator.next(), equals(DateTime(date.year, date.month + 1, 1)));
      expect(cronIterator.next(), equals(DateTime(date.year, date.month + 2, 1)));
      expect(cronIterator.next(), equals(DateTime(date.year, date.month + 3, 1)));
      expect(cronIterator.next(), equals(DateTime(date.year, date.month + 4, 1)));
      expect(cronIterator.next(), equals(DateTime(date.year, date.month + 5, 1)));
    });

    test('next weekday starting from monday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 1");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(1));
      var next = cronIterator.next();
      expect(next.weekday, equals(1));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from sunday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 0");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(7));
      var next = cronIterator.next();
      expect(next.weekday, equals(7));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from sunday with 7', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 7");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(7));
      var next = cronIterator.next();
      expect(next.weekday, equals(7));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from saturday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 6");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(6));
      var next = cronIterator.next();
      expect(next.weekday, equals(6));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next weekday starting from friday', () {
      DateTime date = normalizedDate();
      date = date.subtract(Duration(minutes: date.minute, hours: date.hour));
      var cronIterator = Cron().parse("0 0 * * 5");
      var previous = cronIterator.next();
      expect(previous.weekday, equals(5));
      var next = cronIterator.next();
      expect(next.weekday, equals(5));
      expect(next, equals(previous.add(Duration(days: 7))));
    });

    test('next minutes range starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 31));
      var cronIterator = Cron().parse("0-3 * * * *", date);
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 60))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 61))));
      expect(cronIterator.next(), equals(date.add(Duration(minutes: 62))));
    });

    test('next hours range starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 31));
      var cronIterator = Cron().parse("0 0-3 * * *", date);
      expect(cronIterator.next(), equals(date.add(Duration(hours: 1))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 3))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 24))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 25))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 26))));
    });

    test('next days range starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 29));
      var cronIterator = Cron().parse("0 0 1-3 * *", date);
      expect(cronIterator.next(), equals(DateTime(2020, 04, 1)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 2)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 3)));
      expect(cronIterator.next(), equals(DateTime(2020, 05, 1)));
    });

    test('next month range starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 29));
      var cronIterator = Cron().parse("0 0 4 1-3 *", date);
      expect(cronIterator.next(), equals(DateTime(2021, 01, 4)));
      expect(cronIterator.next(), equals(DateTime(2021, 02, 4)));
      expect(cronIterator.next(), equals(DateTime(2021, 03, 4)));
      expect(cronIterator.next(), equals(DateTime(2022, 01, 4)));
    });

    test('next weekdays range starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 28));
      var cronIterator = Cron().parse("0 0 * * 0-5", date);
      expect(cronIterator.next(), equals(DateTime(2020, 03, 29)));
      expect(cronIterator.next(), equals(DateTime(2020, 03, 30)));
      expect(cronIterator.next(), equals(DateTime(2020, 03, 31)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 1)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 2)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 3)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 5)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 6)));
    });

    test('next minutes interval starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 28));
      var cronIterator = Cron().parse("*/5 * * * *", date);
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
      DateTime date = normalizedDate(DateTime(2020, 03, 28));
      var cronIterator = Cron().parse("0 */2 * * *", date);
      expect(cronIterator.next(), equals(date.add(Duration(hours: 2))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 4))));
      expect(cronIterator.next(), equals(date.add(Duration(hours: 6))));
    });

    test('next days interval starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 28));
      var cronIterator = Cron().parse("0 0 */3 * *", date);
      expect(cronIterator.next(), equals(DateTime(2020, 03, 30)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 3)));
      expect(cronIterator.next(), equals(DateTime(2020, 04, 6)));
    });

    test('next month interval starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 28));
      var cronIterator = Cron().parse("0 0 1 */2 *", date);
      expect(cronIterator.next(), equals(DateTime(2020, 4, 1)));
      expect(cronIterator.next(), equals(DateTime(2020, 6, 1)));
      expect(cronIterator.next(), equals(DateTime(2020, 8, 1)));
    });

    test('next weekdays interval starting from date', () {
      DateTime date = normalizedDate(DateTime(2020, 03, 28));
      var cronIterator = Cron().parse("0 0 * * */2", date);
      expect(cronIterator.next(), equals(DateTime(2020, 3, 29)));
      expect(cronIterator.next(), equals(DateTime(2020, 3, 31)));
      expect(cronIterator.next(), equals(DateTime(2020, 4, 2)));
      expect(cronIterator.next(), equals(DateTime(2020, 4, 4)));
      expect(cronIterator.next(), equals(DateTime(2020, 4, 5)));
      expect(cronIterator.next(), equals(DateTime(2020, 4, 7)));
    });
  });
}
