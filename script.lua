local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local THEME = {
    Background = Color3.fromRGB(15, 8, 22),
    Header = Color3.fromRGB(28, 14, 40),
    Card = Color3.fromRGB(30, 18, 41),
    CardHover = Color3.fromRGB(48, 26, 62),
    Text = Color3.fromRGB(255, 247, 239),
    Muted = Color3.fromRGB(204, 187, 214),
    Orange = Color3.fromRGB(255, 130, 20),
    OrangeGlow = Color3.fromRGB(255, 170, 60),
    Purple = Color3.fromRGB(150, 70, 220),
    Green = Color3.fromRGB(90, 255, 158),
    Border = Color3.fromRGB(255, 120, 0),
}

-- Destroy previous GUI if exists
local oldGui = PlayerGui:FindFirstChild("HalloweenHubSelector")
if oldGui then
    oldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "HalloweenHubSelector"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 50
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local function create(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 12)
    }, parent)
end

local function addStroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or THEME.Orange,
        Thickness = thickness or 1.5,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function tween(object, duration, properties, style)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(
            duration,
            style or Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )
    animation:Play()
    return animation
end

-- Main Window
local Main = create("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.88, 0, 0.72, 0),
    BackgroundColor3 = THEME.Background,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 1,
}, Gui)

create("UISizeConstraint", {
    MinSize = Vector2.new(290, 360),
    MaxSize = Vector2.new(380, 460),
}, Main)

corner(Main, 18)

-- Neon Orange Border for Main Frame
local MainStroke = addStroke(Main, THEME.Orange, 2, 0)

create("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 14, 45)),
        ColorSequenceKeypoint.new(0.5, THEME.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 10, 35)),
    }),
}, Main)

-- Header Frame
local Header = create("Frame", {
    Name = "Header",
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundColor3 = THEME.Header,
    BorderSizePixel = 0,
    ZIndex = 2,
}, Main)

corner(Header, 18) -- Smooth header top corners

create("UIGradient", {
    Rotation = 0,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 20, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 12, 38)),
    }),
}, Header)

-- Header Line Separator
local HeaderLine = create("Frame", {
    Position = UDim2.new(0, 10, 1, -3),
    Size = UDim2.new(1, -20, 0, 3),
    BackgroundColor3 = THEME.Orange,
    BorderSizePixel = 0,
    ZIndex = 3,
}, Header)

corner(HeaderLine, 4)

create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.Orange),
        ColorSequenceKeypoint.new(0.5, THEME.Purple),
        ColorSequenceKeypoint.new(1, THEME.Orange),
    }),
}, HeaderLine)

create("TextLabel", {
    Position = UDim2.new(0, 12, 0, 17),
    Size = UDim2.new(0, 43, 0, 43),
    BackgroundTransparency = 1,
    Text = "🎃",
    TextSize = 33,
    Font = Enum.Font.Gotham,
    ZIndex = 4,
}, Header)

create("TextLabel", {
    Position = UDim2.new(0, 59, 0, 18),
    Size = UDim2.new(1, -112, 0, 24),
    BackgroundTransparency = 1,
    Text = "HUB SELECTOR",
    TextColor3 = THEME.Text,
    Font = Enum.Font.GothamBlack,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
}, Header)

create("TextLabel", {
    Position = UDim2.new(0, 60, 0, 44),
    Size = UDim2.new(1, -100, 0, 16),
    BackgroundTransparency = 1,
    Text = "HALLOWEEN EDITION",
    TextColor3 = THEME.Orange,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
}, Header)

create("TextLabel", {
    Position = UDim2.new(1, -65, 0, 8),
    Size = UDim2.new(0, 25, 0, 23),
    BackgroundTransparency = 1,
    Text = "🦇",
    TextSize = 17,
    ZIndex = 4,
}, Header)

local Close = create("TextButton", {
    Position = UDim2.new(1, -35, 0, 12),
    Size = UDim2.new(0, 24, 0, 24),
    BackgroundColor3 = Color3.fromRGB(65, 25, 40),
    Text = "×",
    TextColor3 = THEME.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    AutoButtonColor = false,
    ZIndex = 5,
}, Header)

corner(Close, 8)
addStroke(Close, THEME.Orange, 1, 0.2)

create("TextLabel", {
    Position = UDim2.new(0, 17, 0, 88),
    Size = UDim2.new(1, -34, 0, 19),
    BackgroundTransparency = 1,
    Text = "CHOOSE YOUR EXPERIENCE",
    TextColor3 = THEME.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, Main)

create("TextLabel", {
    Position = UDim2.new(0, 17, 0, 108),
    Size = UDim2.new(1, -34, 0, 17),
    BackgroundTransparency = 1,
    Text = "Choose your hub for tonight",
    TextColor3 = THEME.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, Main)

local Scroll = create("ScrollingFrame", {
    Name = "HubList",
    Position = UDim2.new(0, 13, 0, 135),
    Size = UDim2.new(1, -26, 1, -191),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = THEME.Orange,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ZIndex = 3,
}, Main)

create("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, Scroll)

create("UIPadding", {
    PaddingTop = UDim.new(0, 3),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 3),
}, Scroll)

-- Bottom Status Bar
local StatusContainer = create("Frame", {
    Position = UDim2.new(0, 13, 1, -38),
    Size = UDim2.new(1, -26, 0, 26),
    BackgroundColor3 = Color3.fromRGB(22, 11, 32),
    BorderSizePixel = 0,
    ZIndex = 3,
}, Main)

corner(StatusContainer, 8)
addStroke(StatusContainer, THEME.Orange, 1, 0.6)

local Status = create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "●  SYSTEM READY  ●",
    TextColor3 = THEME.Green,
    Font = Enum.Font.Code,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 4,
}, StatusContainer)

-- Function to Create Hub Cards with Execute Logic
local function createHub(name, icon, accent, description, tag, executeFunc)
    local Card = create("Frame", {
        Name = name:gsub("%s+", "") .. "Card",
        Size = UDim2.new(1, -5, 0, 88),
        BackgroundColor3 = THEME.Card,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 3,
    }, Scroll)

    corner(Card, 12)  

    create("UIGradient", {  
        Rotation = 15,  
        Color = ColorSequence.new({  
            ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 25, 55)),  
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 14, 35)),  
        }),  
    }, Card)  

    local CardStroke = addStroke(Card, THEME.Orange, 1.2, 0.3)  

    -- Orange Accent Indicator Bar
    local AccentBar = create("Frame", {  
        Position = UDim2.new(0, 0, 0, 11),  
        Size = UDim2.new(0, 4, 1, -22),  
        BackgroundColor3 = accent,  
        BorderSizePixel = 0,  
        ZIndex = 4,  
    }, Card)  
    corner(AccentBar, 4)

    local IconBox = create("Frame", {  
        Position = UDim2.new(0, 12, 0.5, -23),  
        Size = UDim2.new(0, 46, 0, 46),  
        BackgroundColor3 = Color3.fromRGB(22, 12, 32),  
        BorderSizePixel = 0,  
        ZIndex = 4,  
    }, Card)  

    corner(IconBox, 10)  
    addStroke(IconBox, accent, 1.1, 0.2)  

    create("TextLabel", {  
        Size = UDim2.fromScale(1, 1),  
        BackgroundTransparency = 1,  
        Text = icon,  
        TextColor3 = accent,  
        Font = Enum.Font.GothamBold,  
        TextSize = 26,  
        ZIndex = 5,  
    }, IconBox)  

    create("TextLabel", {  
        Position = UDim2.new(0, 68, 0, 13),  
        Size = UDim2.new(1, -105, 0, 19),  
        BackgroundTransparency = 1,  
        Text = name,  
        TextColor3 = THEME.Text,  
        Font = Enum.Font.GothamBlack,  
        TextSize = 13,  
        TextXAlignment = Enum.TextXAlignment.Left,  
        ZIndex = 4,  
    }, Card)  

    create("TextLabel", {  
        Position = UDim2.new(0, 69, 0, 35),  
        Size = UDim2.new(1, -105, 0, 16),  
        BackgroundTransparency = 1,  
        Text = description,  
        TextColor3 = THEME.Muted,  
        Font = Enum.Font.Gotham,  
        TextSize = 9,  
        TextTruncate = Enum.TextTruncate.AtEnd,  
        TextXAlignment = Enum.TextXAlignment.Left,  
        ZIndex = 4,  
    }, Card)  

    local Tag = create("TextLabel", {  
        Position = UDim2.new(0, 68, 0, 58),  
        Size = UDim2.new(0, 145, 0, 19),  
        BackgroundColor3 = Color3.fromRGB(42, 22, 50),  
        Text = tag,  
        TextColor3 = accent,  
        Font = Enum.Font.GothamBold,  
        TextSize = 8,  
        TextTruncate = Enum.TextTruncate.AtEnd,  
        ZIndex = 4,  
    }, Card)  

    corner(Tag, 6)  
    addStroke(Tag, accent, 0.8, 0.4)  

    create("TextLabel", {  
        AnchorPoint = Vector2.new(1, 0.5),  
        Position = UDim2.new(1, -11, 0.5, 0),  
        Size = UDim2.new(0, 16, 0, 25),  
        BackgroundTransparency = 1,  
        Text = "›",  
        TextColor3 = accent,  
        Font = Enum.Font.GothamBold,  
        TextSize = 26,  
        ZIndex = 4,  
    }, Card)  

    local Button = create("TextButton", {  
        Size = UDim2.fromScale(1, 1),  
        BackgroundTransparency = 1,  
        Text = "",  
        AutoButtonColor = false,  
        ZIndex = 6,  
    }, Card)  

    Button.MouseEnter:Connect(function()  
        tween(Card, 0.18, {  
            BackgroundColor3 = THEME.CardHover,  
        })  
        tween(CardStroke, 0.18, {  
            Color = THEME.Orange,
            Transparency = 0,  
            Thickness = 1.8,  
        })  
    end)  

    Button.MouseLeave:Connect(function()  
        tween(Card, 0.18, {  
            BackgroundColor3 = THEME.Card,  
        })  
        tween(CardStroke, 0.18, {  
            Color = THEME.Orange,
            Transparency = 0.3,  
            Thickness = 1.2,  
        })  
    end)  

    Button.Activated:Connect(function()  
        Status.Text = "EXECUTING: " .. name  
        Status.TextColor3 = THEME.Orange  

        tween(CardStroke, 0.12, {  
            Thickness = 2.5,  
            Transparency = 0,  
        })  

        task.delay(0.2, function()  
            if Card.Parent then  
                tween(CardStroke, 0.18, {  
                    Thickness = 1.2,  
                    Transparency = 0.3,
                })  
            end  
        end)  

        print("Executing hub: " .. name)  
        
        -- Safe Execution Script
        task.spawn(function()
            local success, err = pcall(executeFunc)
            if success then
                Status.Text = "LOADED: " .. name
                Status.TextColor3 = THEME.Green
            else
                Status.Text = "ERROR LOADING HUB!"
                Status.TextColor3 = Color3.fromRGB(255, 80, 80)
                warn("Failed to load script:", err)
            end
        end)
    end)
end

-- Create Hubs with exact URLs provided
createHub(
    "INVIS HUB V1",
    "⚡",
    THEME.Orange,
    "Massive feature packed with rich utilities",
    "FEATURE RICH • BASIC PARRY",
    function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/foreverspacexc-blip/Test/refs/heads/main/INVISOnly.txt"))()
    end
)

createHub(
    "INVIS HUB V2",
    "🔥",
    THEME.Purple,
    "Optimized manual spam with balanced parry",
    "MANUAL SPAM • STABLE PARRY",
    function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/foreverspacexc-blip/INVISHUB/refs/heads/main/gui.txt"))()
    end
)

createHub(
    "ILLUSION HUB",
    "👁",
    THEME.Green,
    "Elite auto parry with essential blade ball tools",
    "GOD PARRY • ESSENTIALS",
    function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/foreverspacexc-blip/OTHERHUB/refs/heads/main/endless_hub.txt"))()
    end
)

createHub(
    "illusion v2",
    "👁",
    THEME.Green,
    "best free script ever",
    "PAID SCRIPT PARRY • Very Cool",
    function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/foreverspacexc-blip/Test/refs/heads/main/illusion_hub_v2.txt"))()
    end
)

-- Footer Separator Line
local FooterLine = create("Frame", {
    Position = UDim2.new(0, 17, 1, -48),
    Size = UDim2.new(1, -34, 0, 1),
    BackgroundColor3 = THEME.Orange,
    BorderSizePixel = 0,
    ZIndex = 3,
}, Main)

corner(FooterLine, 1)

create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.new(0, 28, 0, 22),
    BackgroundColor3 = THEME.Background,
    Text = "🎃",
    TextSize = 17,
    ZIndex = 4,
}, FooterLine)

-- Dragging Mechanics
local dragging = false
local dragStart
local startPosition
local dragInput

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true  
        dragStart = input.Position  
        startPosition = Main.Position  

        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then  
                dragging = false  
            end  
        end)  
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(  
            startPosition.X.Scale,  
            startPosition.X.Offset + delta.X,  
            startPosition.Y.Scale,  
            startPosition.Y.Offset + delta.Y  
        )  
    end
end)

-- Smooth Closing Logic
local closed = false

local function closeMenu()
    if closed then return end
    closed = true  

    tween(Main, 0.2, {  
        Position = Main.Position + UDim2.fromOffset(0, 10),  
        BackgroundTransparency = 1,  
    })  

    for _, obj in ipairs(Main:GetDescendants()) do  
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then  
            tween(obj, 0.15, {  
                TextTransparency = 1,  
            })  
        elseif obj:IsA("UIStroke") then  
            tween(obj, 0.15, {  
                Transparency = 1,  
            })  
        end  
    end  

    task.wait(0.23)  

    if Gui.Parent then  
        Gui:Destroy()  
    end
end

Close.Activated:Connect(closeMenu)

Close.MouseEnter:Connect(function()
    tween(Close, 0.12, {
        BackgroundColor3 = Color3.fromRGB(120, 30, 40),
        TextColor3 = THEME.Orange,
    })
end)

Close.MouseLeave:Connect(function()
    tween(Close, 0.12, {
        BackgroundColor3 = Color3.fromRGB(65, 25, 40),
        TextColor3 = THEME.Text,
    })
end)

-- Glowing Pulse Animation for Orange Main Border
task.spawn(function()
    local t = 0
    while Gui.Parent and not closed do  
        t += 0.03
        local alpha = (math.sin(t) + 1) / 2  
        MainStroke.Color = THEME.Orange:Lerp(THEME.OrangeGlow, alpha)  
        task.wait(0.03)  
    end
end)

-- Entrance Animation
Main.Position = UDim2.fromScale(0.5, 0.54)
tween(Main, 0.35, {
    Position = UDim2.fromScale(0.5, 0.5),
}, Enum.EasingStyle.Back)
