ACTION_DATA:NEW(2018,function(playerid,x,y,z)
    ACTION_DATA:ADD(playerid, function()
        if ROUND.GAME_DATA_NOW.objNow then 
            if Block:destroyBlock(x,y,z) == 0 then 
                ROUND.GAME_DATA_NOW.objNow     = ROUND.GAME_DATA_NOW.objNow     + 1;
            end 
        end 
    end, 2, "Destroying Cursed Paper",3)
end);