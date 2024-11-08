import 'package:flutter/material.dart';
import 'package:tolu_7/data/models/todo.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final Function(Todo) onUpdate;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}
bool _isVisible = true;
class _TodoItemState extends State<TodoItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkAnimation;
  bool _isDisappearing = false;
  bool _isChecked = false;
    // New flag to control visibility

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _isChecked = widget.todo.isCompleted;
    _isVisible = !widget.todo.isCompleted;  // Hide if already completed
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleComplete() async {
    setState(() {
      _isChecked = true;
    });

    // Update todo in database
    final updatedTodo = Todo(
      id: widget.todo.id,
      title: widget.todo.title,
      description: widget.todo.description,
      isCompleted: true,
      createdAt: widget.todo.createdAt,
    );

    widget.onUpdate(updatedTodo);

    // Wait for checkbox animation
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Start disappearing animation
    setState(() {
      _isDisappearing = true;
    });

    // Start slide out animation
    await _controller.reverse();

    // Hide the widget but don't delete
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();  // Return empty widget if not visible
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Dismissible(
            key: Key(widget.todo.id),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                widget.onDelete();
                return true;
              } else if (direction == DismissDirection.startToEnd) {
                _handleComplete();
                return false;
              }
              return false;
            },
            background: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            secondaryBackground: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 32,
              ),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isDisappearing ? 0.0 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      if (value == true) {
                        _handleComplete();
                      }
                    },
                  ),
                  title: Text(
                    widget.todo.title,
                    style: TextStyle(
                      decoration: _isChecked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: _isChecked ? Colors.grey : const Color(4283196971),
                    ),
                    child: Text(widget.todo.description),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(widget.todo.title),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.todo.description),
                              const SizedBox(height: 8),
                              Text(
                                'Created: ${widget.todo.createdAt.toString().split('.')[0]}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}