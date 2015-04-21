function erosion(binary_image, max_col, max_row, struct_elem, smax_col, smax_row)
	local result = {}
	for i = 0, max_col do
		result[i] = {} 
		for j = 0, max_row do
			result[i][j] = false
		end
	end
	local cx = math.floor(smax_col / 2)
	local cy = math.floor(smax_row / 2)
	for i = 0, max_col do
		--print(i)
		for j = 0, max_row do
			if i - cx >= 0 and j - cy >= 0 and i + cx < max_col and j + cy < max_row then
				local is_equal = true 
				for m = -1 * cx, 1 * cx do
					for n = -1 * cy, 1 * cy do
						if not struct_elem[cx + m] then
							print(cx + m, cx, m, smax_col)
						end
						if not binary_image[i + m] or binary_image[i + m][j + n] ~= struct_elem[cx + m][cy + n] then
							is_equal = false 
							break
						end
					end
					if not is_equal then
						break
					end
				end
				if is_equal then
					result[i][j] = result[i][j] or struct_elem[cx][cy]
				end
			end
		end
	end
	return result
end

function make_pic(bin, max_col, max_row, filename)
	local image = gd.create(max_col, max_row)
	local black = image:colorAllocate(0, 0, 0)
	local white = image:colorAllocate(255, 255, 255)
	for x = 0, max_col do
		for y = 0, max_row do
			if bin[x][y] then
				image:setPixel(x, y, white)
			else
				image:setPixel(x, y, black)
			end
		end
	end
	image:png(filename)
end

local max_col, max_row

function recursive_connected_components(b, b_max_col, b_max_row)
	max_col = b_max_col
	max_row = b_max_row
	local lb = negate(b)
	local label = 0
	find_components(lb, label)
	return lb
end

function find_components(lb, label)
	for l = 0, max_col do
		for p = 0, max_row do
			if lb[l][p] == -1 then
				label = label + 1
				search(lb, label, l, p)
			end
		end
	end
end

function search(lb, label, l, p)
	lb[l][p] = label
	local Nset = neighbors(l, p)
	for _, lp in pairs(Nset) do
		if lb[lp[1]][lp[2]] == -1 then
			search(lb, label, lp[1], lp[2])
		end
	end
end

function neighbors(l, p)
	local n = {}
	if l-1 >= 0 then table.insert(n, {l-1, p}) end
	if p-1 >= 0 then table.insert(n, {l, p-1}) end
	if p+1 <= max_row then table.insert(n, {l, p+1}) end
	if l+1 <= max_col then table.insert(n, {l+1, p}) end
	return n
end

function negate(b)
	local lb = {}
	for l = 0, max_col do
		lb[l] = {}
		for p = 0, max_row do
			if b[l][p] then
				lb[l][p] = -1
			else
				lb[l][p] = 0
			end
		end
	end
	return lb
end
