-- Shop Module
Shop = {}

local UI = "7455649763268696306";
local element = {
    paginationButton = 15,
    slot = {
        {
            base_btn  = 30,base_pic = 31,item_icon = 32,item_name = 33,
            btn_buy = 34,price_icon = 35,price_text=36,
            speed_ = 37, dmg_ = 39 , rarity_ = 41
        },
        {
            base_btn  = 43,base_pic = 44,item_icon = 45,item_name = 46,
            btn_buy = 47,price_icon = 48,price_text=49,
            speed_ = 50, dmg_ = 52, rarity_ = 54
        },
        {
            base_btn  = 56,base_pic = 57,item_icon = 58,item_name = 59,
            btn_buy = 60,price_icon = 61,price_text=62,
            speed_ = 63, dmg_ = 65 , rarity_ = 67
        },
        {
            base_btn  = 69,base_pic = 70,item_icon = 71,item_name = 72,
            btn_buy = 73,price_icon = 74,price_text=75,
            speed_ = 76, dmg_ = 78 , rarity_ = 80
        },
    },
    nextBtn = 13,
    prevBtn = 14,
    monsterCategoryBtn = 7,
    survivorCategoryBtn = 10
}

local slotBtnAction = {};
local btnAction = {};

local currentCategory = {};
local currentPage = {};

local function setActionBtn(playerid,btn,func)
    if btnAction[playerid] == nil then 
        btnAction[playerid] = {};
    end 
    if type(func) == "function" then 
        btnAction[playerid][UI.."_"..btn] = func ;
    end 
end
-- Pagination settings
local ITEMS_PER_PAGE = 4

local tlen = function(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Function to display the shop items for a category (Monster or Survivor)
function Shop:DisplayShop(playerid, category, page)
    local data_fetcher = (category == "Monster") and MONSTER_DATA or SURVIVOR_DATA
    local total_items = tlen(data_fetcher.DATA) -- Total items in the category
    local start_index = (page - 1) * ITEMS_PER_PAGE + 1
    -- local end_index = math.min(start_index + ITEMS_PER_PAGE - 1, total_items)
    local end_index = start_index + ITEMS_PER_PAGE - 1;

    -- Validate if the page is in range
    if start_index > math.max(total_items,ITEMS_PER_PAGE) then
        print("Invalid page number.")
        return
    end

    -- Fetch and display items for the current page
    local c = 0;
    for i = start_index, end_index do
        c = c + 1;
        local item = data_fetcher:FETCH(i)
        if item then
            -- print("Item:", item.name, "Price:", item.price)
            
            -- Send UI update to player with item data
            Shop:UpdateUI(playerid, item, category,c)
        else
            Shop:hideSlot(playerid,c);
        end
    end

    -- Update pagination buttons
    Shop:UpdatePagination(playerid, category, page, total_items);
end

function  Shop:hideSlot(playerid,c_index)
    local UI_Slot = element.slot[c_index];
    Customui:hideElement(playerid,UI,UI.."_"..UI_Slot.base_btn);
end

-- Function to update the UI for a single item
function Shop:UpdateUI(playerid, item, category,c_index)
    local data = {
        name = item.name,
        description = item.description,
        health = item.health or "N/A",
        damage = item.damage or "N/A",
        speed = item.speed or "N/A",
        stamina = item.stamina or "N/A",
        rarity = item.rarity or "N/A",
        price = item.price,
        icon = item.icon,
    }

    local UI_Slot = element.slot[c_index];
    --[[
        base_btn  = 69,base_pic = 70,item_icon = 71,item_name = 72,
        btn_buy = 73,price_icon = 74,price_text=75,
        speed_ = 76, dmg_ = 78 , rarity_ = 80
    ]]-- Reference 

    -- display the Slot 
    Customui:showElement(playerid,UI,UI.."_"..UI_Slot.base_btn);
    Customui:setText(playerid,UI,UI.."_"..UI_Slot.item_name,item.name);
    Customui:setText(playerid,UI,UI.."_"..UI_Slot.speed_,tostring(item.speed));
    Customui:setText(playerid,UI,UI.."_"..UI_Slot.dmg_,tostring(item.damage));
    Customui:setTexture(playerid,UI,UI.."_"..UI_Slot.item_icon,tostring(item.icon));

    local color = {
        canBuy      = {bg = 0xff9400 , txt = 0xffffff},
        cantBuy     = {bg = 0x4e5251 , txt = 0xbd3728},
        alreadyBuy  = {bg = 0xc3ff00 , txt = 0xffffff},
        equipped    = {bg = 0x0a9b3f , txt = 0xffffff},
    };
    -- use GLOBAL_CURRENCY for checking if player can buy or can't buy 

    -- check if item is owned or not 
    local saved_data_item = SAVE_DATA:GET(playerid,item.key) or {variableValue=[[0]]};
    -- print(saved_data_item,item.key);
    if saved_data_item.variableValue ~= [[1]] then 
        -- item isn't Owned 
        if GLOBAL_CURRENCY:TrySpend(playerid,item.type_currency,tonumber(item.price)) then 
            -- Player Can Buy 
            -- Color The Button According to The Color Table
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.btn_buy,color.canBuy.bg);
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.price_text,color.canBuy.txt);

            -- set the Action Button 
            setActionBtn(playerid,UI_Slot.btn_buy,function()
                print("try Purchase "..item.key);
                Shop:PurchaseItem(playerid,item.key,category);
            end)

        else
            -- Player Cannot Buy 
            -- Color The Button According to The Color Table
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.btn_buy,color.cantBuy.bg);
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.price_text,color.cantBuy.txt);

            -- set the Action Button 
            setActionBtn(playerid,UI_Slot.btn_buy,function()
                Player:notifyGameInfo2Self(playerid,"Not Enough "..item.type_currency.." to buy");
            end)
        end

        -- load Item Icon Currency 
        local item_icon = GLOBAL_CURRENCY:GetIconCurrency(item.type_currency);

        Customui:setTexture(playerid,UI,UI.."_"..UI_Slot.price_icon,item_icon);

        local price_text = GLOBAL_CURRENCY:PrettyDisplay(item.price);
        if price_text == "0" then 
            price_text = "Free";
        end 
        Customui:setText(playerid,UI,UI.."_"..UI_Slot.price_text,price_text);
    else
        -- Item is already Bought 
        -- check is it Equipped item or not 
        -- get Id of Equipped_Monster  from SAVE_DATA 
        local id_equipped = SAVE_DATA:GET(playerid,"Equipped_"..category).variableValue;
        -- id_equipped is prefixed with category _ id 
        id_equipped = string.lower(category).."_"..id_equipped;
        -- print("Equipped id : "..id_equipped);
        if id_equipped == item.key then --compare both string 
            -- Item is Equipped
            -- Color the Button According to The Color Table 
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.btn_buy,color.equipped.bg);
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.price_text,color.equipped.txt);

            -- Set the Text Button into "Equipped"
            Customui:setText(playerid,UI,UI.."_"..UI_Slot.price_text,"Equipped");

            -- Change the Currency Icon 
            Customui:setTexture(playerid,UI,UI.."_"..UI_Slot.price_icon,[[8_1029380338_1727255986]]);

            -- Equip the Monster 
            setActionBtn(playerid,UI_Slot.btn_buy,function()
                Player:notifyGameInfo2Self(playerid,category.." Already Equipped");
            end)
        else 
            -- Item is Not Equipped 
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.btn_buy,color.alreadyBuy.bg);
            Customui:setColor(playerid,UI,UI.."_"..UI_Slot.price_text,color.alreadyBuy.txt);

            -- Set the Text Button into "Equip"
            Customui:setText(playerid,UI,UI.."_"..UI_Slot.price_text,"Equip");

            -- Change the Currency Icon 
            Customui:setTexture(playerid,UI,UI.."_"..UI_Slot.price_icon,[[8_1029380338_1711289202]]);

            -- Equip the Monster 
            setActionBtn(playerid,UI_Slot.btn_buy,function()
                SAVE_DATA:MODIFY(playerid,"Equipped_"..category,tonumber(string.match(item.key, "%d+")));
            end)
        end 

        -- set the Action Button 
    end 

    -- set button Action 
    setActionBtn(playerid,UI_Slot.base_btn,function()
        
        -- close Shop UI 
        if Player:hideUIView(playerid,UI) == 0 then 
            local indexKey = tonumber(string.match(item.key,"%d+"));
            UpgradeUI:OpenUpgradeUI(playerid,tostring(category), indexKey);
            RUNNER:NEW(function()
                ROUND:setState(playerid,"7460487562891303154");
            end,{},2)
        end 
    end)

end

-- Function to update pagination buttons
function Shop:UpdatePagination(playerid, category, page, total_items)
    local total_pages = math.ceil(total_items / ITEMS_PER_PAGE)

    if category == "Monster" then 
        Customui:setColor(playerid,UI,UI.."_5",0x4e5251);

        setActionBtn(playerid,element.survivorCategoryBtn,function()
            currentCategory[playerid] = "Survivor";
        end)
        -- set Category Button 
        setActionBtn(playerid,element.monsterCategoryBtn,function()
            Player:notifyGameInfo2Self(playerid,"Already Open Category Category")
        end)
    else 
        Customui:setColor(playerid,UI,UI.."_5",0x8f9190);

        setActionBtn(playerid,element.survivorCategoryBtn,function()
            Player:notifyGameInfo2Self(playerid,"Already Open Survivor Category")
        end)
        -- set Category Button 
        setActionBtn(playerid,element.monsterCategoryBtn,function()
            currentCategory[playerid] = "Monster";
        end)
    end 

    local content = " ";
    for i = 1 , math.max(total_pages,1) do 
        if i == page then
            content = content.."● "
        else 
            content = content.."○ "
        end 
    end 

    -- print("Page : ",page,"Total Pages : ",total_pages);
    local btnpic= {
        left = {active = [[8_1029380338_1727321191]] , inactive = [[8_1029380338_1727320111]]},
        right= {active = [[8_1029380338_1727321182]] , inactive = [[8_1029380338_1727320091]]}
    }
    local color_inactive , color_active = 0x777777,0xffffff;

    if page <= 1 then 
        -- inactive Left Btn
        Customui:setTexture(playerid,UI,UI.."_"..element.prevBtn,btnpic.left.inactive);
        setActionBtn(playerid,element.prevBtn,function()
            -- check for player category 
            Player:notifyGameInfo2Self(playerid,"You Already at First Page");
        end)
        Customui:setColor(playerid,UI,UI.."_"..element.prevBtn,color_inactive);
    else 
        -- active left Btn
        Customui:setTexture(playerid,UI,UI.."_"..element.prevBtn,btnpic.left.active);
        -- set Action Button 
        setActionBtn(playerid,element.prevBtn,function()
            -- check for player category 
            currentPage[playerid] = math.max(currentPage[playerid] - 1 , 1 );
        end)
        Customui:setColor(playerid,UI,UI.."_"..element.prevBtn,color_active);
    end 

    if page >= total_pages then 
        -- inactive right Btn
        Customui:setTexture(playerid,UI,UI.."_"..element.nextBtn,btnpic.right.inactive);
        setActionBtn(playerid,element.nextBtn,function()
            -- check for player category 
            Player:notifyGameInfo2Self(playerid,"Max Content Page Reached");
        end)
        Customui:setColor(playerid,UI,UI.."_"..element.nextBtn,color_inactive);
    else 
        -- active right Btn
        Customui:setTexture(playerid,UI,UI.."_"..element.nextBtn,btnpic.right.active);
        setActionBtn(playerid,element.nextBtn,function()
            -- check for player category 
            currentPage[playerid] = math.min(currentPage[playerid] + 1 , total_pages);
        end)
        Customui:setColor(playerid,UI,UI.."_"..element.nextBtn,color_active);
    end 

    Customui:setText(playerid,UI,UI.."_"..element.paginationButton,content);
end

-- Function to handle purchasing an item
function Shop:PurchaseItem(playerid, item_key, category)
    local data_fetcher = (category == "Monster") and MONSTER_DATA or SURVIVOR_DATA
    local item = nil

    -- Find the item by its key
    for i = 1, tlen(data_fetcher.DATA) do
        local fetched_item = data_fetcher:FETCH(i)
        if fetched_item.key == item_key then
            item = fetched_item
            break
        end
    end

    if not item then
        print("Item not found!")
        return
    end

    -- check before try to purchase if saved_data_item already owned or not 
    local save_data_item = SAVE_DATA:GET(playerid,item.key)

    if not save_data_item then 

        if GLOBAL_CURRENCY:SpendCurrency(playerid,item.type_currency,item.price) then 

            -- Add into Save_Data
            SAVE_DATA:NEW(playerid,{item.key,category,1});

            -- Send confirmation message
            Player:notifyGameInfo2Self(playerid, "You have successfully purchased: " .. item.name);

            -- Reload the Save Data 
            SAVE_DATA:LOAD_ALL(playerid);

        end 
    else
        
        -- Send Error message
        Player:notifyGameInfo2Self(playerid, "You Already Purchased: " .. item.name);

    end 
end

-- -- Function to handle switching pages
-- function Shop:ChangePage(playerid, category, new_page)
--     Shop:DisplayShop(playerid, category, new_page)
-- end

ScriptSupportEvent:registerEvent("UI.Show",function(e)
    local playerid = e.eventobjid;
    
    -- check for player category 
    if currentCategory[playerid] == nil then
        currentCategory[playerid] = "Monster";
    end     

    -- check for player category 
    if currentPage[playerid] == nil then
        currentPage[playerid] = 1;
    end     

    -- open shop UI
    Shop:DisplayShop(playerid, currentCategory[playerid], currentPage[playerid]);
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
                else
                    Shop:DisplayShop(playerid, currentCategory[playerid], currentPage[playerid]);
                end 
            else 
                -- not a function 
                f_H:SendMessage(playerid,"Action Invalid");
            end 
        end
    else
        f_H:SendMessage(playerid,"Action Invalid: unset");
    end 
end)

ScriptSupportEvent:registerEvent("UI.Hide",function(e)
    ROUND:clearState(e.eventobjid)
end)