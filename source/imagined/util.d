module imagine.util;

import std.algorithm;

import dsfml.graphics;
import dsfml.system;

///The highest bit.
const(uint) maxBit = 0x80000000;

///Return the largest Power of 2 that fits in the i.
uint maxPo2 (uint i) {
	uint mask = maxBit;
	while (!(mask&i))
		mask >>= 1;
	return mask;
}

Texture load(string path) {
	Texture t = new Texture();
	t.loadFromFile(path);
	return t;
}

void save(Texture t, string path) {
	Image i = t.copyToImage();
	i.saveToFile(path ~ "\0");
}

class Scaler {
	private RenderTexture renderer;
	private Sprite renderSprite;

	this() {
		renderSprite = new Sprite();
		renderer = new RenderTexture();
	}

	///Make the image Po2 size, and make it 2^n times as large.
	Texture scaleTo (Texture t, uint n) {
		Vector2u size = t.getSize();
		uint s = min(size.x, size.y);
		uint news = maxPo2(s) * (2^^n);
		float scale = (cast(float) news)/s;

		renderSprite.textureRect = IntRect(0, 0, s, s);
		renderSprite.scale = Vector2f(scale, -scale);
		renderSprite.origin = Vector2f(0, s);


		renderer.create(news, news);

		renderSprite.setTexture(t);
		renderer.draw(renderSprite);

		return renderer.getTexture().dup;
	}

	Texture scaleUp (Texture t) {
		Vector2u size = t.getSize();
		uint s = min(size.x, size.y);

		if (s == maxPo2(s))
			return (scaleTo(t, 0));
		return scaleTo(t, 1);
	}
}