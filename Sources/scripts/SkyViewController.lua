module(..., package.seeall)

imageHelper = require("scripts.util.Image")

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
function SkyViewController:render(physics, world, game)
    local sky = display.newRect(0, 0, game.worldWidth, game.worldHeight)
    sky:setFillColor(207, 229, 130)
    sky:setStrokeColor(207, 229, 130)
    world:insert(sky)

    --todo move configuration for clouds to config?
    local cloudMargin = 5 -- in Pixels
    local maxCloudY = 40 -- in Pixels
    local minCloudY = 10 -- in Pixels
    local maxDistanceBetweenClouds = 20 -- in Pixels

    local worldWidth = game.worldWidth / game.pixel -- in Pixels
    local clouds = imageHelper.loadImageData("data/clouds.json") --todo move to static initialization
    local cloudsCount = table.getn(clouds)

    local cloudXright = 2
    while cloudXright < worldWidth do
        local type = math.random(cloudsCount)
        local newCloud = clouds[type]
        if (cloudXright + cloudMargin + newCloud.width < worldWidth) then
            local yPosition = math.random(minCloudY, maxCloudY - cloudMargin - newCloud.height)
            local xPosition = math.random(cloudXright + cloudMargin, cloudXright + maxDistanceBetweenClouds)
            cloudXright = xPosition + newCloud.width

            pixels = imageHelper.renderImage(xPosition, yPosition, newCloud, game)
            for i,v in ipairs(pixels) do
                world:insert(v)
            end
        else
            cloudXright = worldWidth --TODO: refactor this condition to exit loop
        end
    end

    --TODO: add parallax scrolling: 1-castles,ground,trees 2-pyramid,hills 3-sun,clouds

    print("Rendered sky with " .. tostring(game.worldWidth) .. ", " .. tostring(game.worldHeight))
end
