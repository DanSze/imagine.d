module main;

import std.stdio;
import std.format;
import std.file;
import std.algorithm;
import std.array;
import std.regex;
import std.datetime;
import std.random;

import dcv;
import imagine.d;

int maxSize;

auto loadImages() {
	return dirEntries("res/sources", SpanMode.shallow).map!( a => imread(a));
}

void main(string[] args) {
	auto images = loadImages;

	foreach (image; images) {

	}
}
