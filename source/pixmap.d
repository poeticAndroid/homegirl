module pixmap;

/**
	index-based pixel map
*/
class Pixmap
{
	uint width; /// width of pixel map
	uint height; /// height of pixel map
	ubyte fgColor = 1; /// index of foreground color
	ubyte bgColor = 0; /// index of background color
	ubyte[] pixels; /// all the pixels
	ubyte[] palette; /// the color palette

	/**
		create new pixmap
	*/
	this(uint width, uint height, ubyte colorBits)
	{
		this.width = width;
		this.height = height;
		this.pixels.length = this.width * this.height;
		uint colors = 1;
		for (ubyte i = 0; i < colorBits; i++)
			colors *= 2;
		this.palette.length = colors * 3;
		for (uint i = 0; i < this.pixels.length; i++)
		{
			this.pixels[i] = 0;
		}
		for (uint i = 3; i < this.palette.length; i++)
		{
			this.palette[i] = cast(ubyte)((i * 255) / this.palette.length);
		}
	}

	/**
		edit a color in the color palette
	*/
	void setColor(uint index, ubyte red, ubyte green, ubyte blue)
	{
		uint i = 3 * index;
		this.palette[i + 0] = (red % 16) * 17;
		this.palette[i + 1] = (green % 16) * 17;
		this.palette[i + 2] = (blue % 16) * 17;
	}

	/**
		get color of specific pixel
	*/
	ubyte pget(uint x, uint y)
	{
		if (x >= this.width || y >= this.height)
			return 0;
		const i = y * this.width + x;
		return this.pixels[i];
	}

	/**
		set color of specific pixel
	*/
	void pset(uint x, uint y)
	{
		if (x >= this.width || y >= this.height)
			return;
		uint i = y * this.width + x;
		this.pixels[i] = this.fgColor;
	}

}
