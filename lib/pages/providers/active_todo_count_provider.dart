import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_sync/pages/providers/todo_list_provider.dart';

part 'active_todo_count_provider.g.dart';

@riverpod
int activeTodoCount(ActiveTodoCountRef ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => !todo.completed).toList().length;
}
