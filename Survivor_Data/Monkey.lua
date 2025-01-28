SURVIVOR_DATA:NEW({
    key = "survivor_2",
    name = "Monkey",
    description = "",
    health = 150,
    damage = 5,
    speed = 80,
    stamina = 100,
    rarity = 1,
    icon = SURVIVOR_DATA:getskinIco(2),
    price = 100,
    type_currency = "Crystal",
    model = {
        normal = [[skin_2]],
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

