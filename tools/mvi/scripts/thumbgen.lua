--[[
mpv-gallery-view | https://github.com/occivink/mpv-gallery-view

This mpv script implements a worker for generating gallery thumbnails.
It is meant to be used by other scripts.

File placement: inside scripts directory
]]

local msg = require 'mp.msg'
local utils = require 'mp.utils'

local cwd = mp.get_property_native("working-directory")
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

local sha256
--[[
minified code below is a combination of:
-sha256 implementation from
http://lua-users.org/wiki/SecureHashAlgorithm
-lua implementation of bit32 (used as fallback on lua5.1) from
https://www.snpedia.com/extensions/Scribunto/engines/LuaCommon/lualib/bit32.lua
both are licensed under the MIT below:
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]
do local b,c,d,e,f;if bit32 then b,c,d,e,f=bit32.band,bit32.rrotate,bit32.bxor,bit32.rshift,bit32.bnot else f=function(g)g=math.floor(tonumber(g))%0x100000000;return(-g-1)%0x100000000 end;local h={[0]={[0]=0,0,0,0},[1]={[0]=0,1,0,1},[2]={[0]=0,0,2,2},[3]={[0]=0,1,2,3}}local i={[0]={[0]=0,1,2,3},[1]={[0]=1,0,3,2},[2]={[0]=2,3,0,1},[3]={[0]=3,2,1,0}}local function j(k,l,m,n,o)for p=1,m do l[p]=math.floor(tonumber(l[p]))%0x100000000 end;local q=1;local r=0;for s=0,31,2 do local t=n;for p=1,m do t=o[t][l[p]%4]l[p]=math.floor(l[p]/4)end;r=r+t*q;q=q*4 end;return r end;b=function(...)return j('band',{...},select('#',...),3,h)end;d=function(...)return j('bxor',{...},select('#',...),0,i)end;e=function(g,u)g=math.floor(tonumber(g))%0x100000000;u=math.floor(tonumber(u))u=math.min(math.max(-32,u),32)return math.floor(g/2^u)%0x100000000 end;c=function(g,u)g=math.floor(tonumber(g))%0x100000000;u=-math.floor(tonumber(u))%32;local g=g*2^u;return g%0x100000000+math.floor(g/0x100000000)end end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(n)return string.gsub(n,".",function(t)return string.format("%02x",string.byte(t))end)end;local function x(y,z)local n=""for p=1,z do local A=y%256;n=string.char(A)..n;y=(y-A)/256 end;return n end;local function B(n,p)local z=0;for p=p,p+3 do z=z*256+string.byte(n,p)end;return z end;local function C(D,E)local F=-(E+1+8)%64;E=x(8*E,8)D=D.."\128"..string.rep("\0",F)..E;return D end;local function G(H)H[1]=0x6a09e667;H[2]=0xbb67ae85;H[3]=0x3c6ef372;H[4]=0xa54ff53a;H[5]=0x510e527f;H[6]=0x9b05688c;H[7]=0x1f83d9ab;H[8]=0x5be0cd19;return H end;local function I(D,p,H)local J={}for K=1,16 do J[K]=B(D,p+(K-1)*4)end;for K=17,64 do local L=J[K-15]local M=d(c(L,7),c(L,18),e(L,3))L=J[K-2]local N=d(c(L,17),c(L,19),e(L,10))J[K]=J[K-16]+M+J[K-7]+N end;local O,s,t,P,Q,R,S,T=H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]for p=1,64 do local M=d(c(O,2),c(O,13),c(O,22))local U=d(b(O,s),b(O,t),b(s,t))local V=M+U;local N=d(c(Q,6),c(Q,11),c(Q,25))local W=d(b(Q,R),b(f(Q),S))local X=T+N+W+v[p]+J[p]T=S;S=R;R=Q;Q=P+X;P=t;t=s;s=O;O=X+V end;H[1]=b(H[1]+O)H[2]=b(H[2]+s)H[3]=b(H[3]+t)H[4]=b(H[4]+P)H[5]=b(H[5]+Q)H[6]=b(H[6]+R)H[7]=b(H[7]+S)H[8]=b(H[8]+T)end;local function Y(H)return w(x(H[1],4)..x(H[2],4)..x(H[3],4)..x(H[4],4)..x(H[5],4)..x(H[6],4)..x(H[7],4)..x(H[8],4))end;local Z={}sha256=function(D)D=C(D,#D)local H=G(Z)for p=1,#D,64 do I(D,p,H)end;return Y(H)end end
-- end of sha code

function sha256sum(filepath, width, height)
    if hash_cache[filepath] == nil then
        hash_cache[filepath] = sha256(filepath)
    end
    return hash_cache[filepath]
end

function normalize_path(path)
    path = string.gsub(path, "/%./", "/")
    local n
    repeat
        path, n = string.gsub(path, "/[^/]*/%.%./", "/", 1)
    until n == 0
    return path
end

function mktemp_thumbs()
    -- Temporary directory for BGRA thumbnails
    local result = utils.subprocess({
        args = {"mktemp", "--tmpdir", "--directory", "mvi-gallery-XXXXXXXX"},
        capture_stdout = true,
        capture_stderr = true,
        playback_only = false,
    })
    if result.status > 0 then
        msg.error("Error creating temporary directory for thumbnails. " .. result.stderr)
        return
    end
    thumbs_tmpdir = string.sub(result.stdout, 1, -2)
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

function file_exists(path)
    local info = utils.file_info(path)
    return info ~= nil and info.is_file
end

function thumbnail_command(command_args, tmp_output_path, output_path)
    local res = utils.subprocess({
        args = command_args,
        playback_only = false
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
    local input_path = normalize_path(utils.join_path(cwd, thumbnail_job.input_path))
    local input_dir, input_name = utils.split_path(input_path)
    local compressed_name, compressed_path, bgra_name, bgra_path

    if string.match(input_dir, thumbs_dir_regex) then
        -- Be careful to not generate thumbnails of thumbnails
        local width, height
        sha256sum_str, width, height = string.match(compressed_name, "([a-z0-9]+)_([0-9]+)-([0-9]+)%.[a-z]+")
        if tonumber(width) ~= thumbs_width or tonumber(height) ~= thumbs_height then
            return "" -- Thumbnail of different size than the one currently configured
        end
        bgra_name = string.format("%s_%s-%s", sha256sum_str, thumbs_width, thumbs_height)
        compressed_name = input_name
        compressed_path = input_path
    else
        bgra_name = string.format("%s_%d-%d", sha256sum(input_path), thumbs_width, thumbs_height)
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
                "magick",
                "-background", "none",
                thumbnail_job.input_path .. "[0]",
                "-alpha", "set",
                "-resize", target_size .. ">",
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
