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
		.filter!(a => a.isFile())
		.map!   (a => imread(a.name));
}

void main(string[] args) {
	foreach (dir; dirEntries("res/sources", SpanMode.shallow)) {
		writeln(dir.name);
	}

	//auto images = loadImages.map!(a => a.binarize);

	exists("res/outputs") ? 0 : mkdir("res/outputs"); //I am satan.

	int i = 0;
	//foreach (image; images) {
	//	imwrite(image, format("res/outputs/%d.png", i++));
	//}
}
