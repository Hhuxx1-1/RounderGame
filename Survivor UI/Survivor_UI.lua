local UI = "7455201304258484466";
local UI_BTN = {
    "7455201304258484466_49","7455201304258484466_56", "7455201304258484466_63"
}

ScriptSupportEvent:registerEvent("UI.Button.Click",function(e)
    local playerid = e.eventobjid;
    local elementClicked = e.uielement;
    for i=1,3 do 
        if elementClicked == UI_BTN[i] then
            print("Backpack bar Click = "..i);
            local r,err = pcall(BACKPACK_ITEM.USE,BACKPACK_ITEM,playerid, i);
            if not r then print(err) end;
        end 
    end 
end)