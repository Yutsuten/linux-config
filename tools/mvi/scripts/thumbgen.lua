--[[
mpv-gallery-view | https://github.com/occivink/mpv-gallery-view

This mpv script implements a worker for generating gallery thumbnails.
It is meant to be used by other scripts.

File placement: inside scripts directory
]]

local utils = require 'mp.utils'
local msg = require 'mp.msg'

local jobs_queue = {} -- queue of thumbnail jobs
local failed = {} -- list of failed input paths, to avoid redoing them
local preprocess_queue = {}
local preprocessed_thumb_sizes = {}
local script_id = mp.get_script_name() .. utils.getpid()
local hash_cache = {}

local thumbs_width = 0
local thumbs_height = 0
local thumbs_ext = ""
local thumbs_dir = ""
local thumbs_dir_regex = ""
local thumbs_tmpdir = ""

local function sha256sum(filename, width, height)
    if hash_cache[filename] == nil then
        local sha256sum_res = utils.subprocess({
            args = {"sha256sum", filename},
            capture_stdout = true,
            playback_only = false,
        })
        hash_cache[filename] = string.sub(sha256sum_res.stdout, 1, 64)
    end
    return hash_cache[filename]
end

local function mktemp_thumbs()
    -- Temporary directory for BGRA thumbnails
    local mktemp_res = utils.subprocess({
        args = {"mktemp", "--tmpdir", "--directory", "mvi-gallery-XXXXXXXX"},
        capture_stdout = true,
        playback_only = false,
    })
    if mktemp_res.status > 0 then
        msg.error("Error creating temporary directory for thumbnails")
        return
    end
    thumbs_tmpdir = string.sub(mktemp_res.stdout, 1, -2)
end

function preprocess_thumbnails(playlist)
    local thumb_size_str = string.format("%dx%d", thumbs_width, thumbs_height)
    if preprocessed_thumb_sizes[thumb_size_str] == nil then
        preprocessed_thumb_sizes[thumb_size_str] = true
        preprocess_queue = {}
        for _, item in ipairs(playlist) do
            table.insert(preprocess_queue, 1, { requester = "", input_path = item.filename })
        end
    end
end

local function file_exists(path)
    local info = utils.file_info(path)
    return info ~= nil and info.is_file
end

function thumbnail_command(command_args, tmp_output_path, output_path)
    local res = utils.subprocess({
        args = command_args,
        cancellable = false
    })
    -- "atomically" generate the output to avoid loading half-generated thumbnails (results in crashes)
    if res.status ~= 0 then
        return false
    end
    local info = utils.file_info(tmp_output_path)
    if not info or not info.is_file or info.size == 0 or not os.rename(tmp_output_path, output_path) then
        return false
    end
    return true
end

function generate_thumbnail(thumbnail_job, generate_bgra)
    local compressed_path = utils.join_path(mp.get_property_native("working-directory"), thumbnail_job.input_path)
    local input_dir, compressed_name = utils.split_path(compressed_path)
    local bgra_name
    local bgra_path

    if string.match(input_dir, thumbs_dir_regex) then
        -- Be careful to not generate thumbnails of thumbnails
        local width, height
        sha256sum_str, width, height = string.match(compressed_name, "([a-z0-9]+)_([0-9]+)-([0-9]+)%.[a-z]+")
        if tonumber(width) ~= thumbs_width or tonumber(height) ~= thumbs_height then
            return "" -- Thumbnail of different size than the one currently configured
        end
        bgra_name = string.format("%s_%s-%s", sha256sum_str, thumbs_width, thumbs_height)
    else
        bgra_name = string.format("%s_%d-%d", sha256sum(thumbnail_job.input_path), thumbs_width, thumbs_height)
        compressed_name = string.format("%s.%s", bgra_name, thumbs_ext)
        compressed_path = utils.join_path(thumbs_dir, compressed_name)
    end
    bgra_path = utils.join_path(thumbs_tmpdir, bgra_name)

    local target_size = string.format("%dx%d", thumbs_width, thumbs_height)
    if not file_exists(compressed_path) then
        local tmp_output_path = utils.join_path(
            thumbs_dir,
            string.format("tmp%s-%s", script_id, compressed_name)
        )
        local success = thumbnail_command(
            {
                "magick", thumbnail_job.input_path .. "[0]",
                "-alpha", "set",
                "-resize", target_size,
                "-background", "none",
                "-gravity", "center",
                "-extent", target_size,
                tmp_output_path,
            },
            tmp_output_path,
            compressed_path
        )
        if not success then
            return ""
        end
    end
    if thumbnail_job.requester ~= "" and not file_exists(bgra_path) then
        local tmp_output_path = utils.join_path(
            thumbs_tmpdir,
            string.format("tmp%s-%s", script_id, bgra_name)
        )
        -- Explanation of the bellow command's necessity is on mpv's documentation:
        -- "[...] only bgra is defined. [...] This uses premultiplied alpha: every color component is already multiplied with the alpha component."
        local success = thumbnail_command(
            {
                "magick", compressed_path,
                "(", "+clone", "-alpha", "extract", ")", -- clone + extract alpha channel as grayscale
                "-channel", "RGB",                       -- next command only apply to colors (RGB)
                "-compose", "multiply", "-composite",    -- perform multiply between colors and extracted alpha
                "BGRA:" .. tmp_output_path,
            },
            tmp_output_path,
            bgra_path
        )
        if not success then
            return ""
        end
    end
    return bgra_path
end

function handle_events(wait)
    e = mp.wait_event(wait)
    while e.event ~= "none" do
        if e.event == "shutdown" then
            utils.subprocess({args = {"rm", "-rf", thumbs_tmpdir}, playback_only = false})
            return false
        elseif e.event == "client-message" then
            if e.args[1] == "push-thumbnail-front" then
                local thumbnail_job = {
                    requester = e.args[2],
                    input_path = e.args[3],
                }
                jobs_queue[#jobs_queue + 1] = thumbnail_job
            elseif e.args[1] == "thumb-config-broadcast" then
                thumbs_width = tonumber(e.args[2])
                thumbs_height = tonumber(e.args[3])
                if thumbs_dir ~= e.args[4] then
                    thumbs_dir = e.args[4]
                    thumbs_dir_regex = '^' .. string.gsub(thumbs_dir, "[%%()%[%]^$.*+-]", "%%%1")
                end
                thumbs_ext = e.args[5]
                preprocess_thumbnails(mp.get_property_native("playlist"))
            end
        end
        e = mp.wait_event(0)
    end
    return true
end

mp.observe_property("playlist", "native", function(key, playlist)
    preprocess_thumbnails(playlist)
end)

-- Custom event loop for handling events while generating thumbnails
function mp_event_loop()
    mktemp_thumbs()
    while mp.keep_running do
        if not handle_events(-1) then
            return
        end
        while #jobs_queue > 0 or #preprocess_queue > 0 do
            while #jobs_queue > 0 do
                local thumbnail_job = jobs_queue[#jobs_queue]
                if not failed[thumbnail_job.input_path] then
                    bgra_path = generate_thumbnail(thumbnail_job)
                    if bgra_path ~= "" then
                        mp.commandv(
                            "script-message-to",
                            thumbnail_job.requester,
                            "thumbnail-generated",
                            thumbnail_job.input_path,
                            bgra_path
                        )
                    else
                        msg.warn("Failed to generate thumbnail for " .. thumbnail_job.input_path)
                        failed[thumbnail_job.input_path] = true
                    end
                end
                jobs_queue[#jobs_queue] = nil
                if not handle_events(0) then
                    return
                end
            end
            if #preprocess_queue > 0 then
                local thumbnail_job = preprocess_queue[#preprocess_queue]
                if not failed[thumbnail_job.input_path] then
                    if generate_thumbnail(thumbnail_job) == "" then
                        msg.warn("Failed to generate thumbnail for " .. thumbnail_job.input_path)
                        failed[thumbnail_job.input_path] = true
                    end
                end
                preprocess_queue[#preprocess_queue] = nil
                if not handle_events(0) then
                    return
                end
            end
        end
    end
end
