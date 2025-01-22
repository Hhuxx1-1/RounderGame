ACTION = {}; -- Holder for Global function 

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

local running = {};
-- function to register player to do Run 
local function doRunning(playerid) 
    if not running[playerid] then 
        running[playerid] = true;
    end 
end
-- function to say that Player is Stop Running 
local function stopRunning(playerid)
    running[playerid] = false;
end 

-- Record Running Position here 
local LastPositionOfRunning = {};
local function UpdatePosition(entityId, position)
    LastPositionOfRunning[entityId] = position -- Store position as {x, y, z}
end

function IsSamePosition(entityId, newPosition)
    local lastPosition = LastPositionOfRunning[entityId]
    if not lastPosition then
        return false;
    end

    -- Calculate the distance between the two positions
    local dx = newPosition.x - lastPosition.x
    local dy = newPosition.y - lastPosition.y
    local dz = newPosition.z - lastPosition.z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

    -- Return true if the distance is less than 0.3
    -- if entityId == 1029380338 then 
    --     Chat:sendSystemMsg("distance : "..distance,1029380338);
    -- end 
    return distance == 0;
end


-- local switch = false;
-- Handle Run, Walk, Slowed Debuff Here 
local function updateSpeed(playerid,data,tick) 
    local speed         = data.speed    -- This is original speed : number 
    local staminaNow    = data.sp       -- This is Stamina Now 
    local staminaMax    = data.spmax    -- This is Stamina Max
    local isRunning     = data.isRun    -- Bool to Determina if The Player is in Running Condition Or Not 
    local bonusSpeed    = data.bonusSpeed or 0; -- Bonus Speed 
    local slowed        = data.slowed
    local stunned       = data.stunned 
    local blind         = data.blind

    -- update UI 
    local UI = "7455215546370038002"
    local staminaBar = "7455215546370038002_2"
    local staminaBtn = "7455215546370038002_4"

    local calculatedSpeed = (speed + bonusSpeed)/10;

    if isRunning then 
        staminaNow = math.max(staminaNow - 1,0);
        if  staminaNow == 0 then 
            isRunning = false; 
            slowed = math.min(slowed + 5,15);
        else 

            if math.fmod(tick,10) == 0 then 
                -- checkPosition 
                local r,x,y,z = Actor:getPosition(playerid);
                -- simplify the x,y,z 
                -- x,y,z = math.floor(x),math.floor(y),math.floor(z);
                -- check if Position of Actor are Same 
                if IsSamePosition(playerid, {x=x,y=y,z=z}) then
                -- stop running;
                isRunning = false; 
                end
                UpdatePosition(playerid,{x=x,y=y,z=z}) ;
            end 

            calculatedSpeed = calculatedSpeed * 2
        end 
    else 
        staminaNow = math.min(staminaNow + 0.5,staminaMax);
    end 

    -- handle Stunned 
    if stunned and stunned > 0 then 
        calculatedSpeed = 0;
        stunned = math.max(stunned-0.1,0);
        isRunning = false; 
    end 

    -- handle blinded 
    if blind and blind > 0 then 
        blind = math.max(blind-0.1,0);
        World:SetSkyBoxFilter(playerid, SKYBOXFILTER.GAMMA, math.max(50-(blind*5),0));
    end 
    
    -- handle Slowed 
    if slowed > 0 then 
        calculatedSpeed = math.max(calculatedSpeed - slowed,0);
        slowed = math.max(slowed-0.1,0);
        Customui:setColor(playerid,UI,staminaBar,0xff0000);
        isRunning = false; 
    else
        Customui:setColor(playerid,UI,staminaBar,0xffffff);
    end 

    if isRunning == true then
        -- hide Stamina btn 
        Customui:hideElement(playerid,UI,staminaBtn);
    else
        -- show Stamina btn     
        Customui:showElement(playerid,UI,staminaBtn);
    end 

    -- update Stamina Bar 
    local maxLength = 500;
    local height    =  25;
    local length = staminaNow/staminaMax * maxLength;
    Customui:setSize(playerid,UI,staminaBar,length,height);

    if staminaNow >= staminaMax then 
        -- hide stamina  Bar 
        Customui:hideElement(playerid,UI,staminaBar);
    else 
        -- show stamina  Bar 
        Customui:showElement(playerid,UI,staminaBar);
    end 

    Player:setAttr(playerid,10,calculatedSpeed);

    return staminaNow,isRunning,slowed,stunned,blind;
end

local function UpdateMonster(MONSTER_DATA,tick)

    local UI = "7455561304122267890";

    local key_UI = {
        skill_1     = {btn = 4 , pic = 5 , s = 13 , l = 15},
        skill_2     = {btn = 6 , pic = 7 , s = 12 , l = 16},
        skill_3     = {btn = 8 , pic = 9 , s = 11 , l = 17},
        basicAttack = {pic = 2 , btn = 1 , s = 14}
    }

    local color = {
        cooldown    = 0x515151,
        ready       = 0xffffff,
        locked      = 0x1e1e1e,
        disabled    = 0xff0000,
        just_ready  = 0xe9ff00
    }
    -- print("Updating Monster",MONSTER_DATA);
    -- for Skill Cooldown Logic ; 
    for playerid,data in pairs(MONSTER_DATA) do 
        -- reduce the number of execution 
        if math.fmod(tick,10) == 0 then 
            if data.passive_skill then
                -- print("Passive Skill is Found : ", data.passive_skill);
                local r ,err = pcall(data.passive_skill.action,playerid);

                if not r then 
                    print(err)
                end 
            else 
                -- print("Passive Skill not found : ",data);
            end 
        end 

        -- print(data)
        local skills = data.skill;
        for i,skill in ipairs(skills) do 
            -- get the CD skill from data.CD[skill.key]
            local CD = data.CD[skill.key];
            if tonumber(CD) then 
                if CD > 0 then 
                    -- Skill is on Cooldown 
                    -- Modify Main Root 
                    ROUND.GAME_DATA_NOW.data_monster[playerid].CD[skill.key] = math.max(CD - 0.05,0);
                    -- Ensuring the CD doesn't Go Below 0 by using Math.max 

                    -- setThe Pic Color as cooldown 
                    if CD <= 1 and math.fmod(math.floor(CD*500),4) >= 2 then 
                        Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].pic,color.just_ready);
                    else
                        Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].pic,color.cooldown);
                    end 
                    -- Update The UI to Show that The Skill is Cooldown 
                    Customui:setText(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].s,string.format("%.1f", CD).."s");
                else
                    -- Skill is Ready 

                    -- setThe Pic Color as Ready 
                    Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].pic,color.ready);
                    -- Hide Skill Cooldown Text;
                    Customui:setText(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].s,"");
                end 

                -- Hide Lock Icon 
                Customui:hideElement(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].l);
            else 
                -- Skill is Locked or Disabled 
                if CD == "locked" or CD == "Locked" then 

                -- Hide Skill Cooldown Text;
                Customui:setText(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].s,"");

                -- Show Lock Icon 
                Customui:showElement(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].l);

                -- setThe Pic Color as Locked 
                Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].pic,color.locked);

                else 
                    -- skill is Disabled 
                    -- Hide Skill Cooldown Text;
                    Customui:setText(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].s,"");

                    -- Show Lock Icon 
                    Customui:showElement(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].l);

                    -- set Color as Disabled 
                    Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].pic,color.disabled);
                end 
            end 

            -- set the Picture of Skill 
            if skill.icon then 
                Customui:setTexture(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].pic,skill.icon);
            else 
                Customui:setTexture(tonumber(playerid),UI,UI.."_"..key_UI[skill.key].pic,[[8_1029380338_1719587945]]);
            end 
        end 

        -- Basic Attack Cooldown Logic 
        local CD = data.CD.basic_attack;
        if CD > 0 then 
            -- Basic Attack is on Cooldown 
            -- Modify Main Root 
            ROUND.GAME_DATA_NOW.data_monster[playerid].CD.basic_attack = math.max(CD - 0.05,0);

            -- setThe Pic Color as cooldown 
            if CD <= 1 and math.fmod(math.floor(CD*500),4) >= 2 then 
                Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI.basicAttack.pic,color.just_ready);
            else
                Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI.basicAttack.pic,color.cooldown);
            end 
            -- Update The UI to Show that The Skill is Cooldown 
            Customui:setText(tonumber(playerid),UI,UI.."_"..key_UI.basicAttack.s,string.format("%.1f", CD).."s");
        else
            -- Skill is Ready 

            -- setThe Pic Color as Ready 
            Customui:setColor(tonumber(playerid),UI,UI.."_"..key_UI.basicAttack.pic,color.ready);
            -- Hide Skill Cooldown Text;
            Customui:setText(tonumber(playerid),UI,UI.."_"..key_UI.basicAttack.s,"");
        end 


        -- try update Speed 
        local rSpeed,ErrSpeed = pcall(function()
            local staminaNow,isRunning,debuffSlow,stunned,blind = updateSpeed(playerid,{
                speed       = ROUND.GAME_DATA_NOW.data_monster[playerid].speed,
                sp          = ROUND.GAME_DATA_NOW.data_monster[playerid].sp,
                spmax       = ROUND.GAME_DATA_NOW.data_monster[playerid].stamina,
                isRun       = running[playerid] or false,
                slowed      = ROUND.GAME_DATA_NOW.data_monster[playerid].debuff.slowed or 0,
                stunned     = ROUND.GAME_DATA_NOW.data_monster[playerid].debuff.stunned or 0,
                blind       = ROUND.GAME_DATA_NOW.data_monster[playerid].debuff.blind or 0,
                bonusSpeed  = ROUND.GAME_DATA_NOW.data_monster[playerid].bonus_speed or 0,
            },tick)

            -- Update the Main Data 
            running[playerid] = isRunning;
            ROUND.GAME_DATA_NOW.data_monster[playerid].sp = staminaNow;
            ROUND.GAME_DATA_NOW.data_monster[playerid].debuff.slowed = debuffSlow;
            ROUND.GAME_DATA_NOW.data_monster[playerid].debuff.stunned = stunned;
            ROUND.GAME_DATA_NOW.data_monster[playerid].debuff.blind = blind;
        end);

        if not rSpeed then 
            print(ErrSpeed);
        end 

    end 
end

local function RunExecutionCutscene(playerid)
   -- Get Current Monster on Round 
   local monster = ROUND.GAME_DATA_NOW.data_monster;
   for monsterid , data_monster in pairs(monster) do
        local execute_attack = data_monster.execute_attack;
        if execute_attack and type(execute_attack) == "function" then
            local r,err = pcall(execute_attack,monsterid,playerid)
            if not r then
                print("EXCUTE:",err);
            end 
        end 
   end 

   -- Delay Execution for 3 Seconds which is 20x3
   RUNNER:NEW(function()
    -- Add Into Survivor Died
    table.insert(ROUND.GAME_DATA_NOW.died,playerid);
   end,{},120)

end

local function UpdateSurvivor(Survivor,tick)
    
    local UI = "7455201304258484466";

    local element = {
        hp_bar = 4, 
        hp_text = 5, 
        backpack = {
            {btn = 48 } , {btn = 55} , {btn = 62} 
        }
    }

    local hp_bar_maximum_length,hp_bar_maximum_hight = 297 , 34;

    for survivorid,data in pairs(Survivor) do 

        -- Update the HP Bar 
        local r1,maxHP = Player:getAttr(survivorid,1);
        local r2,curHP = Player:getAttr(survivorid,2);
        -- make sure that both are exist 
        if r1 == 0 and r2 == 0 then 
            Customui:setSize(survivorid,UI,UI.."_"..element.hp_bar,curHP/maxHP*hp_bar_maximum_length,hp_bar_maximum_hight);
            Customui:setText(survivorid,UI,UI.."_"..element.hp_text,math.floor(curHP));
        end 

        -- Update the Backpack Bar 
        for slot,backpack in ipairs(data.backpack) do 
            if backpack.name == "empty" then 
                Customui:hideElement(survivorid,UI,UI.."_"..element.backpack[slot].btn);
            else 
                Customui:showElement(survivorid,UI,UI.."_"..element.backpack[slot].btn);
            end 
        end 

        -- check if Survivor is Out of HP 
        local r,err = pcall(function()
            if curHP < 1 then 
                -- survivor HP is 0;
                -- immediately remove from ROUND.GAME_DATA_NOW.data_survivor 
                ROUND.GAME_DATA_NOW.data_survivor[survivorid] = nil; 
                -- Run Executed Cutscene;
                RunExecutionCutscene(survivorid);
            end 
        end)
        if not r then
            print("Error 195 : ",err);
        end 

        -- try update Speed 
        local rSpeed,ErrSpeed = pcall(function()
            local staminaNow,isRunning,debuffSlow,stunned,blind = updateSpeed(survivorid,{
                speed       = ROUND.GAME_DATA_NOW.data_survivor[survivorid].speed,
                sp          = ROUND.GAME_DATA_NOW.data_survivor[survivorid].sp,
                spmax       = ROUND.GAME_DATA_NOW.data_survivor[survivorid].stamina,
                isRun       = running[survivorid] or false,
                slowed      = ROUND.GAME_DATA_NOW.data_survivor[survivorid].debuff.slowed or 0,
                stunned     = ROUND.GAME_DATA_NOW.data_survivor[survivorid].debuff.stunned or 0,
                blind       = ROUND.GAME_DATA_NOW.data_survivor[survivorid].debuff.blind or 0,
                bonusSpeed  = ROUND.GAME_DATA_NOW.data_survivor[survivorid].bonus_speed or 0,
            },tick)
            
            -- Update the Main Data 
            running[survivorid] = isRunning;
            ROUND.GAME_DATA_NOW.data_survivor[survivorid].sp = staminaNow;
            ROUND.GAME_DATA_NOW.data_survivor[survivorid].debuff.slowed = debuffSlow;
            ROUND.GAME_DATA_NOW.data_survivor[survivorid].debuff.stunned = stunned;
            ROUND.GAME_DATA_NOW.data_survivor[survivorid].debuff.blind = blind;
        end);

        if not rSpeed then 
            print(ErrSpeed);
        end 
    end
end

function ACTION:UPDATE(tick)

    local r,err = pcall(UpdateMonster,ROUND.GAME_DATA_NOW.data_monster,tick)
    
    if not r then 
        print(err);
    end 

    local r,err = pcall(UpdateSurvivor,ROUND.GAME_DATA_NOW.data_survivor,tick)
    
    if not r then 
        print(err);
    end 
end

ScriptSupportEvent:registerEvent("MONSTER_ACTION",function(e)
    local playerid = e.eventobjid;
    local data = e.customdata;
    local index_data = tonumber(string.match(data, "%d+"))
    print("MONSTER "..playerid.." ACTION TRIGGERED : ",data);

    -- data contain index of skill_ index or basic_attack
    local r,err = pcall(function()
        
        if data == "basic_attack" then
            local Data = ROUND.GAME_DATA_NOW.data_monster[playerid]
            local CD = Data.CD[data];
            if tonumber(CD) then 
                if CD <= 0 then
                    -- Skill Can be Used 
                    -- Execute the Skill
                    local basic_attack = ROUND.GAME_DATA_NOW.data_monster[playerid].basic_attack;
                    -- print(ROUND.GAME_DATA_NOW.data_monster[playerid].skill[index_data], skill_action)
                    local r,err = pcall(basic_attack,playerid,ROUND.GAME_DATA_NOW)

                    if r then 
                        -- if no error then enter cooldown 
                        ROUND.GAME_DATA_NOW.data_monster[playerid].CD[string.lower(data)] = ROUND.GAME_DATA_NOW.data_monster[playerid].basic_attack_cd;
                        -- print("Skill Execution Success : ",data," Index Data : ",index_data);
                        else
                        -- print("Skill Execution Failed : ",data," Index Data : ",index_data);
                    end 
                else
                    Player:notifyGameInfo2Self(playerid," In Cooldown");
                end 
            else 
                Player:notifyGameInfo2Self(playerid,"Attack Disabled");
            end 

        else
            -- check skill CD 
            local CD = ROUND.GAME_DATA_NOW.data_monster[playerid].CD[string.lower(data)];
            if tonumber(CD) then 
                if CD <= 0 then
                    -- Skill Can be Used 
                    -- Execute the Skill
                    local skill_action = ROUND.GAME_DATA_NOW.data_monster[playerid].skill[index_data].action;
                    -- print(ROUND.GAME_DATA_NOW.data_monster[playerid].skill[index_data], skill_action)
                    local r,err = pcall(skill_action,playerid,ROUND.GAME_DATA_NOW);

                    if r then 
                        -- if no error then enter cooldown 
                        ROUND.GAME_DATA_NOW.data_monster[playerid].CD[string.lower(data)] = ROUND.GAME_DATA_NOW.data_monster[playerid].skill[index_data].cooldown;
                        -- print("Skill Execution Success : ",data," Index Data : ",index_data);
                        else
                        -- print("Skill Execution Failed : ",data," Index Data : ",index_data);
                    end 
                else
                    Player:notifyGameInfo2Self(playerid,"Skill is In Cooldown");
                end 
            else 
                Player:notifyGameInfo2Self(playerid,"Level are Too Low");
            end 
        end 
    end)

    if not r then print(err) end 

end)

ScriptSupportEvent:registerEvent("startRunning",function(e)
    local playerid = e.eventobjid;
    doRunning(playerid);
end)

ScriptSupportEvent:registerEvent("Player.DamageActor",function(e)
    local playerid = e.toobjid;
    local damage = e.hurtlv;

    Player:shakeCamera(playerid, 1, math.min(math.ceil(damage^2/2),2500));
    Player:setMobileVibrate(playerid, 1.5, 150);
    
    f_H:playSoundOnActor(playerid,10383, 100, 1.2);
end)