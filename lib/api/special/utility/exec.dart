import 'dart:io';

Future<String> execApi(String command) async {
  if (command.trim().isEmpty) {
    throw ArgumentError('Command cannot be empty');
  }

  try {
    // Split the command string into executable and arguments
    final parts = command.split(' ');
    final executable = parts.first;
    final arguments = parts.skip(1).toList();

    // Start the process
    final process = await Process.start(
      executable, // The executable
      arguments, // The arguments
    );

    // Capture stdout and stderr
    final stdout =
        await process.stdout.transform(SystemEncoding().decoder).join();
    final stderr =
        await process.stderr.transform(SystemEncoding().decoder).join();

    // Wait for the process to complete
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw ProcessException(
        executable,
        arguments,
        stderr,
        exitCode,
      );
    }

    return stdout;
  } catch (e) {
    throw Exception('Failed to execute command: $e');
  }
}
