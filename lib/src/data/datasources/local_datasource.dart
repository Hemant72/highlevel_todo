import 'package:drift/drift.dart';

part 'local_datasource.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get tags => text().map(CommaSeparatedListConverter())();
  BoolColumn get isCompleted => boolean().withDefault(Constant(false))();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

class CommaSeparatedListConverter extends TypeConverter<List<String>, String> {
  const CommaSeparatedListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return fromDb.split(',').map((tag) => tag.trim()).toList();
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}
