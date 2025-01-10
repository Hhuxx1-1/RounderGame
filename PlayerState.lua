PLAYER_STATE = {}; -- Store Player State here ; 
-- Player state is Table where key is player id and the value is a table contain 2 main keys which is state_name and function_state; 
-- Player state also have one extra State which is Duration State when not declared the State will Remain until Next State is Added;
-- Duration State is used to Countdown until State is Finished and Return to Idle State again;
-- Some State also Cancel able where it is declared as CanCancel = true;

-- Determine the function of Player State 
function PLAYER_STATE_SET_STATE(dat) 
    local player_id = dat.Playerid; --Expected number Must not Empty or nil
    local state_name = dat.Name; --expected String  Must not Empty or nil 
    local function_state = dat.Func; -- expected function Must not Empty or nil
    local can_cancel = dat.CanCancel; --expected boolean if Empty then it is false as default
    local duration = dat.Duration; --expected number if Nil then it is 0 as default

    -- check each of type of them could be empty 
end 