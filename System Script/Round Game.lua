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
    ,   Stamina_UI              = "7455215546370038002"
}
PLAYER_UI_LOBBY_STATE = {}; --Store UI LOBBY STATE HERE 

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

function cleanDuplicate(t)
    local unique = {}
    local result = {}

    for _, value in ipairs(t) do
        if not unique[value] then
            unique[value] = true
            table.insert(result, value)
        end
    end

    return result;
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
      --print("Not enough players to select as monsters!")
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

  --print("Monsters: ", table.concat(self.MONSTER, ", "))
  --print("Survivors: ", table.concat(self.SURVIVOR, ", "))
end

-- Function to check a player's zone state
function ROUND:CheckPlayerZoneState(playerID)
    local result, x, y, z = Actor:getPosition(playerID)
    if result == 0 then
        local blockResult, blockID = Block:getBlockID(x, 1, z)
        if blockResult == 0 then
            return RoundBlockState[tostring(blockID)] or " " , blockID;
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

ROUND.PLAYER_STATE_NOW = {};
ROUND.NOT_PLAYER_STATE = { --Contain Function to be Executed if Player is not in that State;
    ["lobby"] = function(playerid)
        Actor:killSelf(playerid);
        Player:reviveToPos(playerid, 70+math.random(-2,2),6,26+math.random(-2,2));
    end
}

function ROUND:setState(playerid,state)
    ROUND.PLAYER_STATE_NOW[playerid] = string.lower(state);

    Player:hideUIView(playerid,UIS.Lobby_UI);
    Player:hideUIView(playerid,UIS.Notify_UI);
end 

function ROUND:clearState(playerid)
    ROUND.PLAYER_STATE_NOW[playerid] = nil;

    Player:openUIView(playerid,UIS.Lobby_UI);
    Player:openUIView(playerid,UIS.Notify_UI);
end

function ROUND:getState(playerid)
    return ROUND.PLAYER_STATE_NOW[playerid];
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
            Player:hideUIView(playerid,UIS.Timer_UI);
            Player:hideUIView(playerid,UIS.Stamina_UI); 

            -- Check Player State is it UI Shop, Lobby , Or Character Monster Management UI 
            if ROUND:getState(playerid) == nil then 
                Player:openUIView(playerid,UIS.Lobby_UI);
                Player:openUIView(playerid,UIS.Notify_UI);
            else 
                Player:hideUIView(playerid,UIS.Lobby_UI);
                Player:hideUIView(playerid,UIS.Notify_UI);
            end 

        end 
    end 

    if state == "intro" then 
        for _, playerid in ipairs(players) do

            Player:hideUIView(playerid,UIS.Lobby_UI);
            Player:hideUIView(playerid,UIS.Notify_UI);
            Player:hideUIView(playerid,UIS.Monster_UI);
            Player:hideUIView(playerid,UIS.Survivor_UI);
            Player:hideUIView(playerid,UIS.Loading_UI);
            Player:hideUIView(playerid,UIS.Timer_UI);
            Player:hideUIView(playerid,UIS.Stamina_UI); 

            Player:openUIView(playerid,UIS.Intro_UI);

        end 
    end 

    if state == "playing" then 
        local function openPlayingUI(playerid)
            Player:hideUIView(playerid,UIS.Lobby_UI);
            Player:hideUIView(playerid,UIS.Notify_UI);
            Player:hideUIView(playerid,UIS.Intro_UI);
            Player:hideUIView(playerid,UIS.Loading_UI);
            Player:openUIView(playerid,UIS.Timer_UI);
            Player:openUIView(playerid,UIS.Stamina_UI); 
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

    -- load Monster Data 
    local monsterData = {};
    local monsterModel = {};
    for _,_monster in ipairs(monster) do 

        -- add into monsterData table MONSTER_DATA by Fetch 
        monsterData[_monster] = MONSTER_DATA:FETCH(SAVE_DATA:GET(_monster,"Equipped_Monster").variableValue);

        -- Load Level equipped by Player 
        local level = (SAVE_DATA:GET(_monster,monsterData[_monster].key.."_LEVEL") ~= nil) and tonumber(SAVE_DATA:GET(_monster,monsterData[_monster].key.."_LEVEL").variableValue) or 1;
        monsterData[_monster].level = level;

        -- Add Skill Active holder in CD as 0 for later use 
        for i,skill in ipairs(monsterData[_monster].skill) do
            if monsterData[_monster].CD == nil then 
                monsterData[_monster].CD = {};
            end
            if i <= math.ceil(level/5) then  
                monsterData[_monster].CD[skill.key] = 0;
            else 
                monsterData[_monster].CD[skill.key] = "locked"; --skill not unlocked;
            end 
        end 
        -- init basic Attack CD 
        monsterData[_monster].CD["basic_attack"] = 0;

        -- data to handle debuff itself to use by survivor 
        monsterData[_monster].debuff = {
            stunned = 10,
            slowed = 10,
            blind = 30
        }

        -- add Bonus Speed for Skill that Add Bonus Speed 
        monsterData[_monster].bonus_speed = 0;

        -- data to handel currentModel Stat 
        monsterData[_monster].currentModel = monsterData[_monster].model.normal; 
        monsterData[_monster].sp = monsterData[_monster].stamina;
    end 

    -- Add Survivor Data 
    local survivorData = {};

    for _,_survivor in ipairs(survivor) do
        survivorData[_survivor] = SURVIVOR_DATA:FETCH(SAVE_DATA:GET(_survivor,"Equipped_Survivor").variableValue);
        survivorData[_survivor].backpack    = {
                {
                    name  = "empty",
                    icon  = "Empty_Ico.png",
                },
                {
                    name = "empty",
                    icon  = "Empty_Ico.png",
                },
                {
                    name = "empty",
                    icon  = "Empty_Ico.png",
                }
            }
        survivorData[_survivor].debuff = {
                stunned = 0,
                slowed = 0,
                blind = 0
            }
        survivorData[_survivor].point = 0
        survivorData[_survivor].sp = survivorData[_survivor].stamina;

        -- load Classes and etc TODO --- LATER 
    end 

    self.GAME_DATA_NOW = {
        map  = map      ,
        mons = monster  ,
        surv = survivor ,
        died = {}       ,
        time = 120      ,
        obje = "Not Yet Available",
        data_monster  = monsterData,
        mode_monster  = monsterModel,
        data_survivor = survivorData,
        countdown = 5,
    }

    -- print("Game New : ",self.GAME_DATA_NOW)
end

function ROUND:GAME_CLEAR()
    ROUND.GAME_DATA_NOW = {};
end

local Doll = 123

function ROUND:START_TRANSITION(players)
    local positions = {x = 70.5, y = 5.5, z = 29.5};
    local monsterModel = 2

    -- Spawn or set up Doll
    if Creature:getAttr(Doll, 2) ~= 0 then
        local r, obj = World:spawnCreature(
            positions.x, positions.y-0.5, positions.z+3, 
            monsterModel, 1)
            
        if r == 0 then
            Doll = obj[1]
            Creature:setAttr(Doll, 21, 1.1)
            Actor:changeCustomModel(Doll,self.GAME_DATA_NOW.data_monster[self.MONSTER[1]].currentModel)
        end

        -- SET the Text Name into Monster Name; 
        local r, name = Player:getNickname(self.MONSTER[1]);
        for _, playerid in ipairs(players) do
            Customui:setText(playerid,UIS.Intro_UI,UIS.Intro_UI.."_5",name);
        end
        Actor:setFaceYaw(Doll,0);
        Actor:playAct(Doll,6);
    end

    -- Function to set up players (common logic for monsters and survivors)
    local function setupPlayers(playerList, position)
        for i, player in ipairs(playerList) do
            Player:setPosition(player, position.x , position.y, position.z-(3+i));
            -- Actor:changeCustomModel(player, [[mob_2]])
            if Player:SetCameraMountPos(player, position) == 0 then
                Player:SetCameraRotTransformTo(player, {x = 360, y = -30}, 1, 1);
                RUNNER:NEW(function()
                    Player:SetCameraRotTransformTo(player, {x = 360, y = -35}, 1, 5);
                end,{},25)
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
        self.UI_STATE = "lobby";
        if self.GAME_STARTED then
            self:NEW(second,players)
        end
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
            local checkTeleport = 0
            checkTeleport = checkTeleport + self:teleportPlayerToPlayArena(self.MONSTER,"Monster");
            checkTeleport = checkTeleport + self:teleportPlayerToPlayArena(self.SURVIVOR,"Survivor");

            -- check if all player ready is successfully Teleported to Arena
            if checkTeleport >= tlen(self.PLAYER_READY) then 
                if self:adjustModel() then 
                    self.UI_STATE = "playing";
                    self.STATE = "Playing";

                    -- update the Time End 
                    self.TIME_END = GAME_SECOND + tonumber(self.GAME_DATA_NOW.map.TimeDuration);
                end;
            end 

        else
            if MAP_VOTING.VOTING_ACTIVE then
                self.UI_STATE = "intro";
                MAP_VOTING:EndVoting();
                self:SELECT(1) -- Default to selecting 1 monster
                self:GAME_ADD(MAP_VOTING:fetch(MAP_VOTING.SELECTED_MAP),self.MONSTER,self.SURVIVOR);
                RUNNER:NEW(function()
                    self:START_TRANSITION(players);
                end,{},2)
            -- else 
            --     if tlen(self.SURVIVOR) > 0 and tlen(self.MONSTER) > 0 then
                   
            --     end 
            end
        end
    elseif self.STATE == "Playing" then
        if second < self.TIME_END then

            -- -- Each 2 Second adjust player Model 
            -- if math.fmod(tick,40) == 0 then 
            --     ROUND:adjustModel()
            -- end 
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
                Chat:sendSystemMsg("All Survivor is Eleminated");
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
                Chat:sendSystemMsg("Monster is Disconnected, Match Terminated");
            end 

            -- make sure no duplicate on died table 
            self.GAME_DATA_NOW.died = cleanDuplicate(self.GAME_DATA_NOW.died);
            -- check if number of Survivor Dead more than Survivor itself;
            local ndied , nalive = tlen(self.GAME_DATA_NOW.died),tlen(self.GAME_DATA_NOW.surv)

            if  ndied >= nalive  then 
                -- All player have been Executed by The Monster
                self.STATE = "Finishing"
            end 

            for _,playerid in ipairs(self.PLAYER_READY) do
                Customui:setText(playerid,UIS.Timer_UI,UIS.Timer_UI.."_3",(nalive - ndied).." Survivor left");
            end 

            -- update Action here 
            ACTION:UPDATE(tick)
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

            local r,err = pcall(function()
                self:GiveReward(self.GAME_DATA_NOW);    
                RUNNER:clearDelayedEvents(); -- get rid of All delayed Actions from Previous Game 
            end)

            if not r then print(err) end 

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
    -- print("Player is Ready",e)
    local playerid = e.eventobjid;

    if Player:setAttr(playerid, 21, 0.67) ~= 0 then 
      --print(" Size Player Failed to Change")
    end 

    local r,err = pcall(function()
        table.insert(ROUND.PLAYER_READY,playerid);
        SAVE_DATA:LOAD_ALL(playerid);
    end )

    if not r then 
      --print("Error Something(2) : ",err);
    end 

    -- if ROUND then --Check Todo When Join in middle of playing session ;
    --     for i,a in ipairs(ROUND.UI_PLAYER_STATE[ROUND.PLAYER_STATE_NOW]) do 
    --         Customui:openUIView(playerid,a);
    --     end 
    -- end 

    -- check for equipped Monster and Survivor
    local Equipped_Survivor = nil;
    local Equipped_Monster  = nil;
    local r , err = pcall(function()

        Equipped_Survivor = SAVE_DATA:GET(playerid,"Equipped_Survivor");
        Equipped_Monster  = SAVE_DATA:GET(playerid,"Equipped_Monster");

        if Equipped_Survivor == nil and Equipped_Monster == nil then --first time join 
            local init_Money = {"Coin","FirePoint","Crystal","Rank"}
            for _,name in ipairs(init_Money) do 
                -- init their currency 
                GLOBAL_CURRENCY:AddCurrency(playerid,name,0);
            end 

            -- set Default Unlocked 
            SAVE_DATA:NEW(playerid,{"monster_1","Monster",1});
            -- set Default Unlocked 
            SAVE_DATA:NEW(playerid,{"survivor_1","Survivor",1});
        end 

        if Equipped_Survivor == nil then -- Assign default
            SAVE_DATA:NEW(playerid,{"Equipped_Survivor","String",1})
            SAVE_DATA:LOAD_ALL(playerid);
        else
          --print("Equipped_Survivor",Equipped_Survivor);
        end 

        if Equipped_Monster == nil then -- Assign default
            SAVE_DATA:NEW(playerid,{"Equipped_Monster","String",1})
            SAVE_DATA:LOAD_ALL(playerid);
        else
          --print("Equipped_Monster",Equipped_Monster)
        end 

    end)

    if not r then 
      --print("Error Something(1) : ",err);
    end 
end)

function ROUND:teleportPlayerToPlayArena(players,_type)
    local check = 0;

    if self.GAME_DATA_NOW.countdown > 0 then 
        -- set Everyone to default model
            for _,playerid in ipairs(self.PLAYER_READY) do
                Actor:changeCustomModel(playerid, default);
            end 
        self.GAME_DATA_NOW.countdown = self.GAME_DATA_NOW.countdown - 1;
    else
        
        for _,playerid in ipairs(players) do 
            local r,hp = Player:getAttr(playerid,2);

            if r ~= 0 then 
                Chat:sendSystemMsg("#Y[System] :#WFailed To Start Game (Some Player Leave The Game Or Disconnected)");
            self.STATE = "Finishing"
            end  
            local state , blockID_State = ROUND:CheckPlayerZoneState(playerid);
            if blockID_State ~= ROUND.GAME_DATA_NOW.map.StateBlockId then 
                
                local position = {}
                if _type == "Monster" then 
                    position = ROUND.GAME_DATA_NOW.map.PositionMonster;
                else 
                    position = ROUND.GAME_DATA_NOW.map.PositionStart;
                end 

                local function set2FarPosition(playerid,x,y,z)
                    if Actor:killSelf(playerid) == 0 then 
                        Player:reviveToPos(playerid,x,y,z);
                        Player:ResetCameraAttr(playerid);
                        Player:setPosition(playerid,x,y,z);
                    end 
                end
                -- Chat:sendSystemMsg("Teleporting : "..playerid.." now State Block is : "..blockID_State);
                local rangePos = ROUND.GAME_DATA_NOW.map.RangeStart;
                set2FarPosition(playerid,position.x+math.random(-rangePos,rangePos),position.y,position.z+math.random(-rangePos,rangePos));
                self.GAME_DATA_NOW.countdown = 5;
                break;
            else 
                check = check + 1;
            end 
        end 
    end 

    local proggressBarLegacy = {"▭","▬"};
    local textLoading = "Loading "..(check/tlen(self.PLAYER_READY)*100).."% \n"
    for i=1,tlen(self.PLAYER_READY) do 
        if i <= check then 
            textLoading = textLoading..proggressBarLegacy[2];
        else 
            textLoading = textLoading..proggressBarLegacy[1];
        end 
    end 

    textLoading = textLoading.."\n ".."Teleporting Players";
    
    for i = 0 , self.GAME_DATA_NOW.countdown do textLoading = textLoading .. " ." end;

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

function ROUND:adjustModel()
    local count = 0;    
    local tmax = tlen(self.MONSTER) + tlen(self.SURVIVOR);
    
    -- change everyone Skin to Chief
    local default = [[role_1]];

    if self.GAME_DATA_NOW.countdown > 0 then 
    -- set Everyone to default model
        for _,playerid in ipairs(self.PLAYER_READY) do
            Actor:changeCustomModel(playerid, default);
        end 
        self.GAME_DATA_NOW.countdown = self.GAME_DATA_NOW.countdown - 1;
    end 
    

    for _,playerid in ipairs(self.SURVIVOR) do
        -- check if player appearence is default then change it to survivor skin 
        local r,model= Actor:getActorFacade(playerid);
        local current_model = self.GAME_DATA_NOW.data_survivor[playerid].model.normal;

        local function setModelSurvivor(current_model,playerid)
            RUNNER:NEW(function() 
                Actor:changeCustomModel(playerid,current_model);

                RUNNER:NEW(function() 

                    if Player:setAttr(playerid, 21, 0.67) ~= 0 then 
                      --print(" Size Player Failed to Change")
                    else
                        Player:changeViewMode(playerid, 0 , true); 
                    end 

                end,{},5)
            end,{},5)
        end

        -- textLoading = textLoading.."\n "..playerid.." : "..current_model.." : "..model;

        if model == current_model then 
            count = count + 1 ;
        else
            setModelSurvivor(current_model,playerid)
        end 
    end 

    for _,monster in ipairs(self.MONSTER) do
        -- Load Default Monster Skin --Idle Animation;
        local r,model= Actor:getActorFacade(monster);
        local currentModel = self.GAME_DATA_NOW.data_monster[monster].currentModel;

        local function setModelMonster()
            RUNNER:NEW(function() 
                Actor:changeCustomModel(monster, currentModel );
                RUNNER:NEW(function() 
                    if Player:setAttr(monster, 21, 0.80) ~= 0 then 
                      --print(" Size Player Failed to Change")
                    else
                        Player:changeViewMode(monster, 1 , true);
                    end 
                end,{},5)
            end,{},5)
        end
        -- textLoading = textLoading.."\n "..monster.." : "..currentModel.." : "..model;
        if model == currentModel then 
            count = count + 1;
        else
            setModelMonster();
        end 
    end 
    local textLoading = "Loading Model \n ("..count.."/"..tmax..")"
    for _,playerid in ipairs(self.PLAYER_READY) do 
        Customui:setText(playerid,UIS.Loading_UI,UIS.Loading_UI.."_3",textLoading);
    end 

    return count >= tmax ;
end

function ROUND:GiveReward(Data) 
  --print("Game Result Data : ",Data)

    local GameOverText          = "7457398416253589746_2";
    local textSurvivorisAlive   = "7457398416253589746_3";
    local textSurvivorisDead    = "7457398416253589746_4";
    local textObjectiveisDone   = "7457398416253589746_5";
    local textReward            = "7457398416253589746_6";
    local rewardSlot            = {
        {            icon = "7457398416253589746_8",            txt  = "7457398416253589746_9"        },
        {            icon = "7457398416253589746_10",           txt  = "7457398416253589746_11"       },
        {            icon = "7457398416253589746_12",           txt  = "7457398416253589746_13"       },
        {            icon = "7457398416253589746_14",           txt  = "7457398416253589746_15"       },
        {            icon = "7457398416253589746_16",           txt  = "7457398416253589746_17"       }
    }

    -- determine alive survivor and dead survivor 
    local survivor_alive = {};
    local survivor_died  = {};
    local survivor_task  = {};

    for i,surv in ipairs(Data.surv) do 
        -- check if value of surv is somehow inside Data.died 
        local isInDead = false;
        for i,died in ipairs(Data.died) do
            if died == surv then 
                isInDead = true;
                break;
            end 
        end 
        if isInDead then
            table.insert(survivor_died, surv);
        else
            table.insert(survivor_alive, surv);
        end 
    end 

    -- Now for Each Survivor Alive and Died List them into UI 
    local aliveContent = "Survivor Alive : "
    local deadContent  = "Survivor Died : "

    for i,survivorid_alive in ipairs(survivor_alive) do 
        -- append content with player Name 
        local r,name = Player:getNickname(survivorid_alive);
        aliveContent = aliveContent.." \n ["..i.."] " .. name .. " ";
    end 
    
    for i,survivorid_died in ipairs(survivor_died) do 
        -- append content with player Name 
        local r,name = Player:getNickname(survivorid_died);
        deadContent = deadContent.." \n ["..i.."] ".. name .. " ";
    end 

    -- use API to Edit the UI content 
    local function updateList(playerid)
        Customui:setText(playerid,UIS.GameOver_UI,textSurvivorisAlive,aliveContent);
        Customui:setText(playerid,UIS.GameOver_UI,textSurvivorisDead,deadContent);
        Customui:setText(playerid,UIS.GameOver_UI,textObjectiveisDone, " ");
    end

    -- store Reward Here 
    local Reward = {};

    local function GiveReward(playerid,percentage)
        Reward.Coin         = { value = Data.map.TimeDuration * 15, text = "Coins" ,        icon = GLOBAL_CURRENCY:GetIconCurrency(GLOBAL_CURRENCY.MONEY.Coin)};
        Reward.FirePoint    = { value = Data.map.TimeDuration * math.random(2,3)*2,  text = "Firepoint" ,    icon = GLOBAL_CURRENCY:GetIconCurrency(GLOBAL_CURRENCY.MONEY.FirePoint)};
        Reward.Rank         = { value = 10,                         text = "Rank Point" ,   icon = GLOBAL_CURRENCY:GetIconCurrency("Rank")};
        -- this win 
        local c = 1;
        for name,reward in pairs(Reward) do 
            -- adjust the percentage
            reward.value = math.ceil(reward.value/100 * percentage);

            if GLOBAL_CURRENCY:AddCurrency(playerid,name,reward.value) then 
                -- display the reward on UI slot 
                local slot = rewardSlot[c];
                c = c + 1;
                -- set the text 
                Customui:setText(playerid,UIS.GameOver_UI,slot.txt,reward.text.." + "..reward.value);
                -- set the icon 
                Customui:setTexture(playerid,UIS.GameOver_UI,slot.icon,reward.icon);
                -- add to return value
                
            end 
        end 

        return Reward.Rank.value; 
    end

    -- Update for Survival Alive
    for i,playerid in ipairs(survivor_alive) do 
        Data.reward = GiveReward(playerid,100);
        Data.status = "Win";
        GLOBAL_MATCH:AddHistory(playerid,Data)
        -- Set Customui Player Alive
        Customui:setText(playerid,UIS.GameOver_UI,GameOverText,"You Survived");
        updateList(playerid);
    end 

    -- Update For Survivor Dead 
    for i,playerid in ipairs(survivor_died) do 
        Data.reward = GiveReward(playerid,40);
        Data.status = "Defeat";
        GLOBAL_MATCH:AddHistory(playerid,Data)
        -- Set Customui Player Alive
        Customui:setText(playerid,UIS.GameOver_UI,GameOverText,"You Died");
        updateList(playerid);
    end 

    -- Update for Monster 
    for i,monster in ipairs(Data.mons) do 
        if tlen(survivor_alive) < 1 then 
            Data.reward = GiveReward(monster,100+(#survivor_died*20));
            Data.status = "Win";
            GLOBAL_MATCH:AddHistory(monster,Data)
            Customui:setText(monster,UIS.GameOver_UI,GameOverText,"All Survivor Eleminated");
        else
            Data.reward =  GiveReward(monster,20+(#survivor_died*10));
            Data.status = "Defeat";
            GLOBAL_MATCH:AddHistory(monster,Data)
            Customui:setText(monster,UIS.GameOver_UI,GameOverText,"Game Over");
        end 
        updateList(monster);
    end 
end 