-- Constants
local GAME_SECOND = 0
local UI = "7453424227180026098" -- UI element ID, kept local to avoid conflicts
UIS = {
    -- list of UI ;
        Lobby_UI                = "7455624551810668786"
    ,   Notify_UI               = "7455620892498532594"
    ,   Timer_UI                = "7456653557255313650" 
    ,   Loading_UI              = "7456408812838918386"
    ,   Monster_UI              = "7455561304122267890"
    ,   Survivor_UI             = "7455201304258484466"
    ,   Intro_UI                = "7456895252244928754"
    ,   GameOver_UI             = "7457398416253589746"
}

-- Utility function to generate UI element IDs
local function generateUIElementID(index)
    return UI .. "_" .. index
end

-- helper function to get length of dynamic table
local function tlen(t)
    local c = 0;
    for i ,a in pairs(t) do 
        c = c + 1 ;
    end 
    return c ; 
end 

-- Global ROUND table for managing game state
ROUND = {
    STATE = "Init",
    PLAYER_READY = {}, -- List of players ready for the round
    TIME_START = 0,
    TIME_END = 0,
    GAME_STARTED = false,
    MATCH_STARTED = false,
    MONSTER = {},
    SURVIVOR = {},
    TIME_DURATION = 120, -- Default game duration in seconds
    TIME_INTERMISSION_DURATION = 40, -- Intermission duration
    TRANSITION_DURATION = 5, -- Transition duration between states
    UI_STATE = "lobby",
    GAME_DATA_NOW = {}
}

ROUND.UI_PLAYER_STATE = { --contain pack of UI to be Opened in that state 
    lobby = {UIS.Lobby_UI,UIS.Notify_UI},
    transition = {UIS.Intro_UI}
}
-- Predefined block states
local RoundBlockState = {
    ["104"] = "lobby",
    ["0"] = " ",
}

-- State-specific data
local StateData = {
    lobby = {
        position = { x = 70, y = 5, z = 26 },
        face = { yaw = 0, pitch = 0 },
    },
}

function ROUND:ShowInvalid(players) 
    local ui_countdown , ui_elementid = "7455620892498532594", "_2";
    for _, playerid  in ipairs(players) do
        local text = {"Need 2 Player to Start Game"};
        if T_Text then --check if Translation Function Exist ;
            for i,a in ipairs(text) do 
                text[i] = T_Text(playerid,a);
            end 
        end 
        Customui:setText(playerid,ui_countdown,ui_countdown..ui_elementid,text[1]);
    end 
end 

function ROUND:removeDuplicates()
    local uniquePlayers = {}
    local cleanedList = {}

    for _, player in ipairs(self.PLAYER_READY) do
        if not uniquePlayers[player] then
            uniquePlayers[player] = true
            table.insert(cleanedList, player)
        end
    end

    self.PLAYER_READY = cleanedList
end


-- Function to initialize a new round
function ROUND:NEW(currentSecond,players)

    ROUND:removeDuplicates();

    if tlen(self.PLAYER_READY) < 2 then
        self:ShowInvalid(players)
        return
    end
    self.TIME_START = currentSecond + self.TIME_INTERMISSION_DURATION
    self.TIME_END = self.TIME_START + self.TIME_DURATION
    self.STATE = "Matching"
end

-- Function to clear round data
function ROUND:CLEAR()
    self.PLAYER_READY = {}
    self.STATE = "Init"
    self.MONSTER = {}
    self.SURVIVOR = {}
end

-- Function to select monsters and survivors
function ROUND:SELECT(numMonsters)
    -- make sure it is clean before selecting
    ROUND:removeDuplicates();

    self.MONSTER = {}
    self.SURVIVOR = {}

    if numMonsters > tlen(self.PLAYER_READY) then
        print("Not enough players to select as monsters!")
        self:CLEAR()
        return
    end

    local readyPlayers = { unpack(self.PLAYER_READY) }

    -- Select monsters randomly
    for i = 1, numMonsters do
        local randomIndex = math.random(1, #readyPlayers)
        local selectedPlayer = table.remove(readyPlayers, randomIndex)
        table.insert(self.MONSTER, selectedPlayer)
    end

    -- Assign remaining players as survivors
    self.SURVIVOR = readyPlayers

    print("Monsters: ", table.concat(self.MONSTER, ", "))
    print("Survivors: ", table.concat(self.SURVIVOR, ", "))
end

-- Function to check a player's zone state
function ROUND:CheckPlayerZoneState(playerID)
    local result, x, y, z = Actor:getPosition(playerID)
    if result == 0 then
        local blockResult, blockID = Block:getBlockID(x, 1, z)
        if blockResult == 0 then
            return RoundBlockState[tostring(blockID)] or "Unknown" , blockID;
        else
            return "Block ID not found"
        end
    end
end

-- Function to set notifications for players
function ROUND:setNotifierSystem(text, players)
    for _, playerID in ipairs(players) do
        Customui:setText(playerID, UI, generateUIElementID(2), text)
    end
end

ROUND.PLAYER_STATE_NOW = "";
ROUND.NOT_PLAYER_STATE = { --Contain Function to be Executed if Player is not in that State;
    ["lobby"] = function(playerid)
        Actor:killSelf(playerid);
        Player:reviveToPos(playerid, 70+math.random(-2,2),6,26+math.random(-2,2));
    end
}

function ROUND:setState(state)
    ROUND.PLAYER_STATE_NOW = string.lower(state);
end 

local function openLobbyUI(playerid)
    Player:openUIView(playerid,UIS.Lobby_UI);
    Player:openUIView(playerid,UIS.Notify_UI);
    Player:hideUIView(playerid,UIS.Monster_UI);
    Player:hideUIView(playerid,UIS.Survivor_UI);
end

local function UI_STATE(state,players) -- function to control lobby and intermission and Loading Screen;

    if state == "lobby" then 
        for _, playerid in ipairs(players) do

            Player:hideUIView(playerid,UIS.Monster_UI);
            Player:hideUIView(playerid,UIS.Survivor_UI);
            Player:hideUIView(playerid,UIS.Intro_UI);
            Player:hideUIView(playerid,UIS.Loading_UI);
            Player:hideUIView(playerid,UIS.Timer_UI)

            Player:openUIView(playerid,UIS.Lobby_UI);
            Player:openUIView(playerid,UIS.Notify_UI);

        end 
    end 

    if state == "intro" then 
        for _, playerid in ipairs(players) do

            Player:hideUIView(playerid,UIS.Lobby_UI);
            Player:hideUIView(playerid,UIS.Notify_UI);
            Player:hideUIView(playerid,UIS.Monster_UI);
            Player:hideUIView(playerid,UIS.Survivor_UI);
            Player:hideUIView(playerid,UIS.Loading_UI);
            Player:hideUIView(playerid,UIS.Timer_UI)

            Player:openUIView(playerid,UIS.Intro_UI);

        end 
    end 

    if state == "playing" then 
        local function openPlayingUI(playerid)
            Player:hideUIView(playerid,UIS.Lobby_UI);
            Player:hideUIView(playerid,UIS.Notify_UI);
            Player:hideUIView(playerid,UIS.Intro_UI);
            Player:hideUIView(playerid,UIS.Loading_UI);
            Player:openUIView(playerid,UIS.Timer_UI) 
        end

        -- Monster UI 
        for _, monster in ipairs(ROUND.GAME_DATA_NOW.mons) do 
            openPlayingUI(monster);
            Player:openUIView(monster,UIS.Monster_UI);
        end 

        -- Survivor UI 
        for _, survivor in ipairs(ROUND.GAME_DATA_NOW.surv) do 
            openPlayingUI(survivor);
            Player:openUIView(survivor,UIS.Survivor_UI);
        end 

        -- Spectate UI 
    end 

    if state == "loading" then 
        for _, playerid in ipairs(players) do

            Player:hideUIView(playerid,UIS.Lobby_UI);
            Player:hideUIView(playerid,UIS.Notify_UI);
            Player:hideUIView(playerid,UIS.Intro_UI);
            Player:hideUIView(playerid,UIS.Monster_UI);
            Player:hideUIView(playerid,UIS.Survivor_UI);
            Player:hideUIView(playerid,UIS.Timer_UI)

            Player:openUIView(playerid,UIS.Loading_UI);

        end 
    end 

    if state == "gameover" then 
        for _, playerid in ipairs(players) do

        end 
    end 
end

-- Function to update player UI each tick
local function updatePlayerUI(second, tick, players)
    for _, playerID in ipairs(players) do
        pcall(function()
            local indicator = ""
            if math.fmod(tick, 4) < 2 then indicator = "•" end
            if math.fmod(second, 2) < 1 then indicator = indicator .. "●" end
            local zoneState = ROUND:CheckPlayerZoneState(playerID) or " "
            Customui:setText(playerID, UI, generateUIElementID(1), indicator .. " " .. zoneState);
        end)
    end
end

function ROUND:ShowCountDown_Lobby(second,players) 
    local ui_countdown , ui_elementid = "7455620892498532594", "_2";
    for _, playerid  in ipairs(players) do
        local text = {"Game","Start","in","Seconds"};
        if T_Text then --check if Translation Function Exist ;
            for i,a in ipairs(text) do 
                text[i] = T_Text(playerid,a);
            end 
        end 
        Customui:setText(playerid,ui_countdown,ui_countdown..ui_elementid,text[1].." "..text[2].." "..text[3].." "..(self.TIME_START - second - self.TRANSITION_DURATION).." "..text[4]);
    end 
end 

function ROUND:GAME_ADD(map,monster,survivor)
    ROUND.GAME_DATA_NOW = {
        map  = map      ,
        mons = monster  ,
        surv = survivor ,
        died = {}       ,
        time = 120      ,
        obje = "Not Yet Available",
    }
end

function ROUND:GAME_CLEAR()
    ROUND.GAME_DATA_NOW = {};
end

local Doll = 123

function ROUND:START_TRANSITION()
    local positions = {x = 70, y = 5, z = 30};
    local monsterModel = 2

    -- Spawn or set up Doll
    if Creature:getAttr(Doll, 2) ~= 0 then
        local r, obj = World:spawnCreature(
            positions.x, positions.y, positions.z+2, 
            monsterModel, 1)
            
        if r == 0 then
            Doll = obj[1]
            Creature:setAttr(Doll, 21, 1.2)
            Actor:changeCustomModel(Doll, [[mob_3]])
        end
    end

    -- Function to set up players (common logic for monsters and survivors)
    local function setupPlayers(playerList, position)
        for i, player in ipairs(playerList) do
            Player:setPosition(player, position.x , position.y, position.z);
            Actor:changeCustomModel(player, [[mob_2]])
            if Player:SetCameraMountPos(player, position) == 0 then
                Player:SetCameraRotTransformTo(player, {x = 0, y = -35}, 1, 1);
            end
        end
    end

    -- Apply setup for monsters and survivors
    setupPlayers(self.MONSTER, positions)
    setupPlayers(self.SURVIVOR, positions)
end


-- Main update function for the round
function ROUND:Update(second, tick, players)
    updatePlayerUI(second, tick, players);
    if self.STATE == "Init" then
        World:setHours(4);    
        if self.GAME_STARTED then
            self:NEW(second,players)
        end
        self.UI_STATE = "lobby";
    elseif self.STATE == "Matching" then
        if second < self.TIME_START - self.TRANSITION_DURATION then
            -- Notify players of game start
            if not MAP_VOTING.VOTING_ACTIVE then
                MAP_VOTING:StartVoting(GAME_SECOND)
            else 
                MAP_VOTING:ShowMapVoting();
            end 
            -- Show Countdown for Player 
            self.UI_STATE = "lobby";
            self:ShowCountDown_Lobby(second,players);
        elseif second >= self.TIME_START then

            local r,hp = Creature:getAttr(Doll,2);

            if r == 0 then 
                Actor:killSelf(Doll);
            else
                Doll = 123;
            end 
            
            -- set UI state as LOADING;
            self.UI_STATE = "loading";
            -- forcely update the players ' UI
            UI_STATE(ROUND.UI_STATE,players);
            -- teleport each player to play arena;
            -- print(ROUND.GAME_DATA_NOW);
            
            local checkTeleport = self:teleportPlayerToPlayArena(self.PLAYER_READY);

            -- check if all player ready is successfully Teleported to Arena
            if checkTeleport >= tlen(self.PLAYER_READY) then 
                threadpool:delay(1,function()
                    self.UI_STATE = "playing";
                    self.STATE = "Playing";

                    for _,playerid in ipairs(self.SURVIVOR) do
                        Actor:changeCustomModel(playerid, [[skin_]]..math.random(1,20))
                        Player:changeViewMode(playerid, 0 , true);
                    end 

                    for _,monster in ipairs(self.MONSTER) do
                        Actor:changeCustomModel(monster, [[mob_3]])
                        Player:changeViewMode(monster, 1 , true);
                    end 

                end)
            end 

        else
            if MAP_VOTING.VOTING_ACTIVE then
                self.UI_STATE = "intro";
                MAP_VOTING:EndVoting();
                self:SELECT(1) -- Default to selecting 1 monster
                self:START_TRANSITION();
                self:GAME_ADD(MAP_VOTING:fetch(MAP_VOTING.SELECTED_MAP),self.MONSTER,self.SURVIVOR);
                -- SET the Text Name into Monster Name; 
                local r, name = Player:getNickname(self.MONSTER[1]);
                for _, playerid in ipairs(players) do
                    Customui:setText(playerid,UIS.Intro_UI,UIS.Intro_UI.."_5",name);
                end
                Actor:setFaceYaw(Doll,0);
                threadpool:delay(1,function()
                    Actor:playAct(Doll,6);
                    Actor:setFaceYaw(Doll,0);
                end)
            else 
                if tlen(self.SURVIVOR) > 0 and tlen(self.MONSTER) > 0 then
                    -- there is player and Match Can Start 
                    if math.fmod(tick,20) == 0 then  
                        for _, playerid in ipairs(self.PLAYER_READY) do
                            if Player:SetCameraMountObj(playerid, Doll) == 0 then
                                Player:SetCameraRotTransformTo(playerid, {x = 0, y = -35}, 1, 1);
                                Actor:setFaceYaw(Doll,0);
                            end 
                        end
                    end 
                end 
            end
        end
    elseif self.STATE == "Playing" then
        if second < self.TIME_END then
            -- Notify players of remaining game time
            -- self:setNotifierSystem("Game is running: " .. (self.TIME_END - second) .. " s left", players)
            local timer = self.TIME_END - second ;
            local second_timer , minute_timer = math.fmod(timer,60) , math.floor(timer/60); 

            for _,playerid in ipairs(self.PLAYER_READY) do
                Customui:setText(playerid,UIS.Timer_UI,UIS.Timer_UI.."_2",minute_timer..":"..second_timer);
            end

            -- Count Survivor Allive Numbers Here
            local survivorCount = 0;
            for _,playerid in ipairs(self.GAME_DATA_NOW.surv) do 
                local r,hp = Player:getAttr(playerid,2);

                if r == 0 then  
                    survivorCount = survivorCount + 1 ;
                end 
            end 

            if survivorCount < 1 then 
                self.STATE = "Finishing"
                self:CLEAR();
                Chat:sendSystemMsg("All Survivor is Disconnected, Match Terminated");
            end 

            -- Count Monster Alive Here 
            local monsterCount = 0;
            for _,playerid in ipairs(self.GAME_DATA_NOW.mons) do
                local r,hp = Player:getAttr(playerid,2);
                if r == 0 then
                    monsterCount = monsterCount + 1 ;
                end
            end 

            if monsterCount < 1 then
                self.STATE = "Finishing"
                self:CLEAR();
                Chat:sendSystemMsg("All Monster is Disconnected, Match Terminated");
            end 

            -- check if number of Survivor Dead more than Survivor itself;
            if tlen(self.GAME_DATA_NOW.died) >= tlen(self.GAME_DATA_NOW.surv) then 
                -- All player have been Executed by The Monster
                self.STATE = "Finishing"
            end 

            -- update Action here 
            ACTION:UPDATE()
        else
            self.STATE = "Finishing"
        end
    elseif self.STATE == "Finishing" then 
        -- teleport them Back into Lobby 
        local check = 0;

        for _,playerid in ipairs(players) do 
            if ROUND:CheckPlayerZoneState(playerid) ~= "lobby" then 

                local function set2FarPosition(playerid,x,y,z)
                    if Actor:killSelf(playerid) == 0 then 
                        Player:reviveToPos(playerid,x,y,z)
                        Player:ResetCameraAttr(playerid);
                    end 
                end
                set2FarPosition(playerid,70,5,29);
                break;
            else 
                check = check + 1;
            end 
        end 

        if check >= tlen(players) then 
            
            -- TO DO : Calculate the Game Result who is Win and Who is Still Surviving;
            
            World:SetSkyBoxTemplate(1);
            for i,playerid in ipairs(players) do 
                Player:openUIView(playerid,UIS.GameOver_UI);
                Actor:recoverinitialModel(playerid);
                Player:changeViewMode(playerid, 3 , true);
                World:SetSkyBoxFilter(playerid, 10, 1);
                World:setHours(4);    
            end 

            self:CLEAR()
        end 
    end
end

-- Event listener for runtime updates
ScriptSupportEvent:registerEvent("Game.RunTime", function(event)
    local result, playerCount, players = World:getAllPlayers(-1)
    if event.second then 
        GAME_SECOND = event.second 
        local r , err = pcall(function()
            return UI_STATE(ROUND.UI_STATE,players);
        end)
        
        if not r then print(err) end ;   
    else
        if result == 0 and playerCount > 0 then
            local r,err = pcall(ROUND.Update, ROUND, GAME_SECOND, event.ticks, players);
            if not r then print(err) end;
        end
    end
end)

-- Event listener for game start
ScriptSupportEvent:registerEvent("Game.Start", function()
    ROUND.GAME_STARTED = true;
end)

-- Event Listener when player Started Ready 

ScriptSupportEvent:registerEvent("Player.Ready",function(e)
    print("Player is Ready",e)
    local playerid = e.eventobjid;
    if ROUND.UI_PLAYER_STATE[ROUND.PLAYER_STATE_NOW] ~= nil then 
        for i,a in ipairs(ROUND.UI_PLAYER_STATE[ROUND.PLAYER_STATE_NOW]) do 
            Customui:openUIView(playerid,a);
        end 
    end 
end)

function ROUND:teleportPlayerToPlayArena(players)
    local check = 0;

    for _,playerid in ipairs(players) do 
        local r,hp = Player:getAttr(playerid,2);

        if r ~= 0 then 
            self:CLEAR();
        end 

        local state , blockID_State = ROUND:CheckPlayerZoneState(playerid);
        if blockID_State ~= ROUND.GAME_DATA_NOW.map.StateBlockId then 
            
            local position = ROUND.GAME_DATA_NOW.map.PositionStart

            local function set2FarPosition(playerid,x,y,z)
                if Actor:killSelf(playerid) == 0 then 
                    Player:reviveToPos(playerid,x,y,z)
                    Player:ResetCameraAttr(playerid);
                end 
            end
            Chat:sendSystemMsg("Teleporting : "..playerid.." now State Block is : "..blockID_State);
            local rangePos = ROUND.GAME_DATA_NOW.map.RangeStart;
            set2FarPosition(playerid,position.x+math.random(-rangePos,rangePos),position.y,position.z+math.random(-rangePos,rangePos));
            break;
        else 
            check = check + 1;
        end 
    end 

    local proggressBarLegacy = {"▭","▬"};
    local textLoading = "Loading "..(check/tlen(self.PLAYER_READY)*100).."% \n"
    for i=1,tlen(self.PLAYER_READY) do 
        if i <= check then 
            textLoading = textLoading..proggressBarLegacy[1];
        else 
            textLoading = textLoading..proggressBarLegacy[2];
        end 
    end 

    textLoading = textLoading.."\n ".."Teleporting Players";

    -- load the SkyBox and Filter at this Momment... 
    local skyBoxTemplate = self.GAME_DATA_NOW.map.SkyBoxTemplate;
    local FilterTemplate = self.GAME_DATA_NOW.map.FilterTemplate;
    local hourTime       = self.GAME_DATA_NOW.map.HourTime;

    World:SetSkyBoxTemplate(skyBoxTemplate);

    for _,playerid in ipairs(players) do 
        -- for editing game loading screen ;
        Customui:setText(playerid,UIS.Loading_UI,UIS.Loading_UI.."_3",textLoading);
        World:SetSkyBoxFilter(playerid, 10, FilterTemplate);
        World:setHours(hourTime);    
    end 

    return check;
end