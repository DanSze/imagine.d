module imagine.util;

import std.algorithm;

///The highest bit.
const(uint) maxBit = 0x80000000;

///Return the largest Power of 2 that fits in the i.
uint maxPo2 (uint i) {
	uint mask = maxBit;
	while (!(mask&i))
		mask >>= 1;
	return mask;
}