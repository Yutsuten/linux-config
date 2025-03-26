local msg = require 'mp.msg'
local utils = require "mp.utils"

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
    mp.commandv("show-text", string.format("Deleted '%s'", current), 2000)
end

mp.add_key_binding("x", "trash-file", trash_file)
