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
    skill = {
        {
            key = "skill_1",
            name = "Heavy Attack",
            description = "Charge an Attack for 1.2s and Deal 100 Damage to Surrounding.",
            cooldown = 12, -- seconds
            action = function(playerid, ...)
                print("Heavy Attack executed on player:", playerid)
            end,
        },
        {
            key = "skill_2",
            name = "Rage Speed",
            description = "Increase Running Speed but Decrease When Turning or Stop Running.",
            cooldown = 16, -- seconds
            action = function(playerid, ...)
                print("Rage Speed executed on player:", playerid)
            end,
        },
        {
            key = "skill_3",
            name = "Tighten Sense",
            description = "Increase Running Speed but Decrease When Turning or Stop Running.",
            cooldown = 16, -- seconds
            action = function(playerid, ...)
                print("Rage Speed executed on player:", playerid)
            end,
        },
    },
    passive_skill = {
        key = "passive_skill",
        name = "Restless",
        description = "Stamina Consumption and Stun Duration Reduced.",
        action = function(playerid, ...)
            print("Restless effect applied to player:", playerid)
        end,
    },
    basic_attack_cd = 2,
    basic_attack = function()
        print("Basic Attack Executed");
    end,
    price = 0,
    picture_icon = 0,
    model = {
        normal = [[mob_3]],
        charge = [[mob_4]],
    }
})
