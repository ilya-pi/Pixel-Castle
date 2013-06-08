module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")
local castle_module = require("scripts.CastleViewController")
local imageHelper = require("scripts.util.Image")

local spriteWidthPixels = 3

local function substitutePiece(xPiece, yPiece, pieces, pixels)
    --print("substitutePiece " .. xPiece .. " " .. yPiece)
    local piece = pieces[xPiece][yPiece]
    if piece ~= nil then
        local startX = (xPiece - 1) * spriteWidthPixels + 1
        local startY = (yPiece - 1) * spriteWidthPixels + 1

        --print("start: " .. startX + spriteWidthPixels .. "," .. startY + spriteWidthPixels)

        for y = startY, startY + spriteWidthPixels - 1 do
            for x = startX, startX + spriteWidthPixels - 1 do
                local pixelData = pixels[x][y]
                if (pixelData.a ~= 0) then
                    local left = piece.absoluteX + (x - startX) * game.pixel
                    local top = piece.absoluteY + (y - startY) * game.pixel
                    local pixel = display.newRect(left, top, game.pixel, game.pixel)
                    pixel.strokeWidth = 0
                    pixel:setFillColor(pixelData.r, pixelData.g, pixelData.b, pixelData.a)
                    pixel:setStrokeColor(pixelData.r, pixelData.g, pixelData.b, pixelData.a)
                    pixel.myName = "brick"
                    game.world:insert(pixel)
                    Memmory.trackPhys(pixel); physics.addBody(pixel, "static")
                    pixels[x][y].physicsPixel = pixel
                    pixels[x][y].value = 3
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



    local level = game.level_map["level"]

    self.leftX = 0
    self.topY = 0

    --todo: castle image width and height should be dividable on this number
    local rowsNumber = level.height / spriteWidthPixels
    local columnsNumber = level.width / spriteWidthPixels
    local numFrames = rowsNumber * columnsNumber
    local spriteWidth = spriteWidthPixels * game.pixel
    local options =
    {
        width = spriteWidthPixels,
        height = spriteWidthPixels,
        numFrames = numFrames
    }
    local levelFilename = "images/levels/" .. game.level_map.levelName .. "/level.png"

    local imageSheet = graphics.newImageSheet( levelFilename, options )

    local castlePieces = {}
    for pieceX = 1, columnsNumber do
        castlePieces[pieceX] = {}
        for pieceY = 1, rowsNumber do
            local pieceNumber = (pieceY - 1) * columnsNumber + pieceX
            local emptyBlock = true
            local blockXstrart = (pieceX - 1) * spriteWidthPixels + 1
            local blockYstrart = (pieceY - 1) * spriteWidthPixels + 1
            for xTmp = blockXstrart, blockXstrart + spriteWidthPixels - 1 do
                for yTmp = blockYstrart, blockYstrart + spriteWidthPixels - 1 do
                    local r,g,b,a = imageHelper.pixel( xTmp - 1, yTmp - 1, level)
                    if a ~= 0 then
                        emptyBlock = false
                        break
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

    local physicalPixels = {}
    physicalPixels.height = level.height
    physicalPixels.width = level.width
    for x=1, level.width do
        physicalPixels[x] = {}
        for y=1, level.height do
            physicalPixels[x][y] = {}
            physicalPixels[x][y].xPiece = math.floor( (x - 1) / spriteWidthPixels) + 1
            physicalPixels[x][y].yPiece = math.floor( (y - 1) / spriteWidthPixels) + 1
            physicalPixels[x][y].r, physicalPixels[x][y].g, physicalPixels[x][y].b, physicalPixels[x][y].a = imageHelper.pixel(x - 1, y - 1, level)
            physicalPixels[x][y].value = 0 --no pixel by default
            if (physicalPixels[x][y].a ~= 0) then
                physicalPixels[x][y].value = 4
            end
        end
    end

    --printTable(physicalPixels)

    for y=1,physicalPixels.height do
        for x=1,physicalPixels.width do
            if physicalPixels[x][y].value == 4 then

                for yInternal=y-1, y+1 do
                    for xInternal=x-1, x+1 do
                        if (yInternal < 1 or yInternal > physicalPixels.height or
                                xInternal < 1 or xInternal > physicalPixels.width) then
                        else
                            if (physicalPixels[xInternal][yInternal].value == 0) then
                                substitutePiece(physicalPixels[x][y].xPiece, physicalPixels[x][y].yPiece, castlePieces, physicalPixels)
                                break
                            end
                        end

                    end
                end

            end
        end
    end







    game.castle1 = castle_module.CastleViewController:new{castleName = "castle1", location = "left"}
    game.castle1:render(physics, game.world, game, game.level_map.castle1.x, game.level_map.castle1.y)

    game.castle2 = castle_module.CastleViewController:new{castleName = "castle2", location = "right"}
    game.castle2:render(physics, game.world, game, game.level_map.castle2.x, game.level_map.castle2.y)
end
