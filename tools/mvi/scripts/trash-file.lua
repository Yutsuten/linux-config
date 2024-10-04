local utils = require "mp.utils"

trash_list = {}

function mark_trash()
    table.insert(trash_list, mp.get_property_native("path"))
    mp.commandv("playlist-remove", "current")
end

function trash()
    if next(trash_list) == nil then
        return
    end
    local trash_files = ""
    for _, file in pairs(trash_list) do
        trash_files = trash_files .. string.format(" '%s'", file) 
    end
    os.execute("trash-put" .. trash_files)
end

mp.add_key_binding("x", "mark-trash", mark_trash)
mp.register_event("shutdown", trash)
