ChangeGui = {}
SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild("EggPositionLocation").Position
local MainX = SpawnEggLocation.X
local MainZ = SpawnEggLocation.Z
local Player = game.Players.LocalPlayer
local MainGui = Player.PlayerGui:WaitForChild("MainGui")
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
function ChangeGui.AddXP(Amount)
    local AddXPText = ReplicatedStorage.ClickEggText:Clone()
    AddXPText.Text = "+"..tostring(Amount)
    AddXPText.Parent = MainGui
    AddXPText.Position = UDim2.new(math.random(30,60)/100, 0, math.random(30,60)/100, 0)
    wait(0.5)
    for i=1, 10 do
        wait()
        AddXPText.TextTransparency = AddXPText.TextTransparency + 0.1
        AddXPText.TextStrokeTransparency = AddXPText.TextStrokeTransparency + 0.1
    end
    AddXPText:Destroy()
end
local PlayerView = Player:WaitForChild("Data"):WaitForChild("PlayerView")
function ChangeGui.DetermineLevel(XP,GoalXP,Level)
    local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
    if XP.Value >= GoalXP.Value and Playing.Value == true then
        Playing.Value = false
        local egg = game.Workspace:WaitForChild("StarterEgg")
        local Up = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false, 0)
        
        x=TweenService:Create(egg,Up,{CFrame = CFrame.new(MainX, SpawnEggLocation.Y+5, MainZ)})
        x:Play()
        x.Completed:Wait()
        if egg ~= nil and egg:FindFirstChild("PointLight")~= nil then
            repeat egg.PointLight.Brightness = egg.PointLight.Brightness + 1 wait(0.05) until egg.PointLight.Brightness >= 40
            egg:Destroy()
            XP.Value = 0
            GoalXP.Value = (GoalXP.Value*Level.Value)
            Level.Value = Level.Value+1
            ReplicatedStorage.LevelUp:FireServer()
        end
    end
end

function ChangeGui.PromptPet(Pet)
    PetText = MainGui:FindFirstChild("Prompt")
    PetText.Text = "A new pet "..tostring(Pet).."!"
    PetText.Visible = true
end

function ChangeGui.ClosePromptPet()
    PetText = MainGui:FindFirstChild("Prompt")
    PetText.Visible = false
    wait(2.5)
    if PlayerView.Value == false then
        MainGui:FindFirstChild("Cloud").Visible = true
        MainGui:FindFirstChild("Cloud").Text.Text = "Click me to continue!"
    end
end

function ChangeGui.CloseContinuePrompt()
    MainGui:FindFirstChild("Cloud").Visible = false
end
function ChangeGui.TweenLevelBar(Bar,XP,GoalXP)
    if XP.Value > GoalXP.Value then
        XP = GoalXP
    end
    local x = (XP.Value/GoalXP.Value)*1
    Bar:TweenSize(UDim2.new(x, 0, 0.25, 0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.3,true, callback)
end

function ChangeGui.OpenWalkPetGui()
    MainGui:FindFirstChild("WalkPetButton").Visible = true
end

return ChangeGui