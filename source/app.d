module main;

import std.stdio;
import std.format;
import std.file;
import std.algorithm;
import std.regex;
import std.datetime;

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

void update (RenderWindow window, Sprite spr) {
    window.clear();
    window.draw(spr);
    window.display();
}

void main(string[] args) {
	if (args.length < 0 || args[0] != "cached") {
		cache();
	}
	auto textures = loadCache();
	auto window = new RenderWindow(VideoMode(maxSize,maxSize),"Progress View");
	Sprite spr = new Sprite();

	exists("res/outputs-haar") ? 0 : mkdir("res/outputs-haar"); //I am satan.
	exists("res/outputs") ? 0 : mkdir("res/outputs"); //I am satan.

	for (int j = 0; j < 20; j++) {
		Texture t = construct(textures);

		auto haarOut = "res/outputs-haar/out%d.bmp".format(j);
		auto dehaarOut = "res/outputs/out%d.bmp".format(j);
		t.save(haarOut);

		SplitImage i = SplitImage(haarOut);
		i.dehaar2d;
		i.save(dehaarOut);

		spr.setTexture(load(dehaarOut));
		window.update(spr);
	}

    while (window.isOpen())
    {
        Event event;

        while(window.pollEvent(event))
        {
            if(event.type == event.EventType.Closed)
            {
                window.close();
            }
        }
    }
}