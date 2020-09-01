PlayerHandler = {}


--[[ Makes the player invisible, makes it so players can pass through a player without getting in the way.
No parts are removed from the player *]]
function PlayerHandler.MakePlayerInvisible(Player)
    Character = Player.Character
    print(Character)
    print("firing player invisible function")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if HumanoidRootPart ~= nil then
        for _,v in ipairs(Character:GetDescendants()) do
            --print(v)
            if v:IsA("Part") or v:IsA("MeshPart") then
                v.Transparency = 1
                v.Anchored = true
                v.CanCollide = false
            end
        end
    end
end

--[[ Makes the player visible, undos everything made in MakePlayerInvisible *]]
function PlayerHandler.MakePlayerVisible(Player)
    Character = Player.Character
    --HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    for _,v in ipairs(Character:GetDescendants()) do
        if (v:IsA("Part") or v:IsA("MeshPart")) and v.Name ~= "HumanoidRootPart" then
            v.Transparency = 0
            v.Anchored = false
            v.CanCollide = true
        elseif v.Name == "HumanoidRootPart" then
            v.Anchored = false
            v.CanCollide = true
        end
    end
end

return PlayerHandler