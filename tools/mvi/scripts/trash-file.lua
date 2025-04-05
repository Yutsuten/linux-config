local msg = require 'mp.msg'
local utils = require "mp.utils"

local cwd = mp.get_property_native("working-directory")

function trash_file()
    local current = mp.get_property_native("path")
    msg.warn("Delete " .. current)
    local result = mp.command_native({
        name = "subprocess",
        args = { "trash-put", current },
        capture_stderr = true,
        playback_only = false,
    })
    if result.status > 0 then
        msg.error("Error trashing file. " .. result.stderr)
        return
    end
    mp.commandv("playlist-remove", "current")
    local current_short = string.gsub(current, string.format("^%s/", cwd), "")
    mp.commandv("show-text", string.format("Deleted '%s'", current_short), 2000)
end

mp.add_key_binding("x", "trash-file", trash_file)
