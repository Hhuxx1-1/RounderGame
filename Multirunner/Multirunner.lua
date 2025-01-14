-- Multirunner Framework
--[[
=============================================
### Multirun Framework for Simultaneous Tasks ###
- Simplifies handling delayed events and player-object ownership.
- Provides tools for:
  - Scheduling tasks with delays.
  - Managing object ownership.
  - Attaching functions to objects for event handling.
=============================================
]]

-- Main RUNNER table
RUNNER = {
    OBJECT = {},
    DELAYED_EVENTS = {},
    OBJ_FUNCTIONS = {}
}

-- Create a new delayed event
function RUNNER:NEW(func, args, delay)
    local eventID = #self.DELAYED_EVENTS + 1
    table.insert(self.DELAYED_EVENTS, { id = eventID, func = func, args = args, delay = delay })
    return eventID
end

-- Revoke a delayed event
function RUNNER:REVOKE(eventID)
    for i, event in ipairs(self.DELAYED_EVENTS) do
        if event.id == eventID then
            table.remove(self.DELAYED_EVENTS, i)
            return
        end
    end
end

-- Register and unregister object ownership
function RUNNER:Obj_REGISTER(objectID, playerID)
    self.OBJECT[objectID] = playerID
end

function RUNNER:Obj_UNREGISTER(objectID)
    self.OBJECT[objectID] = nil
end

-- Get the owner of an object
function RUNNER:Obj_OF(objectID)
    return self.OBJECT[objectID]
end

-- Attach and detach functions to objects
function RUNNER:ATTACH_FUNC(objectID, func)
    self.OBJ_FUNCTIONS[objectID] = func
end

function RUNNER:UNATTACH_FUNC(objectID)
    self.OBJ_FUNCTIONS[objectID] = nil
end

-- Execute a delayed event
function RUNNER:EXECUTE_DELAYED_EVENT(eventID)
    for i, event in ipairs(self.DELAYED_EVENTS) do
        if event.id == eventID then
            if event.delay > 0 then
                event.delay = event.delay - 1
            else
                local success, result = pcall(event.func, unpack(event.args))
                if not success then
                    print("Error executing event [" .. eventID .. "]: " .. result)
                end
                table.remove(self.DELAYED_EVENTS, i)
            end
            return
        end
    end
end

-- Handle runtime events
ScriptSupportEvent:registerEvent("Game.RunTime", function()
    for _, event in ipairs(RUNNER.DELAYED_EVENTS) do
        RUNNER:EXECUTE_DELAYED_EVENT(event.id)
    end
end)

-- Handle projectile hit events
ScriptSupportEvent:registerEvent("Actor.Projectile.Hit", function(e)
    local success, result = pcall(function()
        local func = RUNNER.OBJ_FUNCTIONS[e.eventobjid]
        if func then
            func(e.eventobjid, e)
        end
    end)
    if not success then
        print("Error handling projectile hit [" .. e.eventobjid .. "]: " .. result)
    end
    RUNNER:Obj_UNREGISTER(e.eventobjid)
    RUNNER:UNATTACH_FUNC(e.eventobjid)
end)
