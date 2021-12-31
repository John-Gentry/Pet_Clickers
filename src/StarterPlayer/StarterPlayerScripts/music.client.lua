

local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
-- Require audio player module
local AudioPlayer = require(ReplicatedStorage.Modules:WaitForChild("AudioPlayer"))
 
-- Set up audio tracks
AudioPlayer.setupAudio({
	["LucidDream"] = 8411313992
})
 
-- Play a track by name
AudioPlayer.playAudio("LucidDream")