// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'assignment_test.dart' as assignment_test;
import 'class_test.dart' as class_test;
import 'for_in_test.dart' as for_in_test;
import 'mixin_test.dart' as mixin_test;

main() {
  defineReflectiveSuite(() {
    assignment_test.main();
    class_test.main();
    for_in_test.main();
    mixin_test.main();
  }, name: 'resolution');
}
