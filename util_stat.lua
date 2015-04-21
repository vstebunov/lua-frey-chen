function otsu(histogram, total)
	local sum = 0
	for i = 1, 255 do
		sum = sum + i * histogram[i]
	end
	local sumB = 0
	local wB = 0
	local wF = 0
	local mB, mF
	local max = 0.0
	local between = 0.0
	local thresold1 = 0.0
	local thresold2 = 0.0
	for i = 0, 255 do
		wB = wB + histogram[i]
		if (wB ~= 0) then
			wF = total - wB
			if (wF == 0) then
				break
			end
			sumB = sumB + i * histogram[i]
			mB = sumB / wB
			mF = (sum - sumB) / wF
			between = wB * wF * math.pow(mB - mF, 2)
			if (between >= max) then
				thresold1 = i
				if (between > max) then
					thresold2 = i
				end
				max = between
			end

		end
	end
	return (thresold1 + thresold2) / 2.0
end
