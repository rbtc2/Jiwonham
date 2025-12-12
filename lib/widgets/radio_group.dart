// CustomRadioGroup 위젯
// RadioListTile들을 그룹화하여 관리하는 위젯
// InheritedWidget을 사용하여 하위 RadioListTile들과 상태를 공유

import 'package:flutter/material.dart';

class CustomRadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget child;

  const CustomRadioGroup({
    super.key,
    required this.groupValue,
    this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _RadioGroupScope<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }
}

class _RadioGroupScope<T> extends InheritedWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  const _RadioGroupScope({
    required this.groupValue,
    this.onChanged,
    required super.child,
  });

  static _RadioGroupScope<T>? _maybeOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_RadioGroupScope<T>>();
  }

  @override
  bool updateShouldNotify(_RadioGroupScope<T> oldWidget) {
    return groupValue != oldWidget.groupValue ||
        onChanged != oldWidget.onChanged;
  }
}

// RadioListTile을 RadioGroup과 함께 사용할 수 있도록 확장
// RadioListTile이 RadioGroup 내부에 있을 때 자동으로 groupValue와 onChanged를 연결
extension RadioListTileInGroup<T> on RadioListTile<T> {
  Widget buildInGroup(BuildContext context) {
    final scope = _RadioGroupScope._maybeOf<T>(context);
    if (scope == null) {
      // RadioGroup 밖에 있으면 원래대로 동작
      return this;
    }

    // RadioGroup 내부에 있으면 groupValue와 onChanged를 연결
    return RadioListTile<T>(
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      isThreeLine: isThreeLine,
      dense: dense,
      shape: shape,
      selectedTileColor: selectedTileColor,
      value: value,
      groupValue: scope.groupValue,
      onChanged: (value) {
        scope.onChanged?.call(value);
      },
      toggleable: toggleable,
      activeColor: activeColor,
      contentPadding: contentPadding,
      visualDensity: visualDensity,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}

