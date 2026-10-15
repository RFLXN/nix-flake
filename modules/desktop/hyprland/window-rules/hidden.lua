return function(options)
    local workspace = "special:" .. options.workspace
    local pendingClose = false

    local function isTarget(window)
        if not window or not window.xwayland
            or window.initial_class ~= options.initialClass
            or window.initial_title ~= options.initialTitle then
            return false
        end

        -- Wine's /proc/PID/exe points to wine-preloader, not the Windows app.
        -- Read argv[0] exactly; never match arbitrary command-line substrings.
        local file = io.open("/proc/" .. tostring(window.pid) .. "/cmdline", "rb")
        if not file then return false end
        local command = file:read(4096)
        file:close()
        return command ~= nil and command:match("^([^%z]+)%z") == options.processArgv0
    end

    local function tagTarget(window)
        if not isTarget(window) then return false end
        hl.dispatch(hl.dsp.window.tag({ window = window, tag = "+" .. options.tag }))
        return true
    end

    local function closeWorkspace()
        for _, monitor in ipairs(hl.get_monitors()) do
            local special = monitor.active_special_workspace
            if special and special.name == workspace then
                -- Hyprland 0.56: an empty options table closes the overlay.
                monitor:set_special_workspace({})
            end
        end
    end

    local function scheduleClose()
        if pendingClose then return end
        pendingClose = true
        -- Run after the activating dispatcher completes, avoiding reentrancy.
        hl.timer(function()
            pendingClose = false
            closeWorkspace()
        end, { timeout = 1, type = "oneshot" })
    end

    local function isolate(window)
        if not tagTarget(window) then return end
        if not window.workspace or window.workspace.name ~= workspace then
            hl.dispatch(hl.dsp.window.move({
                window = window, workspace = workspace, follow = false,
            }))
        end
        scheduleClose()
    end

    -- In 0.56 this event follows static rules but precedes initial focus/render.
    -- Apply dynamic rules here; move only once the window is fully initialized.
    hl.on("window.open_early", tagTarget)
    hl.on("window.open", isolate)
    hl.on("window.move_to_workspace", isolate)
    hl.on("window.active", function(window)
        if isTarget(window) then isolate(window) end
    end)
    hl.on("workspace.special_active", function(special)
        if special and special.name == workspace then scheduleClose() end
    end)

    local function reconcile()
        for _, window in ipairs(hl.get_windows()) do isolate(window) end
        closeWorkspace()
    end
    hl.on("config.reloaded", reconcile)
    reconcile()
end
