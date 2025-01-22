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
-- TO DO : make Survivor Data