require "gd"
require "util_truecolor"
require "util_bin"

local W9 = {{1,1,1},{1,1,1},{1,1,1}}
local W = {}

local P2 = math.sqrt(2)
local P8 = math.sqrt(8)

W[1] = {{1, P2, 1}, {0,0,0}, {-1, -1 * P2, -1}}
W[2] = {{1, 0, -1}, {P2,0, -1 * P2}, {1, 0, -1}}
W[3] = {{0, -1, P2}, {1,0,-1}, {-1 * P2, 1, 0}}
W[4] = {{P2, -1, 0}, {-1,0,1}, {0, 1, -1 * P2}}
W[5] = {{0, 1, 0}, {-1,0,-1}, {0, 1, 0}}
W[6] = {{-1, 0, 1}, {0,0,0}, {1, 0, -1}}
W[7] = {{1, -2, 1}, {-2,4,-2}, {1, -2, 1}}
W[8] = {{-2, 1, -2}, {1,4,1}, {-2, 1, -2}}

local Wm = { 1 / P8,1 / P8,1 / P8,1 / P8, 0.5, 0.5, 1/6, 1/6 }

function scal_v(U,V, m)
	local R = 0
	for x = 1, 3 do
		for y = 1, 3 do
			R = R + U[x][y] * V[x][y]
		end
	end
	return R * m
end

function compute_using_basis(IN, r, c, S, thresh, noise)
	local N = {}
	for x = -1, 1 do
		N[x + 2] = {}
		for y = -1, 1 do
			if IN[r + x][c + y] == false then
				N[x + 2][y + 2] = 0
			else
				N[x + 2][y + 2] = 1
			end
		end
	end
	local avg_energy = scal_v(N, W9, 1/3)
	local subspace_energy = 0
	for j = 1, 8 do
		if S[j] then
			local x = scal_v(N, W[j], Wm[j])
			subspace_energy = subspace_energy + x * x
		end
	end
	if subspace_energy < noise then
		return false
	end
	local thresh_test = subspace_energy / (scal_v(N,N,1) - avg_energy)
	if thresh_test < thresh then
		return false
	end
	return true
end



function detect_neighborhoods(F, S, thresh, noise)
	local G = {}
	for r = 0, MaxRow do
		G[r] = {}
		for c = 0, MaxCol do
			if (r < 2 or 
				r > MaxRow - 2 or
				c < 2 or
				c > MaxCol - 2) then
				G[r][c] = false
			else
				G[r][c] = compute_using_basis(F, r,c, S, thresh, noise)
			end
		end
	end
	return G
end

function make_pic_appl(image_s, bin, max_col, max_row, filename)
	local image = gd.createTrueColor(max_col, max_row)
	local white = image:colorAllocate(255, 255, 255)
	for x = 0, max_col do
		for y = 0, max_row do
			if bin[x][y] then
				image:setPixel(x, y, white)
			else
				local c = image_s:getPixel(x, y)
				image:setPixel(x, y, c)
			end
		end
	end
	image:png(filename)
end

local filename = arg[1]
local ext = string.sub(filename, -3)
local name = string.sub(filename, 1, -5)
local image_start = nil

if ext == 'png' then
	image_start = gd.createFromPng(filename)
elseif ext == 'jpg' then
	image_start = gd.createFromJpeg(filename)
else
	print("Unknown filetype:" .. ext)
	os.exit()
end

local threshold = tonumber(arg[2])
if threshold == nil then threshold = 0.9 end

local noise = tonumber(arg[3])
if noise == nil then noise = 0.1 end


Image, MaxRow, MaxCol= make_binary_from_truecolor(image_start)
local M = {1,1,1,1,1,1,1,1};
local G = detect_neighborhoods(Image, M, threshold, noise)
make_pic_appl(image_start, G, MaxRow, MaxCol, "mut/" .. name .. "_resultt" .. threshold .. "n" .. noise .. ".png")
