ReplicatedStorage = game.ReplicatedStorage
CameraEvent = ReplicatedStorage:WaitForChild("CameraMode")
BackToPlayerCamera = ReplicatedStorage:WaitForChild("BackToPlayerCamera")
local Player = game.Players.LocalPlayer
local PlayerView = Player:WaitForChild("Data"):WaitForChild("PlayerView")
local Point = CFrame.new(164.975, 37.54, -428.711)
local Offset = CFrame.new(0,0,10)
local active = true

CameraEvent.OnClientEvent:Connect(function(bool)
    if game.Workspace:FindFirstChild("StarterEgg") == nil then
        local egg = ReplicatedStorage:FindFirstChild("StarterEgg"):Clone()
        egg.Parent = game.Workspace
        egg.CFrame = Point
    end
    local Camera = Workspace.CurrentCamera
    Camera.CameraType = "Scriptable"
    Camera.Focus = Point
    Camera.CFrame = Point
    Camera.CameraSubject = game.Workspace:WaitForChild("StarterEgg")
    active = bool
    while active do
        for i = 1,3600 do
            if not active then break end
            Camera.CFrame = Point * CFrame.Angles(0,math.rad(i/10),0) * Offset
            wait()
        end
    end
end)

BackToPlayerCamera.OnClientEvent:Connect(function()
    if PlayerView.Value == false then
        active = false
        PlayerView.Value = true
        if game.Workspace.Pets:FindFirstChildOfClass("Model") ~= nil then
            game.Workspace.Pets:FindFirstChildOfClass("Model"):Destroy()
        end
        local Camera = game.Workspace.CurrentCamera
        Camera.CameraType = "Track"
        Camera.CameraSubject = Player.Character:WaitForChild("HumanoidRootPart")
        Camera.CFrame = Player.Character:WaitForChild("HumanoidRootPart").CFrame
    end
end)
