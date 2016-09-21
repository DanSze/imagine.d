module imagine.transform;

import std.algorithm;
import std.array;
import std.conv;
import std.experimental.ndslice;
import std.range;
import std.traits;
import std.string;

import dcv.core;
import dcv.imgproc;
import imagine.util;

auto binarize(Image img, float sensitivity) {
    ulong divisor = floor(img.width*img.height*sensitivity).to!ulong;
    auto slice = img.sliced;
    for (int i = 0; i < img.channels; i++) {
        auto sl = slice[0..$, 0..$, i];
        auto avg = min(255, size_t(0).ndReduce!"a + b"(sl)/divisor);
        sl[] = sl.threshold!ubyte(avg.to!ubyte)[];    
    }

    return slice.asImage(img.format);
}
