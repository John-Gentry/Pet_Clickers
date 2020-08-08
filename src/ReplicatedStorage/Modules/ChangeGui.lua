ChangeGui = {}
local ClientObjects = game.Workspace.ClientObjects
SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild("EggPositionLocation").Position
local MainX = SpawnEggLocation.X
local MainZ = SpawnEggLocation.Z
local Player = game.Players.LocalPlayer
local MainGui = Player.PlayerGui:WaitForChild("MainGui")
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local Database = require(ReplicatedStorage.Modules.Data)
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
    local PlayerTable = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
    local XP = tonumber(PlayerTable[1])
    local GoalXP = tonumber(PlayerTable[2])
    local Level = tonumber(PlayerTable[3])
    local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
--[[     print("XP: "..tostring(XP))s
    print("GoalXP: "..tostring(GoalXP))
    print(Playing.Value) ]]
    if XP >= GoalXP and Playing.Value == true then
        print("firing a")
        Playing.Value = false
        local egg = ClientObjects:WaitForChild("StarterEgg")
        local Up = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false, 0)
        
        x=TweenService:Create(egg,Up,{CFrame = CFrame.new(MainX, SpawnEggLocation.Y+5, MainZ)})
        x:Play()
        x.Completed:Wait()
        if egg ~= nil and egg:FindFirstChild("PointLight")~= nil then
            repeat egg.PointLight.Brightness = egg.PointLight.Brightness + 1 wait(0.05) until egg.PointLight.Brightness >= 40
            egg:Destroy()
            --[[ Level.Value = Level.Value+1 ]]
            ReplicatedStorage.RemoteEvents.LevelUp:FireServer()
        end
    end
end

function ChangeGui.PromptPet(Pet)
    MainGui:FindFirstChild("WalkPetButton").Visible = true
    PetText = MainGui:FindFirstChild("Prompt")
    PetText.Text = "A new pet "..tostring(Pet).."!"
    PetText.Visible = true
    wait(2)
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
    local PlayerData = Player:FindFirstChild("Data"):WaitForChild("PlayerData")
    local PlayerTable = Database.Pull(PlayerData.Value)
    local XP = tonumber(PlayerTable[1])
    local GoalXP = tonumber(PlayerTable[2])
    if XP > GoalXP then
        PlayerTable[1] = GoalXP
        PlayerData.Value = Database.Convert(PlayerTable)
    end
    local x = (XP/GoalXP)*1
    Bar:TweenSize(UDim2.new(x, 0, 0.25, 0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.3,true, callback)
end


return ChangeGui