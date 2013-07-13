module(..., package.seeall);

local customUI = require("scripts.util.CustomUI")
local controls_module = require("scripts.Controls")

TutorialScreen = {}

-- Constructor
function TutorialScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    self.finisheTutorial = false

    return o
end

function TutorialScreen:render()
    self.tutorialGroup = display.newGroup()

    local imageWidth = display.contentWidth
    local imageHeight = display.contentHeight
    local imageAspectRatio = imageWidth / imageHeight
    if display.screenOriginX ~= 0 then
        imageWidth = display.contentWidth - 2 * display.screenOriginX
        imageHeight = imageWidth / imageAspectRatio
    elseif display.screenOriginY ~= 0 then
        imageHeight = display.contentHeight - 2 * display.screenOriginY
        imageWidth = imageHeight * imageAspectRatio
    else
        imageWidth = display.contentWidth
        imageHeight = display.contentHeight
    end

    self.alphaRect = display.newRect(0, 0, imageWidth, imageHeight)
    self.alphaRect.alpha = 0
    self.alphaRect:setReferencePoint(display.CenterReferencePoint)
    self.alphaRect:setFillColor(0, 0, 0, 255)
    self.alphaRect.alpha, self.alphaRect.x, self.alphaRect.y = 0.6, display.contentWidth / 2, display.contentHeight / 2
    self.tutorialGroup:insert(self.alphaRect)

    local step1 = display.newGroup()    
    self.tutorialGroup:insert(step1)

    timer.performWithDelay(100, function()
            step1:removeSelf()
            local step2 = display.newGroup()    
            self.tutorialGroup:insert(step2)
            local message = customUI.PPText:new("Drag to adjust the firing angle!", display.contentWidth / 2, display.contentHeight / 4, 28, step2)
            message:dance()
            local sampleControls = controls_module.Controls:new(
                { angle = 45, x = display.contentWidth / 2, y = display.contentHeight / 2, container = step2,
                onFire = function(event)
                    if event.phase == "ended" and self.finisheTutorial then
                        self.finisheTutorial = false
                        self.game:goto("TURN_P1")
                    end
                    return true
                end})
            
            sampleControls:setCoordinates()
            sampleControls:render()

            timer.performWithDelay(1000, function()
                local hand = display.newImageRect("images/hand.png", 42, 62)
                hand.alpha = 0
                hand:setReferencePoint(display.CenterReferencePoint)
                hand.x, hand.y = display.contentWidth / 2 - 25, display.contentHeight / 2 + 115
                transition.to(hand, {alpha = 1, time = 200, onComplete = function()                        
                        -- moving forward
                        local angleAnim = timer.performWithDelay(100, function()
                                sampleControls.angleLine.rotation = sampleControls.angleLine.rotation + 1
                                sampleControls.angleText.text = sampleControls.angleLine.rotation .. "°"
                            end, 20)
                        transition.to(hand, {x = display.contentWidth / 2 + 25, time = 2000, onComplete = function()
                                timer.cancel(angleAnim)

                                -- moving back
                                angleAnim = timer.performWithDelay(100, function()
                                        sampleControls.angleLine.rotation = sampleControls.angleLine.rotation - 1
                                        sampleControls.angleText.text = sampleControls.angleLine.rotation .. "°"
                                    end, 20)
                                transition.to(hand, {x = display.contentWidth / 2 - 25, time = 2000, onComplete = function()
                                    timer.cancel(angleAnim)

                                    message:newText("Now try dragging it to 57°...")
                                    message:dance()
                                    transition.to(hand, {alpha = 0, time = 1000, onComplete = function()
                                            timer.performWithDelay(100, function(event)
                                                    if sampleControls.angleLine.rotation >= 57 then
                                                        message:newText("Good, and now fire!")
                                                        message:dance()
                                                        self.finisheTutorial = true
                                                        timer.cancel(event.source)
                                                    end
                                                end, 0)
                                        end})                                    
                                end})
                            end})
                    end})
                end)

        end)
    
end

function TutorialScreen:dismiss()
    transition.to( self.alphaRect, { time=400, alpha=0, onComplete=function()
        self.alphaRect:removeSelf()
        self.alphaRect = nil
    end } )
    transition.to( self.tutorialGroup, { time=400, alpha=0, onComplete=function()
        self.tutorialGroup:removeSelf()
        self.tutorialGroup = nil
    end } )
end

