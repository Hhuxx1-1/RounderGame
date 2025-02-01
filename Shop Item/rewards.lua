local itemHolder = {} ; ITEM_SHOP = {}; ITEM_SHOP.REGISTER_NEW_ITEM = function(itemid,func)         itemHolder[itemid]=func ; end ; ITEM_SHOP.GET_ITEM = function(itemid)     return itemHolder[itemid];  end ; ScriptSupportEvent:registerEvent([[Player.AddItem]],function (e)   if(ITEM_SHOP.GET_ITEM(e.itemid))then  ITEM_SHOP.GET_ITEM(e.itemid)(e); end ; end)

ScriptSupportEvent:registerEvent("Game.Start",function()
    for i,d in ipairs(GLOBAL_CURRENCY.TOPUP_DATA) do 
        -- print("Adding item Data : ",i,d);
        ITEM_SHOP.REGISTER_NEW_ITEM(d.itemid,function(e)  
            -- print("Registering : ",d.itemid);
            if Player:removeBackpackItem(e.eventobjid, d.itemid, 1) == 0 then 
                -- print("Removing Item: ",d.itemid," For Player ",e.eventobjid);
                GLOBAL_CURRENCY:AddCurrency(e.eventobjid,d.name,d.amount)
                -- print("Currency Added ",d.name," :",d.amount," For Player ",e.eventobjid);
            end 
        end )
    end 
end)