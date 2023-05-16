import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_style/dart_style.dart';

void main(List<String> args) async {
  final formatter = DartFormatter();

  FileSystemEntity entity = Directory.current;
  if (args.isNotEmpty) {
    String arg = args.first;
    entity = FileSystemEntity.isDirectorySync(arg) ? Directory(arg) : File(arg);
  }

  final collection = AnalysisContextCollection(
      includedPaths: [entity.absolute.path],
      resourceProvider: PhysicalResourceProvider.INSTANCE);

  for (final context in collection.contexts) {
    print('Analyzing ${context.contextRoot.root.path} ...');

    for (final filePath in context.contextRoot
        .analyzedFiles()
        .where((path) => !path.endsWith('dart'))) {
      final result = await context.currentSession.getResolvedUnit(filePath);

      if (result is ResolvedUnitResult) {
        for (final classElement in result.unit.declaredElement?.classes ?? []) {
          print('  ${classElement.name}');
          for (final field in classElement.fields) {
            final docComment = field.documentationComment;
            final fieldName = field.name;
            final fieldType =
                field.type.getDisplayString(withNullability: false);
            print(
                '${docComment != null ? formatter.format('//$docComment') : ''}\n  ${fieldName} : ${fieldType}');
          }
        }
      }
    }
  }
}
