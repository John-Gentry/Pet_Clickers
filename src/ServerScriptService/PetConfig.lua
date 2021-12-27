--[[
    This script handles anything related to the pet
]]
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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
function PetConfig.DeterminePet()
    local RarityList={
        [0.1] = "Cat",
        [0.1] = "Dog",
        [0.2] = "Koala",
        [0.1] = "Rabbit",
        [0.4] = "Dalmatin",
        [0.1] = "Penguin"
    }
    local Keys = {}
    local index = 1
    for key, _ in next, RarityList do
        Keys[index] = key
        index = index + 1
    end
    selection = selectpet(Keys)
    return RarityList[Keys[selection]]
end
--[[ Puts pet movement into a thread, so it runs independently of the script itself.
This will be changed into some sort of tween very soon.*]]
function PetConfig.ThreadPet(Pet,Player)
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
                        bodyPos.Position = humRootPart.Position + Vector3.new(2, -1.9, 3)
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