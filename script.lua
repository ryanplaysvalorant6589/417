if _G.primas then
    pcall(function()
        if _G._417_window then _G._417_window:Destroy() end
    end)
    _G.primas = nil
end
_G.primas = true

if setfpscap then setfpscap(240) end
repeat task.wait() until game:IsLoaded()

cloneref = cloneref or function(x) return x end

local BallsFolder = workspace:WaitForChild("Balls")
local AliveFolder = workspace:WaitForChild("Alive")
local RuntimeFolder = workspace:WaitForChild("Runtime")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local Debris = cloneref(game:GetService("Debris"))
local Stats = cloneref(game:GetService("Stats"))
local TweenService = cloneref(game:GetService("TweenService"))
local HttpService = cloneref(game:GetService("HttpService"))
local LocalPlayer = Players.LocalPlayer

local config = {
    accuracy = 100,
    curve_method = "camera",
    auto_parry = false,
    manual_spam = false,
    animfix = false,
    spam_keybind = "E",
    show_spam = false,
    show_ball_speed = false,
    sword_changer = false,
    sword_name = "",
    avatar_spoofer = false,
    avatar_id = "",
    ability_esp = false,
    optim = { headless = false, korblox = false, noRender = false },
}

local CONFIG_FILE = "417_config.json"
local _loadingConfig = true

local function SaveConfig()
    if _loadingConfig then return end
    pcall(function()
        local data = {
            auto_parry = config.auto_parry,
            accuracy = config.accuracy,
            curve_method = config.curve_method,
            animfix = config.animfix,
            show_spam = config.show_spam,
            show_ball_speed = config.show_ball_speed,
            optim = config.optim,
            spam_keybind = config.spam_keybind,
            sword_changer = config.sword_changer,
            sword_name = config.sword_name,
            avatar_spoofer = config.avatar_spoofer,
            avatar_id = config.avatar_id,
            ability_esp = config.ability_esp,
        }
        if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end
    end)
end

pcall(function()
    if isfile and isfile(CONFIG_FILE) and readfile then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if ok and type(data) == "table" then
            if data.auto_parry ~= nil then config.auto_parry = data.auto_parry end
            if data.accuracy ~= nil then
                local n = tonumber(data.accuracy)
                config.accuracy = n and math.clamp(n, 1, 100) or 100
            end
            if data.curve_method then config.curve_method = data.curve_method end
            if data.animfix ~= nil then config.animfix = data.animfix end
            if data.show_spam ~= nil then config.show_spam = data.show_spam end
            if data.show_ball_speed ~= nil then config.show_ball_speed = data.show_ball_speed end
            if type(data.optim) == "table" then
                for k, v in pairs(data.optim) do config.optim[k] = v end
            end
            if data.spam_keybind then config.spam_keybind = data.spam_keybind end
            if data.sword_changer ~= nil then config.sword_changer = data.sword_changer end
            if data.sword_name then config.sword_name = data.sword_name end
            if data.avatar_spoofer ~= nil then config.avatar_spoofer = data.avatar_spoofer end
            if data.avatar_id then config.avatar_id = data.avatar_id end
            if data.ability_esp ~= nil then config.ability_esp = data.ability_esp end
        end
    end
end)
_loadingConfig = false

local DebugFlags = {}
pcall(function()
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    local df = shared and shared:FindFirstChild("DebugFlags")
    if df then
        local ok, res = pcall(require, df)
        if ok and type(res) == "table" then DebugFlags = res end
    end
end)

local function GetTrainingBallsFolder()
    return workspace:FindFirstChild("TrainingBalls")
end

local function isInLobby()
    local C = LocalPlayer.Character
    if not C then return false end
    if LocalPlayer:GetAttribute("LobbyTraining") then return false end
    local il = false
    if C:GetAttribute("Stunned") then il = true end
    local aliveFolder = workspace:FindFirstChild("Alive")
    local lobbyParryAttr = LocalPlayer:GetAttribute("LobbyParry")
    if aliveFolder and C.Parent ~= aliveFolder and not (DebugFlags.LobbyParry or lobbyParryAttr) then
        il = true
    end
    local qi
    pcall(function()
        if LocalPlayer.Upgrades then qi = LocalPlayer.Upgrades["Qi-Charge"] end
    end)
    if C:GetAttribute("DoNotParry") or (C:GetAttribute("ChargingAdrenaline") and qi and qi.Value < 2) then
        il = true
    end
    if lobbyParryAttr and LocalPlayer:GetAttribute("InLobbyParryCooldown") then il = true end
    return il
end

local function is_player_alive_and_in_alive()
    local char = LocalPlayer.Character
    if not char then return false end
    if LocalPlayer:GetAttribute("LobbyTraining") then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local aliveFolder = workspace:FindFirstChild("Alive")
    if not aliveFolder then return false end
    if not aliveFolder:FindFirstChild(LocalPlayer.Name) then return false end
    return true
end

local function hasBallAnywhere()
    local function scan(c)
        if not c then return false end
        for _, b in ipairs(c:GetChildren()) do
            if b:GetAttribute("realBall") then return true end
        end
        return false
    end
    if scan(workspace:FindFirstChild("Balls")) then return true end
    if scan(workspace:FindFirstChild("TrainingBalls")) then return true end
    return false
end

local Fluent
pcall(function()
    local src = game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
    local orange_hex = "255, 140, 0"
    local dark_bg_hex = "15, 15, 15"
    local black_hex = "0, 0, 0"
    local item_bg_hex = "30, 30, 30"
    local panel_bg_hex = "22, 22, 22"

    src = src:gsub('Name%s*=%s*"Darker"', 'Name = "Darker"')
    src = src:gsub('Accent%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'Accent = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('Element%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'Element = Color3.fromRGB(' .. item_bg_hex .. ')')
    src = src:gsub('Tab%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'Tab = Color3.fromRGB(' .. panel_bg_hex .. ')')
    src = src:gsub('Hover%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'Hover = Color3.fromRGB(200, 105, 0)')
    src = src:gsub('Text%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'Text = Color3.fromRGB(255, 255, 255)')
    src = src:gsub('SubText%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'SubText = Color3.fromRGB(40, 40, 40)')
    src = src:gsub('ToggleSlider%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'ToggleSlider = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('ToggleToggled%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'ToggleToggled = Color3.fromRGB(' .. black_hex .. ')')
    src = src:gsub('SliderRail%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'SliderRail = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('DropdownFrame%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DropdownFrame = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('DropdownHolder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DropdownHolder = Color3.fromRGB(' .. dark_bg_hex .. ')')
    src = src:gsub('DropdownBorder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DropdownBorder = Color3.fromRGB(200, 105, 0)')
    src = src:gsub('DropdownOption%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DropdownOption = Color3.fromRGB(' .. item_bg_hex .. ')')
    src = src:gsub('Input%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'Input = Color3.fromRGB(' .. item_bg_hex .. ')')
    src = src:gsub('InputFocused%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'InputFocused = Color3.fromRGB(' .. dark_bg_hex .. ')')
    src = src:gsub('InputIndicator%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'InputIndicator = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('Dialog%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'Dialog = Color3.fromRGB(' .. panel_bg_hex .. ')')
    src = src:gsub('DialogHolder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DialogHolder = Color3.fromRGB(' .. dark_bg_hex .. ')')
    src = src:gsub('DialogButton%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DialogButton = Color3.fromRGB(' .. item_bg_hex .. ')')
    src = src:gsub('DialogButtonBorder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DialogButtonBorder = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('DialogBorder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DialogBorder = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('DialogInput%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DialogInput = Color3.fromRGB(' .. item_bg_hex .. ')')
    src = src:gsub('DialogInputLine%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'DialogInputLine = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('AcrylicMain%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'AcrylicMain = Color3.fromRGB(' .. dark_bg_hex .. ')')
    src = src:gsub('AcrylicBorder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'AcrylicBorder = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('AcrylicGradient%s*=%s*ColorSequence%.new%(%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%),%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)%s*%)', 'AcrylicGradient = ColorSequence.new(Color3.fromRGB(' .. orange_hex .. '), Color3.fromRGB(200, 105, 0))')
    src = src:gsub('ElementBorder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'ElementBorder = Color3.fromRGB(200, 105, 0)')
    src = src:gsub('InElementBorder%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'InElementBorder = Color3.fromRGB(' .. orange_hex .. ')')
    src = src:gsub('TitleBarLine%s*=%s*Color3%.fromRGB%s*%(%d+,%s*%d+,%s*%d+%)', 'TitleBarLine = Color3.fromRGB(200, 105, 0)')

    Fluent = loadstring(src)()
end)
if not Fluent then
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end

local Window = Fluent:CreateWindow({
    Title = "417",
    SubTitle = "",
    TabWidth = 100,
    Size = UDim2.fromOffset(440, 315),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = nil,
})
_G._417_window = Window

local Close417Gui = Instance.new("ScreenGui")
Close417Gui.Name = "417_close"
Close417Gui.ResetOnSpawn = false
Close417Gui.IgnoreGuiInset = true
Close417Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local coreGui417 = game:FindFirstChild("CoreGui")
if coreGui417 then pcall(function() Close417Gui.Parent = coreGui417 end) end
if not Close417Gui.Parent then Close417Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local toggleui = Instance.new("TextButton")
toggleui.Name = "toggleui"
toggleui.Position = UDim2.new(0, 20, 1, -20)
toggleui.Size = UDim2.new(0, 50, 0, 50)
toggleui.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
toggleui.BackgroundTransparency = 0.15
toggleui.BorderSizePixel = 0
toggleui.AnchorPoint = Vector2.new(0, 1)
toggleui.Text = ""
toggleui.AutoButtonColor = false
toggleui.Parent = Close417Gui
Instance.new("UICorner", toggleui).CornerRadius = UDim.new(0, 10)

local UIStroke2 = Instance.new("UIStroke", toggleui)
UIStroke2.Name = "OrangeOutline"
UIStroke2.Color = Color3.fromRGB(255, 140, 0)
UIStroke2.Thickness = 2.5
UIStroke2.Transparency = 0
UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke2.LineJoinMode = Enum.LineJoinMode.Round

local toggleuititle = Instance.new("TextLabel", toggleui)
toggleuititle.Size = UDim2.new(1, 0, 1, 0)
toggleuititle.AnchorPoint = Vector2.new(0.5, 0.5)
toggleuititle.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleuititle.BackgroundTransparency = 1
toggleuititle.Text = "417"
toggleuititle.TextColor3 = Color3.fromRGB(255, 140, 0)
toggleuititle.TextSize = 20
toggleuititle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)

toggleui.MouseEnter:Connect(function() TweenService:Create(UIStroke2, TweenInfo.new(0.2), {Thickness = 3.5}):Play() end)
toggleui.MouseLeave:Connect(function() TweenService:Create(UIStroke2, TweenInfo.new(0.2), {Thickness = 2.5}):Play() end)

local dragging417, dragInput417, dragStart417, startPos417 = false, nil, nil, nil
local didDrag417 = false
toggleui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging417 = true
        didDrag417 = false
        dragStart417 = input.Position
        startPos417 = toggleui.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging417 = false end
        end)
    end
end)
toggleui.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput417 = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput417 and dragging417 then
        local delta = input.Position - dragStart417
        if delta.Magnitude > 10 then didDrag417 = true end
        toggleui.Position = UDim2.new(
            startPos417.X.Scale, startPos417.X.Offset + delta.X,
            startPos417.Y.Scale, startPos417.Y.Offset + delta.Y
        )
    end
end)
toggleui.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if not didDrag417 then Window:Minimize() end
    end
end)

local MainTab = Window:AddTab({ Title = "main", Icon = "shield" })
local VisualsTab = Window:AddTab({ Title = "visuals", Icon = "eye" })
local OptimTab = Window:AddTab({ Title = "optim", Icon = "cpu" })

local SwordAPI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SwordAPI")
local skinChangerEnabled = false
local skinChangerModel = ""
local Achaotic_SwordAPI = SwordAPI
pcall(function()
    local old = (getthreadidentity and getthreadidentity()) or 2
    if setthreadidentity then pcall(setthreadidentity, 2) end
    Achaotic_SwordAPI = require(ReplicatedStorage.Shared.SwordAPI)
    if setthreadidentity then pcall(setthreadidentity, old) end
end)
local Achaotic_SwordInstances
pcall(function()
    local old = (getthreadidentity and getthreadidentity()) or 2
    if setthreadidentity then pcall(setthreadidentity, 2) end
    Achaotic_SwordInstances = require(ReplicatedStorage.Shared.ReplicatedInstances.Swords)
    if setthreadidentity then pcall(setthreadidentity, old) end
end)
local AnimationController
pcall(function()
    local old = (getthreadidentity and getthreadidentity()) or 2
    if setthreadidentity then pcall(setthreadidentity, 2) end
    AnimationController = require(ReplicatedStorage.Controllers.AnimationController)
    if setthreadidentity then pcall(setthreadidentity, old) end
end)
local ReplionDATA
pcall(function()
    local old = (getthreadidentity and getthreadidentity()) or 2
    if setthreadidentity then pcall(setthreadidentity, 2) end
    local Replion = require(ReplicatedStorage.Packages.Replion)
    ReplionDATA = Replion.Client:WaitReplion("Data")
    if setthreadidentity then pcall(setthreadidentity, old) end
end)

local AnimationFixService = { Cache = {} }
local function GetParryCD() return 0 end
local function StopAnimation(animationtrack)
    local StopFadeTime = animationtrack:GetAttribute("StopFadeTime")
    animationtrack:Stop(StopFadeTime)
end

local function PlayGrabAnimation(animationtrack)
    local timesParried = ReplionDATA and ReplionDATA:Get("timesParried") or 0
    local IsVaild = (timesParried and timesParried >= 0 and timesParried <= 4) and true or false
    local PlayFadeTime = IsVaild and 0.05 or animationtrack:GetAttribute("PlayFadeTime")
    local PlayWeight = IsVaild and 1 or animationtrack:GetAttribute("PlayWeight")
    local PlaySpeed = IsVaild and (timesParried / 5 + 1) or animationtrack:GetAttribute("PlaySpeed")
    animationtrack:Play(PlayFadeTime, PlayWeight, PlaySpeed)
end

local function GetParryAnimation(swordName)
    local character = LocalPlayer.Character
    if not character then return nil end
    local cacheKey = swordName or ""
    if AnimationFixService.Cache[cacheKey] then return AnimationFixService.Cache[cacheKey] end
    local animationType = "Default"
    local swordType = "Single"
    if swordName and swordName ~= "" and Achaotic_SwordInstances then
        local ok, swordData = pcall(function() return Achaotic_SwordInstances:GetSword(swordName) end)
        if ok and swordData and type(swordData) == "table" then
            animationType = swordData.AnimationType or animationType
            swordType = swordData.SwordType or swordType
        end
    end
    local animation
    if Achaotic_SwordAPI and type(Achaotic_SwordAPI.GetAnimations) == "function" then
        local ok, animations = pcall(function()
            return Achaotic_SwordAPI:GetAnimations(character, {"Parry", "GrabParry"}, animationType, swordType)
        end)
        if ok and type(animations) == "table" then
            for _, anim in pairs(animations) do
                if typeof(anim) == "Instance" then animation = anim break end
            end
        end
    end
    if not animation then
        local defaultCollection = SwordAPI.Collection.Default
        animation = defaultCollection and (defaultCollection:FindFirstChild("GrabParry") or defaultCollection:FindFirstChild("Grab"))
    end
    AnimationFixService.Cache[cacheKey] = animation
    return animation
end

local ParryLocked = false
local ParryCooldownActive = false
local ParryProcessing = false
local ParryM1Stop = false

local function PlayParry_Animation()
    if not config.animfix then return end
    if isInLobby() then return end
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator")
    if not animator then return end
    local currentSword = nil
    if skinChangerEnabled and skinChangerModel ~= "" then
        currentSword = skinChangerModel
    else
        local character = LocalPlayer.Character
        if not character then return end
        currentSword = character:GetAttribute("CurrentlyEquippedSword")
    end
    local animation = GetParryAnimation(currentSword)
    if not animation then
        animation = SwordAPI.Collection.Default:FindFirstChild("GrabParry")
        if not animation then return end
    end
    if AnimationController then
        for _, track in pairs(AnimationController:GetPlayingAnimationTracks(animator)) do
            if track:GetAttribute("SuccessParry") then pcall(StopAnimation, track) end
        end
        local ok, GrabParry = pcall(function() return AnimationController:LoadAnimation(animator, animation, true) end)
        if ok and GrabParry then PlayGrabAnimation(GrabParry) end
    else
        local track = animator:LoadAnimation(animation)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play(0, 1, 1)
    end
end

local function SpamParry_Animation()
    if not config.animfix then return end
    if isInLobby() then return end
    if ParryProcessing or ParryCooldownActive or ParryM1Stop then return end
    ParryProcessing = true
    ParryCooldownActive = true
    PlayParry_Animation()
    local ParryCD = GetParryCD()
    task.delay(ParryCD, function()
        ParryCooldownActive = false
        task.wait(math.max(0.1, 0.3 - ParryCD))
        if not ParryLocked then ParryProcessing = false end
    end)
end

pcall(function()
    local m1StopRemote = ReplicatedStorage.Remotes:FindFirstChild("M1Stop")
    if m1StopRemote then
        m1StopRemote.Event:Connect(function(value) ParryM1Stop = value end)
    end
end)

pcall(function()
    ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
        if not config.animfix then return end
        ParryProcessing = false
        ParryCooldownActive = false
        task.spawn(function()
            ParryLocked = true
            task.wait(0.3)
            ParryLocked = false
        end)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator")
        if not animator then return end
        if AnimationController then
            for _, track in pairs(AnimationController:GetPlayingAnimationTracks(animator)) do
                if track:GetAttribute("GrabParry") then pcall(StopAnimation, track) end
            end
        end
    end)
end)

local SwordChanger = {
    enabled = false,
    swordName = "",
    originalSword = nil,
    swordsController = nil,
    hookedParryAll = false,
    connRespawn = nil,
}

task.spawn(function()
    while task.wait(0.25) and not SwordChanger.swordsController do
        local ok, conns = pcall(getconnections, ReplicatedStorage.Remotes.FireSwordInfo.OnClientEvent)
        if ok and conns then
            for _, v in ipairs(conns) do
                if v.Function and islclosure and islclosure(v.Function) then
                    local ok2, up = pcall(getupvalues, v.Function)
                    if ok2 and #up == 1 and type(up[1]) == "table" then
                        SwordChanger.swordsController = up[1]
                        break
                    end
                end
            end
        end
    end
end)

local function SetupSwordParryHook()
    if SwordChanger.hookedParryAll then return end
    if not getconnections then return end
    SwordChanger.hookedParryAll = true
    local conns = getconnections(ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent)
    if not conns or #conns == 0 then return end
    local originals = {}
    for _, conn in ipairs(conns) do
        if conn.Function then
            table.insert(originals, conn.Function)
            conn:Disable()
            conn:Disconnect()
        end
    end
    if #originals == 0 then return end
    ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(...)
        local v = { ... }
        if SwordChanger.enabled and SwordChanger.swordName ~= "" and tostring(v[4]) == LocalPlayer.Name and Achaotic_SwordInstances then
            local ok, sw = pcall(function() return Achaotic_SwordInstances:GetSword(SwordChanger.swordName) end)
            if ok and sw and sw.SlashName then
                v[1] = sw.SlashName
                v[3] = sw.Name
            end
        end
        for _, fn in ipairs(originals) do pcall(fn, table.unpack(v)) end
    end)
end
SetupSwordParryHook()

local function EquipSword(swordName)
    if type(swordName) ~= "string" or swordName == "" then return end
    local char = LocalPlayer.Character
    if not char then return end
    pcall(function()
        if Achaotic_SwordInstances and rawget and getupvalues and setupvalue then
            local f = rawget(Achaotic_SwordInstances, "EquipSwordTo")
            if type(f) == "function" then
                local ups = getupvalues(f)
                for i = 1, #ups do
                    if type(ups[i]) == "boolean" then
                        setupvalue(f, i, false)
                        break
                    end
                end
            end
        end
    end)
    pcall(function()
        if Achaotic_SwordInstances then Achaotic_SwordInstances:EquipSwordTo(char, swordName) end
    end)
    pcall(function()
        local rem = ReplicatedStorage.Remotes:FindFirstChild("FireSwordInfo")
        if rem then rem:FireServer(swordName) end
    end)
    if SwordChanger.swordsController then
        pcall(function()
            if SwordChanger.swordsController.SetSword then SwordChanger.swordsController:SetSword(swordName) end
            SwordChanger.swordsController.currentSword = swordName
            SwordChanger.swordsController.SwordFX = swordName
        end)
    end
    pcall(function() char:SetAttribute("CurrentlyEquippedSword", swordName) end)
    SwordChanger.swordName = swordName
end

local function EnableSwordChanger(name)
    if type(name) ~= "string" or name == "" then return end
    if not SwordChanger.enabled then
        local char = LocalPlayer.Character
        if char then
            SwordChanger.originalSword = char:GetAttribute("CurrentlyEquippedSword")
        end
    end
    SwordChanger.enabled = true
    SwordChanger.swordName = name
    EquipSword(name)
    if SwordChanger.connRespawn then SwordChanger.connRespawn:Disconnect() end
    SwordChanger.connRespawn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if SwordChanger.enabled and SwordChanger.swordName ~= "" then
            EquipSword(SwordChanger.swordName)
        end
    end)
end

local function DisableSwordChanger()
    local wasEnabled = SwordChanger.enabled
    local restore = SwordChanger.originalSword
    SwordChanger.enabled = false
    if SwordChanger.connRespawn then
        SwordChanger.connRespawn:Disconnect()
        SwordChanger.connRespawn = nil
    end
    if wasEnabled and restore and restore ~= "" then
        task.spawn(function()
            task.wait(0.1)
            EquipSword(restore)
            SwordChanger.swordName = ""
        end)
    else
        SwordChanger.swordName = ""
    end
    SwordChanger.originalSword = nil
end

local PlayerCosmeticsCleanup = {}

local function SaveOriginalMeshes(char)
    local rightLeg = char:FindFirstChild("RightLeg") or char:FindFirstChild("Right Leg")
    if not rightLeg then return end
    if not PlayerCosmeticsCleanup[char] then PlayerCosmeticsCleanup[char] = {} end
    if not PlayerCosmeticsCleanup[char].rightLegChildren then
        PlayerCosmeticsCleanup[char].rightLegChildren = {}
        for _, child in ipairs(rightLeg:GetChildren()) do
            if child:IsA("SpecialMesh") then
                table.insert(PlayerCosmeticsCleanup[char].rightLegChildren, {
                    MeshId = child.MeshId,
                    TextureId = child.TextureId,
                    Scale = child.Scale,
                })
            end
        end
    end
end

local function ApplyKorbloxMesh(char)
    local rightLeg = char:FindFirstChild("RightLeg") or char:FindFirstChild("Right Leg")
    if not rightLeg then return end
    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") then child:Destroy() end
    end
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshId = "rbxassetid://101851696"
    mesh.TextureId = "rbxassetid://115727863"
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = rightLeg
end

local function RestoreOriginalMeshes(char)
    local rightLeg = char:FindFirstChild("RightLeg") or char:FindFirstChild("Right Leg")
    if not rightLeg then return end
    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") then child:Destroy() end
    end
    if PlayerCosmeticsCleanup[char] and PlayerCosmeticsCleanup[char].rightLegChildren then
        for _, data in ipairs(PlayerCosmeticsCleanup[char].rightLegChildren) do
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshId = data.MeshId
            mesh.TextureId = data.TextureId
            mesh.Scale = data.Scale
            mesh.Parent = rightLeg
        end
    end
end

local function ApplyHeadlessMesh(char)
    local head = char:FindFirstChild("Head")
    if not head then return end
    head.Transparency = 1
    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("Decal") then child.Transparency = 1 end
    end
end

local function RestoreHead(char)
    local head = char:FindFirstChild("Head")
    if not head then return end
    head.Transparency = 0
    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("Decal") then child.Transparency = 0 end
    end
end

local function UpdateKorbloxHeadless(char)
    if not char then return end
    SaveOriginalMeshes(char)
    if config.optim.korblox then ApplyKorbloxMesh(char) else RestoreOriginalMeshes(char) end
    if config.optim.headless then ApplyHeadlessMesh(char) else RestoreHead(char) end
end

if LocalPlayer.Character then UpdateKorbloxHeadless(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(newChar)
    for oldChar in pairs(PlayerCosmeticsCleanup) do
        if oldChar ~= newChar then PlayerCosmeticsCleanup[oldChar] = nil end
    end
    task.delay(0.6, function() UpdateKorbloxHeadless(newChar) end)
    newChar.Destroying:Connect(function() PlayerCosmeticsCleanup[newChar] = nil end)
end)

local Ignored_VFX = {
    "BallEmit","Upgrade","Arch2","MaxHook","Wave","Totem","TotemRange",
    "InfinityFX","maxTransmission","transmissionpart","Tornado","Barrier",
    "GUARDIAN_DRAGON","DRAGON_POSITIONER","SpiritDeflect","Vanity",
    "Platform","Swap","MaxBlink",
}
local Ignored_VFX_Set = {}
for _, name in ipairs(Ignored_VFX) do Ignored_VFX_Set[name] = true end

local noRenderConn = nil
local function StartNoRender()
    if noRenderConn then return end
    pcall(function() LocalPlayer.PlayerScripts.EffectScripts.ClientFX.Disabled = true end)
    if RuntimeFolder then
        noRenderConn = RuntimeFolder.ChildAdded:Connect(function(child)
            if not config.optim.noRender then return end
            if child.Name:find("PortalFor_") or child.Name:find("WaypointFor_") then return end
            if Ignored_VFX_Set[child.Name] then return end
            pcall(function() Debris:AddItem(child, 0) end)
        end)
    end
end

local function StopNoRender()
    if noRenderConn then noRenderConn:Disconnect() noRenderConn = nil end
    pcall(function() LocalPlayer.PlayerScripts.EffectScripts.ClientFX.Disabled = false end)
end

local ORANGE = Color3.fromRGB(255, 140, 0)
local DARK_GREY = Color3.fromRGB(30, 30, 30)
local WHITE = Color3.fromRGB(255, 255, 255)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "417_spam_btn"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local coreGui = game:FindFirstChild("CoreGui")
if coreGui then pcall(function() ScreenGui.Parent = coreGui end) end
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local FIXED_MAIN_POS = UDim2.new(0.5, -160, 0.15, 0)
local draggableState = setmetatable({}, { __mode = "k" })

local function MakeDraggable(frame, onDrag)
    local state = { dragging = false, target = nil, dragInput = nil, dragStart = nil, startPos = nil, onDrag = onDrag }
    draggableState[frame] = state
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state.dragging = true
            state.dragStart = input.Position
            state.startPos = frame.Position
            state.target = state.startPos
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then state.dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            state.dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == state.dragInput and state.dragging then
            local d = input.Position - state.dragStart
            state.target = UDim2.new(
                state.startPos.X.Scale, state.startPos.X.Offset + d.X,
                state.startPos.Y.Scale, state.startPos.Y.Offset + d.Y
            )
        end
    end)
end

RunService.RenderStepped:Connect(function(dt)
    if next(draggableState) == nil then return end
    for frame, state in pairs(draggableState) do
        if not state.target then continue end
        local c = frame.Position
        local a = math.clamp(dt * 25, 0, 1)
        local nx = c.X.Offset + (state.target.X.Offset - c.X.Offset) * a
        local ny = c.Y.Offset + (state.target.Y.Offset - c.Y.Offset) * a
        local settledX = math.abs(nx - state.target.X.Offset) < 0.5
        local settledY = math.abs(ny - state.target.Y.Offset) < 0.5
        if settledX then nx = state.target.X.Offset end
        if settledY then ny = state.target.Y.Offset end
        frame.Position = UDim2.new(state.target.X.Scale, nx, state.target.Y.Scale, ny)
        if state.onDrag then state.onDrag(frame.Position) end
        if settledX and settledY then state.target = nil end
    end
end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 130, 0, 60)
MainFrame.Position = FIXED_MAIN_POS
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = ORANGE
MakeDraggable(MainFrame, nil)
MainFrame.Visible = config.show_spam or false

local function CreateStyledButton(parent, text)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -20, 1, -20)
    Btn.Position = UDim2.new(0, 10, 0, 10)
    Btn.BackgroundColor3 = DARK_GREY
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", Btn)
    st.Color = ORANGE
    st.Transparency = 0.5
    st.Thickness = 1
    local l = Instance.new("TextLabel", Btn)
    l.Size = UDim2.new(1, -20, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = ORANGE
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    Btn.MouseEnter:Connect(function() TweenService:Create(st, TweenInfo.new(0.25), {Transparency = 0.1}):Play() end)
    Btn.MouseLeave:Connect(function() TweenService:Create(st, TweenInfo.new(0.25), {Transparency = 0.5}):Play() end)
    return Btn, l, st
end

local function SetButtonActive(active, btn, label, stroke)
    if active then
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = ORANGE}):Play()
        TweenService:Create(label, TweenInfo.new(0.3), {TextColor3 = WHITE}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    else
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = DARK_GREY}):Play()
        TweenService:Create(label, TweenInfo.new(0.3), {TextColor3 = ORANGE}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
    end
end

local StatusBtn, StatusLabel, StatusStroke = CreateStyledButton(MainFrame, "SPAM")
local spamActive = false
local SpamAcc = 0

local function ToggleSpam()
    spamActive = not spamActive
    config.manual_spam = spamActive
    SetButtonActive(spamActive, StatusBtn, StatusLabel, StatusStroke)
    SpamAcc = 0
    pcall(SaveConfig)
end

local ballStats = { current = 0, peak = 0 }

local function GetBallSpeed()
    local maxSpeed = 0
    local function checkContainer(c)
        if not c then return end
        for _, v in pairs(c:GetChildren()) do
            if v:GetAttribute("realBall") then
                local z = v:FindFirstChild("zoomies")
                if z and z.VectorVelocity.Magnitude > maxSpeed then
                    maxSpeed = z.VectorVelocity.Magnitude
                end
            end
        end
    end
    checkContainer(workspace:FindFirstChild("Balls"))
    checkContainer(workspace:FindFirstChild("TrainingBalls"))
    return maxSpeed
end

local SpeedGui = Instance.new("ScreenGui")
SpeedGui.Name = "417_ball_speed"
SpeedGui.ResetOnSpawn = false
SpeedGui.IgnoreGuiInset = true
SpeedGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local coreGuiSpeed = game:FindFirstChild("CoreGui")
if coreGuiSpeed then pcall(function() SpeedGui.Parent = coreGuiSpeed end) end
if not SpeedGui.Parent then SpeedGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local FIXED_SPEED_POS = UDim2.new(0.5, -100, 0.05, 0)
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(0, 200, 0, 24)
SpeedFrame.Position = FIXED_SPEED_POS
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Parent = SpeedGui
SpeedFrame.Visible = config.show_ball_speed or false

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "0 (0)"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedLabel.Font = Enum.Font.GothamBlack
SpeedLabel.TextSize = 18
SpeedLabel.Parent = SpeedFrame
MakeDraggable(SpeedFrame, nil)

local lastBallId = nil
task.spawn(function()
    while true do
        local newId = nil
        local function scan(c)
            if not c or newId then return end
            for _, v in pairs(c:GetChildren()) do
                if v:GetAttribute("realBall") then newId = v:GetDebugId(); return end
            end
        end
        scan(workspace:FindFirstChild("Balls"))
        if not newId then scan(workspace:FindFirstChild("TrainingBalls")) end
        if newId and newId ~= lastBallId then ballStats.peak = 0; lastBallId = newId end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if SpeedFrame.Visible then
            local speed = GetBallSpeed()
            ballStats.current = math.floor(speed + 0.5)
            if speed > ballStats.peak then ballStats.peak = math.floor(speed + 0.5) end
            SpeedLabel.Text = string.format("%d (%d)", ballStats.current, ballStats.peak)
        end
        task.wait(0.05)
    end
end)

local Connections = {}
local BallHelper = {
    ball = {
        properties = {
            aerodynamic_time = tick(),
            last_warping = tick(),
            lerp_radians = 0,
            curving = tick(),
        },
    },
}
local CurrentTarget
local Is_Curved_Data = setmetatable({}, { __mode = "k" })
local Ball_Zoomies_Cache = setmetatable({}, { __mode = "k" })
local Tracked_Ball, Real_Ball_Position

pcall(function()
    local net = require(ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net)
    for _, child in net:GetChildren() do
        if child:IsA("UnreliableRemoteEvent") and child.Name ~= "URE/ReplicateBallPosition" then
            child.OnClientEvent:Connect(function(ball, pos)
                if not ball or not ball.Parent then
                    if ball == Tracked_Ball then Tracked_Ball, Real_Ball_Position = nil, nil end
                    return
                end
                Tracked_Ball, Real_Ball_Position = ball, pos
            end)
        end
    end
end)

local sendParry
do
    local ok, result = pcall(function()
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local serverInfo = require(ReplicatedStorage.ServerInfo)
        local universeIds = require(ReplicatedStorage.Shared.UniverseIds)
        local noobParry = not serverInfo.isDungeonsMatchServer()
            and game.PlaceId ~= universeIds.RankedMatches.PlaceId
            and game.PlaceId ~= universeIds.RankedMatchesNoAbility.PlaceId
            and not serverInfo.isMedalServer()
            and not serverInfo.isClanWarServer()
            and not serverInfo.isTournamentMatchServer()
            and require(ReplicatedStorage.Common.Utils).FFlag.GetInstantFFlag("NoobParryEnabled", true)
        local Controllers = ReplicatedStorage:FindFirstChild("Controllers")
        if not Controllers then error("no Controllers") end
        local SwordsCtrl
        for _, c in Controllers:GetChildren() do
            if c.Name:find("SwordsController") then SwordsCtrl = c; break end
        end
        if not SwordsCtrl then error("no SwordsController folder") end
        local PRY = SwordsCtrl:FindFirstChild("PRY")
        if not PRY then error("no PRY") end
        local parryFunction = require(PRY)
        local encoder = debug.getupvalue(parryFunction, 4)
        local hash = debug.getupvalue(parryFunction, 8)
        if type(encoder) ~= "function" or hash == nil then error("bad PRY upvalues") end
        local SignalLib
        local pk = ReplicatedStorage:FindFirstChild("Packages")
        if pk then
            local direct = pk:FindFirstChild("Signal")
            if direct then
                local okS, lib = pcall(require, direct)
                if okS then SignalLib = lib end
            end
            if not SignalLib then
                local idx = pk:FindFirstChild("_Index")
                if idx then
                    for _, c in idx:GetChildren() do
                        if c.Name:find("Signal") then
                            local okS, lib = pcall(require, c)
                            if okS then SignalLib = lib; break end
                        end
                    end
                end
            end
        end
        if not SignalLib then error("no Signal lib") end
        local remote, key, timeKey
        local timeHash = {}
        local durations = {1.5, 1.25, 1, 0.75, 0.625}
        local signal = SignalLib.new()
        signal:Connect(parryFunction)
        local function capture(event, eventHash, eventKey, proof, duration, direction, targets, aim, flag)
            if eventHash == hash and type(eventKey) == "string" and type(proof) == "string"
                and type(duration) == "number" and typeof(direction) == "CFrame"
                and type(targets) == "table" and type(aim) == "table" and type(flag) == "boolean" then
                remote, key = event, eventKey
            end
        end
        local fireServer
        fireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(event, ...)
            local caller = (not checkcaller) or (function()
                local ok, r = pcall(checkcaller); return ok and r
            end)()
            if not remote and not caller then capture(event, ...) end
            return fireServer(event, ...)
        end))
        local pd = Replion.Client:WaitReplion("Data")
        return function(direction, targets, aim)
            local tp = pd and pd:Get("timesParried") or 0
            local duration = durations[tp + 1] or 0.5
            if noobParry then
                local kills = pd:Get("TotalStats.Kills") or 0
                duration = kills < 20 and duration * kills / 20 or duration
            end
            if not key then signal:Fire(duration, direction, targets, aim, false) return true end
            timeKey = timeKey or encoder(key, "TIME")
            if type(timeKey) ~= "string" or #timeKey == 0 then return false end
            local stamp = tostring(math.floor(workspace:GetServerTimeNow() * 100))
            table.clear(timeHash)
            for i = 1, #stamp do
                timeHash[i] = string.char(bit32.bxor(
                    (string.byte(stamp, i) + i) % 256,
                    string.byte(timeKey, (i - 1) % #timeKey + 1)
                ))
            end
            fireServer(remote, hash, key, table.concat(timeHash), duration, direction, targets, aim, false)
            return true
        end
    end)
    if ok and result then
        sendParry = result
        print("[417] ByteLatest remote pipeline OK")
    end
end

if not sendParry then
    print("[417] ByteLatest failed, using Angeli fallback")
    local replicated_storage = ReplicatedStorage
    local _token
    if getgc and debug and debug.info and debug.getupvalues then
        for _, fn in getgc(true) do
            if type(fn) ~= "function" then continue end
            local okI, info = pcall(debug.info, fn, "s")
            if not okI or not info or not info:find("PRY", 1, true) then continue end
            for _, v in debug.getupvalues(fn) do
                if type(v) == "function" then _token = v; break end
            end
            if _token then break end
        end
    end
    local function _tokenize(uid)
        if type(_token) ~= "function" or type(uid) ~= "string" then return nil end
        local time = tostring(math.floor(workspace:GetServerTimeNow() * 100))
        local key = _token(uid, "TIME")
        if type(key) ~= "string" or #key == 0 then return nil end
        local chars = table.create(#time)
        for i = 1, #time do
            chars[i] = string.char(bit32.bxor(
                (string.byte(time, i) + i) % 256,
                string.byte(key, (i - 1) % #key + 1)
            ))
        end
        return table.concat(chars)
    end
    local _reverted, _original = {}, {}
    local function _is_valid(a)
        return #a == 8 and type(a[2]) == "string" and type(a[3]) == "string"
            and type(a[4]) == "number" and typeof(a[5]) == "CFrame"
            and type(a[6]) == "table" and type(a[7]) == "table" and type(a[8]) == "boolean"
    end
    local function _hook(remote)
        if _reverted[remote] then return end
        local meta = getrawmetatable(remote)
        if not meta or _original[meta] then return end
        _original[meta] = true
        setreadonly(meta, false)
        local oldIndex = meta.__index
        meta.__index = function(self, k)
            if (k == "FireServer" and self:IsA("RemoteEvent")) or (k == "InvokeServer" and self:IsA("RemoteFunction")) then
                return function(_, ...)
                    local a = {...}
                    if _is_valid(a) and not _reverted[self] then _reverted[self] = a end
                    return oldIndex(self, k)(_, table.unpack(a))
                end
            end
            return oldIndex(self, k)
        end
        setreadonly(meta, true)
    end
    if getrawmetatable and setreadonly then
        for _, rem in ipairs(replicated_storage:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then _hook(rem) end
        end
    end
    task.wait(1)
    local function getScrieieRemote()
        for rem, args in pairs(_reverted) do
            if rem and rem.Parent and rem:IsA("RemoteEvent") and type(args) == "table" then
                return rem, args
            end
        end
    end
    sendParry = function(direction, targets, aim)
        local rem, args = getScrieieRemote()
        if not rem or not args then return false end
        local token = _tokenize(args[2])
        if not token then return false end
        rem:FireServer(args[1], args[2], token, 0.5, direction, targets, aim, false)
        return true
    end
end

if not sendParry then
    sendParry = function() return false end
    warn("[417] no remote pipeline - parry disabled")
end

local function linear_predict(a, b, t)
    return a + (b - a) * t
end

function BallHelper.get_ball()
    for _, b in BallsFolder:GetChildren() do
        if b:GetAttribute("realBall") then return b end
    end
    local tb = GetTrainingBallsFolder()
    if tb then
        for _, b in tb:GetChildren() do
            if b:GetAttribute("realBall") then return b end
        end
    end
end

function BallHelper.get_balls()
    local list = {}
    for _, b in BallsFolder:GetChildren() do
        if b:GetAttribute("realBall") then table.insert(list, b) end
    end
    local tb = GetTrainingBallsFolder()
    if tb then
        for _, b in tb:GetChildren() do
            if b:GetAttribute("realBall") then table.insert(list, b) end
        end
    end
    return list
end

local function select_target_by_mouse()
    local living = {}
    for _, c in AliveFolder:GetChildren() do
        if c.Name ~= LocalPlayer.Name and c.PrimaryPart then table.insert(living, c) end
    end
    local cam = workspace.CurrentCamera
    local mp = UserInputService:GetMouseLocation()
    local ray = cam:ScreenPointToRay(mp.X, mp.Y)
    local best, bestDot = nil, -math.huge
    for _, c in living do
        local dot = ray.Direction:Dot((c.PrimaryPart.Position - cam.CFrame.Position).Unit)
        if dot > bestDot then bestDot = dot; best = c end
    end
    CurrentTarget = best
    return best
end

local function ApplyCurveToCFrame(base)
    local curveType = config.curve_method or "camera"
    if curveType == "camera" then return base end
    if curveType == "dot" then
        local char = LocalPlayer.Character
        local cp = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
        if not cp then return base end
        local nearest, bestD = nil, math.huge
        for _, e in ipairs(AliveFolder:GetChildren()) do
      
... (34 KB left)
