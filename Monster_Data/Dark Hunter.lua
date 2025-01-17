-- Define a monster
MONSTER_DATA:NEW({
    key = "monster_2",
    name = "Dark Hunter",
    description = "A human that has been mutated by the virus.",
    health = 1000,
    damage = 50,
    speed = 80,
    stamina = 150,
    rarity = 1,
    damage_grow = 2,
    speed_grow = 2,
    maximum_damage_range = 2,
    icon = [[1004122]],
    skill = {
        {
            key = "skill_1",
            name = "Deadly Poison Gas",
            description = "Release a Deadly Poison Gas from Body. Blocking Walked Path with Deadly Gas.",
            cooldown = 12, -- seconds
            action = function(playerid, ...)
                print("Deadly Poison Gas", playerid)
            end,
        },
        {
            key = "skill_2",
            name = "Terror Scream",
            description = "Terrify Everyone That Hears it. Reduce Their Stamina by 50%",
            cooldown = 16, -- seconds
            action = function(playerid, ...)
                print("Terrify Everyone that Hears It", playerid)
            end,
        },
        {
            key = "skill_3",
            name = "Smash",
            description = "Slam the Ground Causing Damage to Area",
            cooldown = 8, -- seconds
            action = function(playerid, data)
                print("Slaming Ground");
            end 
        }
    },
    passive_skill = {
        key = "passive_skill",
        name = "Restless",
        description = "Stamina Consumption and Stun Duration Reduced.",
        action = function(playerid, data)
            print("Restless effect applied to player:", playerid)
        end,
    },
    basic_attack_cd = 2,
    basic_attack = function(playerid,data)
        print("Basic Attack Executed");
    end,
    execute_attack = function(playerid,data)
        
    end,
    price = 5000,
    picture_icon = [[mob_5]],
    model = {
        normal = [[mob_5]],
        charge = [[mob_6]],
    }
})
