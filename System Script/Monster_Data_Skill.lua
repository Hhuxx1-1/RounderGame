-- Define a monster
MONSTER_DATA:NEW({
    key = "monster_1",
    name = "Mutant Human",
    description = "A human that has been mutated by the virus.",
    health = 1000,
    damage = 50,
    speed = 120,
    attack_speed = 2, -- seconds
    attack_range = 2.5, -- blocks
    rarity = 1,
    skill = {
        {
            key = "skill_1",
            name = "Heavy Attack",
            description = "Charge an Attack for 1.2s and Deal 100 Damage to Surrounding.",
            cooldown = 12, -- seconds
            action = function(playerid, ...)
                print("Heavy Attack executed on player:", playerid)
            end,
            icon_id = [[]]; 
        },
        {
            key = "skill_2",
            name = "Rage Speed",
            description = "Increase Running Speed but Decrease When Turning or Stop Running.",
            cooldown = 16, -- seconds
            action = function(playerid, ...)
                print("Rage Speed executed on player:", playerid)
            end,
            icon_id = [[]]; 
        },
        {
            key = "skill_3",
            name = "Tighten Sense",
            description = "Increase Running Speed but Decrease When Turning or Stop Running.",
            cooldown = 16, -- seconds
            action = function(playerid, ...)
                print("Rage Speed executed on player:", playerid)
            end,
            icon_id = [[]]; 
        },
    },
    passive_skill = {
        key = "passive_skill",
        name = "Restless",
        description = "Stamina Consumption and Stun Duration Reduced.",
        effect = function(playerid, ...)
            print("Restless effect applied to player:", playerid)
        end,
        icon_id = [[]]; 
    },
    price = 0,
    picture_icon = 0,
    model = {
        normal = [[mob_3]],
        charge = [[mob_4]],
    }
})

-- Define a monster
MONSTER_DATA:NEW({
    key = "monster_2",
    name = "Dark Hunter",
    description = "A human that has been mutated by the virus.",
    health = 1000,
    damage = 50,
    speed = 120,
    attack_speed = 2, -- seconds
    attack_range = 2.5, -- blocks
    rarity = 5,
    skill = {
        {
            key = "skill_1",
            name = "Deadly Poison Gas",
            description = "Release a Deadly Poison Gas from Body. Blocking Walked Path with Deadly Gas.",
            cooldown = 12, -- seconds
            action = function(playerid, ...)
                print("Deadly Poison Gas", playerid)
            end,
            icon_id = [[]]; 
        },
        {
            key = "skill_2",
            name = "Terror Scream",
            description = "Terrify Everyone That Hears it. Reduce Their Stamina by 50%",
            cooldown = 16, -- seconds
            action = function(playerid, ...)
                print("Terrify Everyone that Hears It", playerid)
            end,
            icon_id = [[]]; 
        },
        {
            key = "skill_3",
            name = "Smash",
            description = "Slam the Ground Causing Damage to Area",
            cooldown = 8, -- seconds
            action = function(playerid, ...)
                print("Slaming Ground");
            end,
            icon_id = [[]]; 
        }
    },
    passive_skill = {
        key = "passive_skill",
        name = "Restless",
        description = "Stamina Consumption and Stun Duration Reduced.",
        effect = function(playerid, ...)
            print("Restless effect applied to player:", playerid)
        end,
        icon_id = [[]]; 
    },
    price = 500000,
    picture_icon = [[mob_5]],
    model = {
        normal = [[mob_5]],
        charge = [[mob_6]],
    }
})
