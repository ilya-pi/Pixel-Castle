module(..., package.seeall)

physics = require("physics")
imageHelper = require("scripts.util.image")

Wind = {}

local windPixel = 7

--todo: refactor this shit!!!!!!!!!!!

-- Constructor
function Wind:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.speed = 0
    o.pixels = {}
    local assets = imageHelper.loadImageData("data/other.json")
    local windWordImage = assets.wind_text
    o.imgWidth = windWordImage.width
    o.imgHeight = windWordImage.height
    o.leftArrow = assets.left_wind_arrow
    o.rightArrow = assets.right_wind_arrow
    imageHelper.renderImage(o.x, o.y, windWordImage, windPixel)  --todo pixel size decreased so it doesn't depend on game.pixel
    return o
end

function Wind:update()
    self.speed = math.random(-5, 5)
    physics.setGravity(self.speed, 9.8)
    local pixelsX = (self.x + self.imgWidth + 3) * windPixel
    local pixelsY = (self.y + self.imgHeight/2 - 0.5) * windPixel
    for i, v in ipairs(self.pixels) do
        v:removeSelf()
        self.pixels[i] = nil
    end

    if (self.speed < 0) then
        local arrowTable = imageHelper.renderImage(pixelsX / windPixel, self.y, self.leftArrow, windPixel)
        pixelsX = pixelsX + (self.leftArrow.width + 1) * windPixel
        for i, v in ipairs(arrowTable) do
            table.insert(self.pixels, v)
        end

        self:drawPixels(pixelsX, pixelsY, math.abs(self.speed))
    elseif (self.speed > 0) then
        local lineEndX = self:drawPixels(pixelsX, pixelsY, math.abs(self.speed))
        pixelsX = lineEndX
        local arrowTable = imageHelper.renderImage(pixelsX / windPixel, self.y, self.rightArrow, windPixel)
        for i, v in ipairs(arrowTable) do
            table.insert(self.pixels, v)
        end
    else
        --todo: draw 0?
    end
end

function Wind:drawPixels(x, y, count)
    local currentX = x
    for i = 1, count do
        local pixel = display.newRect(currentX, y, windPixel, windPixel) --todo pixel size decreased so it doesn't depend on game.pixel
        pixel.strokeWidth = 0
        pixel:setFillColor(26, 55, 37, 255)
        pixel:setStrokeColor(26, 55, 37, 255)
        table.insert(self.pixels, pixel)
        currentX = currentX + windPixel * 2
    end
    return currentX
end
