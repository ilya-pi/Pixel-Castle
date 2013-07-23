module(..., package.seeall)

local function calculateWrongAngle(correctAngle)
    local random = math.random(-2, 2)
    if random < 0 then random = random - 3 end
    if random > 0 then random = random + 3 end
    if random == 0 then random = 3 end
    return correctAngle + random
end

AI = {}

-- Constructor
function AI:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    o.speed = game.levelConfig.screens[1].levels[game.selectedLevel].bulletSpeed  * 0.184 --magic number picked manually
    o.windList = {}
    o.xA = game.wind.physicsSpeed
    o.yA = game_gravity
    o.x0 = game.controls2.x
    o.y0 = game.controls2.y

    o.enemyLeftX = game.castle1.leftX
    o.enemyRightX = game.castle1.rightX
    o.enemyTopY = game.castle1.topY
    o.enemyBottomY = game.castle1.bottomY

    o.firstRealTry = 4
    o.currentTry = 0
    o.accuracyPercentage = 0.8
   --print(o.enemyLeftX .. " " .. o.enemyRightX .. " | " .. o.enemyTopY .. " " .. o.enemyBottomY)

    return o
end

function AI:calculateAngle()
    table.insert(self.windList, game.wind.speed)
    self.xA = game.wind.physicsSpeed
    self.currentTry = self.currentTry + 1
    for angle = 90, -90, -1 do
        local finalAngle = angle
        if self:checkAngle(angle) then
            if self:checkAngle(angle - 1) then
                finalAngle = angle - 1
            end
            if (self.currentTry < self.firstRealTry) then
                print("!!!!!!!!!!!!!!!!!!!! trying to miss first " .. self.firstRealTry .. " tryes")
                return calculateWrongAngle(finalAngle)
            else
                if self.windList[#self.windList] == self.windList[#self.windList - 1] then
                    print("!!!!!!!!!!!!!!!!!!!! trying to hit because wind is the same")
                    return finalAngle
                end

                local random = math.random()
                if random > self.accuracyPercentage then
                    print("!!!!!!!!!!!!!!!!!!!! trying to miss because of accuracy")
                    return calculateWrongAngle(finalAngle)
                else
                    print("!!!!!!!!!!!!!!!!!!!! trying to hit")
                    return finalAngle
                end
            end
        end
    end
    print("!!!!!!!!!!!!!!!!!!!! default angle")
    return -45 --todo: substitute later. we return this value if didn't find any real value
end

function AI:checkAngle(angle)
    local angleInRadians = math.rad(angle - (angle - 45) * 2)
    self.xV = self.speed * math.cos(angleInRadians)
    self.yV = -self.speed * math.sin(angleInRadians)

    local t = 50
    while t > 0 do
        local x = self.x0 + self.xV * t + self.xA * t * t / 2
        local y = self.y0 + self.yV * t + self.yA * t * t / 2
        if x > self.enemyLeftX and x < self.enemyRightX and y > self.enemyTopY and y < self.enemyBottomY then
            --print("angle found!!!!!!!!!!!!!!! " .. angle)
            return true
        end
        t = t - 0.1
    end
    return false
end


