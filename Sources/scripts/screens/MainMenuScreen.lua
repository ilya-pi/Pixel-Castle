module(..., package.seeall)

local widget = require("widget")

local Memmory = require("scripts.util.Memmory")
local imageHelper = require("scripts.util.Image")
local customUI = require("scripts.util.CustomUI")

MainMenuScreen = {}

-- Constructor
function MainMenuScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    self.assets = imageHelper.loadImageData("data/assets.json")
    self.textMarginTop = 50 --todo: Ilya Pimenov after your last commit this variable disappeared so I'm not sure where it should be
    return o
end

function MainMenuScreen:render()
    self.displayGroup = display.newGroup()

    local bgHeight = display.contentHeight - 2 * display.screenOriginY
    local bgWidth = bgHeight * 128 / 40

    self.bg = imageHelper.ourImage("images/castle_splash.png", bgWidth, bgHeight, self.displayGroup)
    self.bg2 = imageHelper.ourImage("images/castle_splash.png", bgWidth, bgHeight, self.displayGroup)
    self.bg.x, self.bg.y = display.screenOriginX, display.screenOriginY
    self.bg2.x, self.bg2.y = display.screenOriginX + bgWidth, display.screenOriginY

    Memmory.timerStash.bgMovementTimer = timer.performWithDelay(30, function()
        self.bg.x = self.bg.x - 1
        self.bg2.x = self.bg2.x - 1

        if self.bg.x <= display.screenOriginX - bgWidth then
            local tmp = self.bg
            self.bg = self.bg2
            self.bg2 = tmp
            self.bg2.x = self.bg.x + bgWidth
        end
    end, 0)

    local overlay = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth - 2 * display.screenOriginX, display.contentHeight - 2 * display.screenOriginY)
    overlay:setFillColor(game.MAIN_GRADIENT)
    self.displayGroup:insert(overlay)
end

function MainMenuScreen:showMainMenu()
    self.mainMenuGroup = display.newGroup()
    self.displayGroup:insert(self.mainMenuGroup)

    local play = customUI.button(140, 40, "playbtn", "Play", function(event)
            self.game:goto("PLAYMENU")
            return true
        end, self.mainMenuGroup, 5 * display.contentWidth / 7 + 20, 210)

    local options = customUI.button(140, 40, "optionsbtn", "Options", function(event)
            self.game:goto("OPTIONS")
            return true
        end, self.mainMenuGroup, 5 * display.contentWidth / 7 + 20, 260)

    local logo = imageHelper.ourImage("images/title.png", 175, 80, self.mainMenuGroup)
    logo.x, logo.y = 4 * display.contentWidth / 7, display.contentHeight / 6
end

function MainMenuScreen:hideMainMenu()
    self.mainMenuGroup:removeSelf()
    self.mainMenuGroup = nil
end

function MainMenuScreen:showPlayMenu()
    self.playMenuGroup = display.newGroup()
    self.displayGroup:insert(self.playMenuGroup)

    local logo = imageHelper.ourImage("images/title.png", 175, 80, self.playMenuGroup)
    logo.x, logo.y = 4 * display.contentWidth / 7, display.contentHeight / 6

    customUI.button(170, 40, "story_mode_btn", "Story Mode", function(event)
            self.game:goto("LEVELSELECT")
            print("tutorial in story mode")
            return true
        end, self.playMenuGroup, display.contentWidth / 4, 260)

    customUI.button(170, 40, "story_mode_btn", "Versus Mode", function(event)
            self.game:goto("LEVEL_INTRO")
            print("versus mode")
            return true
        end, self.playMenuGroup, display.contentWidth / 4 * 3, 260)

    customUI.backBtn(function(event)
            self.game:goto("MAINMENU")
            return true
        end, self.playMenuGroup)
end

function MainMenuScreen:showLevelSelect()
    self.levelSelectGroup = display.newGroup()
    self.levelsGroup = display.newGroup()
    self.levelSelectGroup:insert(self.levelsGroup)

    local levelNumberTextSize = 16
    local levelNumberTextPaddingTop = 2
    local textSize = 25
    local layerSelectMagicYnumber = 15 --it's only one configuration number everything else should be calculated automatically

    local castleSize = 50
    local rawsCount = 2
    local columnsCount = 3

    -- local rowsCount = 3
    -- local columnsCount = 5

    local levelsGroupViewportWidth = display.contentWidth - 2 * display.screenOriginX
    local levelsGroupViewportHeight = display.contentHeight - 2 * display.screenOriginY - self.textMarginTop - textSize / 2
    local castleXdistance = levelsGroupViewportWidth / (columnsCount + 1)
    local castleYdistance = levelsGroupViewportHeight / (rawsCount + 1)

    customUI.text("Level select", display.contentWidth / 2, self.textMarginTop + display.screenOriginY, textSize, self.levelSelectGroup)

    local levels = self.game.db:getLevels(1) --todo: think about different screens

    for raw = 1, rawsCount do
        for column = 1, columnsCount do
            local levelNumber = (raw - 1) * columnsCount + column
            local castleX, castleY = ((column - 1) * castleXdistance), ((raw - 1) * castleYdistance)
            --local castle = display.newImageRect("images/choose_level/level_select_castle.png", castleSize, castleSize)

            local defaultFile
            local overFile
            local onRelease

            --status - "locked", "new", "done"
            local goto = "LEVEL_INTRO" --todo: move to db
            if levelNumber == 1 then
                goto = "TUTORIAL"
            end

            if levels[levelNumber].status == "done" then
                --todo: accomplished level
                customUI.text(levelNumber, castleX, castleY + levelNumberTextPaddingTop, levelNumberTextSize, self.levelsGroup)
                defaultFile = "images/choose_level/level_select_castle_accomplished.png"
                overFile = "images/choose_level/level_select_castle_accomplished_pushed.png"
                onRelease = function(event)
                    if event.phase == "ended" then
                        self.game.selectedLevel = levelNumber
                        self.game:goto(goto)
                    end
                end
            elseif levels[levelNumber].status == "new" then
                --todo current level
                customUI.text(levelNumber, castleX, castleY + levelNumberTextPaddingTop, levelNumberTextSize, self.levelsGroup)
                defaultFile = "images/choose_level/level_select_castle_current.png"
                overFile = "images/choose_level/level_select_castle_current_pushed.png"
                onRelease = function(event)
                    if event.phase == "ended" then
                        self.game.selectedLevel = levelNumber
                        self.game:goto(goto)
                    end
                end
            elseif levels[levelNumber].status == "locked" then
                --todo locked level
                defaultFile = "images/choose_level/level_select_castle_locked.png"
                overFile = "images/choose_level/level_select_castle_locked_pushed.png"
                onRelease = function(event)
                    return true
                end
            end

            local castle = widget.newButton{
                width = castleSize,
                height = castleSize,
                defaultFile = defaultFile,
                overFile = overFile,
                onRelease = onRelease
            }
            castle:setReferencePoint(display.CenterReferencePoint)
            castle.x, castle.y = castleX, castleY

            self.levelsGroup:insert(1, castle)

        end
    end
    self.levelsGroup:setReferencePoint(display.CenterReferencePoint)
    self.levelsGroup.x = display.contentWidth / 2
    self.levelsGroup.y = display.contentHeight / 2 + self.textMarginTop - layerSelectMagicYnumber

    customUI.backBtn(function(event)
            self.game:goto("PLAYMENU")
            return true
        end, self.levelSelectGroup)
end

function MainMenuScreen:hideLevelSelect()
    self.levelsGroup:removeSelf()
    self.levelsGroup = nil
    self.levelSelectGroup:removeSelf()
    self.levelSelectGroup = nil
end

function MainMenuScreen:hidePlayMenu()
    self.playMenuGroup:removeSelf()
    self.playMenuGroup = nil
end

function MainMenuScreen:showOptionsMenu()
    self.optionsMenuGroup = display.newGroup()
    self.displayGroup:insert(self.optionsMenuGroup)

    local width = (-2 * display.screenOriginX + display.contentWidth)
    local height = -2 * display.screenOriginY + display.contentHeight

    local viewWidth = 2 * width / 3
    local viewHeight = height / 2
    local xOffset = display.screenOriginX + (width - viewWidth) / 2
    local yOffset = display.screenOriginY + height / 4
    local padding = 25
    local lineH = viewHeight / 8

    customUI.text("Options", display.contentWidth / 2, 50 + display.screenOriginY, 25, self.optionsMenuGroup)

    local bg = display.newImageRect("images/button.png", viewWidth, viewHeight)
    self.optionsMenuGroup:insert(bg)
    bg:setReferencePoint(display.TopLeftReferencePoint)
    bg.x, bg.y = xOffset, yOffset

    customUI.text("BGM volume", xOffset + padding, yOffset + 1 * lineH, 19, self.optionsMenuGroup, display.TopLeftReferencePoint)
    self.optionsMenuGroup:insert(customUI.slider(xOffset + viewWidth - padding, yOffset + 1 * lineH, 150, "sfxVolumeSlider",
        self.game.sfxVolume,
        function(event)
            local slider = event.target
            local value = event.value
            self.game.sfxVolume = value
        end))

    customUI.text("SFX volume", xOffset + padding, yOffset + 3 * lineH, 19, self.optionsMenuGroup, display.TopLeftReferencePoint)
    self.optionsMenuGroup:insert(customUI.slider(xOffset + viewWidth - padding, yOffset + 3 * lineH, 150, "bgmVolumeSlider",
        self.game.bgmVolume,
        function(event)
            local slider = event.target
            local value = event.value
            self.game.bgmVolume = value
        end))

    customUI.text("Vibration", xOffset + padding, yOffset + 5 * lineH, 19, self.optionsMenuGroup, display.TopLeftReferencePoint)
    local astroSwitch = customUI.AstroSwitch:new("images/toggle_on.png", "images/toggle_off.png", "images/toggle_transition.png", 
        xOffset + viewWidth - padding, yOffset + 5 * lineH
        , display.TopRightReferencePoint, 106, 31, true, function(isOn)
            self.game.vibration = isOn
            if isOn then
                system.vibrate()
            end
        end, self.optionsMenuGroup)    

    customUI.button(170, 40, "credits_id", "Credits", function(event)
            self.game:goto("CREDITS")
            return true
        end, self.optionsMenuGroup, display.contentWidth / 2, yOffset + viewHeight + 1.5 * padding)

    customUI.backBtn(function(event)
            self.game:goto("MAINMENU")
            return true
        end, self.optionsMenuGroup)
end

function MainMenuScreen:hideOptionsMenu()
    self.optionsMenuGroup:removeSelf()
    self.optionsMenuGroup = nil
end

function MainMenuScreen:showCredits()
    self.creditsGroup = display.newGroup()
    self.displayGroup:insert(self.creditsGroup)

    local width = (-2 * display.screenOriginX + display.contentWidth)
    local height = -2 * display.screenOriginY + display.contentHeight

    local viewWidth = 2 * width / 3
    local viewHeight = height / 2
    local xOffset = display.screenOriginX + (width - viewWidth) / 2
    local yOffset = display.screenOriginY + height / 4
    local padding = 25
    local lineH = viewHeight / 7

    customUI.text("Credits", display.contentWidth / 2, 50 + display.screenOriginY, 25, self.creditsGroup)

    local bg = display.newImageRect("images/button.png", viewWidth, viewHeight)
    self.creditsGroup:insert(bg)
    bg:setReferencePoint(display.TopLeftReferencePoint)
    bg.x, bg.y = xOffset, yOffset

    customUI.text("Hacked by", xOffset + padding, yOffset + 1 * lineH, 19, self.creditsGroup, display.TopLeftReferencePoint)
    customUI.text("Designed by", xOffset + padding, yOffset + 4 * lineH, 19, self.creditsGroup, display.TopLeftReferencePoint)

    customUI.text("Ilya Pimenov", xOffset + viewWidth - padding, yOffset + 1 * lineH, 19, self.creditsGroup, display.TopRightReferencePoint)
    customUI.text("Sergey Belyakov", xOffset + viewWidth - padding, yOffset + 2 * lineH, 19, self.creditsGroup, display.TopRightReferencePoint)
    customUI.text("Rodrigo Maselli", xOffset + viewWidth - padding, yOffset + 4 * lineH, 19, self.creditsGroup, display.TopRightReferencePoint)


    customUI.button(260, 40, "websitebtnid", "Website", function(event)
            system.openURL("http://ilyapimenov.com")
            return true
        end, self.creditsGroup, display.contentWidth / 2, yOffset + viewHeight + 1.5 * padding)

    -- local website = widget.newButton{
    --     width = 260,
    --     height = 40,
    --     defaultFile = "images/button.png",
    --     overFile = "images/button_over.png",
    --     id = "websitebtnid",
    --     label = "Astroberries website",
    --     font = "TrebuchetMS-Bold",
    --     fontSize = 19,
    --     labelColor = { default = { 255 }, over = { 0 } },
    --     onRelease = function(event)
    --         system.openURL("http://ilyapimenov.com")
    --         return true
    --     end
    -- }
    -- website.x, website.y = display.contentWidth / 2, yOffset + viewHeight + 1.5 * padding
    -- self.creditsGroup:insert(website)

    local backButton = widget.newButton{
        width = 60,
        height = 60,
        defaultFile = "images/menus_common/back_button.png",
        overFile = "images/menus_common/back_button_tapped.png",
        onRelease = function(event)
            self.game:goto("OPTIONS")
            return true
        end
    }
    backButton:setReferencePoint(display.TopLeftReferencePoint)
    backButton.x, backButton.y = display.screenOriginX, display.screenOriginY
    self.creditsGroup:insert(backButton)
end

function MainMenuScreen:hideCredits()
    -- todo dismiss credits transition
    self.creditsGroup:removeSelf()
    self.creditsGroup = nil
end



function MainMenuScreen:dismiss()
    timer.cancel(Memmory.timerStash.bgMovementTimer)
    if self.bg ~= nil then
        self.bg:removeSelf()
        self.bg = nil
    end

    if self.mainMenuGroup ~= nil then
        self.mainMenuGroup:removeSelf()
        self.mainMenuGroup = nil
    end
    if self.levelsGroup ~= nil then
        self.levelsGroup:removeSelf()
        self.levelsGroup = nil
    end
    if self.levelSelectGroup ~= nil then
        self.levelSelectGroup:removeSelf()
        self.levelSelectGroup = nil
    end
    if self.playMenuGroup ~= nil then
        self.playMenuGroup:removeSelf()
        self.playMenuGroup = nil
    end

    if self.displayGroup ~= nil then
        self.displayGroup:removeSelf()
        self.displayGroup = nil
    end

end
