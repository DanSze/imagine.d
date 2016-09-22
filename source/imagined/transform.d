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

auto filter(Image img, float sensitivity) {
    auto slice = img.sliced;
    auto avgs = new float[img.channels];
    for (int i = 0; i < img.channels; i++) {

        auto sl = slice[0..$, 0..$, i];
        avgs[i] = min(255, sl.byElement.reduce!"a+b"/sl.elementsCount*sensitivity);
    } 

    auto avg = avgs.reduce!"a+b"/avgs.length;
    
    for (int i = 0; i < img.channels; i++) {
        auto sl = slice[0..$, 0..$, i];
        avgs[i] = min(255, sl.byElement.reduce!"a+b"/sl.elementsCount*sensitivity);
        auto slMask = sl.threshold!ubyte((avgs[i]).to!ubyte);

        sl[] &= slMask;
    }


    return slice.asImage(img.format);
}
