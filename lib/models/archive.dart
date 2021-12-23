import 'package:itblog/models/data.dart';

class Archive {
  String url;
  String title;
  Archive({this.url = '', this.title = ''});

  factory Archive.fromMap(Map<String, dynamic> map) {
    var yearMonth = map['date'] as String;
    return Archive(
      url: "/archives/${yearMonth}",
      title:
          "${monthName(toInt(yearMonth.split('-').last))} ${yearMonth.split('-').first}",
    );
  }
}
