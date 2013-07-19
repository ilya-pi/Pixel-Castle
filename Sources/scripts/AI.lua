module(..., package.seeall)

AI = {}

-- Constructor
function AI:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    o.speed = game.levelConfig.screens[1].levels[game.selectedLevel].bulletSpeed  * 0.184 --magic number picked manually
    o.xA = game.wind.physicsSpeed
    o.yA = game_gravity
    o.x0 = game.controls2.x
    o.y0 = game.controls2.y

    o.enemyLeftX = game.castle1.leftX
    o.enemyRightX = game.castle1.rightX
    o.enemyTopY = game.castle1.topY
    o.enemyBottomY = game.castle1.bottomY

   print(o.enemyLeftX .. " " .. o.enemyRightX .. " | " .. o.enemyTopY .. " " .. o.enemyBottomY)

    return o
end

function AI:calculateAngle()
    for angle = 90, -90, -1 do
        local angleInRadians = math.rad(angle - (angle - 45) * 2)
        self.xV = self.speed * math.cos(angleInRadians)
        self.yV = -self.speed * math.sin(angleInRadians)

        local t = 50
        while t > 0 do
            local x = self.x0 + self.xV * t + self.xA * t * t / 2
            local y = self.y0 + self.yV * t + self.yA * t * t / 2
            if x > self.enemyLeftX and x < self.enemyRightX and y > self.enemyTopY and y < self.enemyBottomY then
                print("angle found!!!!!!!!!!!!!!! " .. angle)
                return angle
            end
            t = t - 0.1
        end
    end
    return -45 --todo: substitute later. we return this value if didn't find any real
end