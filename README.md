# todo_sync

## Filter

- enum을 사용하여 범주를 만들고 switch 구문을 사용하면 모든 범주에 대해 구현하지 않으면 에러가 발생하여 개발시 실수를 방지 한다.

```dart

enum Filter {
  all,
  active,
  completed,
}

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
```

## Debounce

- 텍스트 필드에서 문자가 입력 될때마다 API 호출을 하면 API에 부하를 줄수 있기 때문에 호출에 딜레이를 주어서 API 호출 수를 줄여 주는 기술이다.
- 200~300 millisceond 를 사용하면 사용자가 채감 하기 어렵다.

```dart
class Debounce {
  final int millisecond;

  Debounce({
    this.millisecond = 500,
  });

  Timer? _timer;

  void run(VoidCallback action) {
    dispose();
    _timer = Timer(Duration(milliseconds: millisecond), action);
  }

  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}

// 위젯이 생성될때 생성
final debounce = Debounce(millisecond: 300);

@override
void dispose() {
  debounce.dispose();
  super.dispose();
}

// 사용
onChanged: (value) {
  debounce.run(() {
    ref.read(todoSearchProvider.notifier).setSearchTerm(value);
  });
}
```

## Theme

- Theme을 관리하는 프로바이더 생성

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

enum AppTheme {
  light,
  dark,
}

@riverpod
class Theme extends _$Theme {
  @override
  AppTheme build() {
    return AppTheme.light;
  }

  void toggleTheme() {
    state = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
  }
}

// 사용
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Todos',
      debugShowCheckedModeBanner: false,
      theme: theme == AppTheme.light ? ThemeData.light() : ThemeData.dark(),
      home: const TodosPage(),
    );
  }
}
```

## Computation Provider

1. 다른 프로바이더를 참조해서 새로운 프로바이더를 생성.
   대표적으로 count 또는 filtered
2. 다른 프로바이더의 값이 변하면 리빌드 된다.
3. 제공만 하기때문에 기본 프로바이더를 사용한다.

```dart
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
```

## Dialog 리턴 값

```dart
IconButton(
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
```

## List 최적화

- 더미 프로바이더를 생성하다.
- 리스트에서 아이템을 생성할때 더미 프로바이더에 아이템을 오버라이드 한다.
- 실제 아이템 위젯에서 더미 프로바이더를 watch 한다.

```dart
// 프로바이더
@Riverpod(dependencies: [])
Todo todoItem(TodoItemRef ref) {
  throw UnimplementedError();
}


// 아이템 오버라이드
class ShowTodos extends ConsumerWidget {
  const ShowTodos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterdTodos = ref.watch(filterdTodosProvider);
    return ListView.separated(
      itemCount: filterdTodos.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final todo = filterdTodos[index];
        return ProviderScope(
          overrides: [
            todoItemProvider.overrideWithValue(todo),
          ],
          child: const TodoItem(),
        );
      },
    );
  }
}

// 위젯에서 프로바이더 사용
class TodoItem extends ConsumerWidget {
  const TodoItem({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(todoItemProvider);

    return ListTile(...);
  }
}
```
