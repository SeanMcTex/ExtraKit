#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

var outputString = "// autogenerated by genswiftstrings.swift\n\nimport Foundation\nimport ExtraKit\n\n"

var enumName = "Strings"
var tableName = "nil"

func generateStringsSourceFile(_ stringsPath: String) {
	let tmpPath = "/var/tmp/strings.plist"
	systemcommand(["/usr/bin/plutil", "-convert", "binary1", stringsPath, "-o", tmpPath])
	guard let stringsDict = NSDictionary(contentsOfFile: tmpPath)
	, stringsDict.count > 0 else {
		return
	}
	
	let fileName = URL(fileURLWithPath: stringsPath).lastPathComponent
	outputString += "/**\n"
	outputString += "\tThese are generated from \(fileName). Call localized() to get the localized string.\n";
	outputString += "*/\n"
	outputString += "enum \(enumName): String, Localizable"
	if tableName != "nil" {
		outputString += ", StringTable {\n\n"
	} else {
		outputString += " {\n\n"
	}
	stringsDict.allKeys.forEach {
		if let s = $0 as? String, validSwiftString(s) {
			outputString += "\tcase \(s)\n"
		}
	}
	if tableName != "nil" {
		outputString += "\n\tvar tableName: String? { return \(tableName) }\n"
	}
	outputString += "}\n"
}

func systemcommand(_ args: [String]) {
	let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
}

func validSwiftString(_ string: String) -> Bool {
	guard !string.isEmpty else {
		return false
	}
	let invalidSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).inverted
	if string.rangeOfCharacter(from: invalidSet) != nil {
		return false
	}
	if let first = string.unicodeScalars.first, CharacterSet.decimalDigits.contains(first) {
		return false
	}
	return true
}

func generateFormatStringsSourceFile(_ stringsDictPath: String) {
	guard let stringsDict = NSDictionary(contentsOfFile: stringsDictPath)
	, stringsDict.count > 0 else {
		return
	}
	
	outputString += "\nenum Format\(enumName): String, Localizable {\n\n"

	stringsDict.allKeys.forEach {
		if let s = $0 as? String, validSwiftString(s) {
			outputString += "\tcase \($0)\n"
		}
	}
	outputString += "}\n"
}

if CommandLine.arguments.count >= 5 {
	enumName = CommandLine.arguments[4]
}

if CommandLine.arguments.count >= 6 {
	tableName = "\"\(CommandLine.arguments[5])\""
}

let outputPath = CommandLine.arguments[2]

generateStringsSourceFile(CommandLine.arguments[1])

if CommandLine.arguments.count >= 4 {
	generateFormatStringsSourceFile(CommandLine.arguments[3])
}

try! outputString.write(toFile: outputPath, atomically: true, encoding: String.Encoding.utf8)
