--[[
    This script handles anything related to the pet
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Database = require(ReplicatedStorage.Modules.Data)
PetConfig = {}

function selectpet(list)
	local totalweight = 0;
	for _, v in ipairs(list) do
	    totalweight = totalweight + v;
	end
	local at = math.random() * totalweight;
	local where = 0;
	for i, v in ipairs(list) do
	    if at < v then
	        where = i;
	        break;
	    end
	    at = at - v;
	end
	return where
end

--[[ Rarity ratios for each of the pets *]]
function PetConfig.DeterminePet(EggType) --["Dog","Rabbit","Dalmatian","Penguin","Koala"]
    --print(EggType)
    local Eggs = ReplicatedStorage:WaitForChild("Eggs")
    local Egg = Eggs:FindFirstChild(EggType)
    local PetList = Database.Pull(Egg.Head:FindFirstChild("Rewards").Value)
    local ChanceList = Database.Pull(Egg.Head:FindFirstChild("Chances").Value)
    local percent = {}
    for i,v in pairs(PetList) do
        table.insert(percent,{Name = v, Percentage = ChanceList[i]})
    end
    print(percent)
    selection = selectpet(percent)
    return selection["Name"]
end


function selectpet(table)
	local rand = math.random();
	local pastPercentage = 0;
	for i = 1, #table do
		if rand < table[i].Percentage + pastPercentage then 
			return table[i];
		end
		pastPercentage = pastPercentage + table[i].Percentage;
	end
end


--[[ Puts pet movement into a thread, so it runs independently of the script itself.
This will be changed into some sort of tween very soon.*]]
function PetConfig.ThreadPet(Pet,Player)
    local PhysicsService = game:GetService("PhysicsService")
    for i,v in pairs(Pet:GetChildren()) do
        if v:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(v, "Pets")
        end
    end
    local character = Player.Character
    local humRootPart = character:WaitForChild("HumanoidRootPart")
    Pet:FindFirstChild("Head").CFrame = humRootPart.CFrame
    local RotationTween = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false, 0)
    --local MovingConfig = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false, 0) --[[ Config for moving the pet in a linear direction (Better than updating every render) *]]
    spawn(function()
        local PetHum = Pet:FindFirstChild("Humanoid")
        local WalkingAnimation = Instance.new("Animation")
        local StandingAnimation = Instance.new("Animation")
        if Player then
            local character = Player.Character
            if character then -- 8327638565
                WalkingAnimation.Name = "WalkingAnimation"
                WalkingAnimation.AnimationId = "http://www.roblox.com/asset/?id=8321329213"
                local RunningTrack = PetHum:LoadAnimation(WalkingAnimation)
                local humRootPart = character:WaitForChild("HumanoidRootPart")
                local newPet = Pet:FindFirstChild("Head")
                
                local bodyPos = Instance.new("BodyPosition", newPet)
                bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                local bodyGyro = Instance.new("BodyGyro", newPet)
                bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                
                while wait() do
                    if bodyGyro.CFrame ~= humRootPart.CFrame then
                        bodyPos.Position = humRootPart.Position + Vector3.new(2, -1.5, 3)
                        bodyGyro.CFrame = humRootPart.CFrame
                        if not RunningTrack.IsPlaying == true then
                            RunningTrack:Play()
                        end
                    else
                        RunningTrack:Stop()
                    end
                    --spawn(function()
                       -- bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, 0, 5)
                        --bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, 0, -5)
                    --end)
                end
            end
        end
    end)
end

return PetConfig