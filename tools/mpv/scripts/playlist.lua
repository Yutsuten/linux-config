local utils = require 'mp.utils'
local msg = require 'mp.msg'

function remove_current()
    local playlist_path = mp.get_property_native("playlist-path")
    if not playlist_path then
        return
    end
    local current = mp.get_property_native("path")
    msg.info(string.format("%s: Remove %s", playlist_path, current))
    local playlist_after = {}
    for music_path in io.lines(playlist_path) do
        if music_path ~= current then
            table.insert(playlist_after, music_path)
        end
    end
    local playlist_file = io.open(playlist_path, "w")
    if playlist_file then
        playlist_file:write(table.concat(playlist_after, "\n") .. "\n")
        playlist_file:close()
    else
        msg.error("Failed to remove music")
        return
    end
    mp.commandv("playlist-remove", "current")
    mp.commandv("show-text", string.format("Removed '%s' from playlist", current), 2000)
end

mp.add_key_binding("D", "remove-from-playlist", remove_current)
