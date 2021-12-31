ChangeGui = {}
local ReplicatedStorage = game.ReplicatedStorage
local Database = require(ReplicatedStorage.Modules.Data)
local ClientObjects = game.Workspace.ClientObjects
local Player = game.Players.LocalPlayer
local Data = Player:WaitForChild("Data")
local JSON = Database.Pull(Data:WaitForChild("PlayerData").Value)
local SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild(JSON[15].."_EGGPOS").Position

local MainX = SpawnEggLocation.X
local MainZ = SpawnEggLocation.Z
local Player = game.Players.LocalPlayer
local MainGui = Player.PlayerGui:WaitForChild("MainGui")
local TweenService = game:GetService("TweenService")


function ChangeGui.PromptRandomViewport(Model,viewportFrame,amount,interations,rotationspeed) -- For coin rain, gem rain
    for i = 1, amount do
        spawn(function()
            print("running")
            local Offset = CFrame.new(0,0,4)
            local viewportCamera = Instance.new("Camera")
            local viewportFrame=viewportFrame:Clone()
            local randomposition = math.random()

            viewportFrame.Parent = MainGui.PromptCurrency
            viewportFrame.CurrentCamera = viewportCamera
            viewportFrame.Position = UDim2.new(randomposition, 0, math.random()-1, 0)
            viewportCamera.Parent = viewportFrame
            viewportFrame:TweenPosition(UDim2.new(randomposition, 0, 1.5, 0), 'Out', 'Linear', 4)

            Model:Clone().Parent = viewportFrame
            local Point = CFrame.new(0,0,0)

            viewportCamera.CameraType = "Scriptable"
            viewportCamera.Focus = Point
            viewportCamera.CameraSubject = Model.Head

            for i = 1, interations do
                for i = 1,100 do
                    viewportCamera.CFrame = Point * CFrame.Angles(0,math.rad(i/rotationspeed),0) * Offset
                    wait()
                end
                --print("finished")
            end
            viewportFrame:Destroy()
        end)
    end
end

function ChangeGui.PetLevelUp()
    local AddXPText = ReplicatedStorage.PetLevel:Clone()
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
function ChangeGui.AddClick(Amount)
    local ClickText = MainGui:WaitForChild("ClicksGui").Clicks
    ClickText.Text = tostring(Amount)
end

function ChangeGui.UpdateCoins()
    while wait(0.1) do
        local PlayerTable = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
        MainGui:FindFirstChild("CashGui").Cash.Text = tostring(PlayerTable[9])
    end
end

function ChangeGui.UpdateGems()
    while wait(0.1) do
        local PlayerTable = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
        MainGui:FindFirstChild("GemGui").Cash.Text = tostring(PlayerTable[12])
    end
end


local PlayerView = Player:WaitForChild("Data"):WaitForChild("PlayerView")
function ChangeGui.DetermineLevel(Bar,XP,GoalXP,Level)
    local PlayerTable = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
    local XP = tonumber(PlayerTable[1])
    local GoalXP = tonumber(PlayerTable[2])
    local Level = tonumber(PlayerTable[3])
    local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
    local CurrentPet = Player:FindFirstChild("Data"):WaitForChild("CurrentPet")
    if XP >= GoalXP and Playing.Value == true then
        --print("bar size changed")
        Playing.Value = false
        Bar:TweenSize(UDim2.new(1, 0, 1, 0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0,true, callback)
        local egg = ClientObjects:GetChildren()[1]:FindFirstChild("Head")
        local Up = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false, 0)
        
        x=TweenService:Create(egg,Up,{CFrame = CFrame.new(MainX, SpawnEggLocation.Y+5, MainZ)})
        x:Play()
        x.Completed:Wait()
        if egg ~= nil and egg:FindFirstChild("PointLight")~= nil then
            repeat egg:WaitForChild("PointLight").Brightness = egg:WaitForChild("PointLight").Brightness + 1 wait(0.05) until egg.PointLight.Brightness >= 40
            egg.Parent:Destroy()
            --[[ Level.Value = Level.Value+1 ]]
            ReplicatedStorage.RemoteEvents.LevelUp:FireServer(CurrentPet.Value,Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
        end

    end
end

function ChangeGui.PromptPet(Pet)
    MainGui:FindFirstChild("WalkPetButton").Visible = true
    PetText = MainGui:FindFirstChild("Prompt")
    PetText.Text = "It's a "..tostring(Pet).."!"
    PetText.Visible = true
    wait(2)
    PetText = MainGui:FindFirstChild("Prompt")
    PetText.Visible = false
    wait(0.5)
end

function ChangeGui.CloseContinuePrompt()
    --MainGui:FindFirstChild("Cloud").Visible = false
end
function ChangeGui.TweenLevelBar(Bar,XP,GoalXP,Y)
    local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
    if Playing then
        if XP > GoalXP then
            XP = GoalXP
        end
        local x = (XP/GoalXP)*1
        if x > 1 then
            x = 1
        end
        Bar:TweenSize(UDim2.new(x, 0, Y, 0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.3,true, callback)
    end
end


return ChangeGui