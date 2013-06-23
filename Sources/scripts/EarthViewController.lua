module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")
local castle_module = require("scripts.CastleViewController")
local imageHelper = require("scripts.util.Image")

local spriteWidthPixels = 3

local function substitutePiece(xPiece, yPiece, pieces, pixels)
    print("substitutePiece " .. xPiece .. " " .. yPiece)
    local piece = pieces[xPiece][yPiece]
    if piece ~= nil then
        local startX = (xPiece - 1) * spriteWidthPixels + 1
        local startY = (yPiece - 1) * spriteWidthPixels + 1

        --print("start: " .. startX + spriteWidthPixels .. "," .. startY + spriteWidthPixels)

        for y = startY, startY + spriteWidthPixels - 1 do
            for x = startX, startX + spriteWidthPixels - 1 do
                if pixels[y] ~= nil and pixels[y][x] ~= nil then
                    local pixelData = pixels[y][x]
                    if (pixelData[4] ~= 0) then
                        local left = piece.absoluteX + (x - startX) * game.pixel
                        local top = piece.absoluteY + (y - startY) * game.pixel
                        local pixel = display.newRect(left, top, game.pixel, game.pixel)
                        pixel.strokeWidth = 0
                        pixel:setFillColor(pixelData.rgba[1], pixelData.rgba[2], pixelData.rgba[3], pixelData.rgba[4])
                        --pixel:setStrokeColor(pixelData.rgba[1], pixelData.rgba[2], pixelData.rgba[3], pixelData.rgba[4])
                        pixel.myName = "brick"
                        game.world:insert(pixel)
                        Memmory.trackPhys(pixel); physics.addBody(pixel, "static")
                        pixels[y][x].physicsPixel = pixel
                        pixels[y][x].hl = 3
                    end
                end
            end
        end

        if not piece.empty then
            piece:removeSelf()
        end
        pieces[xPiece][yPiece] = nil
    end
end

EarthViewController = {}

-- Constructor
function EarthViewController:new (o)
	o = o or {castleCount = 1}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function EarthViewController:render(physics)
--[[    imageHelper.ourImage("images/levels/" .. game.level_map.levelName .. "/level.png",
        game.level_map.levelWidth * game.pixel, 
        game.level_map.levelHeight * game.pixel,
        game.world)]]



    self.level = game.level_map

    self.leftX = 0
    self.topY = 0

    local rowsNumber = self.level.levelHeight / spriteWidthPixels
    local columnsNumber = self.level.levelWidth / spriteWidthPixels
    local numFrames = rowsNumber * columnsNumber
    local spriteWidth = spriteWidthPixels * game.pixel
    local options =
    {
        width = spriteWidthPixels,
        height = spriteWidthPixels,
        numFrames = numFrames
    }
    local levelFilename = "images/levels/" .. self.level.levelName .. "/level.png"

    local imageSheet = graphics.newImageSheet( levelFilename, options )
    
    local startYpiece = math.floor(self.level.pixelsSkipFromTop / spriteWidthPixels)
    local castlePieces = {}
    for pieceX = 1, columnsNumber do
        castlePieces[pieceX] = {}
        for pieceY = startYpiece, rowsNumber do
            local pieceNumber = (pieceY - 1) * columnsNumber + pieceX
            local emptyBlock = true
            local blockXstrart = (pieceX - 1) * spriteWidthPixels + 1
            local blockYstrart = (pieceY - 1) * spriteWidthPixels + 1
            for yTmp = blockYstrart, blockYstrart + spriteWidthPixels - 1 do
                if self.level.pixels[yTmp] ~= nil then
                    for xTmp = blockXstrart, blockXstrart + spriteWidthPixels - 1 do
                        if self.level.pixels[yTmp][xTmp] ~= nil then
                            local a = self.level.pixels[yTmp][xTmp][4]
                            if a ~= 0 then
                                emptyBlock = false
                                break
                            end
                        end
                    end
                end
            end

            local castlePiece
            if not emptyBlock then
                castlePiece = imageHelper.ourImageSheet(imageSheet, pieceNumber, spriteWidth, spriteWidth, game.world)
                Memmory.trackPhys(castlePiece); physics.addBody(castlePiece, "static")
            else
                castlePiece = {empty = true}
            end

            local left = self.leftX + (pieceX - 1) * spriteWidth
            local top = self.topY + (pieceY - 1) * spriteWidth
            castlePiece.x, castlePiece.y = left, top
            castlePiece.xPart = pieceX
            castlePiece.yPart = pieceY
            castlePiece.absoluteX = left
            castlePiece.absoluteY = top
            castlePieces[pieceX][pieceY] = castlePiece
            --            print(pieceX .. "," .. pieceY)
        end

    end

--    local physicalPixels = {}
--    for x=1, level.width do
--        physicalPixels[x] = {}
--        for y=1, level.height do
--            physicalPixels[x][y] = {}
--            physicalPixels[x][y].xPiece = math.floor( math(x - 1) / spriteWidthPixels) + 1
--            physicalPixels[x][y].yPiece = math.floor( (y - 1) / spriteWidthPixels) + 1
--            physicalPixels[x][y].r, physicalPixels[x][y].g, physicalPixels[x][y].b, physicalPixels[x][y].a = imageHelper.pixel(x - 1, y - 1, level)
--            physicalPixels[x][y].value = 0 --no pixel by default
--            if (physicalPixels[x][y].a ~= 0) then
--                physicalPixels[x][y].value = 4
--            end
--        end
--    end
    
--    for y=1, self.level.levelHeight do
--        if self.level.pixels[y] ~= nil then
--            for x=1, self.level.levelWidth do
--                self.level.pixels[y][x].xPiece 
--            end
--        end
--    end
    --printTable(physicalPixels)
    
--    for y=1, self.level.levelHeight do
--        
--        if self.level.pixels[y] == nil then
--            print("empty row")
--        else
--            local myRow = ""
--            for x=1, self.level.levelWidth do
--                if self.level.pixels[y][x] ~= nil then
--                    myRow = myRow .. " " .. self.level.pixels[y][x].hl
--                else
--                    myRow = myRow .. " 0"
--                end
--            end
--            print(myRow)
--        end
--            
--    end
        
                
    

    for y=self.level.pixelsSkipFromTop, self.level.levelHeight do
        for x=1, self.level.levelWidth do
            if self.level.pixels[y][x] ~= nil and self.level.pixels[y][x].hl == 4 then

                for yInternal=y-1, y+1 do
                    for xInternal=x-1, x+1 do
                        if (yInternal < self.level.pixelsSkipFromTop or yInternal > self.level.levelHeight or
                                xInternal < 1 or xInternal > self.level.levelWidth) then
                                --do nothing
                        else
                            if (self.level.pixels[yInternal] == nil or self.level.pixels[yInternal][xInternal] == nil) then
                                local xPiece = math.floor((x - 1) / spriteWidthPixels) + 1
                                local yPiece = math.floor((y - 1) / spriteWidthPixels) + 1
                                substitutePiece(xPiece, yPiece, castlePieces, self.level.pixels)
                                break
                            end
                        end

                    end
                end

            end
                
        end
    end

    game.castle1 = castle_module.CastleViewController:new{castleData = self.level.castle1, location = "left"}
    game.castle1:render(physics, game.world, game, game.level_map.castle1.x, game.level_map.castle1.y)

    game.castle2 = castle_module.CastleViewController:new{castleData = self.level.castle2, location = "right"}
    game.castle2:render(physics, game.world, game)
end
