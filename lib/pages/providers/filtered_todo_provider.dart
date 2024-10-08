import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_sync/models/todo_model.dart';
import 'package:todo_sync/pages/providers/todo_filter_provider.dart';
import 'package:todo_sync/pages/providers/todo_list_provider.dart';
import 'package:todo_sync/pages/providers/todo_search_provider.dart';

part 'filtered_todo_provider.g.dart';

@riverpod
List<Todo> filterdTodos(FilterdTodosRef ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  final search = ref.watch(todoSearchProvider);

  List<Todo> tempTodos;

  tempTodos = switch (filter) {
    Filter.active => todos.where((todo) => !todo.completed).toList(),
    Filter.completed => todos.where((todo) => todo.completed).toList(),
    Filter.all => todos,
  };

  if (search.isNotEmpty) {
    tempTodos = tempTodos
        .where((todo) => todo.desc.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  return tempTodos;
}
