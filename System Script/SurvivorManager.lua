SURVIVOR_DATA = {DATA={}}

function SURVIVOR_DATA:NEW(survivor)
    -- Validate required fields
    assert(survivor.key, "Survivor must have a unique key!")
    assert(survivor.name, "Survivor must have a name!")
    assert(survivor.health and survivor.damage and survivor.speed, "Survivor must have health, damage, and speed!")

    -- Register survivor
    self.DATA[survivor.key] = survivor;
end

local function Copy(original)
    if type(original) ~= "table" then return original end
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = Copy(v) -- Recursively copy nested tables
    end
    return copy
end

function SURVIVOR_DATA:FETCH_ORIGINAL(id)
    local key = "survivor_" .. id;
    return self.DATA[key];
end 

function SURVIVOR_DATA:FETCH(id)
    -- Get survivor id based on the key
    local key = "survivor_" .. id
    -- Fetch from SURVIVOR_DATA.DATA
    local originalData = self.DATA[key]

    -- Return a copy of the original data to avoid shared references
    if originalData then
        return Copy(originalData) -- Use a deep copy utility
    else
        return nil -- Handle cases where the key doesn't exist
    end
end

function SURVIVOR_DATA:getskinIco (i)
    return tostring(6000000+i)
end 

BACKPACK_ITEM = {ITEM = {}} -- Global store for functions and item management
-- store the Item creted in ITEM 
-- Function to create a new ItemObject reference using itemID
function BACKPACK_ITEM:NEW(itemID, data)
    -- Create a new item object with provided properties
    if not data  then data = {}; end 
    local _construct = {
        id = itemID,
        name = data.name or "Unnamed Item",
        icon = data.icon or "[[8_1029380338_1724397907]]",
        item_type = data.item_type or "consumable", -- Type of the item (e.g., consumable, trap)
        label     = data.label or "Unknown", -- heal,slow item, or etc 
        execute   = data.execute or function() print("No function assigned to item.") end, -- Function to execute when used
        duration  = data.duration or 0, -- Duration for item effect (if applicable)
    }
    self.ITEM[itemID] = _construct;
    return self.ITEM[itemID];
end

-- Function to add an item to the player's backpack
function BACKPACK_ITEM:ADD(playerid, itemID)
    -- Get the player's backpack
    local backpack = ROUND.GAME_DATA_NOW.data_survivor[playerid].backpack
    if not backpack then
        print("Error: No backpack found for player " .. tostring(playerid))
        return false
    end

    -- fetch the Data from Stored ITEM 
    local data = BACKPACK_ITEM.ITEM[itemID];

    if data then 

        -- Check if the item already exists in the backpack
        for i, slot in ipairs(backpack) do
            if slot.id == itemID then
                -- If item exists, increment the count (max 2 per slot)
                if slot.num < 2 then
                    slot.num = slot.num + 1
                    Player:notifyGameInfo2Self(playerid,"Item added to existing slot. Player ID:".. playerid, "Item:".. slot.name.. "Count:".. slot.num)
                    return true
                else
                    Player:notifyGameInfo2Self(playerid,"Slot full for item:".. slot.name)
                    return false
                end
            end
        end

        -- If item does not exist in the backpack, find an empty slot
        for i, slot in ipairs(backpack) do
            if slot.name == "empty" then
                -- Fill the empty slot with the new item
                backpack[i] = {
                    name = data.name or "Unnamed Item",
                    icon = data.icon or "[[mob_200]]",
                    num = 1,
                    item = data.item_type,
                    label = data.label,
                    id = data.id,
                    execute = data.execute
                }
                Player:notifyGameInfo2Self(playerid,"Item added to backpack. Player ID:".. playerid.."Slot:".. i.."Item:".. data.name)
                return true
            end
        end

        -- If no empty slot is available
        Player:notifyGameInfo2Self(playerid,"Backpack is full. Player ID:".. playerid)
        return false
    else 
        Player:notifyGameInfo2Self(playerid,"Data is Not Found");
        return false
    end
end 

-- Function to use an item from the player's backpack
function BACKPACK_ITEM:USE(playerid, index)
    -- Get the player's backpack
    local backpack = ROUND.GAME_DATA_NOW.data_survivor[playerid].backpack
    if not backpack then
        print("Error: No backpack found for player " .. tostring(playerid))
        return false
    end

    -- Validate the index
    local slot = backpack[index]
    if not slot or slot.name == "empty" then
        Player:notifyGameInfo2Self(playerid, "No item in this slot to use.")
        return false
    end

    -- Fetch the item data
    local itemData = BACKPACK_ITEM.ITEM[slot.id]
    if not itemData then
        Player:notifyGameInfo2Self(playerid, "Item data not found for ID: " .. tostring(slot.id))
        return false
    end

    -- Execute the item's action
    if type(itemData.execute) == "function" then
        itemData.execute(playerid, itemData) -- Pass playerid and item data to the execution function
    else
        print("No valid execute function for item:", slot.name)
        return false
    end

    -- Handle item consumption (if applicable)
    if itemData.item_type == "consumable" then
        slot.num = slot.num - 1 -- Reduce the count of the item
        if slot.num <= 0 then
            -- Clear the slot if no items are left
            backpack[index] = {
                name = "empty",
                icon = "Empty_Ico.png",
                num = 0,
                item = nil,
                id = nil,
            }
            Player:notifyGameInfo2Self(playerid, "Item consumed and slot cleared.")
        else
            Player:notifyGameInfo2Self(playerid, "Item used. Remaining count: " .. slot.num)
        end
    else
        Player:notifyGameInfo2Self(playerid, "Item used successfully.")
    end

    return true
end
