local UI = "7462634028632054002"

local btnAction = {}
local currentPage = {}
local totalPages = {}

-- Function to set action for a button
local function setActionBtn(playerid, btn, func)
    if not btnAction[playerid] then btnAction[playerid] = {} end
    if type(func) == "function" then
        btnAction[playerid][UI .. "_" .. btn] = func
    end
end

-- Slot configuration (4 slots available)
local slot = {
    { base = 17, bgwin = 18, txwin = 19, icon = 20, titlebg = 21, titletx = 22, datetx = 23, desctx = 24, star = 26, startx = 27 },
    { base = 28, bgwin = 29, txwin = 30, icon = 31, titlebg = 32, titletx = 33, datetx = 34, desctx = 35, star = 37, startx = 38 },
    { base = 39, bgwin = 40, txwin = 41, icon = 42, titlebg = 43, titletx = 44, datetx = 45, desctx = 46, star = 48, startx = 49 },
    { base = 50, bgwin = 51, txwin = 52, icon = 53, titlebg = 54, titletx = 55, datetx = 56, desctx = 57, star = 59, startx = 60 },
}

-- Function to update the UI
local function updateUI(playerid)
    local data = GLOBAL_MATCH:LoadHistory(playerid)
    local itemsPerPage = 4

    -- Ensure the current page is initialized
    if not currentPage[playerid] then currentPage[playerid] = 1 end
    totalPages[playerid] = math.ceil(#data / itemsPerPage) 

    -- Calculate indices for the current page
    local startIndex = (currentPage[playerid] - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, #data)

    -- Update each slot
    for i = 1, itemsPerPage do
        local slotIndex = startIndex + i - 1
        local slotData = data[slotIndex]
        if slotData then
            -- Populate UI slot with data
            Customui:showElement(playerid,UI,UI.."_"..slot[i].base);
            Customui:setText(playerid,UI,UI.."_"..slot[i].txwin,slotData.r);

            -- set the Color 
            local color = {bgwin = {defeat=0x5b0900 ,win =0xffffff},txwin = {defeat=0xff1900,win=0xffffff}};
            Customui:setColor(playerid,UI,UI.."_"..slot[i].bgwin,color.bgwin[string.lower(slotData.r)]);
            Customui:setColor(playerid,UI,UI.."_"..slot[i].txwin,color.txwin[string.lower(slotData.r)]);

            -- set icon and name 
            Customui:setTexture(playerid,UI,UI.."_"..slot[i].icon,slotData.i);
            Customui:setText(playerid,UI,UI.."_"..slot[i].titletx,slotData.u);
            
            -- set Color for title Name 
            local bgColor = {text={Monster=0xef2d2d,Survivor =0x93d3f3},bg ={Monster=0x491600,Survivor=0x095e8e}};
            Customui:setColor(playerid,UI,UI.."_"..slot[i].titletx,bgColor.text[slotData.y]);
            Customui:setColor(playerid,UI,UI.."_"..slot[i].titlebg,bgColor.bg[slotData.y]);

            -- set Time Content 
            Customui:setText(playerid,UI,UI.."_"..slot[i].datetx,slotData.t);

            -- set Content Desc
            Customui:setText(playerid,UI,UI.."_"..slot[i].desctx,slotData.m.."\n"..slotData.s);

            -- set Star Reward 
            Customui:setText(playerid,UI,UI.."_"..slot[i].startx,slotData.a);
        else
            -- Clear slot if no data
            Customui:hideElement(playerid,UI,UI.."_"..slot[i].base);
        end
    end
end
-- Handle Next Page
local function nextPage(playerid)
    if currentPage[playerid] < totalPages[playerid] then
        currentPage[playerid] = currentPage[playerid] + 1
        updateUI(playerid)
    end
end

-- Handle Previous Page
local function prevPage(playerid)
    if currentPage[playerid] > 1 then
        currentPage[playerid] = currentPage[playerid] - 1
        updateUI(playerid)
    end
end

-- Function to update pagination controls
local function updatePagination(playerid)
    local current = currentPage[playerid] or 1
    local total = totalPages[playerid] or 1

    -- Update pagination buttons
    local pagination_element = "7462634028632054002_4";
    local prevBtn            = "7462634028632054002_2";
    local nextBtn            = "7462634028632054002_3";
    local contentPagination = " "

    for i = 1, total do
        if i == current then
            contentPagination = contentPagination .. "● "
        else
            contentPagination = contentPagination .. "○ "
        end 
    end 
    -- set the pagination icon 
    Customui:setText(playerid,UI,pagination_element,contentPagination);
    -- set button Action  
    setActionBtn(playerid,2,function()
        prevPage(playerid);
    end)
    -- set button Action  
    setActionBtn(playerid,3,function()
        nextPage(playerid);
    end)
end

-- Handle Slot Selection
-- local function selectSlot(playerid, slotIndex)
--     local data = GLOBAL_MATCH:LoadHistory(playerid)
--     local startIndex = (currentPage[playerid] - 1) * 4 + 1
--     local selectedData = data[startIndex + slotIndex - 1]
--     if selectedData then
--         print("Player " .. playerid .. " selected match: " .. selectedData.title)
--         -- Perform further actions for the selected match
--     else
--         print("No match data in the selected slot.")
--     end
-- end


ScriptSupportEvent:registerEvent("UI.Button.Click",function(e)
    local playerid = e.eventobjid;
    local element =  e.uielement;

    if btnAction[playerid] then 
        -- btn Action for playerid is already defined 
        if btnAction[playerid][element] ~= nil then
            -- btn action is not nil 
            -- check if it is function 
            if type(btnAction[playerid][element]) == "function" then 
                -- It is executeable Function 
                local r , err = pcall(btnAction[playerid][element],playerid);
                if not r then 
                    print(err);
                else
                    updatePagination(playerid);
                end 
            else 
                -- not a function 
                f_H:SendMessage(playerid,"Action Invalid");
            end 
        end
    else
        f_H:SendMessage(playerid,"Action Invalid: unset");
    end 
end)

-- Show and Hide UI Events
ScriptSupportEvent:registerEvent("UI.Show", function(e)
    local function tryOpenUI(playerid,stop)
        local r,err = pcall(updateUI,playerid)
        if not r then
            -- clear the Match History becuz there is bug for old player data 
            GLOBAL_MATCH:ClearHistory(playerid)
            print("Error : ",err);
            if not stop then 
                tryOpenUI(playerid,true);
            end 
        else
            updatePagination(playerid)
        end 
    end 
    tryOpenUI(e.eventobjid);
end)

ScriptSupportEvent:registerEvent("UI.Hide", function(e)
    ROUND:clearState(e.eventobjid)
end)
