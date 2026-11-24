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
return {built=true,stages=3,coins=coinIndex,descendants=#course:GetDescendants()}
