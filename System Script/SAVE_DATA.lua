SAVE_DATA = { 
  data            = {}                -- Data
  ,   vartype         = 18                -- StringGroup
  ,   libname         = "SAVE_DATA_EXT"  -- Name of the Variable;
  ,   KEY             = "B1"
};

function SAVE_DATA:LOAD_ALL(p)
  local r, err = pcall(function()
  -- Fetch all data for the player
  local result, ret = Valuegroup:getAllGroupItem(self.vartype, self.libname, p)
  if result ~= 0 then
    --print("Failed to load player data")
  end
  -- print("Ret : ",ret)
  -- Parse and store data in self.data[p]
  self.data[p] = {}
  for _, entry in ipairs(ret) do
      -- Assuming data is stored in "metaKey|n|t|v" format
      local metaKey, n, t, v = entry:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
      if metaKey == SAVE_DATA.KEY then 
        table.insert(self.data[p], {
            k = metaKey,
            n = n,
            t = t,
            v = v,
        })
      else 
        if Valuegroup:clearGroupByName(SAVE_DATA.vartype, SAVE_DATA.libname,p) == 0 then 
          local ErrorUI = "7476138870394525938";
          -- Reset Level
          Player:openUIView(p,ErrorUI);
          -- local currentExp,Level = PLAYER_STAT:GET_EXP_LEVEL(p);
          -- GLOBAL_CURRENCY:SpendCurrency(p, "Exp" , currentExp);
          -- GLOBAL_CURRENCY:SpendCurrency(p, "Level" , math.max(Level-1),0);
          return SAVE_DATA:LOAD_ALL(p); -- try one more time 
        end 
      end 
  end

  --print( "Loaded data for player:", p, self.data[p] );
  end)
  if not r then
    --print( "Error Loading Player Data:", err );
  end
end

function SAVE_DATA:CHECK(p, n , r)
  -- Ensure data is loaded
  if not self.data[p] then
    if not r then 
      -- Load All when not exist;
      SAVE_DATA:LOAD_ALL(p)
      return SAVE_DATA:CHECK(p,n,true);
    else 
      return false -- Player data doesn't exist
    end 
  end

  -- Check if variable `n` exists for player `p`
  for _, entry in ipairs(self.data[p]) do
      if entry.n == n then
          return true -- Variable found
      end
  end

  return false -- Variable not found
end


SAVE_DATA.missingDataCount = {} -- Track missing data count per player & variable

-- **Handle Data Error and Reset Player Progress**
function SAVE_DATA:HandleDataError(p, n)
  local ErrorUI = "7476144209038874866"
  Customui:setText(p,ErrorUI,ErrorUI.."_3","Too many missing data errors for "..n.." Data will now Reset");

  Player:openUIView(p, ErrorUI)

  -- Reset Player Level and EXP
  -- local currentExp, Level = PLAYER_STAT:GET_EXP_LEVEL(p)
  -- GLOBAL_CURRENCY:SpendCurrency(p, "Exp", currentExp)
  -- GLOBAL_CURRENCY:SpendCurrency(p, "Level", math.max(Level - 1, 0))

  -- Reset counter for THIS variable after handling error
  self.missingDataCount[p][n] = 0
end


-- **Track missing data per player & variable**
function SAVE_DATA:TrackMissingData(p, n)
  -- Initialize missing count table for the player
  self.missingDataCount[p] = self.missingDataCount[p] or {}
  self.missingDataCount[p][n] = (self.missingDataCount[p][n] or 0) + 1

  -- If the SAME variable is missing 10 times, reset player data
  if self.missingDataCount[p][n] >= 10 then
      self:HandleDataError(p, n)
  end
end

function SAVE_DATA:GET(p, n)
  -- Ensure data is loaded
  if not self.data[p] then
      print("No data loaded for player:", p)

      -- Track missing variable
      self:TrackMissingData(p, n)

      return "NIL"
  end

  -- Find the specific variable n
  for _, entry in ipairs(self.data[p]) do
      if entry.n == n then
          -- If found, reset counter for this variable
          self.missingDataCount[p][n] = 0
          return entry
      end
  end

  -- Variable not found, track it
  print("Variable not found:", n, "for player:", p)
  self:TrackMissingData(p, n)

  return nil
end

function SAVE_DATA:READ(p,n)
-- this function fetch data in same way from get but return only the value of asked variable;
  local data = self:GET(p, n)
  return data ~= nil and data.v or nil;
end

function SAVE_DATA:GET_BY_TAG(p, tag)
  -- Ensure data is loaded
  if not self.data[p] then
      print("No data loaded for player:", p)
      return {}
  end

  local results = {}

  -- Iterate through player data to find matching tag
  for _, entry in ipairs(self.data[p]) do
      if entry.t == tag then
          table.insert(results, entry)
      end
  end

  return results -- Returns a table with all matching variables
end


function SAVE_DATA:MODIFY(p, n, newValue)
  local r, err = pcall(function()
    -- Ensure data is loaded
    if not self.data[p] then
        error("No data loaded for player:" .. tostring(p))
    end

    -- Find the specific variable
    for _, entry in ipairs(self.data[p]) do
        if entry.n == n then
            
            local oldval = string.format("%s|%s|%s|%s", self.KEY , entry.n, entry.t, entry.v)
            local newval = string.format("%s|%s|%s|%s", self.KEY , entry.n, entry.t, newValue)
            -- Replace the value using the API
            local result = Valuegroup:replaceValueByName(self.vartype, self.libname, oldval, newval, p)
            if result ~= 0 then
                error("Failed to modify value for n: " .. n)
            end

            -- Update the value in the local table
            entry.v = tostring(newValue)

          --print("Modified data for player:", p, "variable:", n, "new value:", newValue)
            return
        end
    end
    if Valuegroup:clearGroupByName(SAVE_DATA.vartype, SAVE_DATA.libname,p) == 0 then 
        Player:notifyGameInfo2Self(p," DATA ERROR: [Data is Cleared]");
    end 
    error("Variable not found for modification: " .. n)
  end)
  if not r then
    --print("Error Modifying Player Data:", err)
  end
end

function SAVE_DATA:NEW(p, data)
  -- Step 1: Construct the data
  local _data = {}
  local _r, _err = pcall(function()
      _data = { n = data[1], t = data[2], v = data[3]}
  end)
  if not _r then
    --print("Error When Constructing Data:", "Error At NEW:\n", _err)
      return
  end

  -- Step 2: Encode the data into a string
  local encodedData
  local r, err = pcall(function()
      -- Serialize the data to JSON or a simple string
      encodedData = string.format("%s|%s|%s|%s", self.KEY , _data.n, _data.t, _data.v)
  end)
  if not r then
    --print("Error Encoding Data:", err)
      return
  end

  -- Step 3: Use the API to add data to the group
  local insertResult, insertError = pcall(function()
      -- Get the current length of the group for the player
      local result, currentLength = Valuegroup:getGrouplengthByName(self.vartype, self.libname, p)
      if result ~= 0 then
        --print("Failed to get current length of the group")
      end

      -- Add the encoded data to the group
      local insertResult = Valuegroup:insertInGroupByName(self.vartype, self.libname, encodedData, p)
      if insertResult ~= 0 then
        --print("Failed to insert data into the group")
      end

    --print("Data successfully added at index:", currentLength + 1)
  end)
  if not insertResult then
    --print("Error Adding Data:", insertError)
  end
end
