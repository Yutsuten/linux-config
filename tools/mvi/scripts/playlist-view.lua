--[[
mpv-gallery-view | https://github.com/occivink/mpv-gallery-view

This mpv script generates and displays an overview of the current playlist with thumbnails.

File placement: scripts/playlist-view.lua
Settings: script-opts/playlist_view.conf
Default keybinding: g script-binding playlist-view-toggle
]]

local utils = require 'mp.utils'
local msg = require 'mp.msg'
local options = require 'mp.options'
local assdraw = require 'mp.assdraw'

local HOURS = 60 -- find command uses minutes as unit
local DAYS = 24 * HOURS
local MAX_THUMBNAILS = 64

local ass = ""
local ass_changed = false
local bindings = {}
local bindings_repeat = {}
local compute_geometry
local cwd = mp.get_property_native("working-directory")
local flags = {}
local geometry_changed = false
local hash_cache = {}
local pending_selection = nil
local playlist_pos = 0
local thumbs_dir = ""
local opts = {
    thumbs_dir = "~/.cache/thumbnails/mvi-gallery",
    delete_old_thumbs_in_days = 30,
    close_on_load_file = true,
    follow_playlist_position = true,

    gallery_position = "{ (ww - gw) / 2, (wh - gh) / 2}",
    gallery_size = "{ 9 * ww / 10, 9 * wh / 10 }",
    min_spacing = "{ 15, 15 }",
    thumbnail_size = "(ww * wh <= 1366 * 768) and {192, 108} or {288, 162}",
    thumbnail_format = "webp",

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

    flagged_file_path = "./mvi_flagged",

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

local function file_exists(path)
    local info = utils.file_info(path)
    return info ~= nil and info.is_file
end

local gallery = {
    -- Variables
    items = {},
    hash_cache = {},
    config = {
        background_color = '333333',
        background_opacity = '33',
        background_roundness = 5,
        scrollbar = true,
        scrollbar_left_side = false,
        scrollbar_min_size = 10,
        overlay_range = 0,
        show_placeholders = true,
        always_show_placeholders = true,
        placeholder_color = '222222',
        text_size = 28,
        align_text = true,
    },
    active = false,
    geometry = {
        ok = false,
        position = { 0, 0 },
        size = { 0, 0 },
        min_spacing = { 0, 0 },
        thumbnail_size = { 0, 0 },
        rows = 0,
        columns = 0,
        effective_spacing = { 0, 0 },
    },
    view = { -- 1-based indices into the "playlist" array
        first = 0, -- must be equal to N*columns
        last = 0, -- must be > first and <= first + rows*columns
    },
    overlays = {
        active = {}, -- array of <=64 strings indicating the file associated to the current overlay (false if nothing)
        missing = {}, -- associative array of thumbnail path to view index it should be shown at
    },
    selection = nil,
    ass = {
        background = "",
        selection = "",
        scrollbar = "",
        placeholders = "",
    },

    -- Methods
    show_overlay = function(gallery, index_1, thumb_path)
        local g = gallery.geometry
        gallery.overlays.active[index_1] = thumb_path
        local index_0 = index_1 - 1
        local x, y = gallery:view_index_position(index_0)
        mp.commandv("overlay-add",
            tostring(index_0 + gallery.config.overlay_range),
            tostring(math.floor(x + 0.5)),
            tostring(math.floor(y + 0.5)),
            thumb_path,
            "0",
            "bgra",
            tostring(g.thumbnail_size[1]),
            tostring(g.thumbnail_size[2]),
            tostring(4*g.thumbnail_size[1]))
        mp.osd_message(" ", 0.01)
    end,
    remove_overlays = function(gallery)
        for view_index, _ in pairs(gallery.overlays.active) do
            mp.commandv("overlay-remove", gallery.config.overlay_range + view_index - 1)
            gallery.overlays.active[view_index] = false
        end
        gallery.overlays.missing = {}
    end,
    refresh_overlays = function(gallery, force)
        local todo = {}
        local o = gallery.overlays
        local g = gallery.geometry
        o.missing = {}
        for view_index = 1, g.rows * g.columns do
            local index = gallery.view.first + view_index - 1
            local active = o.active[view_index]
            if index > 0 and index <= #gallery.items then
                local filename = gallery.items[index].filename
                local bgra_path = gallery.hash_cache[filename]
                if not force and active == bgra_path then
                    -- nothing to do
                elseif bgra_path ~= nil and file_exists(bgra_path) then
                    gallery:show_overlay(view_index, bgra_path)
                else
                    -- need to generate that thumbnail
                    o.active[view_index] = false
                    mp.commandv("overlay-remove", gallery.config.overlay_range + view_index - 1)
                    o.missing[filename] = view_index
                    todo[#todo + 1] = filename
                end
            else
                -- might happen if we're close to the end of gallery.items
                if active ~= false then
                    o.active[view_index] = false
                    mp.commandv("overlay-remove", gallery.config.overlay_range + view_index - 1)
                end
            end
        end
        -- reverse iterate so that the first thumbnail is at the top of the stack
        for i = #todo, 1, -1 do
            mp.commandv("script-message-to", "thumbgen", "push-thumbnail-front",
                mp.get_script_name(),
                todo[i]
            )
        end
    end,
    index_at = function(gallery, mx, my)
        local g = gallery.geometry
        if mx < g.position[1] or my < g.position[2] then
            return nil
        end
        mx = mx - g.position[1]
        my = my - g.position[2]
        if mx > g.size[1] or my > g.size[2] then
            return nil
        end
        mx = mx - g.effective_spacing[1]
        my = my - g.effective_spacing[2]
        local on_column = (mx % (g.thumbnail_size[1] + g.effective_spacing[1])) < g.thumbnail_size[1]
        local on_row = (my % (g.thumbnail_size[2] + g.effective_spacing[2])) < g.thumbnail_size[2]
        if on_column and on_row then
            local column = math.floor(mx / (g.thumbnail_size[1] + g.effective_spacing[1]))
            local row = math.floor(my / (g.thumbnail_size[2] + g.effective_spacing[2]))
            local index = gallery.view.first + row * g.columns + column
            if index > 0 and index <= gallery.view.last then
                return index
            end
        end
        return nil
    end,
    compute_internal_geometry = function(gallery)
        local g = gallery.geometry
        g.rows = math.floor((g.size[2] - g.min_spacing[2]) / (g.thumbnail_size[2] + g.min_spacing[2]))
        g.columns = math.floor((g.size[1] - g.min_spacing[1]) / (g.thumbnail_size[1] + g.min_spacing[1]))
        if g.rows <= 0 or g.columns <= 0 then
            g.rows = 0
            g.columns = 0
            g.effective_spacing[1] = g.size[1]
            g.effective_spacing[2] = g.size[2]
            return
        end
        if (g.rows * g.columns > MAX_THUMBNAILS) then
            local r = math.sqrt(g.rows * g.columns / MAX_THUMBNAILS)
            g.rows = math.floor(g.rows / r)
            g.columns = math.floor(g.columns / r)
        end
        g.effective_spacing[1] = (g.size[1] - g.columns * g.thumbnail_size[1]) / (g.columns + 1)
        g.effective_spacing[2] = (g.size[2] - g.rows * g.thumbnail_size[2]) / (g.rows + 1)
    end,
    ensure_view_valid = function(gallery)
        -- makes sure that view.first and view.last are valid with regards to the playlist
        -- and that selection is within the view
        -- to be called after the playlist, view or selection was modified somehow
        local g = gallery.geometry
        if #gallery.items == 0 or g.rows == 0 or g.columns == 0 then
            gallery.view.first = 0
            gallery.view.last = 0
            return
        end
        local v = gallery.view
        local selection_row = math.floor((gallery.selection - 1) / g.columns)
        local max_thumbs = g.rows * g.columns
        local changed = false

        if v.last >= #gallery.items then
            v.last = #gallery.items
            if g.rows == 1 then
                v.first = math.max(1, v.last - g.columns + 1)
            else
                local last_row = math.floor((v.last - 1) / g.columns)
                local first_row = math.max(0, last_row - g.rows + 1)
                v.first = 1 + first_row * g.columns
            end
            changed = true
        elseif v.first == 0 or v.last == 0 or v.last - v.first + 1 ~= max_thumbs then
            -- special case: the number of possible thumbnails was changed
            -- just recreate the view such that the selection is in the middle row
            local max_row = (#gallery.items - 1) / g.columns + 1
            local row_first = selection_row - math.floor((g.rows - 1) / 2)
            local row_last = selection_row + math.floor((g.rows - 1) / 2) + g.rows % 2
            if row_first < 0 then
                row_first = 0
            elseif row_last > max_row then
                row_first = max_row - g.rows + 1
            end
            v.first = 1 + row_first * g.columns
            v.last = math.min(#gallery.items, v.first - 1 + max_thumbs)
            return true
        end

        if gallery.selection < v.first then
            -- the selection is now on the first line
            v.first = (g.rows == 1) and gallery.selection or selection_row * g.columns + 1
            v.last = math.min(#gallery.items, v.first + max_thumbs - 1)
            changed = true
        elseif gallery.selection > v.last then
            v.last = (g.rows == 1) and gallery.selection or (selection_row + 1) * g.columns
            v.first = math.max(1, v.last - max_thumbs + 1)
            v.last = math.min(#gallery.items, v.last)
            changed = true
        end
        return changed
    end,
    refresh_background = function(gallery)
        local g = gallery.geometry
        local a = assdraw.ass_new()
        a:new_event()
        a:append('{\\an7}')
        a:append('{\\bord0}')
        a:append('{\\shad0}')
        a:append('{\\1c&' .. gallery.config.background_color .. '}')
        a:append('{\\1a&' .. gallery.config.background_opacity .. '}')
        a:pos(0, 0)
        a:draw_start()
        a:round_rect_cw(g.position[1], g.position[2], g.position[1] + g.size[1], g.position[2] + g.size[2], gallery.config.background_roundness)
        a:draw_stop()
        gallery.ass.background = a.text
    end,
    refresh_placeholders = function(gallery)
        if not gallery.config.show_placeholders then
            return
        end
        if gallery.view.first == 0 then
            gallery.ass.placeholders = ""
            return
        end
        local g = gallery.geometry
        local a = assdraw.ass_new()
        a:new_event()
        a:append('{\\an7}')
        a:append('{\\bord0}')
        a:append('{\\shad0}')
        a:append('{\\1c&' .. gallery.config.placeholder_color .. '}')
        a:pos(0, 0)
        a:draw_start()
        for i = 0, gallery.view.last - gallery.view.first do
            if gallery.config.always_show_placeholders or not gallery.overlays.active[i + 1] then
                local x, y = gallery:view_index_position(i)
                a:rect_cw(x, y, x + g.thumbnail_size[1], y + g.thumbnail_size[2])
            end
        end
        a:draw_stop()
        gallery.ass.placeholders = a.text
    end,
    refresh_scrollbar = function(gallery)
        if not gallery.config.scrollbar then
            return
        end
        gallery.ass.scrollbar = ""
        if gallery.view.first == 0 then
            return
        end
        local g = gallery.geometry
        local before = (gallery.view.first - 1) / #gallery.items
        local after = (#gallery.items - gallery.view.last) / #gallery.items
        -- don't show the scrollbar if everything is visible
        if before + after == 0 then
            return
        end
        local p = gallery.config.scrollbar_min_size / 100
        if before + after > 1 - p then
            if before == 0 then
                after = (1 - p)
            elseif after == 0 then
                before = (1 - p)
            else
                before, after =
                    before / after * (1 - p) / (1 + before / after),
                    after / before * (1 - p) / (1 + after / before)
            end
        end
        local dist_from_edge = g.size[2] * 0.015
        local y1 = g.position[2] + dist_from_edge + before * (g.size[2] - 2 * dist_from_edge)
        local y2 = g.position[2] + g.size[2] - (dist_from_edge + after * (g.size[2] - 2 * dist_from_edge))
        local x1, x2
        if gallery.config.scrollbar_left_side then
            x1 = g.position[1] + g.effective_spacing[1] / 2 - 2
        else
            x1 = g.position[1] + g.size[1] - g.effective_spacing[1] / 2 - 2
        end
        x2 = x1 + 4
        local scrollbar = assdraw.ass_new()
        scrollbar:new_event()
        scrollbar:append('{\\an7}')
        scrollbar:append('{\\bord0}')
        scrollbar:append('{\\shad0}')
        scrollbar:append('{\\1c&AAAAAA&}')
        scrollbar:pos(0, 0)
        scrollbar:draw_start()
        scrollbar:rect_cw(x1, y1, x2, y2)
        scrollbar:draw_stop()
        gallery.ass.scrollbar = scrollbar.text
    end,
    refresh_selection = function(gallery)
        local v = gallery.view
        if v.first == 0 then
            gallery.ass.selection = ""
            return
        end
        local selection_ass = assdraw.ass_new()
        local g = gallery.geometry
        local draw_frame = function(index, size, color)
            local x, y = gallery:view_index_position(index - v.first)
            selection_ass:new_event()
            selection_ass:append('{\\an7}')
            selection_ass:append('{\\bord' .. size ..'}')
            selection_ass:append('{\\3c&'.. color ..'&}')
            selection_ass:append('{\\1a&FF&}')
            selection_ass:pos(0, 0)
            selection_ass:draw_start()
            selection_ass:rect_cw(x, y, x + g.thumbnail_size[1], y + g.thumbnail_size[2])
            selection_ass:draw_stop()
        end
        for i = v.first, v.last do
            local size, color = gallery.item_to_border(gallery, i, gallery.items[i])
            if size > 0 then
                draw_frame(i, size, color)
            end
        end

        for index = v.first, v.last do
            local text = gallery.item_to_text(gallery, index, gallery.items[index])
            if text ~= "" then
                selection_ass:new_event()
                local an = 5
                local x, y = gallery:view_index_position(index - v.first)
                x = x + g.thumbnail_size[1] / 2
                y = y + g.thumbnail_size[2] + gallery.config.text_size * 0.75
                if gallery.config.align_text then
                    local col = (index - v.first) % g.columns
                    if g.columns > 1 then
                        if col == 0 then
                            x = x - g.thumbnail_size[1] / 2
                            an = 4
                        elseif col == g.columns - 1 then
                            x = x + g.thumbnail_size[1] / 2
                            an = 6
                        end
                    end
                end
                selection_ass:an(an)
                selection_ass:pos(x, y)
                selection_ass:append(string.format("{\\fs%d}", gallery.config.text_size))
                selection_ass:append("{\\bord0}")
                selection_ass:append(text)
            end
        end
        gallery.ass.selection = selection_ass.text
    end,
    ass_show = function(new_ass)
        ass_changed = true
        ass = new_ass
    end,
    ass_refresh = function(gallery, selection, scrollbar, placeholders, background)
        if not gallery.active then
            return
        end
        if selection then
            gallery:refresh_selection()
        end
        if scrollbar then
            gallery:refresh_scrollbar()
        end
        if placeholders then
            gallery:refresh_placeholders()
        end
        if background then
            gallery:refresh_background()
        end
        gallery.ass_show(table.concat({
            gallery.ass.background,
            gallery.ass.placeholders,
            gallery.ass.selection,
            gallery.ass.scrollbar
        }, "\n"))
    end,
    set_selection = function(gallery, selection)
        if not selection or selection ~= selection then
            return
        end
        local new_selection = math.max(1, math.min(selection, #gallery.items))
        if gallery.selection == new_selection then
            return
        end
        gallery.selection = new_selection
        if gallery.active then
            if gallery:ensure_view_valid() then
                gallery:refresh_overlays(false)
                gallery:ass_refresh(true, true, true, false)
            else
                gallery:ass_refresh(true, false, false, false)
            end
        end
    end,
    set_geometry = function(gallery, x, y, w, h, sw, sh, tw, th)
        if w <= 0 or h <= 0 or tw <= 0 or th <= 0 then
            msg.warn("Invalid coordinates")
            return
        end
        gallery.geometry.position = {x, y}
        gallery.geometry.size = {w, h}
        gallery.geometry.min_spacing = {sw, sh}
        gallery.geometry.thumbnail_size = {tw, th}
        gallery.geometry.ok = true
        if not gallery.active then
            return
        end
        if not gallery:enough_space() then
            msg.warn("Not enough space to display something")
        end
        local old_total = gallery.geometry.rows * gallery.geometry.columns
        gallery:compute_internal_geometry()
        gallery:ensure_view_valid()
        local new_total = gallery.geometry.rows * gallery.geometry.columns
        for view_index = new_total + 1, old_total do
            if gallery.overlays.active[view_index] then
                mp.commandv("overlay-remove", gallery.config.overlay_range + view_index - 1)
                gallery.overlays.active[view_index] = false
            end
        end
        gallery:refresh_overlays(true)
        gallery:ass_refresh(true, true, true, true)
    end,
    item_to_text = function(gallery, index, item)
        if not opts.show_text or index ~= gallery.selection then
            return "", false
        end
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
    end,
    item_to_border = function(gallery, index, item)
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
    end,
    items_changed = function(gallery, new_sel)
        gallery.selection = math.max(1, math.min(new_sel, #gallery.items))
        if not gallery.active then
            return
        end
        gallery:ensure_view_valid()
        gallery:refresh_overlays(false)
        gallery:ass_refresh(true, true, true, false)
    end,
    thumbnail_generated = function(gallery, input_path, bgra_path)
        gallery.hash_cache[input_path] = bgra_path
        if not gallery.active then
            return
        end
        local view_index = gallery.overlays.missing[input_path]
        if view_index == nil then
            return
        end
        gallery:show_overlay(view_index, bgra_path)
        if not gallery.config.always_show_placeholders then
            gallery:ass_refresh(false, false, true, false)
        end
        gallery.overlays.missing[input_path] = nil
    end,
    view_index_position = function(gallery, index_0)
        local g = gallery.geometry
        return math.floor(g.position[1] + g.effective_spacing[1] + (g.effective_spacing[1] + g.thumbnail_size[1]) * (index_0 % g.columns)),
            math.floor(g.position[2] + g.effective_spacing[2] + (g.effective_spacing[2] + g.thumbnail_size[2]) * math.floor(index_0 / g.columns))
    end,
    enough_space = function(gallery)
        if gallery.geometry.size[1] < gallery.geometry.thumbnail_size[1] + 2 * gallery.geometry.min_spacing[1] then
            return false
        end
        if gallery.geometry.size[2] < gallery.geometry.thumbnail_size[2] + 2 * gallery.geometry.min_spacing[2] then
            return false
        end
        return true
    end,
    activate = function(gallery)
        if gallery.active then
            return false
        end
        if not gallery:enough_space() then
            msg.warn("Not enough space, refusing to start")
            return false
        end
        if not gallery.geometry.ok then
            msg.warn("Gallery geometry unitialized, refusing to start")
            return false
        end
        gallery.active = true
        if not gallery.selection then
            gallery:set_selection(1)
        end
        gallery:compute_internal_geometry()
        gallery:ensure_view_valid()
        gallery:refresh_overlays(false)
        gallery:ass_refresh(true, true, true, true)
        return true
    end,
    deactivate = function(gallery)
        if not gallery.active then
            return
        end
        gallery.active = false
        gallery:remove_overlays()
        gallery.ass_show("")
    end,
}
for i = 1, MAX_THUMBNAILS do
    gallery.overlays.active[i] = false
end

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

function blend_colors(colors)
    if #colors == 1 then
        return colors[1]
    end
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
            if not clamp then
                return
            end
            new = math.max(1, math.min(new, #gallery.items))
        end
        pending_selection = new
    end

    bindings[opts.FIRST]  = function() pending_selection = 1 end
    bindings[opts.LAST]   = function() pending_selection = #gallery.items end
    bindings[opts.ACCEPT] = function()
        load_selection()
        if opts.close_on_load_file then
            stop()
        end
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
            if not index then
                return
            end
            if index == gallery.selection then
                load_selection()
                if opts.close_on_load_file then
                    stop()
                end
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

function playlist_changed(key, playlist)
    if not gallery.active then
        return
    end
    local did_change = function()
        if #gallery.items ~= #playlist then
            return true
        end
        for i = 1, #gallery.items do
            if gallery.items[i].filename ~= playlist[i].filename then
                return true
            end
        end
        return false
    end
    if not did_change() then
        return
    end
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
    if gallery.active then
        return
    end
    playlist = mp.get_property_native("playlist")
    if #playlist == 0 then
        return
    end
    gallery.items = playlist

    local ww, wh = mp.get_osd_size()
    compute_geometry(ww, wh)

    playlist_pos = mp.get_property_number("playlist-pos-1")
    gallery:set_selection(playlist_pos or 1)
    if not gallery:activate() then
        return
    end

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

mp.register_script_message("thumbnail-generated", function(input_path, bgra_path)
    gallery:thumbnail_generated(input_path, bgra_path)
end)

function write_flag_file()
    if next(flags) == nil then
        return
    end
    local flagged_file_path = string.gsub(opts.flagged_file_path, "^~", os.getenv("HOME") or "~")
    local output_file = io.open(flagged_file_path, "w")
    for flag, _ in pairs(flags) do
        output_file:write(utils.join_path(cwd, flag) .. "\0")
    end
    output_file:close()
end
mp.register_event("shutdown", write_flag_file)

function delete_old_thumbnails()
    utils.subprocess({
        args = {
            "find", thumbs_dir,
            "-maxdepth", "1",
            "-type", "f",
            "-amin", "+" .. tostring(opts.delete_old_thumbs_in_days * DAYS),
            "-delete"
        },
        playback_only = false
    })
end
mp.register_event("shutdown", delete_old_thumbnails)

reload_config()

function osd_size_changed()
    local ww, wh = mp.get_osd_size()
    if ww > 0 and wh > 0 then
        compute_geometry(ww, wh)
        mp.commandv(
            "script-message-to",
            "thumbgen",
            "thumb-config-broadcast",
            tostring(gallery.geometry.thumbnail_size[1]),
            tostring(gallery.geometry.thumbnail_size[2]),
            thumbs_dir,
            opts.thumbnail_format
        )
    end
end
mp.observe_property("osd-width", "number", osd_size_changed)
mp.observe_property("osd-height", "number", osd_size_changed)

mp.add_key_binding(nil, "playlist-view-open", function() start() end)
mp.add_key_binding(nil, "playlist-view-close", stop)
mp.add_key_binding('g', "playlist-view-toggle", toggle)
mp.add_key_binding(nil, "playlist-view-load-selection", load_selection)
mp.add_key_binding(nil, "playlist-view-write-flag-file", write_flag_file)
