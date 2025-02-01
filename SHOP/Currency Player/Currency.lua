GLOBAL_CURRENCY = {} -- Initiate The Currency Global Table to Store Function and Much More! 
-- If you peeking my script Make sure to Subscribe on my Youtube Channel https://youtube.com/hhuxx1
--  Even i don't have really time to create good quality content
--   Becuz i spent must of my time Learning to Code Lua and Making Features for Miniworld
--    And I accept Donation but Rupiah Currency only on https://saweria.com/hhuxx1 
--     i Share my Script on https://hhuxx1-1/github.io/miniworld/
--      But the time i write this Message the Webiste is Not Done Yet 
-- ============================== Thank you for your Respect ==========]]] 
GLOBAL_CURRENCY.DATA = {}
GLOBAL_CURRENCY.TOPUP_DATA = {};

function GLOBAL_CURRENCY:REGISTER_TOPUP(itemid,name,description,amount)
    if GLOBAL_CURRENCY.TOPUP_DATA then 
        table.insert(GLOBAL_CURRENCY.TOPUP_DATA,{itemid=itemid,name=name,description=description,amount=amount})
    end 
end
--[[ Adding Method to Create New Currency and Store it  
name is string , id must be number and must index , description is string , type is string ]]
function GLOBAL_CURRENCY:CreateCurrency(name, id , description , type,icon)
    -- initiate new Table with exact Name of  Currency and store its id, description and type
    self.DATA[name] = {name=name,id=id,description=description,type=type,icon=icon}
end 

-- Adding Method to Get Player Currency Data by Name and return it Ammount 
function GLOBAL_CURRENCY:GetCurrency(playerid,name)
    -- String Group 
    local r,datas = Valuegroup:getAllGroupItem(18, "CURRENCY_DATA",playerid)
    if r == 1001 then 
        Player:notifyGameInfo2Self(playerid,"CURRENCY DATA NOT FOUND!")
    end 
    return datas[GLOBAL_CURRENCY.DATA[name].id] or 0 ;
end 

function GLOBAL_CURRENCY:PrettyDisplay(amount)
    amount = tonumber(amount)
    local formatted = ""
    if amount >= 1e12 then
        formatted = string.format("%.1fT", amount / 1e12) -- Display in Trillions
    elseif amount >= 1e9 then
        formatted = string.format("%.1fB", amount / 1e9) -- Display in Billions
    elseif amount >= 1e6 then
        formatted = string.format("%.1fM", amount / 1e6) -- Display in Millions
    elseif amount >= 1e3 then
        formatted = string.format("%.1fk", amount / 1e3) -- Display in Thousands
    else
        formatted = tostring(amount) -- If less than 1000, display the full amount
    end
    return formatted
end

-- Add Methods for Updating UI 
GLOBAL_CURRENCY.UI_DATA={}

-- This is Telling what UI element should be updated when calling UpdateUI for player
function GLOBAL_CURRENCY:AddUI2Update(name,uiid,elementid)
    if GLOBAL_CURRENCY.UI_DATA[name] == nil then 
        -- initiate an Empty table if it is nil
        GLOBAL_CURRENCY.UI_DATA[name] = {}
    end 
    table.insert(GLOBAL_CURRENCY.UI_DATA[name],{uiid=uiid,elementid=elementid});
end

-- Can Be Called  from any UI element to update the UI
function GLOBAL_CURRENCY:UpdateUI(playerid,name)
    if GLOBAL_CURRENCY.UI_DATA[name] == nil then 
        print("FAILED TO UPDATE UI : NO ELEMENTID WERE ADDED")
        return false 
    end 
    local ammountPretty = GLOBAL_CURRENCY:PrettyDisplay(GLOBAL_CURRENCY:GetCurrency(playerid,name))
    for i,a in ipairs(GLOBAL_CURRENCY.UI_DATA[name]) do
        Customui:setText(playerid,a.uiid,a.elementid,ammountPretty)
    end 
end

-- Adding Method to Add Currency to Player Data 
function GLOBAL_CURRENCY:AddCurrency(playerid, name, v_ammount)
    -- Get Player Data 
    local ammount = GLOBAL_CURRENCY:GetCurrency(playerid,name)
    -- handle if ammount is empty 
    if ammount == nil then
        -- Player currency is not set Yet ! STUPID
        ammount = 0 
    end 
    if type(ammount) == "String" then 
        ammount = tonumber(ammount);
    end 
    ammount = ammount + v_ammount;

    local id = GLOBAL_CURRENCY.DATA[name].id;
    -- Add Amount to Player Data
    local r = Valuegroup:setValueNoByName(18, "CURRENCY_DATA", id, tostring(ammount), playerid)
    if r == 0 then 
        -- Automatically Update all UI for player 
        GLOBAL_CURRENCY:UpdateUI(playerid,name)
        return  true;
    else 
        print("ERROR WHEN TRYING TO ADD CURRENCY TO PLAYER DATA")
        return false;
    end 
end

-- Adding Method to Decrease Currency to Player Data 
-- This Allowing a Negatif Currency data
function GLOBAL_CURRENCY:DecreaseCurrency(playerid, name, v_ammount)
    -- Get Player Data 
    local ammount = GLOBAL_CURRENCY:GetCurrency(playerid,name)
    -- handle if ammount is empty 
    if ammount == nil then
        -- Player currency is not set Yet ! STUPID
        ammount = 0 
    end 
    if type(ammount) == "String" then 
        ammount = tonumber(ammount);
    end 
    ammount = ammount - v_ammount;

    local id = GLOBAL_CURRENCY.DATA[name].id;
    -- Add Amount to Player Data
    local r = Valuegroup:setValueNoByName(18, "CURRENCY_DATA", id, tostring(ammount), playerid)
    if r == 0 then 
        -- Automatically Update All UI for player
        GLOBAL_CURRENCY:UpdateUI(playerid,name)
        return true 
    else 
        print("ERROR WHEN TRYING TO DECREASE VALUE ON PLAYER SAVE CURRENCY_DATA")
        return false
    end 
end 

-- Adding Method to Spend Currency on Player Data Currency
-- This Not Allowing Negatif Currency and return false or true 
function GLOBAL_CURRENCY:SpendCurrency(playerid, name, v_ammount)
    -- Get Player Data 
    local ammount = GLOBAL_CURRENCY:GetCurrency(playerid,name)
    -- handle if ammount is empty 
    if ammount == nil then
        -- Player currency is not set Yet ! STUPID
        ammount = 0 
    end 
    if type(ammount) == "String" then 
        ammount = tonumber(ammount);
    end 
    ammount = ammount - v_ammount;
    if ammount >= 0 then 
    local id = GLOBAL_CURRENCY.DATA[name].id;
    -- Add Amount to Player Data
    local r = Valuegroup:setValueNoByName(18, "CURRENCY_DATA", id, tostring(ammount), playerid)
        if r == 0 then 
            -- Automatically Update All UI for player
            GLOBAL_CURRENCY:UpdateUI(playerid,name)
            return true 
        else 
            print("ERROR WHEN TRYING TO UPDATE VALUE ON PLAYER SAVE CURRENCY_DATA")
            return false
        end 
    else 
        Player:notifyGameInfo2Self(playerid,"Not Enough "..name.." Need "..ammount.." of "..name);
        return false;
    end 
end 

function GLOBAL_CURRENCY:TrySpend(playerid,name,v_ammount)
    -- this function simulate if player Can Spend without actually spend the currency 
    -- return true if player can spend and false if player cant spend
    -- Get Player Data
    local ammount = GLOBAL_CURRENCY:GetCurrency(playerid,name)
    -- handle if ammount is empty 
    if ammount == nil then
        -- Player currency is not set Yet ! STUPID
        ammount = 0 
    end 
    if type(ammount) == "String" then 
        ammount = tonumber(ammount);
    end 
    ammount = ammount - v_ammount;
    if ammount >= 0 then
        return true
    else
        return false
    end
end

-- Create Function to Retrive Icon Currency 
function GLOBAL_CURRENCY:GetIconCurrency(name)
    -- Get Icon Currency Data
    local icon = GLOBAL_CURRENCY.DATA[name].icon
    return icon
end 


-- ============= [[ CREATE CURRENCY HERE ]] ====================

GLOBAL_CURRENCY:CreateCurrency(
    "Coin",1,
    [[Currency That Can be Used to Upgrade Character or Buy Temporary Item, Obtained by Simply Playing The Game or Top Up and Watching Ads]],
    "C",
    [[8_1029380338_1727255966]]
);

GLOBAL_CURRENCY:CreateCurrency(
    "FirePoint",2,
    [[Currency That Can Only Be Obtained by Winning The Game, Can be Used to Buy Permanent Item or Upgrade Character. Can Also Obtained by Top Up or Watching Ads]],
    "C",
    [[8_1029380338_1719148067]]
);

GLOBAL_CURRENCY:CreateCurrency(
    "Crystal",3,
    [[Currency That is Used to Buy Premium Character Permanent. Can Be Only Obtained by Top Up or Watching Ads Only]],
    "C",
    [[8_1029380338_1719148085]]
);

GLOBAL_CURRENCY:CreateCurrency(
    "Rank",4,
    [[This Is Player Score Rank]],
    "C",
    [[8_1029380338_1727255986]]
);

GLOBAL_CURRENCY.MONEY = {
    Coin = "Coin",
    FirePoint = "FirePoint",
    Crystal = "Crystal",
    Rank = "Rank",
}

GLOBAL_CURRENCY:AddUI2Update("Coin","7455624551810668786","7455624551810668786_3");
GLOBAL_CURRENCY:AddUI2Update("FirePoint","7455624551810668786","7455624551810668786_28");
GLOBAL_CURRENCY:AddUI2Update("Crystal","7455624551810668786","7455624551810668786_33");
GLOBAL_CURRENCY:AddUI2Update("Rank","7455624551810668786","7455624551810668786_38");

-- ==========[[ Ini Adalah Item Shop ]]==========
GLOBAL_CURRENCY:REGISTER_TOPUP(4127,"Coin",[[Buy 100 Coin for 1 Mini Beans]],100);
GLOBAL_CURRENCY:REGISTER_TOPUP(4128,"Coin",[[Buy 2400 Coin for 14 Mini Beans]],2400);
GLOBAL_CURRENCY:REGISTER_TOPUP(4129,"Coin",[[Buy 7760 Coin for 58 Mini Beans]],7760);
GLOBAL_CURRENCY:REGISTER_TOPUP(4130,"Coin",[[Buy 14500 Coin for 105 Mini Beans]],14500);
GLOBAL_CURRENCY:REGISTER_TOPUP(4131,"Coin",[[Buy 27600 Coin for 216 Mini Beans]],27600);
GLOBAL_CURRENCY:REGISTER_TOPUP(4132,"Coin",[[Buy 45500 Coin for 315 Mini Beans]],45500);
GLOBAL_CURRENCY:REGISTER_TOPUP(4133,"Coin",[[Buy 75600 Coin for 586 Mini Beans]],75600);
GLOBAL_CURRENCY:REGISTER_TOPUP(4134,"Coin",[[Buy 91100 Coin for 661 Mini Beans]],91100);
GLOBAL_CURRENCY:REGISTER_TOPUP(4135,"Coin",[[Buy 124600 Coin for 746 Mini Beans]],124600);
GLOBAL_CURRENCY:REGISTER_TOPUP(4136,"Coin",[[Buy 199800 Coin for 998 Mini Beans]],199800);
GLOBAL_CURRENCY:REGISTER_TOPUP(4137,"FirePoint",[[Buy 2000 FirePoint for 15 Mini Point]],2000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4138,"FirePoint",[[Buy 6000 FirePoint for 35 Mini Point]],6000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4139,"FirePoint",[[Buy 9000 FirePoint for 50 Mini Point]],9000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4140,"FirePoint",[[Buy 13000 FirePoint for 68 Mini Point]],13000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4141,"FirePoint",[[Buy 18000 FirePoint for 77 Mini Point]],18000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4142,"FirePoint",[[Buy 23000 FirePoint for 87 Mini Point]],23000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4143,"FirePoint",[[Buy 42000 FirePoint for 142 Mini Point]],42000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4144,"FirePoint",[[Buy 82000 FirePoint for 367 Mini Point]],82000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4145,"FirePoint",[[Buy 120000 FirePoint for 476 Mini Point]],120000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4146,"FirePoint",[[Buy 300000 FirePoint for 1240 Mini Point]],300000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4147,"Crystal",[[Buy 1 Crystal for 1 Mini Coins]],1);
GLOBAL_CURRENCY:REGISTER_TOPUP(4148,"Crystal",[[Buy 20 Crystal for 1 Mini Coins]],20);
GLOBAL_CURRENCY:REGISTER_TOPUP(4149,"Crystal",[[Buy 400 Crystal for 25 Mini Coins]],400);
GLOBAL_CURRENCY:REGISTER_TOPUP(4150,"Crystal",[[Buy 600 Crystal for 35 Mini Coins]],600);
GLOBAL_CURRENCY:REGISTER_TOPUP(4151,"Crystal",[[Buy 1000 Crystal for 55 Mini Coins]],1000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4152,"Crystal",[[Buy 1400 Crystal for 95 Mini Coins]],1400);
GLOBAL_CURRENCY:REGISTER_TOPUP(4153,"Crystal",[[Buy 2100 Crystal for 123 Mini Coins]],2100);
GLOBAL_CURRENCY:REGISTER_TOPUP(4154,"Crystal",[[Buy 3600 Crystal for 220 Mini Coins]],3600);
GLOBAL_CURRENCY:REGISTER_TOPUP(4155,"Crystal",[[Buy 5600 Crystal for 224 Mini Coins]],5600);
GLOBAL_CURRENCY:REGISTER_TOPUP(4156,"Crystal",[[Buy 7650 Crystal for 299 Mini Coins]],7650);
GLOBAL_CURRENCY:REGISTER_TOPUP(4157,"FirePoint",[[Buy 1000 FirePoint for 1 Mini Coins]],1000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4158,"FirePoint",[[Buy 24000 FirePoint for 6 Mini Coins]],24000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4159,"FirePoint",[[Buy 56000 FirePoint for 18 Mini Coins]],56000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4160,"FirePoint",[[Buy 89000 FirePoint for 20 Mini Coins]],89000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4161,"FirePoint",[[Buy 158000 FirePoint for 26 Mini Coins]],158000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4162,"FirePoint",[[Buy 298000 FirePoint for 39 Mini Coins]],298000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4163,"FirePoint",[[Buy 545000 FirePoint for 44 Mini Coins]],545000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4164,"FirePoint",[[Buy 1078000 FirePoint for 79 Mini Coins]],1078000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4165,"FirePoint",[[Buy 2040000 FirePoint for 80 Mini Coins]],2040000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4166,"FirePoint",[[Buy 4210000 FirePoint for 247 Mini Coins]],4210000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4167,"Coin",[[Buy 500000 Coin for 5 Mini Coins]],500000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4168,"Coin",[[Buy 1540000 Coin for 19 Mini Coins]],1540000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4169,"Coin",[[Buy 4250000 Coin for 25 Mini Coins]],4250000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4170,"Coin",[[Buy 12260000 Coin for 36 Mini Coins]],12260000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4171,"Coin",[[Buy 36000000 Coin for 45 Mini Coins]],36000000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4172,"Coin",[[Buy 107000000 Coin for 55 Mini Coins]],107000000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4173,"Coin",[[Buy 319750000 Coin for 65 Mini Coins]],319750000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4174,"Coin",[[Buy 957790000 Coin for 79 Mini Coins]],957790000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4175,"Coin",[[Buy 2872000000 Coin for 125 Mini Coins]],2872000000);
GLOBAL_CURRENCY:REGISTER_TOPUP(4176,"Coin",[[Buy 8614622400 Coin for 265 Mini Coins]],8614622400);

-- ============= [[ END CREATE CURRENCY ]] ====================
-- Example of Updating UI 
-- GLOBAL_CURRENCY:UpdateUI(playerid,Glob)
-- GLOBAL_CURRENCY:UpdateUI(playerid,"Coin")
-- GLOBAL_CURRENCY:UpdateUI(playerid,"Coin")

-- Example of Usage 
-- print(GLOBAL_CURRENCY:GetCurrency(1029380338,"Coin"))
-- -- adding Player Coin Currency
-- GLOBAL_CURRENCY:AddCurrency(1029380338,"Coin",10);
-- -- Check Player Coin Currency After Adding 
-- print("After Adding " , GLOBAL_CURRENCY:GetCurrency(1029380338,"Coin"))
-- -- Trying to do a transaction 
-- local function SomeTransactionExample()
--     local pid = 1029380338;
--     local price  = 5;
--     if GLOBAL_CURRENCY:SpendCurrency(pid,"Coin",price) then 
--         print("Successfully Bought The Item");
--     else 
--         print("Failed Bought The Item");
--     end 
-- end
-- -- do Transaction Test
-- SomeTransactionExample()
-- print("After Transaction " , GLOBAL_CURRENCY:GetCurrency(1029380338,"Coin"))
-- SomeTransactionExample()
-- print("After Transaction 2x " , GLOBAL_CURRENCY:GetCurrency(1029380338,"Coin"))
-- SomeTransactionExample()
-- print("After Transaction 3x " , GLOBAL_CURRENCY:GetCurrency(1029380338,"Coin"))