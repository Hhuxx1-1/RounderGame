local MAP_DATA = {};
-- Function to add a new map into MAP_DATA
function REGISTER_MAP(data)
    -- Validate required fields
    if not data.Name or not data.StateBlockId or not data.PositionStart or not data.PositionMonster or not data.TimeDuration then
        print("Error: Missing required map data fields.")
        return false
    end

    -- Ensure PositionStart and PositionMonster have valid coordinates
    if not (data.PositionStart.x and data.PositionStart.y and data.PositionStart.z) then
        print("Error: Invalid PositionStart coordinates.")
        return false
    end
    if not (data.PositionMonster.x and data.PositionMonster.y and data.PositionMonster.z) then
        print("Error: Invalid PositionMonster coordinates.")
        return false
    end

    -- Generate a unique key for the new map
    local newIndex = #MAP_DATA + 1
    local newKey = "Map" .. newIndex

    -- Create the new map entry
    local newMap = {
        key             = newKey,
        Name            = data.Name,
        StateBlockId    = data.StateBlockId,
        PositionStart   = data.PositionStart,
        FacingStart     = data.FacingStart      or 1, -- Default to 1 (north)
        RangeStart      = data.RangeStart       or 3, -- Default radius
        PositionMonster = data.PositionMonster,
        TimeDuration    = data.TimeDuration,
        SkyBoxTemplate  = data.SkyBoxTemplate   or 7, -- Default skybox template
        FilterTemplate  = data.FilterTemplate   or 7, -- Default filter template
        HourTime        = data.HourTime         or 4, -- Default hour time
        ImageUrl        = data.ImageUrl         or [[4003021]], -- Default image URL
        Prop            = data.Prop             or {},
        Objective       = data.Objective        or function() return "No Objective" end,
    }

    -- Insert the new map into the MAP_DATA table
    table.insert(MAP_DATA, newMap)
    print("New map registered successfully with key:", newKey)
    return true
end


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
            -- make a copy 
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
      --print("Not enough maps in MAP_DATA to select from.");
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

  --print("Available Maps for Voting: " .. table.concat(self.AVAILABLE_MAPS, ", "))
end

MAP_VOTING.ShownMapVote_Data = {}

function MAP_VOTING:ClearShownMapVote ()
    local position = {
        {x=74,y=6,z=15}, {x=70,y=6,z=15} ,{x=66,y=6,z=15};
    }
    local billboard = {
        40000000,40000001,40000002
    }
    for i = 1 , 3 do
        Graphics:removeGraphicsByPos(position[i].x,position[i].y,position[i].z, i, 1)
        Graphics:removeGraphicsByPos(position[i].x,position[i].y,position[i].z, i+3, 1)
        -- display picture on billboard
        local result,num,allPlayer=World:getAllPlayers(-1)

        for _,playerid in ipairs(allPlayer) do 
            local result = DisPlayBoard:setBoardPicture(playerid, billboard[i],[[8_1029380338_1711289202]]);
        end 
    end 
    MAP_VOTING.ShownMapVote_Data = {};
end

function MAP_VOTING:ShowMapVoting()
    local position = {
        {x=74,y=6,z=15}, {x=70,y=6,z=15} ,{x=66,y=6,z=15};
    }
    local billboard = {
        40000000,40000001,40000002
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
            MAP_VOTING.ShownMapVote_Data[i] = {key = MapKey,MapName = MapName, VoteNum = vote , areaid = areaid, pic = MapData.ImageUrl};
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
            -- display picture on billboard
            local result,num,allPlayer=World:getAllPlayers(-1)

            for _,playerid in ipairs(allPlayer) do 
                local result = DisPlayBoard:setBoardPicture(playerid, billboard[i],MAP_VOTING.ShownMapVote_Data[i].pic);
            end 

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
      --print("Voting is not active!")
        return
    end

    if not self.VOTE_COUNTS[map] then
      --print("Invalid map selected: " .. map)
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
  --print("Player " .. playerID .. " voted for " .. map)
end

-- Tally votes and select a map
function MAP_VOTING:EndVoting()
    if not self.VOTING_ACTIVE then
      --print("Voting is not active!")
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
      --print("Map selected: " .. self.SELECTED_MAP)
    else
      --print("No votes cast. Defaulting to the first map: " .. self.AVAILABLE_MAPS[1])
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
  --print(MAP_VOTING.ShownMapVote_Data);
    for i,a in ipairs(MAP_VOTING.ShownMapVote_Data) do 
        if areaid == a.areaid then 
            MAP_VOTING:Vote(playerid,a.key);
        end 
    end 
end)