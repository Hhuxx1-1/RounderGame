SURVIVOR_DATA:NEW({
    key = "survivor_4",
    name = "Misra",
    description = "",
    health = 100,
    damage = 5,
    speed = 75,
    stamina = 120,
    rarity = 1,
    icon = SURVIVOR_DATA:getskinIco(4),
    price = 4000,
    type_currency = "FirePoint",
    model = {
        normal = [[skin_4]],
    },
    skill = {
        {
            key = "skill_1",
            name = "Start Item : Healing Leaf",
            description = "Use to Recover Health",
            icon = [[item_103]],
            action = function(playerid)
                -- add 1 Healing leaf into Backpack;
            end
        },
        {
            key = "skill_2",
            name = "Start Item : Healing Leaf",
            description = "Use to Recover Health",
            icon = [[item_103]],
            action = function(playerid)
                -- add 1 Healing leaf into Backpack;
            end
        },
        {
            key = "skill_3",
            name = "Perk : Extra Health",
            description = "Got 25 Hp",
            icon = [[item_105]],
            action = function(playerid)
                -- add 25 Hp;
            end
        },
    }
})

