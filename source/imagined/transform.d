module imagine.transform;

import std.algorithm;
import std.array;
import std.conv;
import std.experimental.ndslice;
import std.range;
import std.traits;
import std.string;

import dcv;
import imagine.util;

auto binarize(Image i) {
    return i.sliced.theshold!float(0.5, 1);
}