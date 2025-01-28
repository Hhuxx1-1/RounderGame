-- This map is Asylum Map 
--[[
   Inspired from the map "Asylum" by Wiraaaaaa 
   The Design Is Very Simple Box Goes Around and Has a few rooms in it.
   The Objective or Plot of the game is for Survivor is To Burn 10 Cursed Paper
   The Cursed Paper is Located in the rooms of the Asylum.
   Once The Objective Completed 
   Half The Time End of The Round
]]
local lootBox = 2017;
local f = {south = 1,west = 2,north=3,east=4}
local Prop = {
   {id=lootBox,x=52,y=5,z=98 ,f=f.east},
   {id=lootBox,x=51,y=5,z=94 ,f=f.west},
   {id=lootBox,x=29,y=5,z=115,f=f.north},
   {id=lootBox,x=72,y=5,z=79,f=f.north},
   {id=lootBox,x=114,y=5,z=111,f=f.north},
}

-- Objective is a function that return a string to Show the Objective state and handle the Objective Completion Logic 
REGISTER_MAP({
       Name            = "Asylum"
    ,   StateBlockId    =  501                      -- Determine State of Player special function for special alhoritm
    ,   PositionStart   = {x = 72, y = 5, z = 106}          --Must Contain x,y,z key and value is number where it represent Coordinate in Vector 3 
    ,   FacingStart     = 1                         -- 1, 2, 3, 4 is north , east , south , west    
    ,   RangeStart      = 1                         --Dimension Radius for Start
    ,   PositionMonster = {x = 83, y = 8 , z = 106 }
    ,   TimeDuration    = 180
    ,   SkyBoxTemplate  = 7
    ,   FilterTemplate  = 9
    ,   HourTime        = 4
    ,   Prop            = Prop
    ,   ImageUrl        = [[8_1029380338_1737809571]]
    ,   Objective       = 
      function()
      -- check if the objNow is nil 
      if not ROUND.GAME_DATA_NOW.objNow then 
         -- Create new and set it to 0 
         ROUND.GAME_DATA_NOW.objNow = 0;
         return "Find and Destroy 10 Cursed Paper";
      end 
      local function half()
         -- this is second function that will be executed after the f is done 
         local timeLeft = ROUND.TIME_END - GAME_SECOND;
         if timeLeft <= 0 then
            -- reduce ROUND.TIME_END 
            ROUND.TIME_END = ROUND.TIME_END - (math.ceil(timeLeft/2));
         end 
      end
      if not ROUND.GAME_DATA_NOW.objCompleted then 
         
         -- check if obj now is reached 10 then return true 
         if ROUND.GAME_DATA_NOW.objNow >= 10 then 
            half() 
            ROUND.GAME_DATA_NOW.objCompleted = true;
            return "Find and Destroy Cursed Paper ("..ROUND.GAME_DATA_NOW.objNow.."/10) - Completed";
         else
            return "Find and Destroy Cursed Paper ("..ROUND.GAME_DATA_NOW.objNow.."/10)";
         end   
      else
         return "Find and Destroy Cursed Paper ("..ROUND.GAME_DATA_NOW.objNow.."/10) - Done\n Now Survive Until Time End";
      end
   end
    })
