-- Define a monster
MONSTER_DATA:NEW({
    key = "monster_1",
    name = "Mutant Human",
    description = "A human that has been mutated by the virus.",
    health = 1000,
    damage = 50,
    speed = 120,
    rarity = 1,
    damage_grow = 2,
    speed_grow = 2,
    maximum_damage_range = 3,
    skill = {
        {
            key = "skill_1",
            name = "Heavy Attack",
            description = "Charge an Attack for 1.2s and Deal 100 Damage to Surrounding.",
            cooldown = 12, -- seconds
            action = function(playerid, ...)
                -- print("Heavy Attack executed on player:", playerid)
            end,
            icon = [[8_1029380338_1736871808]]
        },
        {
            key = "skill_2",
            name = "Rage Speed",
            description = "Increase Running Speed but Decrease When Turning or Stop Running.",
            cooldown = 16, -- seconds
            action = function(playerid, data)
                -- print("Rage Speed executed on player:", playerid)
            end,
            icon = [[8_1029380338_1736871805]]
        },
        {
            key = "skill_3",
            name = "Tighten Sense",
            description = "Increase Running Speed but Decrease When Turning or Stop Running.",
            cooldown = 16, -- seconds
            action = function(playerid, data)
                -- print("Rage Speed executed on player:", playerid)
            end,
            icon = [[8_1029380338_1736871798]]
        },
    },
    passive_skill = {
        key = "passive_skill",
        name = "Restless",
        description = "Stamina Consumption and Stun Duration Reduced.",
        action = function(playerid, data)
            -- print("Restless effect applied to player:", playerid)
        end,
    },
    basic_attack_cd = 2,
    basic_attack = function(playerid,data)
        -- print("Basic Attack Executed");

        -- stop Player Movement;
        f_H:SET_ACTOR(playerid,"MOVE",false);

        RUNNER:NEW(function()
            -- play basic Attack Animation and Use model normal 
            f_H:LoadAnim(playerid,data.data_monster[playerid].model.normal);
            f_H:PlayAnim(playerid,"Attack"); 
        end,{},1)

        -- use multirunner to create delay of 0.2 seconds 
        RUNNER:NEW(function()
            -- get each Object in That 3x3 Area 
            local x,y,z     = f_H:GET_POS(playerid)
            local ox,_,oz     = f_H:GET_DIR_ACTOR(playerid)
            local obj       = f_H:getObj_Area(x+(ox*2),y+2,z+(oz*2),2,2,2);

            -- separate the player and creature from it 
            local player    = f_H:filterObj("Player",obj);
            local creature  = f_H:filterObj("Creature",obj);

            -- remove self from player 
            player = f_H:notObj(playerid,player);
            -- Calculate the Damage based on Range the more Closed the more Damage it deals             
            local level  = data.data_monster[playerid].level;
            local bonus_damage = ((level - 1)*data.data_monster[playerid].damage_grow);
            local damage = data.data_monster[playerid].damage + bonus_damage;
            local effectiveRange = data.data_monster[playerid].maximum_damage_range;
            -- if the range is more than half the damage output to that player or creature 
            for i,target_playerid in ipairs(player) do 
                local tx,ty,tz = f_H:GET_POS(target_playerid);
                local calculated_damage = damage * ((math.random(10,15)/10) - (math.abs((tx-x)+(ty-y)+(tz-z))/effectiveRange))
                f_H:Damage2Player(playerid,target_playerid,calculated_damage);
            end 
            -- do the same for creature 
            for i,target_creature in ipairs(creature) do
                local tx,ty,tz = f_H:GET_POS(target_creature);
                local calculated_damage = damage * ((math.random(10,15)/10) - (math.abs((tx-x)+(ty-y)+(tz-z))/effectiveRange))
                f_H:Damage2Player(playerid,target_creature,calculated_damage);
            end 
            -- Enable back the Movement after 0.8
            RUNNER:NEW(function()
                f_H:SET_ACTOR(playerid,"MOVE",true);
            end,{},5)

        end,{},6) -- each thick is 0.05 seconds 

    end,
    execute_attack = function(playerid,targetid,data)
        -- Executed on Target 
        print("Executing Target : ",targetid,"Playerid : ",playerid);
    end,
    price = 0,
    picture_icon = 0,
    model = {
        normal = [[mob_3]],
        rage = [[mob_4]],
    }
})
