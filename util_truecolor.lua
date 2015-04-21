require "gd"
require "util_stat"

function histogram(image)
	local max_col, max_row = image:sizeXY()
	local histogram = {}
	for i = 0, 255 do
		histogram[i] = 0
	end

	for l = 0, max_col do
		for r = 0, max_row do
			local color = image:getPixel(l,r)
			--local r, g, b = image:red(color), image:green(color), image:blue(color)
			--local lum = math.floor(0.3 * r + 0.59 * g + 0.11 * b)
			local r = image:red(color)
			histogram[r] = histogram[r] + 1
		end
	end

	return histogram
end

function make_binary_from_truecolor(image)
	local h = histogram(image)
	local binary = {}

	local max_col, max_row = image:sizeXY()
	local thresold = otsu(h, max_row * max_col)

	local black = image:colorAllocate(0, 0, 0)
	local white = image:colorAllocate(255, 255, 255)
	local curc = 0

	for x = 0, max_col do
		binary[x] = {}
		for y = 0, max_row do
			local c = image:getPixel(x,y)
			local r = image:red(c)
			if r < thresold then
				binary[x][y] = true 
			else
				binary[x][y] = false
			end
		end
	end
	return binary, max_col, max_row
end
