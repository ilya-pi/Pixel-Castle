module(..., package.seeall)

require("sqlite3")

DbWrapper = {}

local function init()
    local path = system.pathForFile( "castle.db", system.DocumentsDirectory )
    local db = sqlite3.open(path)


    --levels setup
    local levelsTableSetup = [[CREATE TABLE IF NOT EXISTS levels (
                                id integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,
                                position integer  NOT NULL DEFAULT 0,
                                screen integer  NOT NULL DEFAULT 0,
                                stars integer  NOT NULL DEFAULT 0,
                                status TEXT  NOT NULL
                               );]]
    --[[
        position - level position, absolute within a screen
        screen - level group, consist of 15 levels at the moment
        stars - reserved value for future use
        status - "locked", "new", "done"
    ]]
    db:exec(levelsTableSetup)
    local levelsCount = 0
    for row in db:nrows("SELECT * FROM levels") do
        levelsCount = levelsCount + 1
    end

    if levelsCount == 0 then
        for screenNumber = 1, #game.levelConfig.screens do
            local levels = game.levelConfig.screens[screenNumber].levels
            for levelNumber = 1, #levels do
                local addLevel = [[INSERT INTO levels VALUES (NULL, ]] .. levelNumber .. [[, ]] .. screenNumber .. [[, 0, 'locked');]]
                db:exec(addLevel)
            end
        end
        local updateFirstLevel = [[UPDATE levels SET status='new' WHERE position=1 AND screen=1;]]
        db:exec(updateFirstLevel)
    end


    --players setup
    local playerTableSetup = [[CREATE TABLE player (
                                id integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,
                                name TEXT  NOT NULL,
                                level integer  NOT NULL DEFAULT 0,
                                screen integer  NOT NULL DEFAULT 0
                               );]]
    --[[
        position - level position, absolute within a screen
        name - player name
        level - active level number
        screen - active screen number
    ]]
    db:exec(playerTableSetup)
    local playersCount = 0
    for row in db:nrows("SELECT * FROM player") do
        playersCount = playersCount + 1
    end

    if playersCount == 0 then
        local addDefaultPlayer = [[INSERT INTO player VALUES (NULL, 'Player1', 1, 1);]]
        db:exec(addDefaultPlayer)
    end

    return db
end

-- Constructor
function DbWrapper:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.db = init()
    return o
end

function DbWrapper:levelComplete(level, screen)
    --todo: check if it's last level and/or last screen
    local setPlayerCurrentLevel = [[UPDATE player SET level=]] .. level + 1 .. [[, screen=]] .. screen .. [[;]]
    self.db:exec(setPlayerCurrentLevel)

    local doneLevel = [[UPDATE levels SET status='done' WHERE position=]] .. level .. [[ AND screen=]] .. screen .. [[;]]
    self.db:exec(doneLevel)

    local unlockLevel = [[UPDATE levels SET status='new' WHERE position=]] .. level + 1 .. [[ AND screen=]] .. screen .. [[;]]
    self.db:exec(unlockLevel)
end

function DbWrapper:getLevels(screen)
    --todo: think about screens
    local i = 1
    local levels = {}
    for row in self.db:nrows("SELECT * FROM levels WHERE screen=" .. screen .. ";") do
        --print(i .. ":" .. row.status .. " position=" .. row.position .. " screen=" .. row.screen)
        levels[i] = row
        i = i + 1
    end
    return levels
end

