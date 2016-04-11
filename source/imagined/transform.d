module imagine.transform;

import std.algorithm;
import std.array;
import std.conv;
import std.experimental.ndslice;
import std.range;
import std.traits;

import dsfml.graphics;
import dsfml.system;
import imagine.util;

///For haaring po2 images
struct SplitImage {

	Slice!(2, double*) rgb;
	uint size;

	this(string path) {
		Image i = new Image();
		i.loadFromFile(path);

		Vector2u dim = i.getSize();

		rgb = i.getPixelArray().map!(a => a/255.0).array.sliced(dim.x*dim.y, 4).transposed;

		size = dim.x;
	}

	void save (string path) {
		Image i = new Image();
		ubyte[] data = rgb.transposed.byElement.map!(a => cast(ubyte)(a*0xFF)).array;

		i.create(size, size, data);
		i.saveToFile(path);
	}

	void haar2d () {
		for (int i = 0; i < 4; i++) {
			rgb[i][] = rgb[i].byElement.array.fwt97(size, size);
		}
	}

	void dehaar2d () {
		for (int i = 0; i < 4; i++) {
			rgb[i][] = rgb[i].byElement.array.ifwt97(size, size);
		}
	}
}

T[] fwt97(T, Dimensions...)(T[] input, Dimensions dimensions)
    if(isNumeric!T && Dimensions.length > 0)
in
{
    assert(input.length > 1, "Input length must be greater than 1.");
    assert((input.length & (input.length - 1)) == 0, "Input length is not power of 2.");
}
body
{
    auto shape = input
        .sliced(dimensions)
        .shape;

    foreach(index; shape.length.iota)
    {
        auto s = input
            .chunks(shape[$ - 1])
            .map!(chunk => chunk.rfwt97)
            .reduce!"a ~ b"
            .sliced(shape)
            .transposed(Dimensions.length - 1);

        input = s.byElement.array;
        shape = s.shape;
    }

    return input;
}

T[] rfwt97(T)(T[] input) if(isNumeric!T)
in
{
    assert(input.length > 1, "Input length must be greater than 1.");
    assert((input.length & (input.length - 1)) == 0, "Input length is not power of 2.");
}
body
{
	int size = input.length;

	for (int i = size; i > 2; i /= 2)
	{
		input = input[0..i].fwt97
	}

	return input
}

T[] fwt97(T)(T[] input) if(isNumeric!T)
in
{
    assert(input.length > 1, "Input length must be greater than 1.");
    assert((input.length & (input.length - 1)) == 0, "Input length is not power of 2.");
}
body
{
    static if(!is(T == double))
    {
        double[] data = input.map!(to!double).array;
    }
    else
    {
        double[] data = input.dup;
    }

    // - Predict 1 - //

    {
        enum double a = -1.586134342;

        for(auto index = 1; index < data.length - 2; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[$ - 1] += 2 * a * data[$ - 2];
    }

    // - Update 1 - //

    {
        enum double a = -0.05298011854;

        for(auto index = 2; index < data.length; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[0] += 2 * a * data[1];
    }

    // - Predict 2 - //

    {
        enum double a = 0.8829110762;

        for(auto index = 1; index < data.length - 2; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[$ - 1] += 2 * a * data[$ - 2];
    }

    // - Update 2 - //

    {
        enum double a = 0.4435068522;

        for(auto index = 2; index < data.length; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[0] += 2 * a * data[1];
    }

    // - Scale - //

    {
        enum double a = 1 / 1.149604398;

        foreach(index; 0 .. data.length)
        {
            if(index % 2 == 1)
            {
                data[index] *= a;
            }
            else
            {
                data[index] /= a;
            }
        }
    }

    // - Pack - //

    T[] output = new T[data.length];

    foreach(index; 0 .. data.length)
    {
        if(index % 2 == 0)
        {
            output[index / 2] = cast(T) data[index];
        }
        else
        {
            output[index / 2 + data.length / 2] = cast(T) data[index];
        }
    }

    return output;
}

T[] ifwt97(T, Dimensions...)(T[] input, Dimensions dimensions)
    if(isNumeric!T && Dimensions.length > 0)
in
{
    assert(input.length > 1, "Input length must be greater than 1.");
    assert((input.length & (input.length - 1)) == 0, "Input length is not power of 2.");
}
body
{
    auto shape = input
        .sliced(dimensions)
        .shape;

    foreach(index; shape.length.iota)
    {
        auto s = input
            .chunks(shape[$ - 1])
            .map!(chunk => chunk.rifwt97)
            .reduce!"a ~ b"
            .sliced(shape)
            .transposed(Dimensions.length - 1);

        input = s.byElement.array;
        shape = s.shape;
    }

    return input;
}

T[] rifwt97(T)(T[] input) if(isNumeric!T)
in
{
    assert(input.length > 1, "Input length must be greater than 1.");
    assert((input.length & (input.length - 1)) == 0, "Input length is not power of 2.");
}
body
{
	int size = input.length;

	for (int i = 4; i <= size; i *= 2)
	{
		input = input[0..i].ifwt97
	}

	return input
}

T[] ifwt97(T)(T[] input) if(isNumeric!T)
in
{
    assert(input.length > 1, "Input length must be greater than 1.");
    assert((input.length & (input.length - 1)) == 0, "Input length is not power of 2.");
}
body
{
    // - Unpack - //

    double[] data = new double[input.length];

    foreach(index; 0 .. data.length / 2)
    {
        data[index * 2 + 0] = input[index + 0];
        data[index * 2 + 1] = input[index + $ / 2];
    }

    // - Reverse Scale - //

    {
        enum double a = 1.149604398;

        foreach(index; 0 .. data.length)
        {
            if(index % 2 == 1)
            {
                data[index] *= a;
            }
            else
            {
                data[index] /= a;
            }
        }
    }

    // - Reverse Update 2 - //

    {
        enum double a = -0.4435068522;

        for(auto index = 2; index < data.length; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[0] += 2 * a * data[1];
    }

    // - Reverse Predict 2 - //

    {
        enum double a = -0.8829110762;

        for(auto index = 1; index < data.length - 2; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[$ - 1] += 2 * a * data[$ - 2];
    }

    // - Reverse Update 1 - //

    {
        enum double a = 0.05298011854;

        for(auto index = 2; index < data.length; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[0] += 2 * a * data[1];
    }

    // - Reverse Predict 1 - //

    {
        enum double a = 1.586134342;

        for(auto index = 1; index < data.length - 2; index += 2)
        {
            data[index] += a * (data[index - 1] + data[index + 1]);
        }

        data[$ - 1] += 2 * a * data[$ - 2];
    }

    // - Result - //

    static if(!isFloatingPoint!T)
    {
        return data.map!(to!T).array;
    }
    else
    {
        return data;
    }
}