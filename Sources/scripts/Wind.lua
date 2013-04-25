module(..., package.seeall)

physics = require("physics")

local scaleFactor = 0.5
local pixelsPadding = 1
local leftMargin = 44

Wind = {}

-- Constructor
function Wind:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.speed = 0
    o.pixels = {}

    o.group = display.newGroup()

    o.wind_hud = display.newImage("images/wind/wind_hud.png")
    o.wind_hud:scale(scaleFactor, scaleFactor)
    o.wind_hud:setReferencePoint(display.TopLeftReferencePoint)
    o.wind_hud.x = 0
    o.wind_hud.y = 0

    local tmp = display.newImage("images/wind/triangle_left.png")
    o.arrowWidth = tmp.width * scaleFactor
    tmp:removeSelf()
    tmp = display.newImage("images/wind/wind_point.png")
    o.windPointWidth = tmp.width * scaleFactor
    tmp:removeSelf()

    return o
end

function Wind:update()
    self.speed = math.random(-5, 5)
    physics.setGravity(self.speed, 9.8)

    local centerOfArrow = (self.wind_hud.width * scaleFactor - leftMargin) / 2 + leftMargin
    local lengthOfArrow = self.arrowWidth + pixelsPadding + math.abs(self.speed) * self.windPointWidth + (math.abs(self.speed) - 1) * pixelsPadding
    local pixelsX = centerOfArrow - lengthOfArrow / 2
    --local pixelsX = leftMargin
    local pixelsY = self.wind_hud.height / 2 * scaleFactor - 2

    for i, v in ipairs(self.pixels) do
        v:removeSelf()
        self.pixels[i] = nil
    end

    if (self.speed < 0) then
        local arrow = display.newImage("images/wind/triangle_left.png")
        arrow:scale(scaleFactor, scaleFactor)
        arrow:setReferencePoint(display.CenterLeftReferencePoint)
        arrow.x = pixelsX
        arrow.y = pixelsY
        pixelsX = pixelsX + arrow.width * scaleFactor + pixelsPadding
        table.insert(self.pixels, arrow)
        self:drawPixels(pixelsX, pixelsY, math.abs(self.speed))
    elseif (self.speed > 0) then
        local lineEndX = self:drawPixels(pixelsX, pixelsY, math.abs(self.speed))
        pixelsX = lineEndX

        local arrow = display.newImage("images/wind/triangle_right.png")
        arrow:scale(scaleFactor, scaleFactor)
        arrow:setReferencePoint(display.CenterLeftReferencePoint)
        arrow.x = pixelsX
        arrow.y = pixelsY
        table.insert(self.pixels, arrow)
    else
        --todo: draw 0?
    end
end

function Wind:drawPixels(x, y, count)
    local currentX = x
    print(count)
    for i = 1, count do
        local pixel = display.newImage("images/wind/wind_point.png")
        pixel:scale(scaleFactor, scaleFactor)
        pixel:setReferencePoint(display.CenterLeftReferencePoint)
        pixel.x = currentX
        pixel.y = y
        table.insert(self.pixels, pixel)
        currentX = currentX + pixel.width * scaleFactor + pixelsPadding
    end
    return currentX
end
