import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

Uuid uuid = const Uuid();

@freezed
class Todo with _$Todo {
  const Todo._();
  const factory Todo({
    required String id,
    required String desc,
    @Default(false) bool completed,
  }) = _Todo;

  factory Todo.add({required String desc}) {
    final id = uuid.v4();
    return Todo(id: id, desc: desc);
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

enum Filter {
  all,
  active,
  completed,
}
