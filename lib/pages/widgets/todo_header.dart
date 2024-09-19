import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_sync/pages/providers/active_todo_count_provider.dart';
import 'package:todo_sync/pages/providers/theme_provider.dart';
import 'package:todo_sync/pages/providers/todo_list_provider.dart';

class TodoHeader extends ConsumerWidget {
  const TodoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final active = ref.watch(activeTodoCountProvider);
    final theme = ref.watch(themeProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Todos',
          style: TextStyle(fontSize: 36.0),
        ),
        const SizedBox(width: 10),
        Text(
          '($active / ${todos.length} item${active >= 1 ? 's' : ''} left)',
          style: const TextStyle(
            fontSize: 18.0,
            color: Colors.blue,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
          icon: Icon(
              theme == AppTheme.light ? Icons.light_mode : Icons.dark_mode),
        ),
      ],
    );
  }
}
