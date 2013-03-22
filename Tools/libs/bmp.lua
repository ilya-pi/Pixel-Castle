module(..., package.seeall)

local function error(err)
	-- Replace with your own error output method:
	print(err);
end

-- Helper function: Parse a 16-bit WORD from the binary string
local function ReadWORD(str, offset)
	local loByte = str:byte(offset);
	local hiByte = str:byte(offset+1);
	return hiByte*256 + loByte;
end

-- Helper function: Parse a 32-bit DWORD from the binary string
local function ReadDWORD(str, offset)
	local loWord = ReadWORD(str, offset);
	local hiWord = ReadWORD(str, offset+2);
	return hiWord*65536 + loWord;
end

-- Process a bitmap file in a string
function parseBitmap(bytecode, fileName)
	local bitmapTable = {}
	-------------------------
	-- Parse BITMAPFILEHEADER
	-------------------------
	local offset = 1;
	local bfType = ReadWORD(bytecode, offset);
	if(bfType ~= 0x4D42) then
		error("Not a bitmap file (Invalid BMP magic value)");
		return;
	end
	local bfOffBits = ReadWORD(bytecode, offset+10);

	-------------------------
	-- Parse BITMAPINFOHEADER
	-------------------------
	offset = 15; -- BITMAPFILEHEADER is 14 bytes long
	local biWidth = ReadDWORD(bytecode, offset+4);
	local biHeight = ReadDWORD(bytecode, offset+8);
	local biBitCount = ReadWORD(bytecode, offset+14);
	local biCompression = ReadDWORD(bytecode, offset+16);
	if(biBitCount ~= 24) then
		error("Only 24-bit bitmaps supported (Is " .. biBitCount .. "bpp)");
		return;
	end
	if(biCompression ~= 0) then
		error("Only uncompressed bitmaps supported (Compression type is " .. biCompression .. ")");
		return;
	end

	bitmapTable.width = biWidth
	bitmapTable.height = biHeight
	bitmapTable.name = fileName
	bitmapTable.pixels = {}
	---------------------
	-- Parse bitmap image
	---------------------
	for y = biHeight-1, 0, -1 do
		offset = bfOffBits + (biWidth*biBitCount/8)*y + 1 + 2*y --todo explane magic numbers
		for x = 0, biWidth-1 do
			local b = bytecode:byte(offset);
			local g = bytecode:byte(offset+1);
			local r = bytecode:byte(offset+2);
			offset = offset + 3;
			--print("x="..x .." y="..y .. "; r=".. r .. " g=" .. g .. " b=" .. b)
			table.insert(bitmapTable.pixels, r)
			table.insert(bitmapTable.pixels, g)
			table.insert(bitmapTable.pixels, b)
		end
	end
	return bitmapTable
end