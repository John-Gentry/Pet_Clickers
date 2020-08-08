Pet = {}
Pet._index = Pet

function Pet.new(Type,PetPosition)
    NewPet = {}
    Pets = game.ReplicatedStorage.Pets
    local ClientObjects = game.Workspace.ClientObjects
    local Camera = game.Workspace.CurrentCamera
    NewPet.Model = Pets:FindFirstChild(Type):Clone()
    a = NewPet.Model:FindFirstChild("Rotation").Value
    --[[ print(PetPosition) ]]
    NewPet.Model.Parent = ClientObjects
    NewPet.Model.HitBox.CFrame = CFrame.new(PetPosition) 
    NewPet.Model.HitBox.CFrame = CFrame.new(PetPosition,Camera.CFrame.p)*CFrame.Angles(math.rad(a.x), math.rad(a.y), math.rad(a.z))
    print(NewPet.Model.HitBox.CFrame)
    return NewPet.Model
end

function Pet:DestroyPets()
    for _,v in pairs(game.Workspace.ClientObjects:GetChildren()) do v:Destroy() end
end


return Pet