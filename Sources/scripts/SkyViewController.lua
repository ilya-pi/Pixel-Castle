module(..., package.seeall)

cloud = require("data.cloud")

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

    local cloudsCount = table.getn(cloud.clouds)
    print("clouds count " .. cloudsCount)

    local function renderCloud(xCloudPosition, yCloudPosition, cloud)
        local cloudHeight = cloud.height
        local cloudWidth = cloud.width
        local primitiveColorsCount = 3
        for y = 0, cloudHeight - 1 do
            for x = 0, cloudWidth - 1 do
                local rPosition = y * cloudWidth * primitiveColorsCount + x * primitiveColorsCount + 1
                local r = cloud.pixels[rPosition]
                local g = cloud.pixels[rPosition + 1]
                local b = cloud.pixels[rPosition + 2]
                if (r + g + b ~= 0) then
                    local left = (xCloudPosition + x) * game.pixel
                    local top = (yCloudPosition + y) * game.pixel
                    local pixel = display.newRect(left, top, game.pixel, game.pixel)
                    pixel.strokeWidth = 0
                    pixel:setFillColor(r, g, b)
                    pixel:setStrokeColor(r, g, b)
                    world:insert(pixel)
                end
            end
        end
    end

    local cloudXright = 2
    while cloudXright < worldWidth do
        local type = math.random(cloudsCount)
        local newCloud = cloud.clouds[type]
        if (cloudXright + cloudMargin + newCloud.width < worldWidth) then
            local yPosition = math.random(minCloudY, maxCloudY - cloudMargin - newCloud.height)
            local xPosition = math.random(cloudXright + cloudMargin, cloudXright + maxDistanceBetweenClouds)
            cloudXright = xPosition + newCloud.width
            print("render cloud " .. xPosition .. " " .. yPosition)
            renderCloud(xPosition, yPosition, newCloud)
        else
            cloudXright = worldWidth --TODO: refactor this condition to exit loop
        end
    end

    --TODO: add parallax scrolling: 1-castles,ground,trees 2-pyramid,hills 3-sun,clouds

    print("Rendered sky with " .. tostring(game.worldWidth) .. ", " .. tostring(game.worldHeight))
end
