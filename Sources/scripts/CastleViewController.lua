module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")
local imageHelper = require("scripts.util.Image")
local customUI = require("scripts.util.CustomUI")
local eventTrack = require("scripts.util.EventTrack")

local spriteWidthPixels = 3

local function printTable(table)
    for y=1,table.height do
        local row = ""
        for x=1,table.width do
            --row = row .. table[x][y].value .. " "
            --row = row .. table[x][y].xPiece .. "," .. table[x][y].yPiece .. " "
            row = row .. x .. "," .. y .. " "
        end
        print(row)
    end
end

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
        piece:removeSelf()
        pieces[xPiece][yPiece] = nil
    end
end


CastleViewController = {}

-- Constructor
function CastleViewController:new (o) --todo save (physics, world, game, x, y) at this point since tower is static
	o = o or {}   -- create object if user does not provide one
	o.bricks = {}
	o.events = eventTrack.EventTrack:new()
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function CastleViewController:render(physics, world, game, x, y) --todo remove redundant params

    local castle = game.level_map[self.castleName]

    self.leftX = x * game.pixel
    self.rightX = (x + castle.width) * game.pixel
    self.topY = (y - castle.height + 1) * game.pixel

     --todo: castle image width and height should be dividable on this number
    local rowsNumber = castle.height / spriteWidthPixels
    local columnsNumber = castle.width / spriteWidthPixels
    local numFrames = rowsNumber * columnsNumber
    local spriteWidth = spriteWidthPixels * game.pixel
    local options =
    {
        width = spriteWidthPixels,
        height = spriteWidthPixels,
        numFrames = numFrames
    }
    local castleFilename = "images/levels/" .. game.level_map.levelName .. "/" .. self.castleName .. ".png"

    local imageSheet = graphics.newImageSheet( castleFilename, options )

    local castlePieces = {}
    for pieceX = 1, columnsNumber do
        castlePieces[pieceX] = {}
        for pieceY = 1, rowsNumber do
            local pieceNumber = (pieceY - 1) * columnsNumber + pieceX
            local castlePiece = imageHelper.ourImageSheet(imageSheet, pieceNumber, spriteWidth, spriteWidth, world)
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
    physicalPixels.height = castle.height
    physicalPixels.width = castle.width
    for x=1,castle.width do
        physicalPixels[x] = {}
        for y=1,castle.height do
            physicalPixels[x][y] = {}
            physicalPixels[x][y].xPiece = math.floor( (x - 1) / spriteWidthPixels) + 1
            physicalPixels[x][y].yPiece = math.floor( (y - 1) / spriteWidthPixels) + 1
            physicalPixels[x][y].r, physicalPixels[x][y].g, physicalPixels[x][y].b, physicalPixels[x][y].a = imageHelper.pixel(x - 1, y - 1, castle)
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
                        if ( (yInternal < 1 or yInternal > physicalPixels.height or
                             xInternal < 1 or xInternal > physicalPixels.width) or
                             physicalPixels[xInternal][yInternal].value == 0) then
                            substitutePiece(physicalPixels[x][y].xPiece, physicalPixels[x][y].yPiece, castlePieces, physicalPixels)
                            --physicalPixels[x][y].value = 3 --todo: here real call to substitute the whole castle piece
                            break
                        end
                    end
                end

            end
        end
    end

    --printTable(physicalPixels)

    self.totalHealth = self:health()
    self.width = castle.width * game.pixel

    self.healthBar = display.newRect(0, 0, self.width, 3)
    self.healthBar:setReferencePoint(display.BottomLeftReferencePoint)
    self.healthBar.x = self.leftX
    self.healthBar.y = self.topY - 15
    world:insert(self.healthBar)
   	self.healthBar:setFillColor(0, 255, 0, 150)

    print("Rendered castle with " .. x .. ", " .. y)
end

function CastleViewController:isDestroyed(game)
	if (self:healthPercent() < game.minCastleHealthPercet) then
		return true
	else
		return false
	end
end

function CastleViewController:updateHealth(game)
	local curr = self:healthPercent()

	local healthEstimation = (curr - game.minCastleHealthPercet ) / (100 - game.minCastleHealthPercet) * 30	
	if healthEstimation > 20 then
		self.healthBar:setFillColor(0, 255, 0, 150)
	elseif healthEstimation > 10 then
		self.healthBar:setFillColor(255, 255, 0, 150)
	else
		self.healthBar:setFillColor(255, 0, 0, 150)
	end

	if curr <= game.minCastleHealthPercet then
		self.healthBar.width = 1
	else		
		self.healthBar.width = self.width * (curr - game.minCastleHealthPercet ) / (100 - game.minCastleHealthPercet)
	end
end

function CastleViewController:say(message, callback, tint)
    local bubbleGroup = display.newGroup()
    local bubble
    if (self.location == "left") then
        bubble = display.newImageRect("images/speech_left.png", 80, 60)
    else
        bubble = display.newImageRect("images/speech_right.png", 80, 60)
    end
    if tint ~=nil then
        bubble:setFillColor(tint.r, tint.g, tint.b)
    end

    bubbleGroup:insert(bubble)

    local text = display.newText(message, -100, -100, "TrebuchetMS-Bold", 14)
    text:setReferencePoint(display.CenterReferencePoint)
    text:setTextColor(0, 0, 0)
    text.x, text.y = 0, -7
    bubbleGroup:insert(text)

    game.world:insert(bubbleGroup)
    bubbleGroup.x, bubbleGroup.y = self:cannonX(), self:cannonY()
    table.insert(Memmory.transitionStash, transition.to(bubbleGroup, {time = 700, alpha = 0, y = self:cannonY() - 50, 
        onComplete = function() 
            bubbleGroup:removeSelf() 
            callback()
        end}))
    -- Memmory.timerStash.castleSayTimer = timer.performWithDelay(2000, function()
    --         bubbleGroup:removeSelf()
    --         callback()
    --     end)
end

function CastleViewController:showBubble(game, message)
    local bubbleGroup = display.newGroup()
    local bubble
    if (self.location == "left") then
        bubble = display.newImageRect("images/speech_left.png", 80, 60)
    else
        bubble = display.newImageRect("images/speech_right.png", 80, 60)
    end
    bubbleGroup:insert(bubble)

    local text = display.newText(message, -100, -100, "TrebuchetMS-Bold", 14)
    text:setReferencePoint(display.CenterReferencePoint)
    text:setTextColor(0, 0, 0)
    text.x, text.y = 0, -7
    bubbleGroup:insert(text)

    game.world:insert(bubbleGroup)
    bubbleGroup.x, bubbleGroup.y = self:cannonX(), self:cannonY()
    table.insert(Memmory.transitionStash, transition.to(bubbleGroup, {time = 3500, alpha = 0, y = self:cannonY() - 100, onComplete = function() bubbleGroup:removeSelf() end}))
end

function CastleViewController:health()
	-- to let the castles die right away, return 5 health points
	-- return 5
	local score = 0
	for i, v in ipairs(self.bricks) do
		if (v ~= nil) then
			if (v.state == "removed") then
				self.events:keep({action = "hit"})
				table.remove(self.bricks, i)
			else
				score = score + 1
			end
		end
	end
	return score
end

function CastleViewController:healthPercent()
	return math.round(100 * self:health() / self.totalHealth)
end	

function CastleViewController:cannonX()
    if (self.location == "left") then
	    return self.rightX + 1
    else
        return self.leftX - 1
    end
end

function CastleViewController:cannonY()
    return self.topY - 1
end


