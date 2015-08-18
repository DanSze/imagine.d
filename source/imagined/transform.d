module imagine.transform;

import std.algorithm;
import std.range;

import dsfml.graphics;
import dsfml.system;
import imagine.util;

///For haaring po2 images
struct SplitImage {

	float[][][] rgb;
	uint size;

	this(string path) {
		Image i = new Image();
		i.loadFromFile(path);

		Vector2u dim = i.getSize();

		rgb = i.getPixelArray().map!(a => a/255f).array.chunks(4).array.chunks(dim.x).array;
		assert(rgb.length == dim.y);

		size = dim.x;
	}

	this(SplitImage img) {
		size = img.size;
		rgb.length = size;
		for (int y = 0; y < size; y++) {
			rgb[y].length = size;
			for (int x = 0; x < size; x++) {
				rgb[y][x].length = 4;
				rgb[y][x][0] = img.rgb[y][x][0];
				rgb[y][x][1] = img.rgb[y][x][1];
				rgb[y][x][2] = img.rgb[y][x][2];
				rgb[y][x][3] = img.rgb[y][x][3];
			}
		}
	}

	void save (string path) {
		Image i = new Image();
		float[] flatRgb;
		foreach (row ; rgb) {
			foreach (pixel ; row) {
				flatRgb ~= pixel;
			}
		}
		ubyte[] data = flatRgb.map!(a => cast(ubyte)(a*0xFF)).array;

		i.create(size, size, data);
		i.saveToFile(path);
	}

	void haar2d () {
		SplitImage buf = SplitImage(this);
		haar2d(size, 0, buf);
		haar2d(size, 1, buf);
		haar2d(size, 2, buf);
	}

	void dehaar2d () {
		SplitImage buf = SplitImage(this);
		dehaar2d(4, 0, buf);
		dehaar2d(4, 1, buf);
		dehaar2d(4, 2, buf);
	}

	private:
	void haar2d (uint bounds, uint index, SplitImage buf) {
		if (bounds == 2)
			return;
		for (int x = 0; x < bounds; x++) {
			for (int y = 0; y < bounds/2; y++) {
				buf.rgb[y][x][index] = (rgb[y*2][x][index] + rgb[y*2 + 1][x][index])/2f;
				buf.rgb[y + bounds/2][x][index] = (rgb[y*2][x][index] - rgb[y*2 + 1][x][index])/2f;
			}
		}
		cloneRgb(buf);
		for (int y = 0; y < bounds; y++) {
			for (int x = 0; x < bounds/2; x++) {
				buf.rgb[y][x][index] = (rgb[y][x*2][index] + rgb[y][x*2 + 1][index])/2f;
				buf.rgb[y][x + bounds/2][index] = (rgb[y][x*2][index] - rgb[y][x*2 + 1][index])/2f;
			}
		}
		cloneRgb(buf);
		haar2d(bounds/2, index, buf);
	}

	void dehaar2d (uint bounds, uint index, SplitImage buf) {
		if (bounds > size)
			return;
		for (int x = 0; x < bounds; x++) {
			for (int y = 0; y < bounds/2; y++) {
				buf.rgb[y*2][x][index]   = rgb[y][x][index] + rgb[y + bounds/2][x][index];
				buf.rgb[y*2+1][x][index] = rgb[y][x][index] - rgb[y + bounds/2][x][index];
			}
		}
		cloneRgb(buf);
		for (int y = 0; y < bounds; y++) {
			for (int x = 0; x < bounds/2; x++) {
				buf.rgb[y][x*2][index]   = rgb[y][x][index] + rgb[y][x + bounds/2][index];
				buf.rgb[y][x*2+1][index] = rgb[y][x][index] - rgb[y][x + bounds/2][index];
			}
		}
		cloneRgb(buf);
		dehaar2d(bounds*2, index, buf);
	}

	void cloneRgb(SplitImage img) {
		for (int y = 0; y < size; y++) {
			for (int x = 0; x < size; x++) {
				rgb[y][x][] = img.rgb[y][x].dup;
			}
		}
	}
}

