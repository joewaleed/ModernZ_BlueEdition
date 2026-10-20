local utils = require "mp.utils"

-- Path to mpv.conf
local conf_path = mp.command_native({"expand-path", "~~/mpv.conf"})

local function update_config(enabled)
    local lines = {}
    local found = false
    
    -- Read existing config file if present
    local f = io.open(conf_path, "r")
    if f then
        for line in f:lines() do
            if line:match("^%s*save%-position%-on%-quit%s*=") then
                lines[#lines + 1] = "save-position-on-quit=" .. (enabled and "yes" or "no")
                found = true
            else
                lines[#lines + 1] = line
            end
        end
        f:close()
    end
    
    -- Append option if it wasn't previously in mpv.conf
    if not found then
        lines[#lines + 1] = "save-position-on-quit=" .. (enabled and "yes" or "no")
    end
    
    -- Write back to mpv.conf
    f = io.open(conf_path, "w")
    if f then
        f:write(table.concat(lines, "\n") .. "\n")
        f:close()
    end
end

-- Observe changes to save-position-on-quit property
mp.observe_property("save-position-on-quit", "bool", function(_, val)
    if val ~= nil then
        update_config(val)
    end
end)
