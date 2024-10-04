function show_osc()
    mp.commandv("script-message", "osc-show")
end

mp.register_event("seek", show_osc)
mp.observe_property("pause", "bool", show_osc)
