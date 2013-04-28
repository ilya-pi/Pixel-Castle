module(..., package.seeall)

local imageHelper = require("scripts.util.Image")

SkyViewController = { clouds = true }

-- Constructor
function SkyViewController:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function SkyViewController:render(world, game)
    local sky = display.newRect(display.screenOriginX, display.screenOriginY, game.worldWidth, game.worldHeight)
    sky:setFillColor(207, 229, 130)
    sky:setStrokeColor(207, 229, 130)
    world:insert(sky)
    local pixels = imageHelper.renderImage(0, 0, game.level_map.sky, game.pixel)
    for i,v in ipairs(pixels) do
        world:insert(v)
    end
    print("Rendered sky")
end
