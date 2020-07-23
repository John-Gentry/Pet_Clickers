InitialStart = script.Parent:WaitForChild("InitialStart")
EggProperties = script.Parent:WaitForChild("EggProperties")
ChangeGui = script.Parent:WaitForChild("ChangeGui")
local RunService = game:GetService("RunService")
GivePet = game.ReplicatedStorage.GivePet
ReplicatedStorage = game:GetService("ReplicatedStorage")

require(InitialStart).Egg("StarterEgg") --Starter Egg for the beginning

local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local MainGui = Player.PlayerGui:WaitForChild("MainGui")
local XPText = Player.PlayerGui:WaitForChild("MainGui").Level.XPBarBackground.TextLabel
local LevelText = Player.PlayerGui:WaitForChild("MainGui").Level.BoosterButton
local Bar = Player.PlayerGui:WaitForChild("MainGui").Level.XPBar
local PlayerView = Player:WaitForChild("Data"):WaitForChild("PlayerView")

UserInputService.InputBegan:Connect(function(input)
    local XP = Player:FindFirstChild("Data"):WaitForChild("XP")
    local GoalXP = Player:FindFirstChild("Data"):WaitForChild("GoalXP")
    local Level = Player:FindFirstChild("Data"):WaitForChild("Level")
    local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
    
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Playing.Value == true and PlayerView.Value == false then
        print("click")
        XP.Value = XP.Value + 1
        XPText.Text = tostring(XP.Value).."/"..tostring(GoalXP.Value)
        LevelText.Text = "Level: "..tostring(Level.Value)
        spawn(function()require(ChangeGui).AddGold(1)end)
        require(ChangeGui).DetermineLevel(XP,GoalXP,Level)
        require(ChangeGui).TweenLevelBar(Bar,XP,GoalXP)
        require(EggProperties).HitEgg()
    end
end)

--[[ Below needs to be changed so that it's mainly handled by the PetHandler module *]]
GivePet.OnClientEvent:Connect(function(Pet)
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if PlayerView.Value == false then
        CurrentPet.Value = Pet
        local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
        local Camera = game.Workspace.CurrentCamera
        local Location = Vector3.new(164.975, 37.54, -428.711)
        local Pet = game.ReplicatedStorage:WaitForChild("Pets"):FindFirstChild(Pet):Clone()
        a = Pet:FindFirstChild("Rotation").Value
        Pet.HitBox.Position = Location
        Pet.HitBox.CFrame = CFrame.new(Pet.HitBox.Position,Camera.CFrame.p)*CFrame.Angles(math.rad(a.x), a.y, a.z)
        Pet.Parent = game.Workspace.Pets
        require(ChangeGui).PromptPet(Pet.Name)
        require(ChangeGui).OpenWalkPetGui()
        wait(2)
        require(ChangeGui).ClosePromptPet()
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and Playing.Value == false and Pet ~= nil and PlayerView.Value == false then
                Pet:Destroy()
                require(ChangeGui).CloseContinuePrompt()
                require(InitialStart).Egg("StarterEgg")
            end
        end)
        --print(Pet)
    end
end)

MainGui.WalkPetButton.MouseButton1Click:Connect(function()
    print("Clicking")
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    local BackToPlayerCamera = game.ReplicatedStorage:WaitForChild("BackToPlayerCamera")
    TriggerPlayerPet = ReplicatedStorage:WaitForChild("TriggerPlayerPet")
    BackToPlayerCamera:FireServer()
    TriggerPlayerPet:FireServer(CurrentPet.Value)
end)
