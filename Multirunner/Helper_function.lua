f_H = {} -- function Helper for Global Shortcut and Logic API

    function f_H:Damage2Player(obj1, obj2, dmg)
        if Actor:playerHurt(obj1, obj2, dmg, 1) == 0 then
            return true
        else
            return false
        end
    end
    
    function f_H:PlayAnim(obj1, name)
        local animations = {
            Wave = 1, Gratitude = 7, What = 2, Casual = 8,
            Cry = 3, Fall_Down = 9, Angry = 4, Pose = 10,
            Relive = 5, Stand = 11, Happy = 6, Run = 12,
            Sit = 14, Sleep = 13, Swim = 15, Attack = 16,
            Die = 17, Striked = 18, Relaxed = 19, Jump = 20
        }
    
        if Actor:isPlayer(obj1) == 0 then
            if Player:playAct(obj1, animations[name]) == 0 then
                return true
            else
                return false
            end
        else
            if Actor:playAct(obj1, animations[name]) == 0 then
                return true
            else
                return false
            end
        end
    end
    
    function f_H:LoadAnim(obj1, modelID)
        if Actor:changeCustomModel(obj1, modelID) == 0 then
            return true
        else
            return false
        end
    end
    
    function f_H:getAttr(obj, type_)
        if Actor:isPlayer(obj) == 0 then
            return Player:getAttr(obj, type_)
        else
            return Creature:getAttr(obj, type_)
        end
    end
    
    function f_H:setAttr(obj, type_, value)
        if Actor:isPlayer(obj) == 0 then
            return Player:setAttr(obj, type_, value)
        else
            return Creature:setAttr(obj, type_, value)
        end
    end
    
    function f_H:getPos(obj)
        local r1, tPos = Actor:getPositionV2(obj)
        local r2, x, y, z = Actor:getPosition(obj)
        return { x = x, y = y, z = z, tPos = tPos }
    end
    
    function f_H:getAimPos_Player(playerID)
        local r, x, y, z = Player:getAimPos(playerID)
        return { x = x, y = y, z = z }
    end
    
    function f_H:CalculateDistance(pos1, pos2)
        local dx = pos2.x - pos1.x
        local dy = pos2.y - pos1.y
        local dz = pos2.z - pos1.z
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
    
    function f_H:CalculateDirBetween2Pos(pos1, pos2)
        local dx = pos2.x - pos1.x
        local dy = pos2.y - pos1.y
        local dz = pos2.z - pos1.z
        local magnitude = math.sqrt(dx * dx + dy * dy + dz * dz)
        return { x = dx / magnitude, y = dy / magnitude, z = dz / magnitude }
    end
    
    function f_H:spawnObj(x,y,z,creatureid)
        if World:spawnCreature(x,y,z,creatureid,1) == 0 then 
            return true;
        else 
            return false;
        end 
    end

    function f_H:shootProjectile(shooter,itemid,pos,dir)
        local r,obj = World:spawnProjectileByDir(shooter, itemid, pos.x, pos.y, pos.z, dir.x, dir.y, dir.z, dir.speed);
        if r == 0 then 
            return obj;
        else
            return false;
        end 
    end

    function f_H:GET_POS(actorID)
        local r, x, y, z = Actor:getPosition(actorID)
        if r then return x, y, z end
    end
    
    function f_H:GET_AIM_POS_PLAYER(obj)
        local r, x, y, z = Player:getAimPos(obj)
        if r == 0 then return x, y, z end
    end
    
    function f_H:GET_EYE_POS_ACTOR(obj)
        local r, x, y, z = Actor:getEyePosition(obj)
        if r == 0 then return x, y, z end
    end
    
    function f_H:GET_DIR_ACTOR(obj)
        local r, x, y, z = Actor:getFaceDirection(obj)
        if r == 0 then return x, y, z end
    end
    
    function f_H:ADD_EFFECT(x, y, z, effectID, scale)
        World:playParticalEffect(x, y, z, effectID, scale)
    end
    
    function f_H:DEL_EFFECT(x, y, z, effectID, scale)
        World:stopEffectOnPosition(x, y, z, effectID, scale)
    end
    
    function f_H:DEALS_DAMAGE_2_AREA(playerID, x, y, z, dx, dy, dz, amount, dtype)
        local r, areaID = Area:createAreaRect({x = x, y = y, z = z}, {x = dx, y = dy, z = dz})
        local r1, players = Area:getAreaPlayers(areaID)
        local r2, creatures = Area:getAreaCreatures(areaID)
        for i, a in ipairs(players) do
            if a ~= playerID then
                Actor:playerHurt(playerID, a, amount, dtype)
            end
        end
        for i, a in ipairs(creatures) do
            Actor:playerHurt(playerID, a, amount, dtype)
        end
        Area:destroyArea(areaID)
    end
    
    function f_H:DEALS_DAMAGE_2_AREA_WITH_BUFF(playerID, x, y, z, dx, dy, dz, amount, dtype, buffID, buffLV, customTicks)
        f_H:DEALS_DAMAGE_2_AREA(playerID, x, y, z, dx, dy, dz, amount, dtype)
        local r, areaID = Area:createAreaRect({x = x, y = y, z = z}, {x = dx, y = dy, z = dz})
        local r1, players = Area:getAreaPlayers(areaID)
        local r2, creatures = Area:getAreaCreatures(areaID)
        for i, a in ipairs(players) do
            if a ~= playerID then
                Actor:addBuff(a, buffID, buffLV, customTicks)
            end
        end
        for i, a in ipairs(creatures) do
            Actor:addBuff(a, buffID, buffLV, customTicks)
        end
        Area:destroyArea(areaID)
    end
    
    function f_H:dash(playerID, x, y, z)
        Actor:appendSpeed(playerID, x, y, z)
    end
    
    function f_H:checkBlockIsSolid(x, y, z)
        local r, b = Block:isSolidBlock(x, y, z)
        return b
    end
    
    function f_H:addBlock(blockID, x, y, z)
        if not f_H:checkBlockIsSolid(x, y, z) then
            Block:placeBlock(blockID, x, y, z)
        end
    end
    
    function f_H:healsDamage(playerID, dmg)
        local r, HP = Player:getAttr(playerID, 2)
        Player:setAttr(playerID, 2, HP + dmg)
    end
    
    function f_H:getDir(playerID)
        local pX, pY, pZ = f_H:GET_POS(playerID)
        local dX, dY, dZ = f_H:getAimPos_Player(playerID)
        local dirX, dirY, dirZ = dX - pX, dY - pY, dZ - pZ
        local magnitude = math.sqrt(dirX^2 + dirY^2 + dirZ^2)
        return dirX / magnitude, dirY / magnitude, dirZ / magnitude
    end
    
    function f_H:getObj_Area(x, y, z, dx, dy, dz)
        local res = {}
        for i = 1, 4 do
            local r, t = Area:getAllObjsInAreaRange({x = x - dx, y = y - dy, z = z - dz}, {x = x + dx, y = y + dy, z = z + dz}, i)
            res[i] = t
        end
        return res
    end
    
    function f_H:filterObj(i, t)
        local k = {Player = 1, Creature = 2, DropItem = 3, Projectile = 4}
        return t[k[i]]
    end
    
    function f_H:notObj(playerID, t)
        local newTable = {}
        if t then
            for i = 1, #t do
                if t[i] ~= playerID then
                    table.insert(newTable, t[i])
                end
            end
        end
        return newTable
    end
    
    function f_H:PAttackObj(playerID, a, amount, dtype)
        Actor:playerHurt(playerID, a, amount, dtype)
    end
    
    function f_H:in2per(o, p)
        return math.max(1, math.floor(o * p / 100))
    end
    
    function f_H:playSoundOnActor(actorID, soundID, volume, pitch)
        if not pitch then pitch = 1 end
        return Actor:playSoundEffectById(actorID, soundID, volume, pitch, false)
    end
    
    function f_H:mergeTables(table1, table2)
        local mergedTable = {}
        local index = 1
        if table1 then
            for _, value in ipairs(table1) do
                mergedTable[index] = value
                index = index + 1
            end
        end
        if table2 then
            for _, value in ipairs(table2) do
                mergedTable[index] = value
                index = index + 1
            end
        end
        return mergedTable
    end
    
    function f_H:ActorDmg2Player(o1, o2, dmg, typeDmg)
        local r = Actor:actorHurt(o1, o2, dmg, typeDmg)
        if r == 0 then return true else return false end
    end
    
    function f_H:SHOOT_PROJECTILE(shooter, itemProjectileID, tPos, dPos, speed)
        local itemID = itemProjectileID
        local x, y, z = tPos.x, tPos.y, tPos.z
        local dstX, dstY, dstZ = dPos.x, dPos.y, dPos.z
        local code, objID = World:spawnProjectile(shooter, itemID, x, y, z, dstX, dstY, dstZ, speed)
        if code == 0 then return objID end
    end
    
    function f_H:ADD_EFFECT_TO_ACTOR(targetID, effect, scale)
        Actor:playBodyEffectById(targetID, effect, scale, 10)
    end

    function f_H:SET_ACTOR (id,v,bool)
        if type(v) == "number" then 
        Actor:setActionAttrState(id, v, bool)
        else 
            if type(v) == "string" then 
                if v == "MOVE" then 
                    Actor:setActionAttrState(id,1, bool)
                end 
                if v == "ATTACK" then 
                    Actor:setActionAttrState(id,32, bool)
                end 
                if v == "ATTACKED" then 
                    Actor:setActionAttrState(id,64, bool)
                end 
                if v == "KILLED" then 
                    Actor:setActionAttrState(id,128, bool)
                end 
            end 
        end 
    end