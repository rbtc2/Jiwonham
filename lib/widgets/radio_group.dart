// CustomRadioGroup 위젯
// Flutter의 표준 RadioGroup을 래핑한 위젯
// RadioListTile들을 그룹화하여 관리하는 위젯

import 'package:flutter/material.dart';

// Flutter의 표준 RadioGroup을 CustomRadioGroup으로 export
export 'package:flutter/material.dart' show RadioGroup;

// CustomRadioGroup은 Flutter의 표준 RadioGroup의 별칭
typedef CustomRadioGroup<T> = RadioGroup<T>;

