SAVE_DATA = { 
        data            = {}                -- 
    ,   surv_dat        = {}                --
    ,   mons_dat        = {}                --
    ,   match_data      = {}                -- 
    ,   meta_data       = {}                -- Save the Data index 
    ,   meta_surv_dat   = {}                -- Save Data index of survivor data
    ,   meta_mons_dat   = {}                -- Save Data index of monster data
    ,   vartype         = 18                -- StringGroup
    ,   libname         = "SAVE_DATA_EXT"  -- Name of the Variable;
    ,   KEY             = "K123"
};

function SAVE_DATA:LOAD_ALL(playerid)
    local r, err = pcall(function()
        -- Fetch all data for the player
        local result, ret = Valuegroup:getAllGroupItem(self.vartype, self.libname, playerid)
        if result ~= 0 then
            print("Failed to load player data")
        end
        print("Ret : ",ret)
        -- Parse and store data in self.data[playerid]
        self.data[playerid] = {}
        for _, entry in ipairs(ret) do
            -- Assuming data is stored in "metaKey|variableName|typeOfVariable|variableValue" format
            local metaKey, variableName, typeOfVariable, variableValue = entry:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
            table.insert(self.data[playerid], {
                metaKey = metaKey,
                variableName = variableName,
                typeOfVariable = typeOfVariable,
                variableValue = variableValue,
            })
        end

        print( "Loaded data for player:", playerid, self.data[playerid] );
    end)
    if not r then
        print( "Error Loading Player Data:", err );
    end
end

function SAVE_DATA:GET(playerid, variableName)
    -- Ensure data is loaded
    if not self.data[playerid] then
        print("No data loaded for player:", playerid)
        return nil
    end

    -- Find the specific variableName
    for _, entry in ipairs(self.data[playerid]) do
        if entry.variableName == variableName then
            return entry
        end
    end

    print("Variable not found:", variableName, "for player:", playerid)
    return nil
end

function SAVE_DATA:MODIFY(playerid, variableName, newValue)
    local r, err = pcall(function()
        -- Ensure data is loaded
        if not self.data[playerid] then
            error("No data loaded for player:" .. tostring(playerid))
        end

        -- Find the specific variable
        for _, entry in ipairs(self.data[playerid]) do
            if entry.variableName == variableName then
                
                local oldval = string.format("%s|%s|%s|%s", self.KEY , entry.variableName, entry.typeOfVariable, entry.variableValue)
                local newval = string.format("%s|%s|%s|%s", self.KEY , entry.variableName, entry.typeOfVariable, newValue)
                -- Replace the value using the API
                local result = Valuegroup:replaceValueByName(self.vartype, self.libname, oldval, newval, playerid)
                if result ~= 0 then
                    error("Failed to modify value for variableName: " .. variableName)
                end

                -- Update the value in the local table
                entry.variableValue = tostring(newValue)

                print("Modified data for player:", playerid, "variable:", variableName, "new value:", newValue)
                return
            end
        end

        error("Variable not found for modification: " .. variableName)
    end)
    if not r then
        print("Error Modifying Player Data:", err)
    end
end

function SAVE_DATA:NEW(playerid, data)
    -- Step 1: Construct the data
    local _data = {}
    local _r, _err = pcall(function()
        _data = { variableName = data[1], typeOfVariable = data[2], variableValue = data[3]}
    end)
    if not _r then
        print("Error When Constructing Data:", "Error At NEW:\n", _err)
        return
    end

    -- Step 2: Encode the data into a string
    local encodedData
    local r, err = pcall(function()
        -- Serialize the data to JSON or a simple string
        encodedData = string.format("%s|%s|%s|%s", self.KEY , _data.variableName, _data.typeOfVariable, _data.variableValue)
    end)
    if not r then
        print("Error Encoding Data:", err)
        return
    end

    -- Step 3: Use the API to add data to the group
    local insertResult, insertError = pcall(function()
        -- Get the current length of the group for the player
        local result, currentLength = Valuegroup:getGrouplengthByName(self.vartype, self.libname, playerid)
        if result ~= 0 then
            print("Failed to get current length of the group")
        end

        -- Add the encoded data to the group
        local insertResult = Valuegroup:insertInGroupByName(self.vartype, self.libname, encodedData, playerid)
        if insertResult ~= 0 then
            print("Failed to insert data into the group")
        end

        print("Data successfully added at index:", currentLength + 1)
    end)
    if not insertResult then
        print("Error Adding Data:", insertError)
    end
end
