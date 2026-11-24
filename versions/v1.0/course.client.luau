local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local course = workspace:WaitForChild("SkyhopObby")
local coins = course:WaitForChild("Coins")
local totalCoins = course:GetAttribute("CoinCount") or 15
local stats = player:WaitForChild("leaderstats")
local coinCount = stats:WaitForChild("Coins")
local stageValue = stats:WaitForChild("Stage")
local gui = Instance.new("ScreenGui")
gui.Name = "SkyhopHUD"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function make(class, properties, parent)
    local item = Instance.new(class)
    for key, value in properties do item[key] = value end
    item.Parent = parent
    return item
end
local function rounded(item, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 14)}, item)
end
local function label(name, text, size, position, parent, color)
    local item = make("TextLabel", {Name=name, Text=text, Size=size, Position=position,
        BackgroundTransparency=1, TextColor3=color or Color3.fromRGB(245,248,255),
        Font=Enum.Font.GothamBold, TextScaled=true, TextWrapped=true}, parent)
    make("UITextSizeConstraint", {MinTextSize=10, MaxTextSize=22}, item)
    return item
end

local top = make("Frame", {Name="ProgressCard", AnchorPoint=Vector2.new(.5,0),
    Position=UDim2.new(.5,0,0,12), Size=UDim2.new(.88,0,0,98),
    BackgroundColor3=Color3.fromRGB(21,30,55), BackgroundTransparency=.06, BorderSizePixel=0}, gui)
make("UISizeConstraint", {MaxSize=Vector2.new(620,98)}, top)
rounded(top)
label("Title", "SKYHOP", UDim2.new(.26,0,0,28), UDim2.new(.03,0,0,10), top, Color3.fromRGB(102,242,212))
local stage = label("Stage", "1 / 3  RAINBOW STEPS", UDim2.new(.43,0,0,28), UDim2.new(.30,0,0,10), top)
local coinLabel = label("Coins", "0 / 15 COINS", UDim2.new(.23,0,0,28), UDim2.new(.74,0,0,10), top, Color3.fromRGB(255,218,77))
local status = label("Status", "Follow the coins. Green pads save your progress!", UDim2.new(.94,0,0,24), UDim2.new(.03,0,0,45), top)
status.Font = Enum.Font.Gotham
status:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize=16
local track = make("Frame", {Name="ProgressTrack", BackgroundColor3=Color3.fromRGB(51,62,90),
    BorderSizePixel=0, Position=UDim2.new(.03,0,1,-15), Size=UDim2.new(.94,0,0,5)}, top)
rounded(track, 3)
local fill = make("Frame", {Name="ProgressFill", BackgroundColor3=Color3.fromRGB(102,242,212),
    BorderSizePixel=0, Size=UDim2.new(0,0,1,0)}, track)
rounded(fill, 3)

local hint = label("Controls", "MOVE: WASD / ARROWS    JUMP: SPACE    |    Green = checkpoint    Red = lava",
    UDim2.new(.8,0,0,36), UDim2.new(.1,0,1,-48), gui)
hint.BackgroundColor3 = Color3.fromRGB(21,30,55)
hint.BackgroundTransparency = .12
hint.Font = Enum.Font.Gotham
rounded(hint, 10)
local UserInputService = game:GetService("UserInputService")
if UserInputService.TouchEnabled then hint.Text = "Use the thumbstick and jump button. Green pads save progress!" end

local win = make("Frame", {Name="FinishCard", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
    Size=UDim2.new(.82,0,0,260), BackgroundColor3=Color3.fromRGB(21,30,55), BorderSizePixel=0, Visible=false}, gui)
make("UISizeConstraint", {MaxSize=Vector2.new(440,260)}, win)
rounded(win,20)
label("Winner", "YOU DID IT!", UDim2.new(.9,0,0,46), UDim2.new(.05,0,0,20), win, Color3.fromRGB(255,218,77))
label("Completed", "ALL 3 STAGES COMPLETE", UDim2.new(.9,0,0,30), UDim2.new(.05,0,0,72), win)
local summary = label("Summary", "", UDim2.new(.9,0,0,56), UDim2.new(.05,0,0,112), win)
local again = make("TextButton", {Name="PlayAgain", Text="PLAY AGAIN", Font=Enum.Font.GothamBold, TextSize=20,
    TextColor3=Color3.fromRGB(15,35,42), BackgroundColor3=Color3.fromRGB(102,242,212), BorderSizePixel=0,
    Position=UDim2.new(.15,0,1,-66), Size=UDim2.new(.7,0,0,44)}, win)
rounded(again,12)
again.Activated:Connect(function() game.ReplicatedStorage.SkyhopRestart:FireServer() end)

local names = {"RAINBOW STEPS", "LAVA LANE", "SUMMIT SPRINT"}
local function update()
    local current = math.clamp(stageValue.Value,1,3)
    local finished = player:GetAttribute("SkyhopFinished") == true
    stage.Text = current .. " / 3  " .. names[current]
    coinLabel.Text = coinCount.Value .. " / " .. totalCoins .. " COINS"
    win.Visible = finished
    if finished then
        summary.Text = coinCount.Value .. " / " .. totalCoins .. " coins collected\nTime: " .. math.floor(player:GetAttribute("SkyhopElapsed") or 0) .. " seconds"
    end
end
coinCount.Changed:Connect(update)
stageValue.Changed:Connect(update)
player:GetAttributeChangedSignal("SkyhopFinished"):Connect(function()
    update()
    if not player:GetAttribute("SkyhopFinished") then return end
    -- Lightweight client-only confetti; no paid assets required.
    for i=1,45 do
        local piece = make("Frame", {Name="Confetti", BorderSizePixel=0, Size=UDim2.fromOffset(8,14),
            Position=UDim2.fromScale(math.random(),-.1), Rotation=math.random(360),
            BackgroundColor3=Color3.fromHSV(math.random(),.7,1), ZIndex=10}, gui)
        TweenService:Create(piece, TweenInfo.new(2+math.random()*2), {
            Position=UDim2.fromScale(math.random(),1.2), Rotation=math.random(-360,360)}):Play()
        task.delay(4.1,function() piece:Destroy() end)
    end
end)
player:GetAttributeChangedSignal("SkyhopMessageAt"):Connect(function()
    status.Text = player:GetAttribute("SkyhopMessage") or ""
end)

local coinBases = {}
local function setupCoin(coin)
    if coinBases[coin] then return end
    coinBases[coin] = coin.CFrame
    local function visibility()
        local hidden = player:GetAttribute(coin.Name) == true
        coin.LocalTransparencyModifier = hidden and 1 or 0
        for _, child in coin:GetDescendants() do
            if child:IsA("PointLight") or child:IsA("Sparkles") then child.Enabled = not hidden end
        end
    end
    player:GetAttributeChangedSignal(coin.Name):Connect(visibility)
    visibility()
end
coins.ChildAdded:Connect(setupCoin)
for _, coin in coins:GetChildren() do setupCoin(coin) end

local camera = workspace.CurrentCamera
local function faceForward(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    camera.CameraSubject = humanoid
    camera.CameraType = Enum.CameraType.Custom
    camera.CFrame = CFrame.lookAt(root.Position + Vector3.new(0,12,-22), root.Position + Vector3.new(0,1,8))
end
player.CharacterAdded:Connect(faceForward)
if player.Character then task.spawn(faceForward, player.Character) end

local clock = 0
RunService.RenderStepped:Connect(function(dt)
    clock += dt
    for coin, base in coinBases do
        if not player:GetAttribute(coin.Name) then
            coin.CFrame = base * CFrame.new(0,math.sin(clock*2.5)*.25,0) * CFrame.Angles(0,clock*1.8,0)
        end
    end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local progress = root and math.clamp(root.Position.Z / 282,0,1) or 0
    if player:GetAttribute("SkyhopFinished") then progress = 1 end
    fill.Size = UDim2.fromScale(progress,1)
end)
update()
print("[Skyhop] HUD and coin visuals ready")
