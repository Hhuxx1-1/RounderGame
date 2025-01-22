-- Map Voting System
-- TO Do add Objective in Map Data and Time Play Duration; Each Map is Different;
local MAP_DATA = {
    {   key             =  "Map1"
    ,   Name            = "Asylum"
    ,   StateBlockId    =  501                      -- Determine State of Player special function for special alhoritm
    ,   PositionStart   = {x = 72, y = 5, z = 106}          --Must Contain x,y,z key and value is number where it represent Coordinate in Vector 3 
    ,   FacingStart     = 1                         -- 1, 2, 3, 4 is north , east , south , west    
    ,   RangeStart      = 2                         --Dimension Radius for Start
    ,   PositionMonster = {x = 83, y = 8 , z = 106 }
    ,   TimeDuration    = 180
    ,   SkyBoxTemplate  = 7
    ,   FilterTemplate  = 9
    ,   HourTime        = 4
    ,   ImageUrl        = "https://example.com/example.png"
    },
    {   key             = "Map2"
    ,   Name            = "Prison"
    ,   StateBlockId    =  537                       -- Determine State of Player special function for special alhoritm
    ,   PositionStart   = {x=183,y=5,z=113}          --Must Contain x,y,z key and value is number where it represent Coordinate in Vector 3 
    ,   FacingStart     = 2                          -- 1, 2, 3, 4 is north , east , south , west    
    ,   RangeStart      = 3                          --Dimension Radius for Start
    ,   PositionMonster = {x = 166, y = 6 , z = 113 }
    ,   TimeDuration    = 360
    ,   SkyBoxTemplate  = 7
    ,   FilterTemplate  = 7
    ,   HourTime        = 4
    ,   ImageUrl        = "https://example.com/example.png"
    },
    {   key             = "Map3"
    ,   Name            = "Basement      "
    ,   StateBlockId    =  208                       -- Determine State of Player special function for special alhoritm
    ,   PositionStart   = {x=138,y=13,z=183}         --Must Contain x,y,z key and value is number where it represent Coordinate in Vector 3 
    ,   FacingStart     = 1                          -- 1, 2, 3, 4 is north , east , south , west    
    ,   RangeStart      = 3                          --Dimension Radius for Start
    ,   PositionMonster = {x = 136, y = 11 , z = 202 }
    ,   TimeDuration    = 180
    ,   SkyBoxTemplate  = 7
    ,   FilterTemplate  = 7
    ,   HourTime        = 4
    ,   ImageUrl        = "https://example.com/example.png"
    }
}

MAP_VOTING = {
    AVAILABLE_MAPS = {}, -- this later will be assigned 3 maps from MAP_DATA;
    PLAYER_VOTES = {}, -- PlayerID to Map mapping
    VOTE_COUNTS = {}, -- Map to vote count mapping
    VOTING_TIME = 30, -- Voting duration in seconds
    VOTING_END_TIME = 0,
    SELECTED_MAP = nil, -- Stores the selected map
    VOTING_ACTIVE = false,
}

-- Function to shuffle a table using Fisher-Yates algorithm
local function shuffleTable(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

function MAP_VOTING:fetch(key)
    -- Function to fetch map data by key
    for _, map in ipairs(MAP_DATA) do
        if map.key == key then
            return map -- Return the map data if the key matches
        end
    end
    return nil -- Return nil if no matching map is found
end

-- Function to select 3 unique random maps
function MAP_VOTING:SelectRandomMaps()
    self.AVAILABLE_MAPS = {}
    local requiredMaps = 3

    if #MAP_DATA < requiredMaps then
        print("Not enough maps in MAP_DATA to select from.");
        return
    end

    -- Create a copy of MAP_DATA to avoid modifying the original table
    local mapsCopy = { unpack(MAP_DATA) }
    -- print("Maps Copy " , mapsCopy);
    -- Shuffle the copied maps
    shuffleTable(mapsCopy)

    -- Select the first 3 maps after shuffling
    for i = 1, requiredMaps do
        local selectedMap = mapsCopy[i]
        table.insert(self.AVAILABLE_MAPS, selectedMap.key)
    end

    print("Available Maps for Voting: " .. table.concat(self.AVAILABLE_MAPS, ", "))
end

MAP_VOTING.ShownMapVote_Data = {}

function MAP_VOTING:ClearShownMapVote ()
    local position = {
        {x=74,y=6,z=15}, {x=70,y=6,z=15} ,{x=66,y=6,z=15};
    }
    for i = 1 , 3 do
        Graphics:removeGraphicsByPos(position[i].x,position[i].y,position[i].z, i, 1)
        Graphics:removeGraphicsByPos(position[i].x,position[i].y,position[i].z, i+3, 1)
    end 
    MAP_VOTING.ShownMapVote_Data = {};
end

function MAP_VOTING:ShowMapVoting()
    local position = {
        {x=74,y=6,z=15}, {x=70,y=6,z=15} ,{x=66,y=6,z=15};
    }
    -- print("Available Maps data ",self.AVAILABLE_MAPS);
    for i = 1 , 3 do
        if MAP_VOTING.ShownMapVote_Data[i] == nil then
            local MapKey = self.AVAILABLE_MAPS[i];
            local MapData = MAP_VOTING:fetch(MapKey);
            -- print("index : "..i,"Key = "..MapKey,"Map Data : ",MapData);
            local MapName = MapData.Name;
            local vote = self.VOTE_COUNTS[MapKey];
            local r,areaid = Area:createAreaRect(position[i], {x=1,y=1,z=1});
            MAP_VOTING.ShownMapVote_Data[i] = {key = MapKey,MapName = MapName, VoteNum = vote , areaid = areaid};
        else 
        -- Display it to the world
            local fontsize , alpha = 13,60;
            local xx0,yy0,xx1,yy1 = 0 , 250 , 0 , -5;
            local GraphicsMapName = Graphics:makeGraphicsText("#cdddd00  "..MAP_VOTING:fetch(self.AVAILABLE_MAPS[i]).Name.."      ", fontsize,alpha, i);
            local VoteNum = Graphics:makeGraphicsText("#c00ff00  "..self.VOTE_COUNTS[self.AVAILABLE_MAPS[i]].." Vote    ",  fontsize,alpha, i+3);
            local result,graphid1 = Graphics:createGraphicsTxtByPos(
            position[i].x,position[i].y,position[i].z,
            GraphicsMapName,xx0, yy0);
            local result , graphid2 = Graphics:createGraphicsTxtByPos(
            position[i].x,position[i].y,position[i].z,
            VoteNum,xx1,yy1);
        end 
    end 
    Graphics:snycGraphicsInfo2Client()
end 

-- Start the voting phase
function MAP_VOTING:StartVoting(currentSecond)
    self:SelectRandomMaps();
    self.PLAYER_VOTES = {};
    self.VOTE_COUNTS = {};
    for _, map in ipairs(self.AVAILABLE_MAPS) do
        self.VOTE_COUNTS[map] = 0
    end

    self.VOTING_END_TIME = currentSecond + self.VOTING_TIME;
    self.VOTING_ACTIVE = true;
    -- print("Voting started! Choose a map: " .. table.concat(self.AVAILABLE_MAPS, ", "))
    self:ShowMapVoting()
end

-- Cast a vote for a map
function MAP_VOTING:Vote(playerID, map)
    if not self.VOTING_ACTIVE then
        print("Voting is not active!")
        return
    end

    if not self.VOTE_COUNTS[map] then
        print("Invalid map selected: " .. map)
        return
    end

    -- Remove the previous vote if the player voted before
    local previousVote = self.PLAYER_VOTES[playerID]
    if previousVote then
        self.VOTE_COUNTS[previousVote] = self.VOTE_COUNTS[previousVote] - 1
    end

    -- Record the new vote
    self.PLAYER_VOTES[playerID] = map
    self.VOTE_COUNTS[map] = self.VOTE_COUNTS[map] + 1
    print("Player " .. playerID .. " voted for " .. map)
end

-- Tally votes and select a map
function MAP_VOTING:EndVoting()
    if not self.VOTING_ACTIVE then
        print("Voting is not active!")
        return
    end

    self.VOTING_ACTIVE = false
    local highestVotes = 0
    local candidates = {}

    -- Determine the map(s) with the highest votes
    for map, count in pairs(self.VOTE_COUNTS) do
        if count > highestVotes then
            highestVotes = count
            candidates = { map }
        elseif count == highestVotes then
            table.insert(candidates, map)
        end
    end

    -- Select a map randomly if there is a tie
    if #candidates > 0 then
        self.SELECTED_MAP = candidates[math.random(#candidates)]
        print("Map selected: " .. self.SELECTED_MAP)
    else
        print("No votes cast. Defaulting to the first map: " .. self.AVAILABLE_MAPS[1])
        self.SELECTED_MAP = self.AVAILABLE_MAPS[1]
    end

    MAP_VOTING:ClearShownMapVote();
end

-- -- Periodically check for voting end
-- ScriptSupportEvent:registerEvent("Game.RunTime", function(event)
--     if MAP_VOTING.VOTING_ACTIVE and event.second >= MAP_VOTING.VOTING_END_TIME then
--         MAP_VOTING:EndVoting()
--     end
-- end)

-- Command for players to vote
-- ScriptSupportEvent:registerEvent("Player.Command", function(playerID, command)
--     local cmd, map = command:match("(%S+)%s*(%S*)")
--     if cmd == "/vote" then
--         MAP_VOTING:Vote(playerID, map)
--     end
-- end)
ScriptSupportEvent:registerEvent("Player.AreaIn",function(e)
    local playerid = e.eventobjid;
    local areaid = e.areaid;
    -- check 
    print(MAP_VOTING.ShownMapVote_Data);
    for i,a in ipairs(MAP_VOTING.ShownMapVote_Data) do 
        if areaid == a.areaid then 
            MAP_VOTING:Vote(playerid,a.key);
        end 
    end 
end)