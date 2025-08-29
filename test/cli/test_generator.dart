import 'dart:io';

import 'package:test/test.dart';
import 'package:bloc_testmate/src/cli/test_generator.dart';
import 'package:bloc_testmate/src/cli/bloc_scanner.dart';

void main() {
  test(
    'generates placeholder test file with success and error scenarios',
    () async {
      final tempDir = await Directory.systemTemp.createTemp();
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final libDir = Directory('${tempDir.path}/lib');
      await libDir.create(recursive: true);

      final blocFile = File('${libDir.path}/sample_bloc.dart');
      await blocFile.writeAsString('''
import 'package:bloc/bloc.dart';

class SampleEvent {}
class SampleState {}

class SampleBloc extends Bloc<SampleEvent, SampleState> {
  SampleBloc() : super(SampleState());

  @override
  Stream<SampleState> mapEventToState(SampleEvent event) async* {}
}
''');

      final info = BlocInfo(name: 'SampleBloc', path: blocFile.path);
      await generate(info, testDirectory: '${tempDir.path}/test');

      final generated = File('${tempDir.path}/test/sample_bloc_test.dart');
      expect(generated.existsSync(), isTrue);
      final content = await generated.readAsString();
      expect(content, contains('success scenario'));
      expect(content, contains('error scenario'));
      expect(content, contains('BlocTestMate<SampleBloc, SampleState>()'));
    },
  );
}
