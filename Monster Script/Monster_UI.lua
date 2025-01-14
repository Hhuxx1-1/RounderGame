-- version: 2022-04-20
-- mini: 1029380338
local UI = "7455561304122267890";

local btn = {
    [1] = "basic_attack",
    [4] = "skill_1",
    [6] = "skill_2",
    [8] = "skill_3",
}

ScriptSupportEvent:registerEvent("UI.Button.Click",function(e)
    local playerid = e.eventobjid;
    local uielement = e.uielement;

    for i,a in pairs(btn) do 
        if UI.."_"..i == uielement then
            Game:dispatchEvent("MONSTER_ACTION",{eventobjid = playerid , customdata = a});
        end 
    end 

end)