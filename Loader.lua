local function loadScript(url, scriptName)
    print("Starting to load: " .. scriptName)
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if success then
        print(scriptName .. " loaded successfully.")
    else
        print("Error loading " .. scriptName .. ": " .. err)
    end
end

local scripts = {
    { url = "https://raw.githubusercontent.com/devvedbydev/Systemhook/refs/heads/main/aimlock.lua", name = "Aim Lock" },
    { url = "https://raw.githubusercontent.com/devvedbydev/Systemhook/refs/heads/main/cursor.lua", name = "Cursor" },
    { url = "https://raw.githubusercontent.com/devvedbydev/Systemhook/refs/heads/main/ESP/ESPLoader.lua", name = "ESP" },
    { url = "https://raw.githubusercontent.com/devvedbydev/Systemhook/refs/heads/main/overlay.lua", name = "Overlay" },
    { url = "https://raw.githubusercontent.com/devvedbydev/Systemhook/refs/heads/main/flyto.lua", name = "Fly / TP" },
}

for _, script in ipairs(scripts) do
    spawn(function()
        loadScript(script.url, script.name)
    end)
end
print("All loading initiated.")
