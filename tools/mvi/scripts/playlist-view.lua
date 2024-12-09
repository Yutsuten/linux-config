--[[
mpv-gallery-view | https://github.com/occivink/mpv-gallery-view

This mpv script generates and displays an overview of the current playlist with thumbnails.

File placement: scripts/playlist-view.lua
Settings: script-opts/playlist_view.conf
Requires: script-modules/gallery-module.lua
Default keybinding: g script-binding playlist-view-toggle
]]

local utils = require 'mp.utils'
local msg = require 'mp.msg'
local options = require 'mp.options'

package.path = mp.command_native({ "expand-path", "~~/script-modules/?.lua;" }) .. package.path
require 'gallery'

-- global variables

flags = {}
hash_cache = {}
playlist_pos = 0

bindings = {}
bindings_repeat = {}

compute_geometry = function(ww, wh) end

ass_changed = false
ass = ""
geometry_changed = false
pending_selection = nil

thumb_dir = ""

gallery = gallery_new()
gallery.config.always_show_placeholders = true

opts = {
    thumbs_dir = "~/.cache/thumbnails/mpv-gallery/",

    gallery_position = "{ (ww - gw) / 2, (wh - gh) / 2}",
    gallery_size = "{ 9 * ww / 10, 9 * wh / 10 }",
    min_spacing = "{ 15, 15 }",
    thumbnail_size = "(ww * wh <= 1366 * 768) and {192, 108} or {288, 162}",

    close_on_load_file = true,
    follow_playlist_position = false,

    start_on_mpv_startup = false,

    show_text = true,
    show_title = true,
    strip_directory = true,
    strip_extension = true,
    text_size = 28,

    background_color = "333333",
    background_opacity = "33",
    normal_border_color = "BBBBBB",
    normal_border_size = 1,
    selected_border_color = "E5E4E5",
    selected_border_size = 6,
    highlight_active = true,
    active_border_color = "EBC5A7",
    active_border_size = 4,
    flagged_border_color = "96B58D",
    flagged_border_size = 4,
    placeholder_color = "222222",

    flagged_file_path = "./mpv_gallery_flagged",

    mouse_support = true,
    UP        = "UP",
    DOWN      = "DOWN",
    LEFT      = "LEFT",
    RIGHT     = "RIGHT",
    PAGE_UP   = "PGUP",
    PAGE_DOWN = "PGDWN",
    FIRST     = "HOME",
    LAST      = "END",
    RANDOM    = "r",
    ACCEPT    = "ENTER",
    CANCEL    = "ESC",
    REMOVE    = "DEL",
    FLAG      = "SPACE",
}
function reload_config()
    gallery.config.background_color = opts.background_color
    gallery.config.background_opacity = opts.background_opacity
    gallery.config.placeholder_color = opts.placeholder_color
    gallery.config.text_size = opts.text_size
    thumbs_dir = string.gsub(opts.thumbs_dir, "^~", os.getenv("HOME") or "~")
    local res = utils.file_info(thumbs_dir)
    if not res or not res.is_dir then
        local args = { "mkdir", "-p", thumbs_dir }
        utils.subprocess({ args = args, playback_only = false })
    end

    compute_geometry = get_geometry_function()
    reload_bindings()
    if gallery.active then
        local ww, wh = mp.get_osd_size()
        compute_geometry(ww, wh)
        gallery:ass_refresh(true, true, true, true)
    end
end
options.read_options(opts, mp.get_script_name(), reload_config)

gallery.ass_show = function(new_ass)
    ass_changed = true
    ass = new_ass
end
gallery.item_to_overlay_path = function(item)
    local filename = item.filename
    if hash_cache[filename] == nil then
        local cmd_handle = io.popen("echo -n '" .. normalize_path(filename) .. "' | sha256sum")
        local cmd_out = cmd_handle:read("*all")
        cmd_handle:close()
        hash_cache[filename] = string.format("%s_%d-%d", string.sub(cmd_out, 1, 64), gallery.geometry.thumbnail_size[1], gallery.geometry.thumbnail_size[2])
    end
    return utils.join_path(thumbs_dir, hash_cache[filename])
end
function blend_colors(colors)
    if #colors == 1 then return colors[1] end
    local comp1 = 0
    local comp2 = 0
    local comp3 = 0
    for _, val in ipairs(colors) do
        comp1 = comp1 + tonumber(string.sub(val, 1, 2), 16)
        comp2 = comp2 + tonumber(string.sub(val, 3, 4), 16)
        comp3 = comp3 + tonumber(string.sub(val, 5, 6), 16)
    end
    return string.format("%02x%02x%02x", comp1 / #colors, comp2 / #colors, comp3 / #colors)
end
gallery.item_to_border = function(index, item)
    local size = 0
    colors = {}
    if flags[item.filename] then
        colors[#colors + 1] = opts.flagged_border_color
        size = math.max(size, opts.flagged_border_size)
    end
    if index == gallery.selection then
        colors[#colors + 1] = opts.selected_border_color
        size = math.max(size, opts.selected_border_size)
    end
    if opts.highlight_active and index == playlist_pos then
        colors[#colors + 1] = opts.active_border_color
        size = math.max(size, opts.active_border_size)
    end
    if #colors == 0 then
        return opts.normal_border_size, opts.normal_border_color
    else
        return size, blend_colors(colors)
    end
end
gallery.item_to_text = function(index, item)
    if not opts.show_text or index ~= gallery.selection then return "", false end
    local f
    if opts.show_title and item.title then
        f = item.title
    else
        f = item.filename
        if opts.strip_directory then
            f = string.match(f, "([^/]+)$") or f
        end
        if opts.strip_extension then
            f = string.match(f, "(.+)%.[^.]+$") or f
        end
    end
    return f, true
end

function setup_ui_handlers()
    for key, func in pairs(bindings_repeat) do
        mp.add_forced_key_binding(key, "playlist-view-"..key, func, {repeatable = true})
    end
    for key, func in pairs(bindings) do
        mp.add_forced_key_binding(key, "playlist-view-"..key, func)
    end
end

function teardown_ui_handlers()
    for key, _ in pairs(bindings_repeat) do
        mp.remove_key_binding("playlist-view-"..key)
    end
    for key, _ in pairs(bindings) do
        mp.remove_key_binding("playlist-view-"..key)
    end
end

function reload_bindings()
    if gallery.active then
        teardown_ui_handlers()
    end

    bindings = {}
    bindings_repeat = {}

    local increment_func = function(increment, clamp)
        local new = (pending_selection or gallery.selection) + increment
        if new <= 0 or new > #gallery.items then
            if not clamp then return end
            new = math.max(1, math.min(new, #gallery.items))
        end
        pending_selection = new
    end

    bindings[opts.FIRST]  = function() pending_selection = 1 end
    bindings[opts.LAST]   = function() pending_selection = #gallery.items end
    bindings[opts.ACCEPT] = function()
        load_selection()
        if opts.close_on_load_file then stop() end
        mp.set_property("video-zoom", 0)
        mp.set_property("video-pan-x", 0)
        mp.set_property("video-pan-y", 0)
        mp.set_property("video-unscaled", "downscale-big")
        mp.set_property("video-rotate", 0)
    end
    bindings[opts.CANCEL] = function() stop() end
    bindings[opts.FLAG]   = function()
        local name = gallery.items[gallery.selection].filename
        if flags[name] == nil then
            flags[name] = true
        else
            flags[name] = nil
        end
        gallery:ass_refresh(true, false, false, false)
    end
    if opts.mouse_support then
        bindings["MBTN_LEFT"]  = function()
            local index = gallery:index_at(mp.get_mouse_pos())
            if not index then return end
            if index == gallery.selection then
                load_selection()
                if opts.close_on_load_file then stop() end
            else
                pending_selection= index
            end
        end
        bindings["WHEEL_UP"]   = function() increment_func(- gallery.geometry.columns, false) end
        bindings["WHEEL_DOWN"] = function() increment_func(  gallery.geometry.columns, false) end
    end

    bindings_repeat[opts.UP]        = function() increment_func(- gallery.geometry.columns, false) end
    bindings_repeat[opts.DOWN]      = function() increment_func(  gallery.geometry.columns, false) end
    bindings_repeat[opts.LEFT]      = function() increment_func(- 1, false) end
    bindings_repeat[opts.RIGHT]     = function() increment_func(  1, false) end
    bindings_repeat[opts.PAGE_UP]   = function() increment_func(- gallery.geometry.columns * gallery.geometry.rows, true) end
    bindings_repeat[opts.PAGE_DOWN] = function() increment_func(  gallery.geometry.columns * gallery.geometry.rows, true) end
    bindings_repeat[opts.RANDOM]    = function() pending_selection = math.random(1, #gallery.items) end
    bindings_repeat[opts.REMOVE]    = function()
        local s = gallery.selection
        mp.commandv("playlist-remove", s - 1)
        gallery:set_selection(s + (s == #gallery.items and -1 or 1))
    end

    if gallery.active then
        setup_ui_handlers()
    end
end

function get_geometry_function()
    local geometry_functions = loadstring(string.format([[
    return {
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end
    }]], opts.gallery_position, opts.gallery_size, opts.min_spacing, opts.thumbnail_size))()

    local names = { "gallery_position", "gallery_size", "min_spacing", "thumbnail_size" }
    local order = {} -- the order in which the 4 properties should be computed, based on inter-dependencies

    -- build the dependency matrix
    local patterns = { "g[xy]", "g[wh]", "s[wh]", "t[wh]" }
    local deps = {}
    for i = 1,4 do
        for j = 1,4 do
            local i_depends_on_j = (string.find(opts[names[i]], patterns[j]) ~= nil)
            if i == j and i_depends_on_j then
                msg.error(names[i] .. " depends on itself")
                return
            end
            deps[i * 4 + j] = i_depends_on_j
        end
    end

    local has_deps = function(index)
        for j = 1,4 do
            if deps[index * 4 + j] then
                return true
            end
        end
        return false
    end
    local num_resolved = 0
    local resolved = { false, false, false, false }
    while true do
        local resolved_one = false
        for i = 1, 4 do
            if resolved[i] then
                -- nothing to do
            elseif not has_deps(i) then
                order[#order + 1] = i
                -- since i has no deps, anything that depends on it might as well not
                for j = 1, 4 do
                    deps[j * 4 + i] = false
                end
                resolved[i] = true
                resolved_one = true
                num_resolved = num_resolved + 1
            end
        end
        if num_resolved == 4 then
            break
        elseif not resolved_one then
            local str = ""
            for index, resolved in ipairs(resolved) do
                if not resolved then
                    str = (str == "" and "" or (str .. ", ")) .. names[index]
                end
            end
            msg.error("Circular dependency between " .. str)
            return
        end
    end

    return function(window_width, window_height)
        local new_geom = {
             gallery_position = {},
             gallery_size = {},
             min_spacing = {},
             thumbnail_size = {},
         }
        for _, index in ipairs(order) do
            new_geom[names[index]] = geometry_functions[index](
                window_width, window_height,
                new_geom.gallery_position[1], new_geom.gallery_position[2],
                new_geom.gallery_size[1], new_geom.gallery_size[2],
                new_geom.min_spacing[1], new_geom.min_spacing[2],
                new_geom.thumbnail_size[1], new_geom.thumbnail_size[2]
            )
            -- extrawuerst
            if opts.show_text and names[index] == "min_spacing" then
                new_geom.min_spacing[2] = math.max(opts.text_size, new_geom.min_spacing[2])
            elseif names[index] == "thumbnail_size" then
                new_geom.thumbnail_size[1] = math.floor(new_geom.thumbnail_size[1])
                new_geom.thumbnail_size[2] = math.floor(new_geom.thumbnail_size[2])
            end
        end
        gallery:set_geometry(
            new_geom.gallery_position[1], new_geom.gallery_position[2],
            new_geom.gallery_size[1], new_geom.gallery_size[2],
            new_geom.min_spacing[1], new_geom.min_spacing[2],
            new_geom.thumbnail_size[1], new_geom.thumbnail_size[2]
        )
    end
end

function normalize_path(path)
    if string.find(path, "://") then
        return path
    end
    path = utils.join_path(utils.getcwd(), path)
    path = string.gsub(path, "/%./", "/")
    local n
    repeat
        path, n = string.gsub(path, "/[^/]*/%.%./", "/", 1)
    until n == 0
    return path
end

function playlist_changed(key, playlist)
    if not gallery.active then return end
    local did_change = function()
        if #gallery.items ~= #playlist then return true end
        for i = 1, #gallery.items do
            if gallery.items[i].filename ~= playlist[i].filename then return true end
        end
        return false
    end
    if not did_change() then return end
    if #playlist == 0 then
        stop()
        return
    end
    local selection_filename = gallery.items[gallery.selection].filename
    gallery.items = playlist
    local new_selection = math.max(1, math.min(gallery.selection, #gallery.items))
    for i, f in ipairs(gallery.items) do
        if selection_filename == f.filename then
            new_selection = i
            break
        end
    end
    gallery:items_changed(new_selection)
end

function playlist_pos_changed(_, val)
    playlist_pos = val
    if opts.highlight_active then
        gallery:ass_refresh(true, false, false, false)
    end
    if opts.follow_playlist_position then
        pending_selection = val
    end
end

function idle()
    if pending_selection then
        gallery:set_selection(pending_selection)
        pending_selection = nil
    end
    if ass_changed or geometry_changed then
        local ww, wh = mp.get_osd_size()
        if geometry_changed then
            geometry_changed = false
            compute_geometry(ww, wh)
        end
        if ass_changed then
            ass_changed = false
            mp.set_osd_ass(ww, wh, ass)
        end
    end
end

function mark_geometry_stale()
    geometry_changed = true
end

function start()
    if gallery.active then return end
    playlist = mp.get_property_native("playlist")
    if #playlist == 0 then return end
    gallery.items = playlist

    local ww, wh = mp.get_osd_size()
    compute_geometry(ww, wh)

    playlist_pos = mp.get_property_number("playlist-pos-1")
    gallery:set_selection(playlist_pos or 1)
    if not gallery:activate() then return end

    mp.observe_property("playlist-pos-1", "native", playlist_pos_changed)
    mp.observe_property("playlist", "native", playlist_changed)
    mp.observe_property("osd-width", "native", mark_geometry_stale)
    mp.observe_property("osd-height", "native", mark_geometry_stale)
    mp.register_idle(idle)
    idle()

    setup_ui_handlers()
end

function load_selection()
    local sel = mp.get_property_number("playlist-pos-1", -1)
    if sel == gallery.selection then
        return
    end
    mp.set_property("playlist-pos-1", gallery.selection)
end

function stop()
    if not gallery.active then
        return
    end
    mp.unobserve_property(playlist_pos_changed)
    mp.unobserve_property(playlist_changed)
    mp.unobserve_property(mark_geometry_stale)
    mp.unregister_idle(idle)
    teardown_ui_handlers()
    gallery:deactivate()
    idle()
end

function toggle()
    if gallery.active then
        stop()
    else
        start()
    end
end

mp.register_script_message("thumbnail-generated", function(thumb_path)
     gallery:thumbnail_generated(thumb_path)
end)

mp.register_script_message("thumbnails-generator-broadcast", function(generator_name)
     gallery:add_generator(generator_name)
end)

function write_flag_file()
    if next(flags) == nil then return end
    local out = io.open(opts.flagged_file_path, "w")
    for f, _ in pairs(flags) do
        out:write(f .. "\n")
    end
    out:close()
end
mp.register_event("shutdown", write_flag_file)

reload_config()

if opts.start_on_mpv_startup then
    local autostart
    autostart = function()
        if mp.get_property_number("playlist-count") == 0 then return end
        if mp.get_property_number("osd-width") <= 0 then return end
        start()
        mp.unobserve_property(autostart)
    end
    mp.observe_property("playlist-count", "number", autostart)
    mp.observe_property("osd-width", "number", autostart)
end

mp.add_key_binding(nil, "playlist-view-open", function() start() end)
mp.add_key_binding(nil, "playlist-view-close", stop)
mp.add_key_binding('g', "playlist-view-toggle", toggle)
mp.add_key_binding(nil, "playlist-view-load-selection", load_selection)
mp.add_key_binding(nil, "playlist-view-write-flag-file", write_flag_file)
