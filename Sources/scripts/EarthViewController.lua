module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")
local castle_module = require("scripts.CastleViewController")
local imageHelper = require("scripts.util.Image")

local spriteWidthPixels = 3

EarthViewController = {}
        
function EarthViewController:substitutePiece(xPiece, yPiece)
    local piece = self.castlePieces[xPiece][yPiece]
    if piece ~= nil then
        local startX = (xPiece - 1) * spriteWidthPixels + 1
        local startY = (yPiece - 1) * spriteWidthPixels + 1

        for y = startY, startY + spriteWidthPixels - 1 do
            for x = startX, startX + spriteWidthPixels - 1 do
                if self.level.pixels[y] ~= nil and self.level.pixels[y][x] ~= nil then
                    local pixelData = self.level.pixels[y][x]
                    if (pixelData[3] ~= 0) then
                        local left = piece.absoluteX + (x - startX) * game.pixel
                        local top = piece.absoluteY + (y - startY) * game.pixel
                        local myPixel = display.newRect(left, top, game.pixel, game.pixel)
                        myPixel.strokeWidth = 0
                        myPixel:setFillColor(pixelData.rgba[1], pixelData.rgba[2], pixelData.rgba[3], pixelData.rgba[4])
                        --myPixel:setStrokeColor(pixelData.rgba[1], pixelData.rgba[2], pixelData.rgba[3], pixelData.rgba[4])
                        myPixel.myName = "brick"
                        myPixel.pX = x
                        myPixel.pY = y
                        game.world:insert(myPixel)
                        Memmory.trackPhys(myPixel); timer.performWithDelay(1, function() physics.addBody(myPixel, "static") end)
                        self.level.pixels[y][x].physicsPixel = myPixel
                        self.level.pixels[y][x].hl = 2
                    end
                end
            end
        end
        
        piece:removeSelf()
        self.castlePieces[xPiece][yPiece] = nil
    end
end

function EarthViewController:checkPixels(startX, endX, startY, endY, substitueAll) 
    if startX < self.minX then startX = self.minX end
    if endX > self.maxX then endX = self.maxX end
    if startY < self.minY then startY = self.minY end
    if endY > self.maxY then endY = self.maxY end
    
    for y=startY, endY do
        for x=startX, endX do
            if self.level.pixels[y] ~= nil and self.level.pixels[y][x] ~= nil and self.level.pixels[y][x].hl == 3 then
                if substitueAll then
                    local xPiece = math.floor((x - 1) / spriteWidthPixels) + 1
                    local yPiece = math.floor((y - 1) / spriteWidthPixels) + 1
                    self:substitutePiece(xPiece, yPiece)
                else
                    for yInternal=y-1, y+1 do
                        for xInternal=x-1, x+1 do
                            if (yInternal < startY or yInternal > endY or
                                xInternal < startX or xInternal > endX) then
                                --do nothing
                            else
                                if (self.level.pixels[yInternal] == nil or self.level.pixels[yInternal][xInternal] == nil) then
                                    local xPiece = math.floor((x - 1) / spriteWidthPixels) + 1
                                    local yPiece = math.floor((y - 1) / spriteWidthPixels) + 1
                                    self:substitutePiece(xPiece, yPiece)
                                    break
                                end
                            end

                        end
                    end
                end

            end

        end
    end
end

-- Constructor
function EarthViewController:new(o)
	o = o or {castleCount = 1}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
        
        o.level = game.level_map
        o.minX = 1 
        o.maxX = o.level.levelWidth
        o.minY = o.level.pixelsSkipFromTop 
        o.maxY = o.level.levelHeight
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function EarthViewController:render(physics)

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
    self.castlePieces = {}
    for pieceX = 1, columnsNumber do
        self.castlePieces[pieceX] = {}
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
                -- Memmory.trackPhys(castlePiece); physics.addBody(castlePiece, "static")
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
            self.castlePieces[pieceX][pieceY] = castlePiece
        end

    end

    self:checkPixels(1, self.level.levelWidth, self.level.pixelsSkipFromTop, self.level.levelHeight, false)
    
    --self:substitutePiece(26, 95)
--        local piece = self.castlePieces[26][95]
--        if piece ~= nil then 
--            piece:removeSelf()
--        end
        

    game.castle1 = castle_module.CastleViewController:new{castleData = self.level.castle1, location = "left", pixels = self.level.pixels}
    game.castle1:render(physics, game.world, game, game.level_map.castle1.x, game.level_map.castle1.y)

    game.castle2 = castle_module.CastleViewController:new{castleData = self.level.castle2, location = "right", pixels = self.level.pixels}
    game.castle2:render(physics, game.world, game)
end

function processCollisionNRemove(body, xV, yV)
    body.bodyType = "dynamic"
    body.isSensor = true

    -- tmpPixel.physicsPixel.bodyType = "kinematic"

    -- body:setLinearVelocity(math.random(-200, 200), - math.random(500, 750))
    -- body:setLinearVelocity(math.random(-100, 100), - math.random(100, 250))
    local aX = xV / game.DAMPING
    local aY = yV / game.DAMPING
    local aDX = math.random(- math.abs(aX), math.abs(aX)) / game.D_DAMPING
    local aDY = math.random(- math.abs(aY), math.abs(aY)) / game.D_DAMPING
    body:setLinearVelocity(-(aX + aDX), -(aY + aDY))
    transition.to(body, {alpha = 0, time = game.DEAD_PIXEL_STAY_TIME, transition = easing.inExpo, onComplete = function()
        body:removeSelf()
        end})

    -- timer.performWithDelay(game.DEAD_PIXEL_STAY_TIME, function()
    --     body:removeSelf()    
    -- end)
end

function EarthViewController:calculateHit(physicsPixel, hit, xV, yV) 
    print("bullet size " .. #hit)
    local x = physicsPixel.pX
    local y = physicsPixel.pY
    local dx = (#hit - 1) / 2
    --local dx = 10
    self:checkPixels(x - dx, x + dx, y - dx, y + dx, true)
    print("before")
    for hitX=-dx, dx do
        for hitY=-dx, dx do
            local pixelY = hitY + y
            local pixelX = hitX + x
            local power = hit[hitX + dx + 1][hitY + dx + 1]
            if self.level.pixels[pixelY] ~= nil and self.level.pixels[pixelY][pixelX] ~= nil and power > 0 then
                local tmpPixel = self.level.pixels[pixelY][pixelX]
                tmpPixel.hl = tmpPixel.hl - power
                if tmpPixel.hl <= 0 then
                    timer.performWithDelay(10, function()
                                                    if tmpPixel.physicsPixel ~= nil and tmpPixel.physicsPixel.state ~= "removed" then
                                                        tmpPixel.physicsPixel.state = "removed"
                                                        
                                                        processCollisionNRemove(tmpPixel.physicsPixel, xV, yV)

                                                        self.level.pixels[pixelY][pixelX] = nil
                                                    end
                                               end
                    )
                else
                  tmpPixel.physicsPixel:setFillColor(53, 93, 34, 255)
                end
                    
            end
        end
    end
    print("end")
    
    self:checkPixels(x - dx - 2, x + dx + 2, y - dx - 2, y + dx + 2, false)
end
