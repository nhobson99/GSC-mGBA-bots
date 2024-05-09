-- NOTE: FOR NOW THIS SCRIPT IS CRYSTAL ONLY
-- Usage: Save just south of the north gate of the Ruins of Alph,
--  and put repels as your first bag item.
--  Then, just run the script.

-- Function to check if a given IV value is shiny
function isShiny(attack, defense, speed, special)
    return (special == 10 and speed == 10 and defense == 10 and ((attack & 2) > 0))
end

local state = emu:saveStateBuffer()
local totalEncounterCounter = 0
local previousFrame = emu:currentFrame() + 2
local buffer = console:createBuffer("Tracker")
local cb

-- OPTIONS

-- enemyAddr: Stores the memory location for wild Total encounters
-- Follow these instructions:
--      English Gold/Silver, set enemyAddr to 0xd0f5
--      Japanese Gold/Silver, set enemyAddr to 0xd0e7
--      Korean Gold/Silver, set enemyAddr to 0xd1b2
--      Japanese Crystal, set enemyAddr to 0xd23d
--      English Crystal, set enemyAddr to 0xd20c
local enemyAddr = 0xd20c

-- encounterDir1, encounterDir2
-- These are the directions to walk in to get into an encounter
-- It's best to use the corner method:
--     Align your character with a corner
--     The two directions with walls, use these as encounterDir1 and encounterDir2
local encounterDir1 = C.GB_KEY.RIGHT
local encounterDir2 = C.GB_KEY.DOWN

-- desiredSpecies
-- Tells the script which mon you are looking for
-- Look up the species ID here: https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_index_number_(Generation_II)
-- If -1, searches for all possible species
local desiredSpecies = 206

local routes = {
    0x1803,
    0x1a01,
    0x1a02,
    0x0a01,
    0x0806,
    0x0b01,
    0x0a02,
    0x0a03,
    0x0a04,
    0x010c,
    0x010d,
    0x0205,
    0x0905,
    0x0206,
    0x0508,
    0x0503
}

local route_names = {
    "r29",
    "r30",
    "r31",
    "r32",
    "r33",
    "r34",
    "r35",
    "r36",
    "r37",
    "r38",
    "r39",
    "r42",
    "r43",
    "r44",
    "r45",
    "r46"
}

function route_to_name(route_num)
    for i = 1, 16 do
        if route_num == routes[i] then
            return route_names[i]
        end
    end
    return ""
end

local routeChangeFrame = emu:currentFrame()

local repel_queue = {
    0,
    0,
    C.GB_KEY.START,
    C.GB_KEY.DOWN,
    C.GB_KEY.DOWN,
    C.GB_KEY.A,
    C.GB_KEY.A,
    C.GB_KEY.A,
    C.GB_KEY.B,
    C.GB_KEY.B,
    C.GB_KEY.B,
    0,
    0
}

local sr_queue = {
    0,
    0,
    C.GB_KEY.A,
    0,
    C.GB_KEY.A,
    0,
    C.GB_KEY.A,
    0,
    C.GB_KEY.A,
    0,
    0
}

function playQueue(frameNum, queue)
    if frameNum <= 0 then
        return
    end
    local i = math.floor(frameNum/50) + 1
    if i > #queue then
        return
    end
    if frameNum % 50 < 10 then
        console:log("" .. i)
        emu:addKey(queue[i])
        return
    end
end

local function test()
    emu:clearKey(C.GB_KEY.A)
    emu:clearKey(C.GB_KEY.B)
    emu:clearKey(C.GB_KEY.LEFT)
    emu:clearKey(C.GB_KEY.RIGHT)
    emu:clearKey(C.GB_KEY.DOWN)
    emu:clearKey(C.GB_KEY.UP)
    emu:clearKey(C.GB_KEY.START)
    emu:clearKey(C.GB_KEY.SELECT)

    local currentFrame = emu:currentFrame()
    playQueue(currentFrame - routeChangeFrame)
end

local reset = false
local resetFrame = emu:currentFrame()

-- Main function
local function onFrame()
    buffer:clear()

    emu:clearKey(C.GB_KEY.A)
    emu:clearKey(C.GB_KEY.B)
    emu:clearKey(C.GB_KEY.LEFT)
    emu:clearKey(C.GB_KEY.RIGHT)
    emu:clearKey(C.GB_KEY.DOWN)
    emu:clearKey(C.GB_KEY.UP)
    emu:clearKey(C.GB_KEY.START)
    emu:clearKey(C.GB_KEY.SELECT)

    local currentFrame = emu:currentFrame()
    local roamerMapGroup = emu:read8(0xdfd1)
    local roamerRoute = emu:read8(0xdfd2)
    local playerMapGroup = emu:read8(0xdcb5)
    local playerRoute = emu:read8(0xdcb6)

    if reset then
        if currentFrame - resetFrame > 1000 then
            reset = false
        else
            playQueue(currentFrame - resetFrame, sr_queue)
        end
    end

    if roamerMapGroup == playerMapGroup and roamerRoute == playerRoute then
        buffer:print("Roamer is on this route! Frame " .. currentFrame - routeChangeFrame)
        if (currentFrame - routeChangeFrame) <= ((1 + #repel_queue) * 50) then
            playQueue(currentFrame - routeChangeFrame, repel_queue)
            return
        end
        if emu:read8(enemyAddr+0x21) > 0 and emu:read8(enemyAddr+0x22) > 0 then
            -- Note: earlier versions of these scripts accidentally swapped speed and spec :)
            local enemyDVsAD = emu:read8(enemyAddr)
            local enemyDVsSS = emu:read8(enemyAddr+1)
            local defense = (enemyDVsAD & 0xF)
            local attack = (enemyDVsAD >> 4)
            local special = (enemyDVsSS & 0xF)
            local speed = (enemyDVsSS >> 4)

            totalEncounterCounter = totalEncounterCounter + 1
            console:log("Total encounters: " .. totalEncounterCounter)
            console:log("DVS: def(" .. defense .. ") atk(" .. attack .. ") speed(" .. speed .. ") spec(" .. special .. ")")
            buffer:clear()
            buffer:print("Total encounters: " .. totalEncounterCounter .. "\n")
            buffer:print("DVS: def(" .. defense .. ") atk(" .. attack .. ") speed(" .. speed .. ") spec(" .. special .. ")")

            if isShiny(attack, defense, speed, special) then
                console:log("Shiny Encounter! Total Encounters: " .. totalEncounterCounter)
                callbacks:remove(cb)
            else
                console:log("Reset")
                emu:addKey(C.GB_KEY.A)
                emu:addKey(C.GB_KEY.B)
                emu:addKey(C.GB_KEY.SELECT)
                emu:addKey(C.GB_KEY.START)
                reset = true
                resetFrame = currentFrame + 200
            end
            return
        end
        if currentFrame % 20 < 10 then
            emu:addKey(C.GB_KEY.LEFT)
        else
            emu:addKey(C.GB_KEY.UP)
        end
    else
        routeChangeFrame = currentFrame + 100
        if currentFrame % 500 < 250 then
            emu:addKey(C.GB_KEY.DOWN)
        else
            emu:addKey(C.GB_KEY.UP)
        end
    end
end

cb = callbacks:add("frame", onFrame)
-- cb = callbacks:add("frame", test)