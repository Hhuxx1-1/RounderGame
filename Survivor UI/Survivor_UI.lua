-- version: 2022-04-20
-- mini: 1029380338
local UI = "7455201304258484466";
local btn = {
    "7455201304258484466_49","7455201304258484466_56", "7455201304258484466_63"
}

ScriptSupportEvent:registerEvent("UI.Button.Click",function(e)
    local playerid = e.eventobjid;
    local uielement = e.uielement;
    -- print("Clicked Element : ",uielement," Event data : ",e);
    for i,ui in ipairs(btn) do 
        print(i,ui,uielement,ui == uielement);
        if ui == uielement then
            Game:dispatchEvent("SURVIVOR_ACTION",{eventobjid = playerid , customdata = i});
            break;
        end 
    end 

end)
-- ScriptSupportEvent:registerEvent("UI.Button.Click",function(e)
--     local playerid = e.eventobjid;
--     local elementClicked = e.uielement;
--     print("Clicked Element : ",elementClicked," Event data : ",e);
--     for i=1,3 do 
--         if elementClicked == UI_BTN[i] then

--         end 
--     end 
-- end)

