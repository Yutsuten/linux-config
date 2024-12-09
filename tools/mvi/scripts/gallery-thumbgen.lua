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

function append_table(lhs, rhs)
    for i = 1,#rhs do
        lhs[#lhs+1] = rhs[i]
    end
    return lhs
end

local function file_exists(path)
    local info = utils.file_info(path)
    return info ~= nil and info.is_file
end

function thumbnail_command(input_path, width, height, output_path, with_mpv)
    local vf = string.format("%s,%s",
        string.format("scale=iw*min(1\\,min(%d/iw\\,%d/ih)):-2", width, height),
        string.format("pad=%d:%d:(%d-iw)/2:(%d-ih)/2:color=0x00000000", width, height, width, height)
    )
    local out = {}
    local add = function(table) out = append_table(out, table) end

    if not with_mpv then
        out = { "ffmpeg" }
        add({
            "-i", input_path,
            "-vf", vf,
            "-map", "v:0",
            "-f", "rawvideo",
            "-pix_fmt", "bgra",
            "-c:v", "rawvideo",
            "-frames:v", "1",
            "-y", "-loglevel", "quiet",
            output_path
        })
    else
        out = { "mpv", input_path }
        add({
            "--no-config", "--msg-level=all=no",
            "--vf=lavfi=[" .. vf .. ",format=bgra]",
            "--audio=no",
            "--sub=no",
            "--frames=1",
            "--image-display-duration=0",
            "--of=rawvideo", "--ovc=rawvideo",
            "--o="..output_path
        })
    end
    return out
end

function generate_thumbnail(thumbnail_job)
    if file_exists(thumbnail_job.output_path) then
        return true
    end

    local dir, _ = utils.split_path(thumbnail_job.output_path)
    local tmp_output_path = utils.join_path(dir, script_id)

    local command = thumbnail_command(
        thumbnail_job.input_path,
        thumbnail_job.width,
        thumbnail_job.height,
        tmp_output_path,
        thumbnail_job.with_mpv
    )

    local res = utils.subprocess({ args = command, cancellable = false })
    --"atomically" generate the output to avoid loading half-generated thumbnails (results in crashes)
    if res.status == 0 then
        local info = utils.file_info(tmp_output_path)
        if not info or not info.is_file or info.size == 0 then
            return false
        end
        if os.rename(tmp_output_path, thumbnail_job.output_path) then
            return true
        end
    end
    return false
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
                    output_path = e.args[6],
                    with_mpv = (e.args[7] == "true"),
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
            if not failed[thumbnail_job.output_path] then
                if generate_thumbnail(thumbnail_job) then
                    mp.commandv("script-message-to", thumbnail_job.requester, "thumbnail-generated", thumbnail_job.output_path)
                else
                    failed[thumbnail_job.output_path] = true
                end
            end
            jobs_queue[#jobs_queue] = nil
            if not handle_events(0) then return end
            broadcast_func()
        end
    end
end
