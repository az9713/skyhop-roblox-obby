-- Skyhop gameplay. Rewards and progression are owned by the server.
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
