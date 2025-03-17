local UI = "7460487562891303154";

local element = {
    pagination = {
        nextBtn = 3,
        prevBtn = 2,
        selectid = {
            5 ,  7 , 9 , 11, 13
        },
        nextPage = 19,
        prevPage = 21,
    },
    EquipBtn = 25, EquipTxt = 26, EquipIcon = 34,
    LevelUpBtn = 35 , LevelUpTxt = 36 , LevelUpIcon = 37 , LevelUpPrice = 38 ,LevelUpPriceIcon = 39,
    CurrentLevelTxt = 73,
    detailPage = {
        icon = 27 , 
        title = 29 ,
        title_bg = 28 , 
        rarityStar = 32,
        shortDesc = 31 ,
        skillTitle = 47,
        skill_1 = {
            bg = 49 , title = 55 , 
            desc = 54 , questionMark = 56,
            btn = 50 , icon = 51 , lock = 53
        },
        skill_2 = {
            bg = 49+8 , title = 55+8 , 
            desc = 54+8 , questionMark = 56+8,
            btn = 50+8 , icon = 51+8 , lock = 53+8
        },
        skill_3 = {
            bg = 49+8+8 , title = 55+8+8 , 
            desc = 54+8+8 , questionMark = 56+8+8,
            btn = 50+8+8 , icon = 51+8+8 , lock = 53+8+8
        }
    }
}

-- Helper Function to get Length of Table 
local tlen = function(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Helper Function to Adjust Button Action Easier 
local btnAction = {};
local function setActionBtn(playerid,btn,func)
    if btnAction[playerid] == nil then 
        btnAction[playerid] = {};
    end 
    if type(func) == "function" then 
        btnAction[playerid][UI.."_"..btn] = func ;
    end 
end

-- Global UPGRADE UI to Handle UI upgrade 
UpgradeUI = {}

-- Data Fetch Method
function UpgradeUI:FETCH(category, id)
    local function data() 
        return (category == "Monster") and MONSTER_DATA or SURVIVOR_DATA
    end 
    return data():FETCH(id);
end

-- Equip Function
function UpgradeUI:Equip(playerid, category, id)
    local data = self:FETCH(category, id)
    if not data then return end

    print("Equipping", data.name, "for Player ID:", playerid)
    -- Add logic to equip the selected Monster or Survivor
end

-- Level Up Function
function UpgradeUI:LevelUp(playerid, category, id)
    local data = self:FETCH(category, id)
    if not data then return end

    -- get Player level to determine Cost 
    local level = (SAVE_DATA:GET(playerid,data.key.."_LEVEL") ~= nil) and tonumber(SAVE_DATA:GET(playerid,data.key.."_LEVEL").v) or 1;

    local nextLevelCost = (data.rarity^2) * level * 200;

    local levelMax = 20;

    if level >= levelMax then
        Player:notifyGameInfo2Self(playerid,"Already at max level!");
        return
    end

    -- Check if the player has enough currency
    if GLOBAL_CURRENCY:SpendCurrency(playerid,GLOBAL_CURRENCY.MONEY.Coin,nextLevelCost) then 
        -- upgrade the Level 
        -- get Before Attempt to Modify 
        if not SAVE_DATA:GET(playerid,data.key.."_LEVEL") then 
            -- Data Not Exist create new 
            SAVE_DATA:NEW(playerid,{data.key.."_LEVEL","Level_"..category,level+1});
        else
            -- Data Already Exist 
            SAVE_DATA:MODIFY(playerid,data.key.."_LEVEL",level+1);
        end 

        SAVE_DATA:LOAD_ALL(playerid);

        Player:notifyGameInfo2Self(playerid,"Successfully Level Up "..data.name);
    else 
        -- show not enough Coin 
        Player:notifyGameInfo2Self(playerid,"Not Enough Coins to Level Up");
    end 

end

-- Pagination Function
function UpgradeUI:updateCarousel(playerid, currentIndex, category)
    local list = {}
    local numberOfList = 5 -- Maximum one page is 5
    -- Fetch the entire category data
    local data_fetcher = (category == "Monster") and MONSTER_DATA or SURVIVOR_DATA
    local total_items = tlen(data_fetcher.DATA) -- Total items in the category

    if currentIndex <= 2 then
        -- Near start edge
        for i = 1, math.min(numberOfList, total_items) do
            local item = data_fetcher:FETCH(i)
            if item then
                table.insert(list, item)
            end
        end

        -- hide button pageLeft 
        Customui:hideElement(playerid,UI,UI.."_"..element.pagination.prevPage);
        -- show button NextPage 
        Customui:showElement(playerid,UI,UI.."_"..element.pagination.nextPage);
    
    elseif currentIndex >= total_items - 2 then
        -- Near end edge
        for i = total_items - numberOfList + 1, total_items do
            if i > 0 then
                local item = data_fetcher:FETCH(i)
                if item then
                    table.insert(list, item)
                end
            end
        end

        -- show button pageLeft 
        Customui:hideElement(playerid,UI,UI.."_"..element.pagination.prevPage);
        -- show button NextPage 
        Customui:showElement(playerid,UI,UI.."_"..element.pagination.nextPage);

    -- Middle content
    else
        for i = currentIndex - 2, currentIndex + 2 do
            local item = data_fetcher:FETCH(i)
            if item then
                table.insert(list, item)
            end
        end
        -- show button pageLeft 
        Customui:hideElement(playerid,UI,UI.."_"..element.pagination.prevPage);
        -- hide button NextPage 
        Customui:showElement(playerid,UI,UI.."_"..element.pagination.nextPage);
    end

    -- check if list is less than 5 
    if #list < 5 then
        -- hide both button pagination 
        Customui:hideElement(playerid,UI,UI.."_"..element.pagination.prevPage);
        Customui:hideElement(playerid,UI,UI.."_"..element.pagination.nextPage);
        -- set Both button action to empty function 
        setActionBtn(playerid,element.pagination.nextPage,function() Player:notifyGameInfo2Self(playerid,"Reached Max Page")       end);
        setActionBtn(playerid,element.pagination.prevPage,function() Player:notifyGameInfo2Self(playerid,"Already Reach Limit")    end);
    end 

    for i = 1 , numberOfList do 
        if list[i] then -- list exist 

            -- show the Button 
            Customui:showElement(playerid,UI,UI.."_"..element.pagination.selectid[i]);

            -- set the Icon 
            Customui:setTexture(playerid,UI,UI.."_"..(element.pagination.selectid[i]+1),list[i].icon);

            local keyIndex = tonumber(string.match(list[i].key,"%d"));
            if keyIndex  == currentIndex then 
                Customui:setColor(playerid,UI,UI.."_"..element.pagination.selectid[i],0xf6ff00);

                setActionBtn(playerid,element.pagination.selectid[i],function()
                    Player:notifyGameInfo2Self(playerid,"This is Current "..category.." Selected");
                end)

                -- set the Next or Prev Btn 

                if data_fetcher:FETCH(keyIndex-1) then 
                    -- previous item is Exist;
                    Customui:showElement(playerid,UI,UI.."_"..element.pagination.prevBtn);
                    -- set prev btn action 
                    setActionBtn(playerid,element.pagination.prevBtn,function()
                        UpgradeUI:OpenUpgradeUI(playerid, category, keyIndex-1);
                    end)
                else
                    -- previous item is Not Exist 
                    Customui:hideElement(playerid,UI,UI.."_"..element.pagination.prevBtn);
                    -- set prev btn action as not exist 
                    setActionBtn(playerid,element.pagination.prevBtn,function()
                        Player:notifyGameInfo2Self(playerid,"Nothing at Previous")
                    end)
                end 

                if data_fetcher:FETCH(keyIndex+1) then 
                    -- next item is Exist
                    Customui:showElement(playerid,UI,UI.."_"..element.pagination.nextBtn);
                    -- set next btn action 
                    setActionBtn(playerid,element.pagination.nextBtn,function()
                        UpgradeUI:OpenUpgradeUI(playerid, category, keyIndex+1);
                    end)
                else 
                    -- next item is Not Exist
                    Customui:hideElement(playerid,UI,UI.."_"..element.pagination.nextBtn);
                    -- set next btn action as not exist 
                    setActionBtn(playerid,element.pagination.nextBtn,function()
                        Player:notifyGameInfo2Self(playerid,"Nothing Next")
                    end)
                end 
                
            else
                Customui:setColor(playerid,UI,UI.."_"..element.pagination.selectid[i],0xffffff);

                setActionBtn(playerid,element.pagination.selectid[i],function()
                    UpgradeUI:OpenUpgradeUI(playerid, category, keyIndex);
                end)
            end 
        else
            Customui:hideElement(playerid,UI,UI.."_"..element.pagination.selectid[i]);
        end 
    end 
end

local isUI_Opened={}

-- Open Upgrade UI Function
function UpgradeUI:OpenUpgradeUI(playerid, category, id)
    local data = self:FETCH(category, id)
    if not data then return end

    if Player:openUIView(playerid,UI) == 0 then 
        if not isUI_Opened[playerid] then 
            ROUND:setState(playerid,UI);
            -- print("Opening Upgrade UI for", data.name);
            -- print(data);
            -- adjust Camera 
            Player:ResetCameraAttr(playerid);
            Player:changeViewMode(playerid, 2 , true);
            Player:SetCameraPosTransformBy(playerid, {x=250,y=-20}, 1, 0.5);
            local result,yaw=Actor:getFaceYaw(playerid)
            Player:rotateCamera(playerid,yaw,-15)
            isUI_Opened[playerid] = true;
        end 
    end 
    -- Set up UI elements (skills/items, equip button, level-up button, etc.)
    -- Add UI logic here (e.g., display skills/items and enable/disable buttons based on state)

    -- set the Icon Content 
    Customui:setTexture(playerid,UI,UI.."_"..element.detailPage.icon,data.icon);

    -- set The Text Content from data into UI 
     
    -- set The Title
    Customui:setText(playerid,UI,UI.."_"..element.detailPage.title,data.name);
    -- set The Short Desc
    Customui:setText(playerid,UI,UI.."_"..element.detailPage.shortDesc,data.description);
    -- set The Category Text Skill 
    Customui:setText(playerid,UI,UI.."_"..element.detailPage.skillTitle,(category == "Monster") and "Monster Skill" or "Survivor Ability");
    -- set The Skill Title and Content 

    -- get Player level to determine skill lock or unlock 
    local level = (SAVE_DATA:GET(playerid,data.key.."_LEVEL") ~= nil) and SAVE_DATA:GET(playerid,data.key.."_LEVEL").v or 1;
    
    local nextLevelCost = (data.rarity^2) * level * 200;

    local equip_pallete = {
        equip = 0xffffff, equipped = 0xffe57f , locked = 0x7c7c7c
    }

    -- check if Player already own this monster or survivor  or not
    local save_data_item = SAVE_DATA:GET(playerid,data.key);
    if save_data_item then 
        -- player already purchase it 
        -- check if monster or survivor  is Equipped or not 
        local id_equipped = SAVE_DATA:GET(playerid,"Equipped_"..category).v;
        -- id_equipped is prefixed with category _ id 
        id_equipped = string.lower(category).."_"..id_equipped;
        if id_equipped == data.key then
            -- it is equipped 
            Customui:setText(playerid,UI,UI.."_"..element.EquipTxt,"Equipped");
            Customui:setColor(playerid,UI,UI.."_"..element.EquipBtn,equip_pallete.equipped);
            -- set Action Button to Say Already Equipped 
            setActionBtn(playerid,element.EquipBtn,function()
                Player:notifyGameInfo2Self(playerid,"Already Equipped");
                self:OpenUpgradeUI(playerid,category,id);
            end)
        else 
            -- it is not equipped 
            Customui:setText(playerid,UI,UI.."_"..element.EquipTxt,"Equip");
            Customui:setColor(playerid,UI,UI.."_"..element.EquipBtn,equip_pallete.equip);
            -- set Action Button to Equip 
            setActionBtn(playerid,element.EquipBtn,function()
                SAVE_DATA:MODIFY(playerid,"Equipped_"..category,tonumber(string.match(data.key, "%d+")));
                Player:notifyGameInfo2Self(playerid,"Successfully Equip "..data.name);
                self:OpenUpgradeUI(playerid,category,id);
            end)
            
        end 

        -- Levelup as buy 
        Customui:setText(playerid,UI,UI.."_"..element.LevelUpTxt,"Level Up");
        -- set Price for Upgrade text 
        Customui:setText(playerid,UI,UI.."_"..element.LevelUpPrice,GLOBAL_CURRENCY:PrettyDisplay(nextLevelCost));
        -- Price Icon 
        Customui:setTexture(playerid,UI,UI.."_"..element.LevelUpPriceIcon,GLOBAL_CURRENCY:GetIconCurrency(GLOBAL_CURRENCY.MONEY.Coin));
        -- Set Text Level 
        Customui:setText(playerid,UI,UI.."_"..element.CurrentLevelTxt,"Your Current Level is "..level);
        -- Buy Button 
        setActionBtn(playerid,element.LevelUpBtn,function()
            UpgradeUI:LevelUp(playerid,category,id);
            self:OpenUpgradeUI(playerid,category,id);
        end)
    else 
        -- player isn't have the monster or survivor  yet 
        Customui:setText(playerid,UI,UI.."_"..element.EquipTxt,"Locked");
        Customui:setColor(playerid,UI,UI.."_"..element.EquipBtn,equip_pallete.locked);
        -- set Action button that Says Unlock at Shop 
        setActionBtn(playerid,element.EquipBtn,function()
            Player:notifyGameInfo2Self(playerid,"Unlock at Shop");
        end)

        -- Levelup as buy 
        Customui:setText(playerid,UI,UI.."_"..element.LevelUpTxt,"Buy");
        -- Price for Buy text 
        Customui:setText(playerid,UI,UI.."_"..element.LevelUpPrice,data.price);
        -- Price Icon 
        Customui:setTexture(playerid,UI,UI.."_"..element.LevelUpPriceIcon,GLOBAL_CURRENCY:GetIconCurrency(data.type_currency));
        -- Set Price Text
        Customui:setText(playerid,UI,UI.."_"..element.CurrentLevelTxt,category.." Is Locked");
        -- Buy Button 
        setActionBtn(playerid,element.LevelUpBtn,function()
            Shop:PurchaseItem(playerid,data.key,category);
            self:OpenUpgradeUI(playerid,category,id);
        end)
    end 

    -- Update the Skill Slot 
    for i,skill in ipairs(data.skill) do 
        local sSkill = element.detailPage["skill_"..i];
        -- load the Text into UI 
        Customui:setText(playerid,UI,UI.."_"..sSkill.title,skill.name);
        Customui:setText(playerid,UI,UI.."_"..sSkill.desc,skill.description..((skill.cooldown~=nil) and "\n CD : "..skill.cooldown.."s" or ""));
        -- Set The Skill Icon 
        Customui:setTexture(playerid,UI,UI.."_"..sSkill.icon,skill.icon);

        if i <= math.ceil(level/5) then  
            -- skill is Unlocked Hide the Lock Icon
            Customui:hideElement(playerid,UI,UI.."_"..sSkill.lock);
        else 
            -- skill is Locked Show the Lock Icon
            Customui:showElement(playerid,UI,UI.."_"..sSkill.lock);
        end 
    end 

    -- update Carousel 
    self:updateCarousel(playerid,id, category);

    -- update the Player model 
    Actor:changeCustomModel(playerid,data.model.normal);
    f_H:PlayAnim(playerid,"Happy")
end

ScriptSupportEvent:registerEvent("UI.Hide",function(e)
    local playerid = e.eventobjid;
    ROUND:clearState(playerid);
    Player:changeViewMode(playerid, 1 , false);
    Player:ResetCameraAttr(playerid);
    local result,yaw=Actor:getFaceYaw(playerid)
    Player:rotateCamera(playerid,yaw,15)
    isUI_Opened[playerid] = nil;
    Actor:recoverinitialModel(playerid);
end)

ScriptSupportEvent:registerEvent("UI.Button.Click",function(e)
    local playerid = e.eventobjid;
    local element =  e.uielement;

    if btnAction[playerid] then 
        -- btn Action for playerid is already defined 
        if btnAction[playerid][element] ~= nil then
            -- btn action is not nil 
            -- check if it is function 
            if type(btnAction[playerid][element]) == "function" then 
                -- It is executeable Function 
                local r , err = pcall(btnAction[playerid][element],playerid);
                if not r then 
                    print(err);
                end 
            else 
                -- not a function 
                f_H:SendMessage(playerid,"Action Invalid");
            end 
        end
    else
        f_H:SendMessage(playerid,"Action Invalid: unset ("..playerid..")");
    end 
end)