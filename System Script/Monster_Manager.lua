MONSTER_DATA = {}

function MONSTER_DATA:NEW(monster)
    -- Validate required fields
    assert(monster.key, "Monster must have a unique key!")
    assert(monster.name, "Monster must have a name!")
    assert(monster.health and monster.damage and monster.speed, "Monster must have health, damage, and speed!")

    -- Register monster
    self[monster.key] = monster

    -- Automatically register skills
    if monster.skill then
        for _, skill in ipairs(monster.skill) do
            SKILL_DATA:NEW(monster.name, skill)
        end
    end

    -- Automatically register passive skill
    if monster.passive_skill then
        SKILL_DATA:NEW(monster.name, monster.passive_skill, true) -- Mark as passive skill
    end
end

function MONSTER_DATA:FETCH(id)
    -- get monster id based on key 
    -- key is prefixed with "monsetr_"
    local key = "monster_" .. id
    -- fetch from MONSTER_DATA[]
    return self[key]
end

SKILL_DATA = {}

function SKILL_DATA:NEW(monster_name, skill, is_passive)
    -- Validate skill structure
    assert(skill.key, "Skill must have a unique key!")
    assert(skill.name, "Skill must have a name!")
    assert(skill.action, "Skill must have an action function!")

    if not self[monster_name] then
        self[monster_name] = {}
    end

    -- Register the skill (distinguish between active and passive)
    local skill_type = is_passive and "passive" or "active"
    if not self[monster_name][skill_type] then
        self[monster_name][skill_type] = {}
    end
    self[monster_name][skill_type][skill.key] = skill
end

function SKILL_DATA:RUN(monster_name, skill_key, playerid, ...)
    -- Find and execute the skill
    local skill = self[monster_name] and self[monster_name].active and self[monster_name].active[skill_key]
    if not skill then
        print("Skill not found:", monster_name, skill_key)
        return
    end

    print("Executing skill:", skill.name, "for monster:", monster_name)
    return skill.action(playerid, ...)
end

function SKILL_DATA:RUN_PASSIVE(monster_name, playerid, ...)
    -- Find and execute passive skills
    local passive_skills = self[monster_name] and self[monster_name].passive
    if not passive_skills then
        print("No passive skills for monster:", monster_name)
        return
    end

    for key, skill in pairs(passive_skills) do
        print("Executing passive skill:", skill.name, "for monster:", monster_name)
        skill.effect(playerid, ...)
    end
end

