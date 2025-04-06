-- Based on mpv-gallery-view | https://github.com/occivink/mpv-gallery-view

package.path = mp.command_native({ "expand-path", "~~/script-modules/?.lua;" }) .. package.path
require 'thumbgen'
