import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';

extension _ on String {
  toSnakeCase() {
    return replaceAllMapped(
            RegExp(r'[A-Z]'), (Match match) => match.group(0)!.toLowerCase())
        .toLowerCase();
  }
}

extension _1 on String? {
  bool get safeIsNotEmpty {
    return this != null && this!.isNotEmpty;
  }
}

void main(List<String> args) async {
  FileSystemEntity entity = Directory.current;
  if (args.isNotEmpty) {
    String arg = args.first;
    entity = FileSystemEntity.isDirectorySync(arg) ? Directory(arg) : File(arg);
  }

  final collection = AnalysisContextCollection(
      includedPaths: [entity.absolute.path],
      resourceProvider: PhysicalResourceProvider.INSTANCE);

  final text = [];
  for (final context in collection.contexts) {
    print('Analyzing ${context.contextRoot.root.path} ...');

    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (!filePath.endsWith('.dart')) continue;

      final result = await context.currentSession.getResolvedUnit(filePath);
      if (result is! ResolvedUnitResult) continue;

      result.unit.declaredElement?.classes.forEach((classElement) {
        final className = classElement.name;
        final classDoc = classElement.documentationComment?.replaceAll('/', '');

        print('entity ${className.toSnakeCase()} {');
        text.add('entity ${className.toSnakeCase()} {');

        classElement.fields.where((f) => f.isFinal).forEach(
          (field) {
            final fieldDoc = field.documentationComment?.replaceAll('/', '');
            final fieldName = field.name;
            final fieldType =
                field.type.getDisplayString(withNullability: false);

            field.name;
            print(' ${fieldName} : ${fieldType} [${fieldDoc}]');
            text.add(' ${fieldName} : ${fieldType} [${fieldDoc}]');
          },
        );

        if (classDoc.safeIsNotEmpty) {
          print(' ${className} [${classDoc}]');
          text.add('\n---\n${classDoc}');
        }
        text.add('}\n');
      });
    }
  }

  if (text.isNotEmpty) {
    final output = [
      '@startuml',
      ...text,
      '@enduml',
    ];

    final file = File('output.txt');
    file.writeAsStringSync(output.join('\n'), mode: FileMode.write);
  }
}
