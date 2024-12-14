--[[
mpv-gallery-view | https://github.com/occivink/mpv-gallery-view

This mpv script implements a worker for generating gallery thumbnails.
It is meant to be used by other scripts.
Multiple copies of this script can be loaded by mpv.

File placement: inside scripts directory
]]

local utils = require 'mp.utils'
local msg = require 'mp.msg'

local jobs_queue = {} -- queue of thumbnail jobs
local failed = {} -- list of failed output paths, to avoid redoing them
local script_id = mp.get_script_name() .. utils.getpid()

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

function generate_tmp_filepath(path)
    local dir, name = utils.split_path(path)
    return utils.join_path(dir, "tmp" .. script_id .. "-" .. name)
end

function generate_thumbnail(thumbnail_job)
    local target_size = thumbnail_job.width .. "x" .. thumbnail_job.height
    if not file_exists(thumbnail_job.thumb_path) then
        local tmp_output_path = generate_tmp_filepath(thumbnail_job.thumb_path)
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
            thumbnail_job.thumb_path
        )
        if not success then
            return false
        end
    end
    if not file_exists(thumbnail_job.bgra_path) then
        local tmp_output_path = generate_tmp_filepath(thumbnail_job.bgra_path)
        -- Explanation of the bellow command's necessity is on mpv's documentation:
        -- "[...] only bgra is defined. [...] This uses premultiplied alpha: every color component is already multiplied with the alpha component."
        local success = thumbnail_command(
            {
                "magick", thumbnail_job.thumb_path,
                "(", "+clone", "-alpha", "extract", ")", -- clone + extract alpha channel as grayscale
                "-channel", "RGB",                       -- next command only apply to colors (RGB)
                "-compose", "multiply", "-composite",    -- perform multiply between colors and extracted alpha
                "BGRA:" .. tmp_output_path,
            },
            tmp_output_path,
            thumbnail_job.bgra_path
        )
        if not success then
            return false
        end
    end
    return true
end

function handle_events(wait)
    e = mp.wait_event(wait)
    while e.event ~= "none" do
        if e.event == "shutdown" then
            return false
        elseif e.event == "client-message" then
            if e.args[1] == "push-thumbnail-front" or e.args[1] == "push-thumbnail-back" then
                local thumbnail_job = {
                    requester = e.args[2],
                    input_path = e.args[3],
                    width = tonumber(e.args[4]),
                    height = tonumber(e.args[5]),
                    thumb_path = e.args[6],
                    bgra_path = e.args[7]
                }
                if e.args[1] == "push-thumbnail-front" then
                    jobs_queue[#jobs_queue + 1] = thumbnail_job
                else
                    table.insert(jobs_queue, 1, thumbnail_job)
                end
            end
        end
        e = mp.wait_event(0)
    end
    return true
end

local registration_timeout = 2 -- seconds
local registration_period = 0.2

-- shitty custom event loop because I can't figure out a better way
-- works pretty well though
function mp_event_loop()
    local start_time = mp.get_time()
    local sleep_time = registration_period
    local last_broadcast_time = -registration_period
    local broadcast_func
    broadcast_func = function()
        local now = mp.get_time()
        if now >= start_time + registration_timeout then
            mp.commandv("script-message", "thumbnails-generator-broadcast", mp.get_script_name())
            sleep_time = 1e20
            broadcast_func = function() end
        elseif now >= last_broadcast_time + registration_period then
            mp.commandv("script-message", "thumbnails-generator-broadcast", mp.get_script_name())
            last_broadcast_time = now
        end
    end

    while true do
        if not handle_events(sleep_time) then return end
        broadcast_func()
        while #jobs_queue > 0 do
            local thumbnail_job = jobs_queue[#jobs_queue]
            if not failed[thumbnail_job.bgra_path] then
                if generate_thumbnail(thumbnail_job) then
                    mp.commandv("script-message-to", thumbnail_job.requester, "thumbnail-generated", thumbnail_job.bgra_path)
                else
                    failed[thumbnail_job.bgra_path] = true
                end
            end
            jobs_queue[#jobs_queue] = nil
            if not handle_events(0) then return end
            broadcast_func()
        end
    end
end
