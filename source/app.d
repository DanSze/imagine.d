module main;

import std.stdio;
import std.format;
import std.file;
import std.algorithm;
import std.array;
import std.regex;
import std.datetime;
import std.random;

import dsfml.graphics;
import imagine.d;

auto rx = regex(r".(bmp|dds|jpg|png|tga|psd)$");
int maxSize;

void cache() {
	Texture[] textures;
	maxSize = 0;
	Scaler s = new Scaler();
	foreach (file ; dirEntries("res/", SpanMode.shallow).filter!(a => a.isFile)) {
		if (file.name.matchAll(rx).empty)
			continue;
		Texture t = s.scaleUp(load(file.name));
		maxSize = maxSize < t.getSize().x ? t.getSize().x : maxSize;
		textures ~= t;
	}

	exists("res/rawcache") ? 0 : mkdir("res/rawcache"); //I am satan.
	exists("res/haarcache") ? 0 : mkdir("res/haarcache"); //I am satan.
	foreach (fileName, texture ; textures) {
		auto fn = "res/rawcache/%d.bmp".format(fileName);
		texture.save(fn);
		SplitImage i = SplitImage(fn);
		i.haar2d;
		i.save("res/haarcache/%d.bmp".format(fileName));
	}
}

Texture[] loadCache() {
	Texture[] textures;
	maxSize = 0;
	foreach (file ; dirEntries("res/haarcache", SpanMode.shallow).filter!(a => a.isFile)) {
		if (file.name.matchAll(rx).empty)
			continue;

		Texture t = load(file.name);
		maxSize = maxSize < t.getSize().x ? t.getSize().x : maxSize;
		textures ~= t;
	}
	return textures;
}

void main(string[] args) {
	if (args.length < 2 || args[1] != "--useCache") {
		cache();
	} else {
		writeln("Using cached stuff");
	}
	auto textures = loadCache();
	exists("res/outputs-haar") ? 0 : mkdir("res/outputs-haar"); //I am satan.
	exists("res/outputs") ? 0 : mkdir("res/outputs"); //I am satan.

	for (int j = 1; j <= 50; j++) {
		writefln("%d/50",j);
		Texture t = construct(textures.randomSample(3).array);

		string haarOut = "res/outputs-haar/out%02d.png".format(j)[0..26];
		t.save(haarOut);

		SplitImage i = SplitImage(haarOut);
		i.dehaar2d;

		string dehaarOut = "res/outputs/out%02d.png".format(j)[0..21];
		i.save(dehaarOut);
	}

}