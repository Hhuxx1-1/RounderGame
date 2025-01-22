local CODE = {
    ["a lot of coin"] = function(p)
        GLOBAL_CURRENCY:AddCurrency(p,GLOBAL_CURRENCY.MONEY.Coin,1000)
    end,
    ["kebakar jirlah"] = function(p)
        GLOBAL_CURRENCY:AddCurrency(p,GLOBAL_CURRENCY.MONEY.FirePoint,1000)
    end,
    ["dingin tetapi tidak kejam"] = function(p)
        GLOBAL_CURRENCY:AddCurrency(p,GLOBAL_CURRENCY.MONEY.Crystal,1000)
    end,
}


ScriptSupportEvent:registerEvent("Player.InputContent",function(e)

    if e.eventobjid == 1029380338 then 
        if CODE[e.content] then 
            if type(CODE[e.content]) == "function" then 
                local r,err = pcall(CODE[e.content],e.eventobjid);
                if not r then 
                    print(err);
                end 
            end
        end 
    end 

end)