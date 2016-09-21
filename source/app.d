module main;

import std.stdio;
import std.format;
import std.file;
import std.algorithm;
import std.array;
import std.regex;
import std.datetime;
import std.random;

import dcv.core;
import dcv.io;
import imagine.d;

int maxSize;

auto loadImages() {
	return dirEntries("res/sources", SpanMode.shallow)
		.map!(a => imread(a));
}

void main(string[] args) {
	foreach (dir; dirEntries("res/sources", SpanMode.shallow)) {
		writeln(dir);
	}

	ubyte sensitivity = args.length > 1 ? args[1].to!ubyte : 50;

	auto images = loadImages.map!(a => a.binarize(sensitivity));

	exists("res/outputs") ? 0 : mkdir("res/outputs"); //I am satan.

	int i = 0;
	foreach (image; images) {
		auto dir = format("res/outputs/%d.png", i++)
		writeln(dir);
		imwrite(image, dir);
	}
}
