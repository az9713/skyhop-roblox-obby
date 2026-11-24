-- Run in Studio Edit mode. Existing baseplate and objects are preserved.
assert(not workspace:FindFirstChild("SkyhopObby"), "SkyhopObby already exists; inspect before rebuilding")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
ChangeHistoryService:SetWaypoint("Before Skyhop Obby")
local course = Instance.new("Model")
course.Name = "SkyhopObby"
course.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
course:SetAttribute("WalkSpeed",16)
course:SetAttribute("JumpHeight",8)
course:SetAttribute("StageCount",3)
course:SetAttribute("CoinCount",15)
course.Parent = workspace
local function folder(name)
    local f=Instance.new("Folder") f.Name=name f.Parent=course return f
end
local platforms, decor, hazards, checkpoints, coins = folder("Platforms"),folder("Scenery"),folder("Hazards"),folder("Checkpoints"),folder("Coins")
local function part(name,size,position,color,parent,material)
    local p=Instance.new("Part") p.Name=name p.Size=size p.Position=position p.Color=color
    p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
    p.Material=material or Enum.Material.SmoothPlastic p.Parent=parent or platforms return p
end
local white=Color3.fromRGB(245,249,255)
local navy=Color3.fromRGB(30,43,74)
local green=Color3.fromRGB(84,239,162)
local gold=Color3.fromRGB(255,212,63)
local rainbow={Color3.fromRGB(255,112,143),Color3.fromRGB(255,183,83),Color3.fromRGB(255,225,94),Color3.fromRGB(92,224,183),Color3.fromRGB(95,183,255)}
local function textSurface(p,text,face,color,textSize)
    local gui=Instance.new("SurfaceGui") gui.Face=face or Enum.NormalId.Front gui.CanvasSize=Vector2.new(900,300) gui.LightInfluence=0 gui.Parent=p
    local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1
    t.Text=text t.TextColor3=color or white t.Font=Enum.Font.GothamBold t.TextScaled=true t.TextWrapped=true t.Parent=gui
    local pad=Instance.new("UIPadding") pad.PaddingTop=UDim.new(.1,0) pad.PaddingBottom=UDim.new(.1,0)
    pad.PaddingLeft=UDim.new(.04,0) pad.PaddingRight=UDim.new(.04,0) pad.Parent=t
    return gui
end
local function board(name,text,pos,width,color)
    local p=part(name,Vector3.new(width or 24,5,.6),pos,color or navy,decor)
    textSurface(p,text)
    return p
end
local function deck(name,pos,size,color)
    local p=part(name,size,pos,color)
    part(name.."Trim",Vector3.new(size.X+.5,.35,size.Z+.5),pos-Vector3.new(0,size.Y/2-.15,0),white,decor)
    return p
end
local coinIndex=0
local function coin(position,stage)
    coinIndex+=1
    local c=part(string.format("SkyhopCoin%02d",coinIndex),Vector3.new(.6,2.6,2.6),position,gold,coins,Enum.Material.Neon)
    c.Shape=Enum.PartType.Cylinder c.CanCollide=false c.CastShadow=false
    c:SetAttribute("Stage",stage)
    local light=Instance.new("PointLight") light.Color=gold light.Range=5 light.Brightness=.6 light.Parent=c
end
local function checkpoint(index,z,y)
    local spawn=Instance.new("SpawnLocation") spawn.Name="Checkpoint"..index spawn.Size=Vector3.new(12,.5,8)
    spawn.Position=Vector3.new(0,y+1.3,z) spawn.Color=green spawn.Anchored=true spawn.Material=Enum.Material.Neon
    spawn.Neutral=true spawn.Duration=0 spawn.AllowTeamChangeOnTouch=false spawn:SetAttribute("Stage",index)
    spawn.Parent=checkpoints
    textSurface(spawn,index==1 and "START\nFOLLOW THE COINS" or "CHECKPOINT\nPROGRESS SAVED",Enum.NormalId.Top,navy)
    return spawn
end
local function gate(name,z,y,color,title)
    for _,x in {-13,13} do
        part(name.."Post",Vector3.new(1.2,12,1.2),Vector3.new(x,y+7,z),color,decor,Enum.Material.SmoothPlastic)
        local orb=part(name.."Orb",Vector3.new(2.1,2.1,2.1),Vector3.new(x,y+13.5,z),gold,decor,Enum.Material.Neon) orb.Shape=Enum.PartType.Ball orb.CanCollide=false
    end
    board(name.."Sign",title,Vector3.new(0,y+11,z),25,color)
end

-- Stage 1: wide, flat stepping stones with 2--4 stud gaps.
deck("StartIsland",Vector3.new(0,40,0),Vector3.new(30,2,24),Color3.fromRGB(98,210,166))
checkpoint(1,0,40)
gate("RainbowGate",8,40,Color3.fromRGB(72,151,230),"1  RAINBOW STEPS")
board("Welcome","WELCOME TO SKYHOP\n3 STAGES  /  15 COINS",Vector3.new(0,47,-11),27,navy)
board("JumpTip","SPACE = JUMP\nAim for the middle!",Vector3.new(-22,45,18),15,navy)
for i=1,5 do
    local z=22+(i-1)*14
    deck("RainbowStep"..i,Vector3.new(0,40,z),Vector3.new(12,2,12),rainbow[i])
    coin(Vector3.new(0,43.2,z),1)
end
task.wait()

-- Stage 2: a wide runway above lava. Short glowing bars teach timed jumps.
deck("LavaCheckpointIsland",Vector3.new(0,40,96),Vector3.new(30,2,20),Color3.fromRGB(255,167,87))
checkpoint(2,96,40)
gate("LavaGate",102,40,Color3.fromRGB(234,103,77),"2  LAVA LANE")
deck("LavaRunway",Vector3.new(0,40,132),Vector3.new(18,2,52),Color3.fromRGB(101,91,146))
local pool=part("LavaPool",Vector3.new(44,1,80),Vector3.new(0,31,134),Color3.fromRGB(255,83,35),hazards,Enum.Material.Neon)
for i=1,4 do
    part("LavaBar"..i,Vector3.new(18,.55,2.4),Vector3.new(0,41.3,114+(i-1)*12),Color3.fromRGB(255,70,47),hazards,Enum.Material.Neon)
end
for _,z in {109,121,133,145,166} do coin(Vector3.new(0,43.2,z),2) end
deck("LavaExitStep",Vector3.new(0,40,166),Vector3.new(12,2,12),Color3.fromRGB(255,192,102))
board("LavaTip","RED = LAVA\nJump over each red bar",Vector3.new(-24,46,113),19,navy)
for _,x in {-10.8,10.8} do
    part("RunwayGuide",Vector3.new(.45,1,52),Vector3.new(x,41,132),gold,decor)
end
task.wait()

-- Stage 3: gentle 2-stud rises and broad zig-zag landings.
deck("SummitCheckpointIsland",Vector3.new(0,40,184),Vector3.new(30,2,24),Color3.fromRGB(163,133,240))
checkpoint(3,184,40)
gate("SummitGate",190,40,Color3.fromRGB(143,102,222),"3  SUMMIT SPRINT")
local stepX={0,4,-2,4,0}
for i=1,5 do
    local pos=Vector3.new(stepX[i],40+i*2,204+(i-1)*14)
    deck("SummitStep"..i,pos,Vector3.new(14,2,14),Color3.fromRGB(167+i*12,140+i*12,246))
    coin(pos+Vector3.new(0,3.2,0),3)
end
board("SummitTip","SMALL STEPS, BIG FINISH\nYou can do this!",Vector3.new(-24,46,201),22,navy)

local finish=Instance.new("Folder") finish.Name="Finish" finish.Parent=course
deck("FinishIsland",Vector3.new(0,50,282),Vector3.new(32,2,28),Color3.fromRGB(99,221,189))
gate("FinishGate",282,50,Color3.fromRGB(47,168,155),"FINISH  /  YOU DID IT!")
for row=0,3 do for col=0,7 do
    local color=(row+col)%2==0 and white or navy
    local tile=part("FinishChecker",Vector3.new(3,.12,2),Vector3.new(-10.5+col*3,51.07,278+row*2),color,decor)
    tile.CanCollide=false
end end
local trigger=part("Trigger",Vector3.new(24,8,2),Vector3.new(0,55,282),green,finish)
trigger.Transparency=1 trigger.CanCollide=false
local pedestal=part("TrophyPedestal",Vector3.new(5,1.5,5),Vector3.new(0,51.75,291),navy,decor)
local stem=part("TrophyStem",Vector3.new(1,3,1),Vector3.new(0,54,291),gold,decor,Enum.Material.Metal)
local cup=part("Trophy",Vector3.new(4,4,4),Vector3.new(0,57,291),gold,decor,Enum.Material.Metal) cup.Shape=Enum.PartType.Ball
for _,x in {-2.3,2.3} do local handle=part("TrophyHandle",Vector3.new(1.5,2.5,1.5),Vector3.new(x,57,291),gold,decor,Enum.Material.Metal) handle.Shape=Enum.PartType.Ball end
task.wait()

-- Scenery is outside the jump route and does not collide with characters.
for i=1,16 do
    local z=(i-1)*20-10
    for _,side in {-1,1} do
        local cloud=part("Cloud",Vector3.new(25,8,16),Vector3.new(side*(27+(i%3)*6),22+(i%3)*2,z),white,decor)
        cloud.Shape=Enum.PartType.Ball cloud.CanCollide=false cloud.CanTouch=false
        if i%3==0 then
            local balloon=part("Balloon",Vector3.new(5,7,5),Vector3.new(side*33,58,z),rainbow[(i%5)+1],decor)
            balloon.Shape=Enum.PartType.Ball balloon.CanCollide=false balloon.CanTouch=false
            local rope=part("BalloonString",Vector3.new(.12,8,.12),Vector3.new(side*33,51,z),white,decor)
            rope.CanCollide=false rope.CanTouch=false
        end
    end
end
local kill=part("FallReset",Vector3.new(500,2,700),Vector3.new(0,12,140),Color3.new(1,0,0),hazards)
kill.Transparency=1 kill.CanCollide=false
local lighting=game:GetService("Lighting")
lighting.ClockTime=14 lighting.Brightness=2.5
lighting.Ambient=Color3.fromRGB(140,150,175)
lighting.OutdoorAmbient=Color3.fromRGB(165,175,200)
lighting.GlobalShadows=true
local baseplate=workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
    baseplate:SetAttribute("SkyhopOriginalTransparency",baseplate.Transparency)
    baseplate.Transparency=1
    for _, item in baseplate:GetDescendants() do
        if item:IsA("Texture") or item:IsA("Decal") then
            item:SetAttribute("SkyhopOriginalTransparency",item.Transparency)
            item.Transparency=1
        end
    end
end
local atmosphere=Instance.new("Atmosphere") atmosphere.Name="SkyhopAtmosphere"
atmosphere.Density=.18 atmosphere.Offset=.3 atmosphere.Color=Color3.fromRGB(203,232,255) atmosphere.Decay=Color3.fromRGB(155,190,230) atmosphere.Parent=lighting

-- Disable only old spawns so the first spawn is deterministic; keep the objects.
for _,spawn in workspace:GetDescendants() do
    if spawn:IsA("SpawnLocation") and not spawn:IsDescendantOf(course) then
        spawn:SetAttribute("SkyhopOriginalEnabled",spawn.Enabled)
        spawn.Enabled=false
    end
end
local remote=Instance.new("RemoteEvent") remote.Name="SkyhopRestart" remote.Parent=game:GetService("ReplicatedStorage")
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(110,150,5),Vector3.new(0,39,140))
game:GetService("Selection"):Set({course})
ChangeHistoryService:SetWaypoint("Built Skyhop Obby")
local server = Instance.new("Script")
server.Name = "SkyhopServer"
server.Source = [====[-- Skyhop gameplay. Rewards and progression are owned by the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local course = workspace:WaitForChild("SkyhopObby")
local checkpoints = course.Checkpoints
local coins = course.Coins
local restart = ReplicatedStorage:WaitForChild("SkyhopRestart")
local sessions = {}
Players.RespawnTime = 1.5

local function message(player, text)
    player:SetAttribute("SkyhopMessage", text)
    player:SetAttribute("SkyhopMessageAt", workspace:GetServerTimeNow())
end

local function playerFromHit(hit)
    local character = hit:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if player and humanoid and humanoid.Health > 0 then
        return player, humanoid
    end
end

local function resetRun(player)
    local session = sessions[player]
    session.collected = {}
    session.started = workspace:GetServerTimeNow()
    player.RespawnLocation = checkpoints.Checkpoint1
    player:SetAttribute("SkyhopCheckpoint", 1)
    player:SetAttribute("SkyhopFinished", false)
    player:SetAttribute("SkyhopElapsed", 0)
    player:SetAttribute("SkyhopStarted", session.started)
    for _, coin in coins:GetChildren() do
        player:SetAttribute(coin.Name, false)
    end
    player.leaderstats.Coins.Value = 0
    player.leaderstats.Stage.Value = 1
    message(player, "Follow the coins. Green pads save your progress!")
end

local function onCharacter(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    if not sessions[player] or player.Character ~= character then return end
    humanoid.WalkSpeed = course:GetAttribute("WalkSpeed") or 16
    humanoid.UseJumpPower = false
    humanoid.JumpHeight = course:GetAttribute("JumpHeight") or 8
    local checkpoint = checkpoints:FindFirstChild("Checkpoint" .. (player:GetAttribute("SkyhopCheckpoint") or 1))
    if checkpoint then
        local position = checkpoint.Position + Vector3.new(0, 4, -1)
        root.CFrame = CFrame.lookAt(position, position + Vector3.new(0, 0, 1))
        root.AssemblyLinearVelocity = Vector3.zero
    end
    humanoid.Died:Connect(function()
        if sessions[player] then
            message(player, "Nice try! Returning to your checkpoint.")
        end
    end)
end

local function onPlayer(player)
    if sessions[player] then return end
    sessions[player] = {collected = {}, started = 0, lastRestart = -math.huge}
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    for _, name in {"Stage", "Coins"} do
        local value = Instance.new("IntValue")
        value.Name = name
        value.Parent = stats
    end
    resetRun(player)
    player.CharacterAdded:Connect(function(character) onCharacter(player, character) end)
    if player.Character then task.spawn(onCharacter, player, player.Character) end
end

for _, checkpoint in checkpoints:GetChildren() do
    checkpoint.Touched:Connect(function(hit)
        local player = playerFromHit(hit)
        if not player or not sessions[player] or player:GetAttribute("SkyhopFinished") then return end
        local nextStage = checkpoint:GetAttribute("Stage")
        local current = player:GetAttribute("SkyhopCheckpoint") or 1
        if nextStage == current + 1 then
            player:SetAttribute("SkyhopCheckpoint", nextStage)
            player.RespawnLocation = checkpoint
            player.leaderstats.Stage.Value = nextStage
            message(player, "Checkpoint saved! Stage " .. nextStage .. " of 3")
        end
    end)
end

for _, hazard in course.Hazards:GetChildren() do
    hazard.Touched:Connect(function(hit)
        local _, humanoid = playerFromHit(hit)
        if humanoid then humanoid.Health = 0 end
    end)
end

for _, coin in coins:GetChildren() do
    coin.Touched:Connect(function(hit)
        local player = playerFromHit(hit)
        local session = player and sessions[player]
        if not session or session.collected[coin.Name] or player:GetAttribute("SkyhopFinished") then return end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or (root.Position - coin.Position).Magnitude > 8 then return end
        session.collected[coin.Name] = true
        player:SetAttribute(coin.Name, true)
        player.leaderstats.Coins.Value += 1
        message(player, "+1 coin! " .. player.leaderstats.Coins.Value .. " / " .. #coins:GetChildren())
    end)
end

course.Finish.Trigger.Touched:Connect(function(hit)
    local player = playerFromHit(hit)
    if not player or not sessions[player] or player:GetAttribute("SkyhopFinished") then return end
    if player:GetAttribute("SkyhopCheckpoint") ~= 3 then
        message(player, "Visit the green checkpoints in order first.")
        return
    end
    player:SetAttribute("SkyhopElapsed", workspace:GetServerTimeNow() - sessions[player].started)
    player:SetAttribute("SkyhopFinished", true)
    message(player, "You did it! All three stages complete.")
    print("[Skyhop] FINISH", player.Name, "coins", player.leaderstats.Coins.Value)
end)

restart.OnServerEvent:Connect(function(player)
    local session = sessions[player]
    if not session or not player:GetAttribute("SkyhopFinished") then return end
    if os.clock() - session.lastRestart < 3 then return end
    session.lastRestart = os.clock()
    resetRun(player)
    player:LoadCharacterAsync()
end)

Players.PlayerAdded:Connect(onPlayer)
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
for _, player in Players:GetPlayers() do onPlayer(player) end
print("[Skyhop] Ready: 3 stages, " .. #coins:GetChildren() .. " coins, checkpoints and lava active")
]====]
server.Parent = game:GetService("ServerScriptService")
local client = Instance.new("LocalScript")
client.Name = "SkyhopClient"
client.Source = [====[local Players = game:GetService("Players")
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
]====]
client.Parent = game:GetService("StarterPlayer").StarterPlayerScripts
ChangeHistoryService:SetWaypoint("Installed Skyhop gameplay")
return {built=true,stages=3,coins=coinIndex,descendants=#course:GetDescendants()}
