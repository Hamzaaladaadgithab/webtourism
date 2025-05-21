import 'package:timeago/timeago.dart' as timeago;

class TrMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => ' önce';
  @override
  String suffixFromNow() => ' sonra';
  @override
  String lessThanOneMinute(int seconds) => 'az önce';
  @override
  String aboutAMinute(int minutes) => 'bir dakika';
  @override
  String minutes(int minutes) => '$minutes dakika';
  @override
  String aboutAnHour(int minutes) => 'bir saat';
  @override
  String hours(int hours) => '$hours saat';
  @override
  String aDay(int hours) => 'bir gün';
  @override
  String days(int days) => '$days gün';
  @override
  String aboutAMonth(int days) => 'bir ay';
  @override
  String months(int months) => '$months ay';
  @override
  String aboutAYear(int year) => 'bir yıl';
  @override
  String years(int years) => '$years yıl';
  @override
  String wordSeparator() => ' ';
}

void initTimeAgoTr() {
  timeago.setLocaleMessages('tr', TrMessages());
}
