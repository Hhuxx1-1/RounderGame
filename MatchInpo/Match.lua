GLOBAL_MATCH = {RENDERED_DATA={},valtype=18, groupname = "MATCH_HISTORY"}; -- handle data here based on player and method 

local function table_find(tbl, value)
    for index, v in ipairs(tbl) do
        if v == value then
            return index -- Return the index where the value is found
        end
    end
    return nil -- Return nil if the value is not found
end

-- method to encode and decode data 
-- Custom serialization: Encode table to string
local function encodeMatchData(data)
    local encoded = {}
    for key, value in pairs(data) do
        table.insert(encoded, tostring(key) .. "|" .. tostring(value))
    end
    return table.concat(encoded, ";") -- Use ";" to separate fields
end

-- Custom deserialization: Decode string back to table
local function decodeMatchData(encodedStr)
    local data = {}
    for _, pair in ipairs(encodedStr:split(";")) do
        local key, value = pair:match("([^|]+)|([^|]+)")
        if key and value then
            data[key] = value
        end
    end
    return data
end

-- Split helper function (Lua 5.1 compatible)
string.split = function(input, delimiter)
    local result = {}
    for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- working function to get All Encoded data for specific player 
local function getAllEncodedDataFromPlayer(playerid)
    local result,ret=Valuegroup:getAllGroupItem(GLOBAL_MATCH.valtype, GLOBAL_MATCH.groupname, playerid);
    if result == 0 then 
        return ret else print('Something is wrong') return nil 
    end 
end 

-- working gunction to Insert Match History to Specific Player 
local function insertMatchHistory(playerid,EncodedMatchData)
    -- math data must be encoded first 
    if Valuegroup:insertInGroupByName(GLOBAL_MATCH.valtype, GLOBAL_MATCH.groupname,EncodedMatchData , playerid) == 0 then 
        return true else return false ;
    end 
end 

-- function to Add Match History 
function GLOBAL_MATCH:AddHistory(playerid,data)
    local r,err = pcall(function()
    -- turn player UID into nickname 
    local survivorlist = "Survivor : \n";
    local monsterlist  = "Monster : \n";
    for i,p in ipairs(data.surv) do 
        -- data.surv 
        local r,playername = Player:getNickname(p);
        -- check if playerid value is also in data.died 
        if table_find(data.died,p) then
            survivorlist = survivorlist.." Died-"
        else 
            survivorlist = survivorlist.." Alive-"
        end 
        survivorlist = survivorlist .. playername .. "|n|";
    end 
    for i,monsterid in ipairs(data.mons) do
        -- data.mons
        local r,monstername = Player:getNickname(monsterid);
        monsterlist = monsterlist .. monstername .. "|n|";
    end 

    -- map data is map name 
    local mapname = data.map.Name;
    -- determine if playerid is monster or survivor ? 
    local role,iconid,type = "","","";
    if data.mons[1] == playerid then 
        -- monsterName  
        role = data.data_monster[data.mons[1]].name;
        -- iconid 
        iconid = data.data_monster[data.mons[1]].icon;
        -- set type 
        type = "Monster";
    else 
        -- monsterName 
        role = data.data_survivor[playerid].name;
        -- iconid 
        iconid = data.data_survivor[playerid].icon;
        -- set type 
        type = "Survivor";        
    end 
    -- data status is win or lose 
    local status       = data.status;
    local rank         = "+"..data.reward;

    local r,t = World:getLocalDateString();

    -- all data is already in simple string format 

    -- converting them into single table 
    local dataCopy = {s=survivorlist,m=monsterlist,n=mapname,u=role,r=status,t=t,i=iconid,y=type,a=rank};

    -- encode the table into string 
    local encodedStr = encodeMatchData(dataCopy);

    -- insert into player save 
    insertMatchHistory(playerid,encodedStr);

    end)

    if not r then print("Game Match Error : ",err); end 
end 

-- function to load All Match History 
function GLOBAL_MATCH:LoadHistory(playerid)
    local data = getAllEncodedDataFromPlayer(playerid);

    -- -check if data is exist 
    local _data = {};
    if data then
        -- data is encoded string , need to decode each of them back into table 
        -- and store each of loaded table into _data 
        for i=1, #data do
            local decodedData = decodeMatchData(data[i]);
            _data[#data - i + 1] = decodedData;
        end
    end 

    if _data ~= {} then 
        return _data;
    else 
        print("Data is Empty");
    end 
end 

function GLOBAL_MATCH:ClearHistory(playerid)
    Valuegroup:clearGroupByName(GLOBAL_MATCH.valtype, GLOBAL_MATCH.groupname,playerid)
end