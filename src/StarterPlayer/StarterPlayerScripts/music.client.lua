--[[ Added this from the wiki, not mine *]]

-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
-- Require module
local AudioPlayerModule = require(ReplicatedStorage.Modules:WaitForChild("AudioPlayer"))
 
-- Preload music tracks
AudioPlayerModule.preloadAudio({
	["Lucid_Dream"] = 1837103530,
	["Desert_Sands"] = 1848350335
})
 
-- Play music track
AudioPlayerModule.playAudio("Lucid_Dream")