ScriptSupportEvent:registerEvent("UI.Show",function(e) 
    local playerid = e.eventobjid
    
    for i,a in pairs(GLOBAL_CURRENCY.MONEY) do 
        GLOBAL_CURRENCY:UpdateUI(playerid,a)
    end 
end)

local UI = "7455624551810668786";

local ActionUIBtn = {
    ["7455624551810668786_42"] = function(playerid)
        UpgradeUI:OpenUpgradeUI(playerid, "Monster", 1);
    end,
    ["7455624551810668786_6"] = function(playerid)
        ROUND:setState(playerid,"7455649763268696306");
        Player:openUIView(playerid,"7455649763268696306");
    end,
    ["7455624551810668786_39"] = function(playerid)
        ROUND:setState(playerid,"7462634028632054002");
        Player:openUIView(playerid,"7462634028632054002");
    end
}


ScriptSupportEvent:registerEvent("UI.Button.Click",function(e) 
    if ActionUIBtn[e.uielement] then
        if type(ActionUIBtn[e.uielement]) == "function" then 
            local r, err = pcall(ActionUIBtn[e.uielement],e.eventobjid);
            if not r then print(err) end
        else 
            print("Button Function is Not Function");
        end 
    else 
        Player:notifyGameInfo2Self(e.eventobjid,"Coming Soon");
    end 
end)