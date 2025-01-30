require("hs.ipc")

-- Set up the logger
local log = hs.logger.new('WindowMover', 'info')

-- Cache for mapping Mission Control desktop numbers to space IDs
local desktopToSpaceCache = {}

-- Function to refresh the desktop to space mapping
function refreshDesktopToSpaceMapping()
    local mcSpaces = hs.spaces.missionControlSpaceNames()
    desktopToSpaceCache = {}

    -- Iterate through all screens and their spaces
    for _, screenSpaces in pairs(mcSpaces) do
        for spaceID, name in pairs(screenSpaces) do
            -- Extract desktop number from name (e.g., "Desktop 1" -> 1)
            local desktopNum = tonumber(name:match("Desktop (%d+)"))
            if desktopNum then
                desktopToSpaceCache[desktopNum] = spaceID
            end
        end
    end
end

-- Function to get space ID for a Mission Control desktop number
function getSpaceIDForDesktop(desktopNum)
    -- Refresh mapping if we don't have the desktop number
    if not desktopToSpaceCache[desktopNum] then
        log.i("Refreshing desktop to space mapping")
        refreshDesktopToSpaceMapping()
    end
    return desktopToSpaceCache[desktopNum]
end

-- Function to move focused window to a specific Mission Control desktop number
function moveFocusedWindowToSpace(desktopNum)
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow then
        log.w("No focused window")
        return
    end

    local spaceID = getSpaceIDForDesktop(desktopNum)
    if not spaceID then
        log.w("Could not find space ID for desktop " .. desktopNum)
        return
    end

    -- Move the window to the target space
    local success = hs.spaces.moveWindowToSpace(focusedWindow, spaceID)
    if success then
        log.i("Moved window to desktop " .. desktopNum .. " (Space ID: " .. spaceID .. ")")
    else
        log.e("Failed to move window to desktop " .. desktopNum)
    end
end

-- Function to move all windows of an application to a specific Mission Control desktop number
function moveAppWindowsToSpace(appName, desktopNum)
    -- Get the target space ID
    local spaceID = getSpaceIDForDesktop(desktopNum)
    if not spaceID then
        log.w("Invalid desktop number: " .. desktopNum)
        return
    end

    -- Find all windows for the application using window filter
    local windows = hs.window.filter.new(function(w)
        return w:application():name() == appName
    end):getWindows()

    log.i("Found " .. #windows .. " windows for " .. appName)

    if #windows == 0 then
        log.w("No windows found for " .. appName)
        return
    end

    -- Move each window to the target space
    local successCount = 0
    for i, window in ipairs(windows) do
        log.i("Moving window " .. i .. ": " .. window:title())
        if hs.spaces.moveWindowToSpace(window, spaceID) then
            successCount = successCount + 1
        else
            log.e("Failed to move window: " .. window:title())
        end
    end

    log.i("Successfully moved " .. successCount .. " out of " .. #windows .. " windows of " .. appName .. " to desktop " .. desktopNum)
end

-- Initialize the desktop to space mapping
refreshDesktopToSpaceMapping()

-- Bind keys cmd + shift + 0-9
for i = 0, 9 do
    hs.hotkey.bind({ "cmd", "shift" }, tostring(i), function()
        log.i("Hotkey pressed: cmd + shift + " .. i)
        moveFocusedWindowToSpace(i)
    end)
end

-- Optional: Set up a spaces watcher to refresh mapping when spaces change
local spacesWatcher = hs.spaces.watcher.new(function()
    refreshDesktopToSpaceMapping()
end)
spacesWatcher:start()
