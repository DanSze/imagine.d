module imagine.transform;

import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.random;
import std.math;
import std.string;
import std.stdio;

import dcv.core;
import dcv.imgproc;
import imagine.util;

const windowSize = 7;
const hiddenNeurons = 9;

auto improve(Image img, float sensitivity) {
    auto slice = img.sliced;
    
    return slice.asImage(img.format);
}

ubyte computeNN(Slice!(2,ubyte) window, Slice!(1, float) params) {
    auto paramMatrix = params[0..windowSize*windowSize*hiddenNeurons].reshape(windowSize*windowSize, hiddenNeurons);
    auto paramHidden = params[windowSize*windowSize*hiddenNeurons .. $];
    return window.byElements * paramMatrix * paramHidden;
}

auto crossOverParams(Slice!(1, float) params1, Slice!(1, float) params2) {
    auto crossoverPoint = uniform(0, params.elementsCount);
    return params1[0..crossoverPoint] ~ params2[crossoverPoint..$];
}

auto fitness(Slice(2, ubyte) img, Slice!(1, float) params) {
    auto target = img.windows(windowSize, windowSize)
            .byElements
            .map!(a => a[windowSize/2, windowSize/2])
            .array;
    auto result = img.windows(windowSize, windowSize)
            .byElements
            .map!(a => a.computeNN(params))
            .array;
    auto diff = target[] - resutl[];
    return (diff[] * diff[]).sum;
}