import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_sync/models/todo_model.dart';
import 'package:todo_sync/pages/providers/todo_item_provider.dart';
import 'package:todo_sync/pages/providers/todo_list_provider.dart';

class TodoItem extends ConsumerWidget {
  const TodoItem({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(todoItemProvider);

    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return ConfirmEditDialog(todo: todo);
          },
        );
      },
      leading: Checkbox(
        value: todo.completed,
        onChanged: (value) {
          ref.read(todoListProvider.notifier).toggleTodo(todo.id);
        },
      ),
      title: Text(
        todo.desc,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      trailing: IconButton(
        onPressed: () async {
          final removeOrNot = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const ConfirmRemoveDialog();
            },
          );

          if (removeOrNot) {
            ref.read(todoListProvider.notifier).removeTodo(todo.id);
          }
        },
        icon: const Icon(Icons.delete),
      ),
    );
  }
}

class ConfirmRemoveDialog extends StatelessWidget {
  const ConfirmRemoveDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('Do you really want to delete?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Ok'),
        )
      ],
    );
  }
}

class ConfirmEditDialog extends ConsumerStatefulWidget {
  const ConfirmEditDialog({
    super.key,
    required this.todo,
  });

  final Todo todo;

  @override
  ConsumerState<ConfirmEditDialog> createState() => _ConfirmEditDialogState();
}

class _ConfirmEditDialogState extends ConsumerState<ConfirmEditDialog> {
  late TextEditingController controller;
  bool error = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.todo.desc);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit todo'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          errorText: error ? 'Value cannot be empty' : null,
        ),
        onSubmitted: (desc) {
          ref.read(todoListProvider.notifier).editTodo(widget.todo.id, desc);
          Navigator.of(context).pop();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isEmpty) {
              setState(() {
                error = true;
              });
            } else {
              ref
                  .read(todoListProvider.notifier)
                  .editTodo(widget.todo.id, controller.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}
