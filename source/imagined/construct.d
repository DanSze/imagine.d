module imagine.construct;

import std.random;
import std.algorithm;
import std.range;
import std.exception;

import imagine.util;
import dsfml.graphics;

Texture construct (Texture[] donor) {
	uint s = donor[0].getSize().x;
	RenderTexture reciever = new RenderTexture();
	reciever.create(s,s);

	Sprite renderSprite = new Sprite();
	renderSprite.scale = Vector2f(1, -1);
	renderSprite.origin = Vector2f(0, s);

	for(; s > 2; s /= 2) {
		Texture t;
		while ((t = donor[uniform(0, donor.length)]).getSize.x < s){}
		renderSprite.textureRect = IntRect(0, 0, s, s);
		renderSprite.setTexture(t);
		reciever.draw(renderSprite);	
	}

	return reciever.getTexture().dup;
}