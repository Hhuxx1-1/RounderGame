ACTION = {
    DATA = {},
    _DATA = {}
};

function ACTION:NEW(playerid,channeling_duration,func,animation_id,force) 
    if animation_id == nil then         animation_id = 1;    end 
    -- store it into playerid ACTION DATA 
    local function setAction(playerid,func,channeling_duration,animation_id)
        self.DATA[playerid] = { action = func , s = channeling_duration*20 , animation = animation_id }
    end 

    if not force then 
        if self.DATA[playerid] == nil then 
            setAction(playerid,func,channeling_duration,animation_id);
            return true;
        else 
            Player:notifyGameInfo2Self(playerid,"Busy");
            return false; 
        end 
    else 
        setAction(playerid,func,channeling_duration,animation_id);
        return true;
    end 

end 

function ACTION:UPDATE()
    if self.DATA ~= nil then 
        for playerid,data in ipairs(self.DATA) do 
            if data.s > 0 then 
                data.s = data.s - 1;

                if data.animation ~= nil then 
                    if Actor:playAct(playerid,data.animation) == 0 then 
                        self.DATA[playerid].animation = nil;
                    end 
                end 
            else 
                -- try execute stored function;

                if type(data.action) == "function" then 
                    local r, err = pcall(data.action, playerid);
                    if not r then 
                        print("Action Error["..playerid.."]:",err);
                    end 
                end 
            end 
        end 
    end 
end