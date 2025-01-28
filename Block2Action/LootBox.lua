ACTION_DATA:NEW(2017,function(playerid,x,y,z)
    ACTION_DATA:ADD(playerid, function()
        Block:destroyBlock(x,y,z)
        BACKPACK_ITEM:ADD(playerid,1);
        print("Backpack Now : ",ROUND.GAME_DATA_NOW.data_survivor[playerid].backpack);
    end, 4, "Opening Lootbox",5)
end)

BACKPACK_ITEM:NEW(1,{
    name = "Dummy Item",
})