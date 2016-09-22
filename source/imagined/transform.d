module imagine.transform;

import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.traits;
import std.math;
import std.string;

import dcv.core;
import dcv.imgproc;
import imagine.util;

const blockWidth = 50;

auto binarize(Image img, float sensitivity) {
    auto iSlice = img.sliced;
    for (int i = 0; i < img.channels; i++) {
        auto sl = iSlice[0..$, 0..$, i];
        auto avg = min(255, sl.byElement.reduce!"a+b"/sl.elementsCount*sensitivity);
        auto slMask = sl.threshold!ubyte((avg).to!ubyte);
	sl[] &= slMask;
    }

    return iSlice.asImage(img.format);
}
