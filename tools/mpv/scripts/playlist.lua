local msg = require 'mp.msg'
local utils = require 'mp.utils'

local cwd = mp.get_property_native("working-directory")
local msg_time = 2000

function remove_current()
    local playlist_path = mp.get_property_native("playlist-path")
    if not playlist_path then
        return
    end

    local current = mp.get_property_native("path")
    local current_short = string.gsub(current, string.format("^%s/", cwd), "")
    local playlist_before_length = 0
    local playlist_after = {}

    for music_path in io.lines(playlist_path) do
        playlist_before_length = playlist_before_length + 1
        if music_path ~= current and music_path ~= current_short then
            table.insert(playlist_after, music_path)
        end
    end

    if #playlist_after < playlist_before_length then
        msg.warn(string.format("%s: Remove %s", playlist_path, current))
        local playlist_file = io.open(playlist_path, "w")
        if playlist_file then
            playlist_file:write(table.concat(playlist_after, "\n") .. "\n")
            playlist_file:close()
            mp.commandv("show-text", string.format("Removed from playlist: %s", current_short), msg_time)
            mp.commandv("playlist-remove", "current")
        else
            msg.error("Failed to open playlist file")
            mp.commandv("show-text", "Failed to remove from playlist: Cannot open playlist file", msg_time)
        end
    else
        msg.error(string.format("%s: Not found for removal current=%s cwd=%s", playlist_path, current, cwd))
        mp.commandv("show-text", string.format("Failed to remove from playlist: %s", current_short), msg_time)
    end
end

mp.add_key_binding("D", "remove-from-playlist", remove_current)
