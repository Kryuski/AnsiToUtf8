# ANSI to UTF-8 File Converter

Command-line utility to convert ANSI-encoded files to UTF-8 with a BOM (Byte Order Mark).

## Installation

No installation required. Just download `AnsiToUtf8.exe` and run it from the command line.

## Usage

```text
AnsiToUtf8 <file_mask> [codepage]
```

where:

- `file_mask` — file name or mask of files to convert, e.g. `source.pas` or `*.pas`.
- `codepage` — source ANSI code page. Defaults to 1251.

Examples:

```bat
AnsiToUtf8 source.pas
AnsiToUtf8 *.pas
AnsiToUtf8 Source\*.pas 1252
```

## Features

- Converts a single file or multiple files matching a mask.
- Adds a UTF-8 BOM (`EF BB BF`) to converted files.
- Skips files that already have a UTF-8 BOM.
- Creates a `.bak` backup of the original file before conversion.

The utility can also be used in batch files for bulk conversion.
