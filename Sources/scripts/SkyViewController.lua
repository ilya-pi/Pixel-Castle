module(..., package.seeall)

local imageHelper = require("scripts.util.Image")
local Memmory = require("scripts.util.Memmory")

SkyViewController = { clouds = true }

-- Constructor
function SkyViewController:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function SkyViewController:render(group)
	local skyWidth = game.level_map.levelWidth * game.pixel
	local skyHeight = game.level_map.levelHeight * game.pixel
	local skyImage = "images/levels/" .. game.level_map.levelName .. "/sky.png"

	local sky1 = imageHelper.ourImage(skyImage, skyWidth, skyHeight, group)
	local sky2 = imageHelper.ourImage(skyImage, skyWidth, skyHeight, group)
	sky1.x = 0 -- because the group itself is already positioned at display.screenOriginX
	sky2.x = sky1.x + skyWidth

    Memmory.timerStash.skyMovementTimer = timer.performWithDelay(30, function()
        sky1.x = sky1.x + game.wind.speed / 2
        sky2.x = sky2.x + game.wind.speed / 2

        if sky1.x < -skyWidth then
            local tmp = sky1
            sky1 = sky2
            sky2 = tmp
            sky2.x = sky1.x + skyWidth
        elseif sky1.x >= 0 then
            local tmp = sky1
            sky1 = sky2
            sky2 = tmp
            sky1.x = sky2.x - skyWidth        	
        end
    end, 0)

end
