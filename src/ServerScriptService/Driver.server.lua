local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
ReplicatedStorage = game.ReplicatedStorage
CameraEvent = ReplicatedStorage:WaitForChild("CameraMode")
BackToPlayerCamera = ReplicatedStorage:WaitForChild("BackToPlayerCamera")
TriggerPlayerPet = ReplicatedStorage:WaitForChild("TriggerPlayerPet")
RemovePetInGame = ReplicatedStorage:WaitForChild("RemovePetInGame")
PetConfig = require(script.Parent.PetConfig)
--DeterminePet = PetConfig.DeterminePet

Players.PlayerAdded:Connect(function(Player)
    CameraEvent:FireClient(Player,true)
end)

BackToPlayerCamera.OnServerEvent:Connect(function(Player)
    BackToPlayerCamera:FireClient(Player)
end)

--[[ RunService.Heartbeat:Connect(function()
    if PlayerView.Value == true then
        if 
    end
end *]]

TriggerPlayerPet.OnServerEvent:Connect(function(Player,Pet)
    Pet = ReplicatedStorage.Pets:FindFirstChild(Pet):Clone()
    Pet.Name = Pet.Name.."_"..Player.Name
    Pet.Parent = game.Workspace.PlayerPets
    for i,v in ipairs(Pet:GetChildren()) do
        if v:IsA("UnionOperation") or v:IsA("Union") or v:IsA("Part") then
            v.CanCollide = false
        end
    end
    --[[ Needs to be added into a separate module *]]
    spawn(function()
        local offset = Vector3.new(0,0.05,0.05)
        while Pet ~= nil do
            wait()
            GameRotation = Pet:WaitForChild("GameRotation")
            PlayerPos = Player.Character:WaitForChild("HumanoidRootPart")
            PlayerHead = Player.Character:WaitForChild("Head")
            Pet:FindFirstChild("HitBox").Anchored = true
            Pet:FindFirstChild("HitBox").CFrame = PlayerPos.CFrame*CFrame.new(5,-1.8,4)*CFrame.Angles(math.rad(GameRotation.Value.X), math.rad(GameRotation.Value.Y), math.rad(GameRotation.Value.Z))
            Pet:FindFirstChild("HitBox").RotVelocity = Vector3.new(0,0,0)
            Pet:FindFirstChild("HitBox").Velocity = Vector3.new(0,0,0)
        end
    end)
end)

RemovePetInGame.OnServerEvent:Connect(function(Player,PetName)
    local Pet = game.Workspace.PlayerPets:FindFirstChild(PetName)
    Pet:Destroy()
    CameraEvent:FireClient(Player,true)
end)