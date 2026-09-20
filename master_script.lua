-- =================================================================
-- 1. CLIENT MAP PURGE & BASEPLATE GENERATOR
-- =================================================================
for _, obj in pairs(game:GetService("Workspace"):GetChildren()) do
    if obj:IsA("Folder") or obj:IsA("Model") then
        if obj.Name ~= game:GetService("Players").LocalPlayer.Name and not obj:FindFirstChildOfClass("Humanoid") then
            obj:Destroy()
        end
    elseif obj:IsA("Part") or obj:IsA("MeshPart") then
        if obj.Name ~= "Terrain" then obj:Destroy() end
    end
end
local Floor = Instance.new("Part", workspace)
Floor.Size = Vector3.new(600, 1, 600)
Floor.Position = Vector3.new(0, 0, 0)
Floor.Anchored = true
Floor.Material = Enum.Material.SmoothPlastic
Floor.Color = Color3.fromRGB(45, 45, 50)

-- =================================================================
-- 2. ENVIRONMENT VIRTUALIZATION BYPASS (STOPS THE CRASH)
-- =================================================================
local oldRequire = require
local require = function(target)
    local success, result = pcall(function()
        if typeof(target) == "Instance" then
            return oldRequire(target)
        end
    end)
    if success and result then 
        return result 
    else 
        return setmetatable({}, {
            __index = function() 
                return function() end 
            end
        })
    end
end

local SmartBone = require("SmartBone")
SmartBone.Start()
task.wait(.05)
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Bypasses the missing script object error cleanly
local methods = {}
local storage = replicatedStorage:WaitForChild("LocalScriptAPI", 3) or { AnimSpeed = { OnServerInvoke = function() end } }


storage.AnimSpeed.OnServerInvoke = function(Playerrr, NewSpeed)
	local AnimFolder = workspace:WaitForChild("GoatAnimFol")
	
	if NewSpeed > 5 then
		NewSpeed = 5
	end
	if NewSpeed < 0 then
		NewSpeed = 0
	end
	
	if AnimFolder:FindFirstChild(Playerrr.Name) then
		local ThisAnimator = AnimFolder:FindFirstChild(Playerrr.Name)

		if ThisAnimator:FindFirstChildOfClass("Script") then
			ThisAnimator = ThisAnimator
			ThisAnimator.Speed.Value = NewSpeed
		end
	end

	if AnimFolder:FindFirstChild(Playerrr.Name.."Bot") then
		AnimFolder:FindFirstChild(Playerrr.Name.."Bot").Speed.Value = NewSpeed
	end

	if Playerrr:FindFirstChild("PlayerGui") then
		local Pgui = Playerrr.PlayerGui
		if Pgui:FindFirstChild("Syncs") then
			for i,v in pairs(Pgui.Syncs:GetChildren()) do
				local syncplname = v.Name
				if AnimFolder:FindFirstChild(syncplname) then
					local thisPA = AnimFolder:FindFirstChild(syncplname)
					if thisPA:FindFirstChild("Speed") then
						thisPA.Speed.Value = NewSpeed
					end
					if thisPA:FindFirstChild("ChangeSpeed") then
						if game.Players:FindFirstChild(syncplname) then
							thisPA.ChangeSpeed:FireClient(game.Players:FindFirstChild(syncplname),NewSpeed)
						end
					end
				end
			end
		end
	end
end

for i,v in pairs(methods) do
	local handler; do
		if storage:FindFirstChild(i) then
			handler = storage[i]
		else
			handler = Instance.new(i == "PlayAnimation" and "RemoteFunction" or "RemoteEvent")
			handler.Name = i
			handler.Parent = storage
		end
	end
	if handler:IsA("RemoteFunction") then
		handler.OnServerInvoke = function(...)
			return v(...)
		end
	elseif handler:IsA("RemoteEvent") then
		handler.OnServerEvent:connect(v)
	end
endlocal module = {}

function GiveCollarGetAttachment(player)
	local char = player.Character
	
	local g = script.Collar:clone()
	g.Parent = char
	local C = g:GetChildren()
	for i=1, #C do
		if C[i]:IsA("BasePart") then
			local W = Instance.new("Weld")
			W.Part0 = g.Middle
			W.Part1 = C[i]
			local CJ = CFrame.new(g.Middle.Position)
			local C0 = g.Middle.CFrame:inverse()*CJ
			local C1 = C[i].CFrame:inverse()*CJ
			W.C0 = C0
			W.C1 = C1
			W.Parent = g.Middle
		end
			local Y = Instance.new("Weld")
			Y.Part0 = char.Head
			Y.Part1 = g.Middle
			Y.C0 = CFrame.new(0, 0, 0)
			Y.Parent = Y.Part0
	end

	local h = g:GetChildren()
	for i = 1, # h do
		if h[i]:IsA("BasePart") then
			h[i].Anchored = false
			h[i].CanCollide = false
		end
	end
	
	return g.AttachmentPart.Attachment
end

function AddAttachmentToArm(player)
	local char = player.Character
	local newAttachment = Instance.new("Attachment")
	newAttachment.Position = Vector3.new(0,-1,0)
	newAttachment.Parent = char["Right Arm"]
	
	return newAttachment
end

function MakeLeash(Attachment0, Attachment1)
	local newRopeRenderer = script.RopeRenderer:Clone()
	newRopeRenderer.DrawLocalLine.Attachment0.Value = Attachment0
	newRopeRenderer.DrawLocalLine.Attachment1.Value = Attachment1
	newRopeRenderer.DrawLocalLine.RemoveEvent.Value = newRopeRenderer.RemoveCollar
	newRopeRenderer.Parent = workspace
	newRopeRenderer.Disabled = false
	
	return newRopeRenderer
end

function AddPlayerController(victim, owner, removeEvent)
	local newPlayerController = script.PlayerController:Clone()
	newPlayerController.Owner.Value = owner.Character
	newPlayerController.RemoveEvent.Value = removeEvent
	newPlayerController.Parent = victim.PlayerGui
	newPlayerController.Disabled = false
end

function AddCollarRemover(victim, owner, removeEvent)
	local newRemover = script.CollarRemover:Clone()
	newRemover.RemoveEvent.Value = removeEvent
	newRemover.Victim.Value = victim
	newRemover.Owner.Value = owner
	newRemover.Parent = workspace
	newRemover.Disabled = false
end

function module.MakeCollar(owner,victim)
	local attachment0 = GiveCollarGetAttachment(victim)
	local attachment1 = AddAttachmentToArm(owner)
	local newRope = MakeLeash(attachment0, attachment1)
	
	AddPlayerController(victim, owner, newRope.RemoveCollar)
	AddCollarRemover(victim,owner,newRope.RemoveCollar)
end

return module
local remote = game.ReplicatedStorage:WaitForChild("CustomRGB")
local remote2 = game.ReplicatedStorage:WaitForChild("BOTCustomRGB")

local function customRGBrequest(Player,selected,R,G,B)
	if selected == 1 then
		Player.PlayerGui.Color1.Value = Color3.fromRGB(R,G,B)
	else
		if selected == 2 then
			Player.PlayerGui.Color2.Value = Color3.fromRGB(R,G,B)
		else
			if selected == 3 then
				Player.PlayerGui.Color3.Value = Color3.fromRGB(R,G,B)
			else
				if selected == 4 then
					Player.PlayerGui.Color4.Value = Color3.fromRGB(R,G,B)
				else
					if selected == 5 then
						Player.PlayerGui.Color5.Value = Color3.fromRGB(R,G,B)
					end
				end
			end
		end
	end
end

local function BOTcustomRGBrequest(Player,selected,R,G,B)
	if selected == 1 then
		Player.PlayerGui.BOTColor1.Value = Color3.fromRGB(R,G,B)
	else
		if selected == 2 then
			Player.PlayerGui.BOTColor2.Value = Color3.fromRGB(R,G,B)
		else
			if selected == 3 then
				Player.PlayerGui.BOTColor3.Value = Color3.fromRGB(R,G,B)
			else
				if selected == 4 then
					Player.PlayerGui.BOTColor4.Value = Color3.fromRGB(R,G,B)
				else
					if selected == 5 then
						Player.PlayerGui.BOTColor5.Value = Color3.fromRGB(R,G,B)
					end
				end
			end
		end
	end
end

remote.OnServerEvent:Connect(customRGBrequest)
remote2.OnServerEvent:Connect(BOTcustomRGBrequest)game.Loaded:Wait()

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

local PlayerCollisionGroupName = "Players"
PhysicsService:CreateCollisionGroup(PlayerCollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(PlayerCollisionGroupName, PlayerCollisionGroupName, false)

local previousCollisionGroups = {}

local Listy = {}
local thegoodlist1 = {}
local thegoodlist2 = {}
local infolist1 = {}
local infolist2 = {}

local checkerrr = game.ServerStorage:WaitForChild('Checker')
checkerrr.Parent = Instance.new("StringValue")

function CheckIfComplete(Player)
	if not thegoodlist1[tostring(Player.UserId)] or not thegoodlist2[tostring(Player.UserId)] then
		return end
	if not infolist1[tostring(Player.UserId)] or not infolist2[tostring(Player.UserId)] then 
		return end


	if Player:FindFirstChild("PlayerGui") then
		if Player.PlayerGui:FindFirstChild("Checker") then
			Player.PlayerGui.Checker:Destroy()
		end
	end

	local charrr = Player.Character
	if not charrr then 
		return end

	local headerrrr = charrr:FindFirstChild("headerrrr") or game.ServerStorage.headerrrr:Clone()
	headerrrr.Parent = charrr
	headerrrr.Enabled = true

	headerrrr.Main.Text1.Text = infolist1[tostring(Player.UserId)]
	headerrrr.Main.Text2.Text = infolist2[tostring(Player.UserId)]
	headerrrr.Main.Text3.Text = Player.DisplayName

	if infolist1[tostring(Player.UserId)] == ("2".."2") or infolist1[tostring(Player.UserId)] == ("2".."1") or infolist1[tostring(Player.UserId)] == ("2".."0") or infolist1[tostring(Player.UserId)] == ("older".."lmao") or infolist1[tostring(Player.UserId)] == ("1".."8") then
		headerrrr.Main.Text1.TextColor3 = Color3.fromRGB(255, 255, 250)
	else
		headerrrr.Main.Text1.TextColor3 = Color3.fromRGB(255, 255, 250)
	end

	if infolist2[tostring(Player.UserId)] == "MALE" then
		headerrrr.Main.Text2.TextColor3 = Color3.fromRGB(147, 244, 255)
	elseif infolist2[tostring(Player.UserId)] == "FEMALE" then
		headerrrr.Main.Text2.TextColor3 = Color3.fromRGB(255, 94, 242)
	elseif infolist2[tostring(Player.UserId)] == "OTHER" then
		headerrrr.Main.Text2.TextColor3 = Color3.fromRGB(255, 197, 250)
	end

	if charrr:FindFirstChild("Head") then
		headerrrr.Adornee = charrr.Head
	end

	game.ReplicatedStorage.Header:FireAllClients(headerrrr)
end

local function setCollisionGroup(object)
	for i, y in pairs(object:GetChildren()) do
		if y:IsA("BasePart") then
			if y.Name == "HumanoidRootPart" then
				for i,v in pairs(script:GetChildren()) do
					if v:IsA("Sound") then
						v:Clone().Parent = y
					end
				end
			end
		end
	end
end

local function setCollisionGroupRecursive(object)
	setCollisionGroup(object)
end

local function onCharacterAdded(character,Player)
	setCollisionGroupRecursive(character)

	if character:FindFirstChild("Humanoid") then
		character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

local function onPlayerAdded(Player)
	for i,v in pairs(Listy) do
		if tostring(Player.UserId) == v[1] then
			if v[2] ~= nil then
			else
			end
			break
		end
	end
	Player.CharacterAdded:Connect(function(character)
		onCharacterAdded(character,Player)
		CheckIfComplete(Player)
	end)	
	if not thegoodlist1[tostring(Player.UserId)] and not thegoodlist2[tostring(Player.UserId)] then
		if Player ~= nil then
			if Player:FindFirstChild("PlayerGui") then
				checkerrr:Clone().Parent = Player.PlayerGui
			end
		end
	end
end	

for i,Player in pairs(Players:GetPlayers()) do
	if Player:IsA("Player") then
		onPlayerAdded(Player)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(Player)
	local stringgg = Player.Name.."Bot"
	if workspace:FindFirstChild(stringgg) then
		workspace:FindFirstChild(stringgg):Destroy()
	end

	if workspace:FindFirstChild("GoatAnimFol") then
		for i,v in pairs(workspace:FindFirstChild("GoatAnimFol"):GetChildren()) do
			if v.Name == stringgg then
				v:Destroy()
			end
		end
	end
end)


game.ReplicatedStorage.CheckerRemote.OnServerEvent:Connect(function(Player,yes1,yes2)
	print(Player,yes1,yes2)
	if thegoodlist1[tostring(Player.UserId)] and thegoodlist2[tostring(Player.UserId)] then 
		return end
	if yes2 == "1" then
		if yes1 == nil then
			Listy[#Listy+1] = {tostring(Player.UserId)}
			return
		end
		thegoodlist1[tostring(Player.UserId)] = true
		infolist1[tostring(Player.UserId)] = yes1
		CheckIfComplete(Player)
	elseif yes2 == "2" then
		if yes1 == 'none' then
			local NewIndex = #Listy+1
			Listy[NewIndex] = {tostring(Player.UserId),true}
			task.wait(120)
			Listy[NewIndex] = nil
			return
		end
		thegoodlist2[tostring(Player.UserId)] = true
		infolist2[tostring(Player.UserId)] = yes1
		CheckIfComplete(Player)
	end
end)--[[

	19 -- All Accessories
	9 -- Hat
	20 -- HairAccessory
	21 -- FaceAccessory
	22 -- NeckAccessory
	23 -- ShoulderAccessory
	24 -- FrontAccessory
	25 -- BackAccessory
	26 -- WaistAccessory
	
	4 -- Faces+Heads
	10 -- Faces
	15 -- Heads

--]]

local Http = game:GetService("HttpService")

local subcategory = 9
local url = "https://search.roblox.com/catalog/json?Subcategory=" .. subcategory .. "&IncludeNotForSale=true&ResultsPerPage=60&PageNumber="

local pages = 25

local assets = {}

for i = 1, pages do
	local urlPage = url .. i
	local data = Http:JSONEncode(Http:GetAsync(urlPage))
	data = Http:JSONDecode(data)
	
	for ii = 1, #data do
		local asset = data[ii]
		
		local id = asset.AssetId
		local name = asset.Name
		
		assets[#assets + 1] = "{Id = " ..id .. ", Name = \"" .. name .. "\"}"
	end
	print(i)
end

local source = "return { \n\t" .. table.concat(assets, ",\n\t") .. "\n}"
local module = Instance.new("ModuleScript")
module.Source = source
module.Parent = workspacelocal telModule = {}

function telModule.teleportPlayer(player, destination)		

	local playerGui = player:FindFirstChild("PlayerGui")
	local blackScreenGui = game.ReplicatedStorage.BlackScreenGui:Clone()
	blackScreenGui.Parent = playerGui	

	local frame = blackScreenGui.Frame
	for i = 1,10 do
		frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1
		wait(0.025)
	end	

	local character = player.Character 
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		humanoidRootPart.CFrame = destination.CFrame * CFrame.new(0,4,0)
	end	

	wait(0.5)
	for i = 1,10 do
		frame.BackgroundTransparency = frame.BackgroundTransparency + 0.1
		wait(0.025)
	end
	
	blackScreenGui:Destroy()
end

return telModulelocal ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

local animsFolder = ServerStorage:WaitForChild("anims")
local templateButton = script:WaitForChild("TemplateButton")

local menu = ServerStorage:WaitForChild("Menu")
local animFrame = menu:WaitForChild("Animation")
local allList = animFrame:WaitForChild("All_List")
local menList = animFrame:WaitForChild("Men_List")
local womenList = animFrame:WaitForChild("Women_List")
local emoteList = animFrame:WaitForChild("Emote_List")

local botFrame = menu:WaitForChild("BOTAnimation")
local allBotList = botFrame:WaitForChild("AllBot_List")
local menBotList = botFrame:WaitForChild("MenBot_List")
local womenBotList = botFrame:WaitForChild("WomenBot_List")
local emoteBotList = botFrame:WaitForChild("EmoteBot_List")

local function createButton(animObj, parent, categoryColor)
	local btn = templateButton:Clone()
	btn.Name = animObj.Name
	btn.Parent = parent
	btn.Visible = true

	local textColor = animObj:GetAttribute("Color") or categoryColor
	if textColor then
		btn.TextColor3 = textColor
	end

	btn.Text = animObj.Name

	local daString = btn:FindFirstChild("daString")
	if daString and daString:IsA("StringValue") then
		daString.Value = animObj.Name
	end
end

local function fillCategory(folder, lists)
	local categoryColor = folder:GetAttribute("Color")
	for _, animObj in ipairs(folder:GetChildren()) do
		if animObj:IsA("KeyframeSequence") then
			for _, list in ipairs(lists) do
				createButton(animObj, list, categoryColor)
			end
		end
	end
end

for _, frame in ipairs({allList, menList, womenList, emoteList,
	allBotList, menBotList, womenBotList, emoteBotList}) do
	if frame then
		for _, child in ipairs(frame:GetChildren()) do
			if child:IsA("TextButton") and child.Name ~= "TemplateButton" then
				child:Destroy()
			end
		end
	end
end

fillCategory(animsFolder:WaitForChild("Male"), {allList, menList, allBotList, menBotList})
fillCategory(animsFolder:WaitForChild("Female"), {womenList, allList, womenBotList, allBotList})
fillCategory(animsFolder:WaitForChild("Emote"), {emoteList, allList, emoteBotList, allBotList})
--fillCategory(animsFolder:WaitForChild("Lunar's Optimized"), {emoteList, allList, emoteBotList, allBotList}) -- I got rid of the animations.

print("✅ All Anims Added in GUI")local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local TeleportEvent = ReplicatedStorage:WaitForChild("TeleportEvent")
local MapsFolder = ReplicatedStorage:WaitForChild("Maps")
local TeleportPoints = Workspace:WaitForChild("TeleportPoints")

local CONFIG = {
	AlwaysLoadedMap = "DAHOOD", -- THIS IS THE SPAWN MAP.
}

local mapContainer = Workspace:FindFirstChild("ServerMaps") or Instance.new("Folder")
mapContainer.Name = "ServerMaps"
mapContainer.Parent = Workspace

local isTeleporting = {}
local playerCurrentMap = {}
local mapPlayerCount = {}

local function loadMap(targetName)
	local existingMap = mapContainer:FindFirstChild(targetName)
	if not existingMap then
		local mapTemplate = MapsFolder:FindFirstChild(targetName)
		if not mapTemplate then 
			warn("Map missing in ReplicatedStorage:", targetName) 
			return false 
		end
		local newMap = mapTemplate:Clone()
		newMap.Parent = mapContainer
	end
	return true
end

local function checkAndUnloadMap(mapName)
	if mapName == CONFIG.AlwaysLoadedMap then return end

	local count = mapPlayerCount[mapName] or 0
	if count <= 0 then
		local existingMap = mapContainer:FindFirstChild(mapName)
		if existingMap then
			existingMap:Destroy()
		end
		mapPlayerCount[mapName] = 0
	end
end

local function changePlayerMap(player, newMapName)
	local userId = player.UserId
	local oldMapName = playerCurrentMap[userId]

	if oldMapName == newMapName then return end

	if oldMapName then
		mapPlayerCount[oldMapName] = (mapPlayerCount[oldMapName] or 0) - 1
		checkAndUnloadMap(oldMapName)
	end

	playerCurrentMap[userId] = newMapName
	mapPlayerCount[newMapName] = (mapPlayerCount[newMapName] or 0) + 1
end

local function performTeleport(player, targetName)
	if isTeleporting[player.UserId] then return end
	isTeleporting[player.UserId] = true

	targetName = tostring(targetName)
	local tpPoint = TeleportPoints:FindFirstChild(targetName)

	if not tpPoint then 
		warn("Teleport point not found:", targetName)
		isTeleporting[player.UserId] = false 
		return 
	end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")

	if not root then isTeleporting[player.UserId] = false return end

	TeleportEvent:FireClient(player, "FadeOut")
	task.wait(0.6)

	if loadMap(targetName) then
		changePlayerMap(player, targetName)

		if hum then hum.Sit = false end
		root.Anchored = true
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero

		root.CFrame = tpPoint.CFrame
		task.wait(0.2)
		root.Anchored = false
	end

	TeleportEvent:FireClient(player, "FadeIn")
	isTeleporting[player.UserId] = false
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(char)
		local root = char:WaitForChild("HumanoidRootPart")

		loadMap(CONFIG.AlwaysLoadedMap)
		changePlayerMap(player, CONFIG.AlwaysLoadedMap)

		local startPoint = TeleportPoints:FindFirstChild(CONFIG.AlwaysLoadedMap)
		if startPoint then
			task.wait() 
			root.CFrame = startPoint.CFrame
		end
	end)
end

local function onPlayerRemoving(player)
	local userId = player.UserId
	local currentMap = playerCurrentMap[userId]

	if currentMap then
		mapPlayerCount[currentMap] = (mapPlayerCount[currentMap] or 0) - 1
		checkAndUnloadMap(currentMap)
	end

	playerCurrentMap[userId] = nil
	isTeleporting[userId] = nil
end

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

TeleportEvent.OnServerEvent:Connect(function(player, targetName)
	performTeleport(player, targetName)
end)

loadMap(CONFIG.AlwaysLoadedMap)local event = game.ReplicatedStorage:WaitForChild("RelinkRopeEvent")
local linkingEnabled = {}
local hubMapping = {
	["HubAttachment2"] = "Attachment2",
	["HubAttachment3"] = "Attachment3",
	["HubAttachment"]  = "Attachment",
	 ["HubAttachment4"] = "Attachment4",
	 ["HubAttachment5"] = "Attachment5",
}

local function getCharacterFromAttachment(attachment)
	local current = attachment
	while current.Parent and current.Parent ~= workspace do
		current = current.Parent
		if current:IsA("Model") and (current:FindFirstChild("Humanoid") or current:FindFirstChild("HumanoidRootPart")) then
			return current
		end
	end
	return nil
end

local function linkRopesToNearestHub(target, hubs, isEnabled)
	local targetCharacter = getCharacterFromAttachment(target)
	local targetPosition = target.WorldPosition
	local ropeCount = 0
	local nearestHub = nil
	local minDistance = math.huge

	if isEnabled then
		for _, hub in ipairs(hubs) do
			local hubCharacter = getCharacterFromAttachment(hub)
			if targetCharacter and hubCharacter and targetCharacter == hubCharacter then
				continue
			end
			
			local distance = (hub.WorldPosition - targetPosition).Magnitude
			if distance < minDistance then
				minDistance = distance
				nearestHub = hub
			end
		end
	end

	for _, rope in ipairs(target:GetChildren()) do
		if rope:IsA("RopeConstraint") then
			if isEnabled and nearestHub then
				rope.Attachment0 = target
				rope.Attachment1 = nearestHub
				ropeCount += 1
			else
				rope.Attachment0 = nil
				rope.Attachment1 = nil
				ropeCount += 1
			end
		end
	end
	return ropeCount
end


event.OnServerEvent:Connect(function(player, isEnabled)
	linkingEnabled[player.UserId] = isEnabled
	local totalCount = 0
	local allHubs = {}
	local allTargets = {}

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("Attachment") then
			local name = descendant.Name

			if hubMapping[name] then
				if not allHubs[name] then allHubs[name] = {} end
				table.insert(allHubs[name], descendant)

			else
				for _, targetName in pairs(hubMapping) do
					if name == targetName then
						if not allTargets[name] then allTargets[name] = {} end
						table.insert(allTargets[name], descendant)
						break
					end
				end
			end
		end
	end

	for hubName, targetName in pairs(hubMapping) do
		local hubs = allHubs[hubName]
		local targets = allTargets[targetName]

		if hubs and targets then
			for _, target in ipairs(targets) do
				local count = linkRopesToNearestHub(target, hubs, isEnabled)
				totalCount += count
			end
		end
	end
end)-- By Mania.
local toggleCollideRemote = game.ReplicatedStorage:WaitForChild("ToggleCollideRemote")

toggleCollideRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	-- Toggle CanCollide for these parts
	local parts = {
		character:FindFirstChild("Left Arm"),
		character:FindFirstChild("RightHand"),
		character:FindFirstChild("LeftFoot"),
		character:FindFirstChild("RightFoot"),
		character:FindFirstChild("Torso"),
		character:FindFirstChild("Head")
	}

	for _, part in ipairs(parts) do
		if part and part:IsA("BasePart") then
			part.CanCollide = not part.CanCollide
		end
	end
end)event = game.ReplicatedStorage.Expand

function makemorphcool(char)
	local hit = char.Torso
	local mark = Instance.new("StringValue",hit)
	mark.Name = "Expand"
	local a = game.ServerStorage.Thick.LeftL:Clone()
	a.Parent = hit.Parent["Left Leg"]
	local W = Instance.new("Weld")
	W.Part0 = hit.Parent["Left Leg"]
	W.Part1 = hit.Parent["Left Leg"].LeftL
	local CJ = CFrame.new(hit.Parent["Left Leg"].Position)
	W.Parent = hit.Parent["Left Leg"]
	a.Color = hit.Parent["Left Leg"].Color
	local b = game.ServerStorage.Thick.RightL:Clone()
	b.Parent = hit.Parent["Right Leg"]
	local X = Instance.new("Weld")
	X.Part0 = hit.Parent["Right Leg"]
	X.Part1 = hit.Parent["Right Leg"].RightL
	local XJ = CFrame.new(hit.Parent["Right Leg"].Position)
	X.Parent = hit.Parent["Right Leg"]
	b.Color = hit.Parent["Right Leg"].Color
	local a = game.ServerStorage.Thick.RightA:Clone()
	a.Parent = hit.Parent["Right Arm"]
	local W = Instance.new("Weld")
	W.Part0 = hit.Parent["Right Arm"]
	W.Part1 = hit.Parent["Right Arm"].RightA
	local CJ = CFrame.new(hit.Parent["Right Arm"].Position)
	W.Parent = hit.Parent["Right Arm"]
	a.Color = hit.Parent["Right Arm"].Color		
	local b = game.ServerStorage.Thick.LeftA:Clone()
	b.Parent = hit.Parent["Left Arm"]
	local W = Instance.new("Weld")
	W.Part0 = hit.Parent["Left Arm"]
	W.Part1 = hit.Parent["Left Arm"].LeftA
	local CJ = CFrame.new(hit.Parent["Left Arm"].Position)
	W.Parent = hit.Parent["Left Arm"]
	b.Color = hit.Parent["Left Arm"].Color
	local c = game.ServerStorage.Thick.T:Clone()
	c.Parent = hit.Parent.Torso
	local W = Instance.new("Weld")
	W.Part0 = hit.Parent.Torso
	W.Part1 = hit.T
	local CJ = CFrame.new(hit.Parent.Torso.Position)
	W.Parent = hit.Parent.Torso
	c.Color = hit.Parent.Torso.Color
end

function togglethick(toggle,char)
	if toggle == "on" then
		if char.Parent:FindFirstChild("Left Leg") then
			if char.Parent["Left Leg"]:FindFirstChild("LeftL") then
				char.Parent["Left Leg"].LeftL.Transparency = 0
				char.Parent["Left Leg"].Transparency = 1
			end
		end

		if char.Parent:FindFirstChild("Right Leg") then
			if char.Parent["Right Leg"]:FindFirstChild("RightL") then
				char.Parent["Right Leg"].RightL.Transparency = 0
				char.Parent["Right Leg"].Transparency = 1
			end
		end

		if char.Parent:FindFirstChild("Left Arm") then
			if char.Parent["Left Arm"]:FindFirstChild("LeftA") then
				char.Parent["Left Arm"].LeftA.Transparency = 0
				char.Parent["Left Arm"].Transparency = 1
			end
		end

		if char.Parent:FindFirstChild("Right Arm") then
			if char.Parent["Right Arm"]:FindFirstChild("RightA") then
				char.Parent["Right Arm"].RightA.Transparency = 0
				char.Parent["Right Arm"].Transparency = 1
			end
		end

		if char.Parent:FindFirstChild("Torso") then
			if char.Parent["Torso"]:FindFirstChild("T") then
				char.Parent["Torso"].T.Transparency = 0
				char.Parent["Torso"].Transparency = 1
			end
		end
	elseif toggle == "off" then
		if char.Parent:FindFirstChild("Left Leg") then
			if char.Parent["Left Leg"]:FindFirstChild("LeftL") then
				char.Parent["Left Leg"].LeftL.Transparency = 1
				char.Parent["Left Leg"].Transparency = 0
			end
		end

		if char.Parent:FindFirstChild("Right Leg") then
			if char.Parent["Right Leg"]:FindFirstChild("RightL") then
				char.Parent["Right Leg"].RightL.Transparency = 1
				char.Parent["Right Leg"].Transparency = 0
			end
		end

		if char.Parent:FindFirstChild("Left Arm") then
			if char.Parent["Left Arm"]:FindFirstChild("LeftA") then
				char.Parent["Left Arm"].LeftA.Transparency = 1
				char.Parent["Left Arm"].Transparency = 0
			end
		end

		if char.Parent:FindFirstChild("Right Arm") then
			if char.Parent["Right Arm"]:FindFirstChild("RightA") then
				char.Parent["Right Arm"].RightA.Transparency = 1
				char.Parent["Right Arm"].Transparency = 0
			end
		end

		if char.Parent:FindFirstChild("Torso") then
			if char.Parent["Torso"]:FindFirstChild("T") then
				char.Parent["Torso"].T.Transparency = 1
				char.Parent["Torso"].Transparency = 0
			end
		end
	end
end

event.OnServerEvent:Connect(function(plr,toggle,botmayb)
	if plr.Character.Torso:FindFirstChild("Expand") == nil then
		if botmayb ~= nil then
			if workspace:FindFirstChild(plr.Name.."Bot") then
				makemorphcool(workspace:FindFirstChild(plr.Name.."Bot"))
			end
		else
			makemorphcool(plr.Character)
		end
	end
	if toggle == "on" or toggle == "off" then
		if botmayb ~= nil then
			if workspace:FindFirstChild(plr.Name.."Bot") then
				togglethick(toggle,workspace:FindFirstChild(plr.Name.."Bot").Torso)
			end
		else
			togglethick(toggle,plr.Character.Torso)
		end
	end
end)
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")
local AccesoryCache = {} :: { [number]: Part }
local ACCESORY_NAME_PREFIX = "%s %d"
local ACCESORIES_NAME = {
	"BackAccessory",
	"FaceAccessory",
	"FrontAccessory",
	"HairAccessory",
	"HatAccessory",
	"NeckAccessory",
	"ShouldersAccessory",
	"WaistAccessory",
}

local function waitForAppearance(character)
	local humanoid = character:WaitForChild("Humanoid", 20)
	if not humanoid then
		return nil, nil
	end
	for i = 1, 20 do
		local desc = humanoid:GetAppliedDescription()
		local hasData = desc.HatAccessory ~= "" or desc.HairAccessory ~= ""
			or desc.FaceAccessory ~= "" or desc.FrontAccessory ~= ""
			or desc.BackAccessory ~= "" or desc.NeckAccessory ~= ""
			or desc.ShouldersAccessory ~= "" or desc.WaistAccessory ~= ""
		if hasData then
			return humanoid, desc
		end
		task.wait(0.5)
	end
	return humanoid, humanoid:GetAppliedDescription()
end

local function LoadAccessory(id: number, character: Model, accesoryName: string)
	if not character or not id then
		return
	end
	local accesoryFolder = character:FindFirstChild("Accesories")
	if not accesoryFolder then
		accesoryFolder = Instance.new("Folder")
		accesoryFolder.Name = "Accesories"
		accesoryFolder.Parent = character
	end
	local fixAccesory = if AccesoryCache[id]
		then AccesoryCache[id]:Clone()
		else InsertService:LoadAsset(id):GetChildren()[1].Handle
	if not AccesoryCache[id] then
		fixAccesory.CanCollide = false
		fixAccesory.CanQuery = false
		fixAccesory.CanTouch = false
		fixAccesory.Massless = true
		AccesoryCache[id] = fixAccesory:Clone()
	end
	
	fixAccesory.Name = ACCESORY_NAME_PREFIX:format(accesoryName, id)
	-- Fetch and store the real name as an attribute
	local success, info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(id)
	end)
	if success and info then
		fixAccesory:SetAttribute("AssetName", info.Name)
	end
	
	fixAccesory.Parent = accesoryFolder
	local attachment = fixAccesory:FindFirstChildOfClass("Attachment")
	if not attachment then
		return
	end
	local attachOnBody = character:FindFirstChild(attachment.Name, true)
	if not attachOnBody then
		return
	end
	local attachPart = attachOnBody.Parent
	fixAccesory.CFrame = attachOnBody.WorldCFrame * attachment.CFrame:Inverse()
	local weld = Instance.new("WeldConstraint")
	weld.Name = "WeldAccesory"
	weld.Part0 = fixAccesory
	weld.Part1 = attachPart
	weld.Parent = fixAccesory
end

local function onCharacterAdded(character: Model)
	local humanoid, desc = waitForAppearance(character)
	if not humanoid then
		return
	end
	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return
	end
	humanoid:RemoveAccessories()
	for _, accesoryName: string in ACCESORIES_NAME do
		local accesoryDesc = tostring(desc[accesoryName])
		if accesoryDesc == "0" or accesoryDesc == "" then
			continue
		end
		for _, id: number in accesoryDesc:split(",") do
			LoadAccessory(tonumber(id) :: number, character, accesoryName)
		end
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)
end

local function init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

local function ApplyToCharacter(character: Model)
	local humanoid, desc = waitForAppearance(character)
	if not humanoid then return end
	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end
	humanoid:RemoveAccessories()
	for _, accesoryName: string in ACCESORIES_NAME do
		local accesoryDesc = tostring(desc[accesoryName])
		if accesoryDesc == "0" or accesoryDesc == "" then continue end
		for _, id: number in accesoryDesc:split(",") do
			LoadAccessory(tonumber(id) :: number, character, accesoryName)
		end
	end
end

return {
	Init = init,
	ApplyToCharacter = ApplyToCharacter,
	LoadAccessory = LoadAccessory,
}
local collar = require(script.Parent.Main_C)
local events = game.ReplicatedStorage:WaitForChild("CollarEvents")

events.SendRequest.OnServerEvent:Connect(function(player, target)
	print("Filtering a request to the player")
	events.ActivateLocalUI:FireClient(target, player.Name)
end)

events.CollarPlayer.OnServerEvent:Connect(function(victim, owner)
	collar.MakeCollar(owner, victim)
end)local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local RS_Events = ReplicatedStorage:WaitForChild("Events", 10) or ReplicatedStorage
local RS_Catalog = ReplicatedStorage:WaitForChild("CatalogStuff", 10) or ReplicatedStorage
local RS_Sounds = ReplicatedStorage:WaitForChild("Sounds", 10) or ReplicatedStorage

local LoadEvent = RS_Events:WaitForChild("LoadEvent", 5) or RS_Events:FindFirstChild("LoadEvent")
local ToggleBotEvent = ReplicatedStorage:WaitForChild("ToggleBotSyncEvent", 5)
local BotSyncValue = ReplicatedStorage:WaitForChild("BotSyncEnabled", 5)
local ChangeBotValue = ReplicatedStorage:WaitForChild("changeBotValue", 5)

local CatalogEvent = ReplicatedStorage:WaitForChild("CatalogStuff", 5)
local CatalogDeleteEvent = ReplicatedStorage:WaitForChild("CatalogStuffDelete", 5)
local CharUserEvent = ReplicatedStorage:WaitForChild("CharUser", 5)
local FaceDecalEvent = ReplicatedStorage:WaitForChild("asr32", 5)
local OilToggleEvent = ReplicatedStorage:WaitForChild("OilyToggleEvent", 5)
local SizeRemote = ReplicatedStorage:WaitForChild("SizeRemote", 5)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local toggleEvent = ReplicatedStorage:WaitForChild("ToggleAutoSeat")

local BlowEvent = ReplicatedStorage:WaitForChild("Blow", 5)
local BlowHardEvent = ReplicatedStorage:WaitForChild("BlowHard", 5)
local VignetteEvent = ReplicatedStorage:WaitForChild("BlowVignette", 5)
local FluidEvent = ReplicatedStorage:FindFirstChild("CumEvent")
local SexSoundEvent = ReplicatedStorage:FindFirstChild("SexSound")

local LocalSoundEvent = ReplicatedStorage:WaitForChild("LocalSoundEvent")

local SyncFolder = ReplicatedStorage:WaitForChild("SyncEvents", 5)
local TeleportEvent = ReplicatedStorage:WaitForChild("TeleportEvent", 5)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local OGMorphs = ServerStorage:WaitForChild("Morphs")
local CloneMorphs = OGMorphs:Clone()

local NAMETAG_NAME = "AFK"
local NAMETAG_TEMPLATE = script:WaitForChild(NAMETAG_NAME)
local OIL_VARIANT = "Oil"
local DEFAULT_VARIANT = ""

local activeMoans = {}
local soundDebounce = {} 


local function GetTargetCharacter(player, isBotRequest)
	local char = player.Character
	if isBotRequest then
		local bot1Enabled = player:FindFirstChild("bot1enabled") and player.bot1enabled.Value
		local bot2Enabled = player:FindFirstChild("bot2enabled") and player.bot2enabled.Value
		if bot1Enabled and Workspace:FindFirstChild(player.Name .. "Bot") then
			char = Workspace:FindFirstChild(player.Name .. "Bot")
		elseif bot2Enabled and Workspace:FindFirstChild(player.Name .. "Bot2") then
			char = Workspace:FindFirstChild(player.Name .. "Bot2")
		end
	end
	return char
end

local function GetSyncedPlayers(player)
	local syncedList = {}
	local syncs = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Syncs")
	if syncs then
		for _, sync in ipairs(syncs:GetChildren()) do
			local syncPlayer = Players:FindFirstChild(sync.Name)
			if syncPlayer then
				table.insert(syncedList, syncPlayer)
			end
		end
	end
	return syncedList
end

local function IsMainAudioHandler(player)
	local syncs = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Syncs")
	if syncs then
		for _, token in ipairs(syncs:GetChildren()) do
			if token:GetAttribute("IsRequester") == true then
				return false
			end
		end
	end
	return true
end

local function FireVignetteToSynced(player, buttonFired)
	local synced = GetSyncedPlayers(player)
	for _, syncPlayer in ipairs(synced) do
		VignetteEvent:FireClient(syncPlayer, buttonFired)
	end
end

local function ApplyHardSpeedParams(player)
	local GAF = Workspace:FindFirstChild("GoatAnimFol")
	if GAF then
		local function setSpeed(objName)
			local data = GAF:FindFirstChild(objName)
			if data and data:FindFirstChild("Speed") then data.Speed.Value = 0.5 end
		end
		setSpeed(player.Name)
		setSpeed(player.Name.."Bot")
		local syncs = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Syncs")
		if syncs then
			for _, sync in ipairs(syncs:GetChildren()) do
				setSpeed(sync.Name)
			end
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	local bot1value = Instance.new("BoolValue")
	bot1value.Name = "bot1enabled"
	bot1value.Value = true
	bot1value.Parent = plr

	local bot2value = Instance.new("BoolValue")
	bot2value.Name = "bot2enabled"
	bot2value.Value = false
	bot2value.Parent = plr
end)

if ToggleBotEvent then
	ToggleBotEvent.OnServerEvent:Connect(function(player)
		BotSyncValue.Value = not BotSyncValue.Value
	end)
end

if ChangeBotValue then
	ChangeBotValue.OnServerEvent:Connect(function(plr, whichBot)
		local pGui = plr:FindFirstChild("PlayerGui")
		if not pGui then return end
		local settingsUI = pGui:FindFirstChild("Settings") and pGui.Settings:FindFirstChild("SETTINGS")
		if not settingsUI then return end
		local b1 = settingsUI.Multbots.bot1
		local b2 = settingsUI.Multbots.bot2
		if whichBot == "bot1" then
			b1.Text = "Bot 1 ✅"
			b2.Text = "Bot 2 ❌"
			plr.bot1enabled.Value = true
			plr.bot2enabled.Value = false
		else
			b1.Text = "Bot 1 ❌"
			b2.Text = "Bot 2 ✅"
			plr.bot1enabled.Value = false
			plr.bot2enabled.Value = true
		end
	end)
end

if LoadEvent then
	LoadEvent.OnServerEvent:Connect(function(plr, isActive)
		local char = plr.Character or plr.CharacterAdded:Wait()
		local head = char:WaitForChild("Head", 5)
		if not head then return end
		if isActive and not head:FindFirstChild(NAMETAG_NAME) then
			NAMETAG_TEMPLATE:Clone().Parent = head
		elseif not isActive and head:FindFirstChild(NAMETAG_NAME) then
			head[NAMETAG_NAME]:Destroy()
		end
	end)
end

local AccessoryFix = require(game.ServerScriptService.R6AccessoryFix)

if CatalogEvent then
	CatalogEvent.OnServerEvent:Connect(function(Player, ID, WhatType, isBot)
		if not Player.Character or not ID then return end
		local chr = GetTargetCharacter(Player, isBot)
		if not chr then return end
		if WhatType == "Shirt" then
			for _, v in pairs(chr:GetChildren()) do if v:IsA("Shirt") then v:Destroy() end end
		elseif WhatType == "Pants" then
			for _, v in pairs(chr:GetChildren()) do if v:IsA("Pants") then v:Destroy() end end
		elseif WhatType == "TShirt" then
			for _, v in pairs(chr:GetChildren()) do if v:IsA("ShirtGraphic") then v:Destroy() end end
		end
		local FoundObj = nil
		if ID ~= 0 and ID ~= "" then
			-- Route accessories through the high quality loader
			if WhatType == nil then
				AccessoryFix.LoadAccessory(tonumber(ID), chr, "HatAccessory")
				return
			end
			local success, model = pcall(InsertService.LoadAsset, InsertService, ID)
			if success and model then
				FoundObj = model:GetChildren()[1]
				if FoundObj then FoundObj.Parent = chr end
				model:Destroy()
			end
		end
		if WhatType == "Face" and chr:FindFirstChild("Head") then
			if chr.Head:FindFirstChild("face") then chr.Head.face:Destroy() end
			if FoundObj then
				FoundObj.Name = "face"
				FoundObj.Parent = chr.Head
			end
		elseif WhatType == "TShirt" and chr:FindFirstChild("Torso") then
			if chr.Torso:FindFirstChild("roblox") then chr.Torso.roblox:Destroy() end
			if FoundObj then
				FoundObj.Name = "roblox"
				FoundObj.Parent = chr.Torso
				if FoundObj:IsA("ShirtGraphic") then
					local decal = Instance.new("Decal", chr.Torso)
					decal.Name = "roblox"
					decal.Texture = FoundObj.Graphic
					FoundObj:Destroy()
				end
			end
		end
	end)
end

if CatalogDeleteEvent then
	CatalogDeleteEvent.OnServerEvent:Connect(function(Player, obj, isBot)
		if not Player.Character or not obj then return end
		local chr = GetTargetCharacter(Player, isBot)
		if not chr then return end
		if obj.Parent == chr or obj.Parent.Parent == chr then
			obj:Destroy()
		end
	end)
end

if CharUserEvent then
	CharUserEvent.OnServerEvent:Connect(function(Player, UserName, isBot)
		if not Player.Character then return end
		local chr = GetTargetCharacter(Player, isBot)
		if not chr then return end
		for _, v in pairs(chr:GetChildren()) do
			if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
		end
		if chr:FindFirstChild("Torso") and chr.Torso:FindFirstChild("roblox") then
			chr.Torso.roblox:Destroy()
		end

		-- Clear previously fixed accessories
		local accesoryFolder = chr:FindFirstChild("Accesories")
		if accesoryFolder then
			accesoryFolder:Destroy()
		end

		local defaultId = Players:GetUserIdFromNameAsync("Roblox")
		if defaultId then
			chr.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(defaultId))
		end
		task.wait()
		local targetName = (UserName == "" or UserName == 0) and Player.Name or UserName
		local targetId = Players:GetUserIdFromNameAsync(targetName)
		if targetId then
			chr.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(targetId))
		end

		-- Re-run the accessory fixer for the new avatar
		task.spawn(function()
			AccessoryFix.ApplyToCharacter(chr)
			game.ReplicatedStorage.AccessoriesReloaded:FireClient(Player)
		end)
	end)
end

if FaceDecalEvent then
	FaceDecalEvent.OnServerEvent:Connect(function(player, button)
		local char = player.Character
		if not char or not char:FindFirstChild("Head") then return end
		local head = char.Head
		local function applyDecal(name, textureId)
			if head:FindFirstChild(name) then
				head[name].Texture = textureId
			else
				local decal = Instance.new("Decal")
				decal.Name = name
				decal.Texture = textureId
				decal.Parent = head
			end
		end
		if button:FindFirstChild("EyesImage") then applyDecal("Eyes", button.EyesImage.Image) end
		if button:FindFirstChild("MouthImage") then applyDecal("Mouth", button.MouthImage.Image) end
		if button:FindFirstChild("MiscImage") then applyDecal("Misc", button.MiscImage.Image) end
		if button:FindFirstChild("BrowImage") then applyDecal("Brow", button.BrowImage.Image) end
		if (button:FindFirstChild("EyesImage") or button:FindFirstChild("MouthImage")) and head:FindFirstChild("face") then
			head.face:Destroy()
		end
	end)
end

if OilToggleEvent then
	OilToggleEvent.OnServerEvent:Connect(function(player, isActive, targetType)
		local targetModel = nil
		if targetType == "Bot1" then
			targetModel = workspace:FindFirstChild(player.Name .. "Bot")
		elseif targetType == "Bot2" then
			targetModel = workspace:FindFirstChild(player.Name .. "Bot2")
		else
			targetModel = player.Character
		end
		if targetModel then
			for _, descendant in ipairs(targetModel:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Material = Enum.Material.SmoothPlastic
					descendant.MaterialVariant = isActive and OIL_VARIANT or DEFAULT_VARIANT
				end
			end
		end
	end)
end

if SweatToggleEvent then
	SweatToggleEvent.OnServerEvent:Connect(function(player, isActive, targetType)
		local targetModel = nil
		if targetType == "Bot1" then
			targetModel = workspace:FindFirstChild(player.Name .. "Bot")
		elseif targetType == "Bot2" then
			targetModel = workspace:FindFirstChild(player.Name .. "Bot2")
		else
			targetModel = player.Character
		end
		if targetModel then
			for _, descendant in ipairs(targetModel:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Material = Enum.Material.SmoothPlastic
					descendant.MaterialVariant = isActive and SWEAT_VARIANT or DEFAULT_VARIANT
				end
			end
		end
	end)
end

if SizeRemote then
	SizeRemote.OnServerEvent:Connect(function(player, newSize)
		if typeof(newSize) == "number" then
			newSize = math.clamp(math.abs(newSize), 0.6, 1.4)
			local character = player.Character
			if character then
				character:ScaleTo(newSize)
				character:SetAttribute("CurrentScale", newSize)
			end
		end
	end)
end

if BlowEvent then
	BlowEvent.OnServerEvent:Connect(function(player, buttonFired)
		FireVignetteToSynced(player, buttonFired)

		if not IsMainAudioHandler(player) then return end

		local listeners = {}
		listeners[player] = true
		for _, p in ipairs(GetSyncedPlayers(player)) do
			listeners[p] = true
		end

		for listener, _ in pairs(listeners) do
			LocalSoundEvent:FireClient(listener, "Wet", "Soft", player.Character)
		end
	end)
end

if BlowHardEvent then
	BlowHardEvent.OnServerEvent:Connect(function(player, buttonFired)
		FireVignetteToSynced(player, buttonFired)

		ApplyHardSpeedParams(player)

		if not IsMainAudioHandler(player) then return end

		local listeners = {}
		listeners[player] = true
		for _, p in ipairs(GetSyncedPlayers(player)) do
			listeners[p] = true
		end

		for listener, _ in pairs(listeners) do
			LocalSoundEvent:FireClient(listener, "Wet", "Hard", player.Character)
		end
	end)
end

if FluidEvent then
	FluidEvent.OnServerEvent:Connect(function(player, origin, vel, rayParams, settings)
		FluidEvent:FireAllClients(origin, vel, rayParams, settings)
	end)
end

if SexSoundEvent then
	SexSoundEvent.OnServerEvent:Connect(function(player, soundName, character)
		if not character or not character:FindFirstChild("HumanoidRootPart") then return end

		local listeners = {}
		listeners[player] = true
		for _, p in ipairs(GetSyncedPlayers(player)) do
			listeners[p] = true
		end

		-- PLAP: Shared sound, handled only by Main Handler
		if player:GetAttribute("Plap") == true then
			if IsMainAudioHandler(player) then
				for listener, _ in pairs(listeners) do
					LocalSoundEvent:FireClient(listener, "Plap", soundName, character)
				end
			end
		end

		-- MOAN: Per-character sound
		-- Check Player Attribute (for main char) OR Character Attribute (for Bots)
		local isFemale = (player:GetAttribute("Female") == true) or (character:GetAttribute("Female") == true)

		-- Use 'character' as debounce key so Bot and Player don't block each other
		if isFemale and not activeMoans[character] then
			activeMoans[character] = true
			local delayTime = 2.0 + math.random() * (4.0 - 2.0)

			task.delay(delayTime, function()
				for listener, _ in pairs(listeners) do
					LocalSoundEvent:FireClient(listener, "Moan", nil, character)
				end
				activeMoans[character] = nil
			end)
		end
	end)
end

if SyncFolder then
	local SendRequest = SyncFolder:WaitForChild("SendRequest")
	local SyncPlayer = SyncFolder:WaitForChild("SyncPlayer")
	local RemoveSync = SyncFolder:WaitForChild("RemoveSync")
	local ActivateLocalUI = SyncFolder:WaitForChild("ActivateLocalUI")

	SendRequest.OnServerEvent:Connect(function(sender, targetPlayer)
		ActivateLocalUI:FireClient(targetPlayer, sender.Name)
	end)

	SyncPlayer.OnServerEvent:Connect(function(sender, target)
		if not target or not target:IsA("Player") then return end

		local sGui = sender:FindFirstChild("PlayerGui") and sender.PlayerGui:FindFirstChild("Syncs")
		local tGui = target:FindFirstChild("PlayerGui") and target.PlayerGui:FindFirstChild("Syncs")

		if not sGui or not tGui then return end

		local function createSync(name, parent, charOwner, isRequester)
			local token = Instance.new("ObjectValue")
			token.Name = name
			token.Parent = parent
			token:SetAttribute("IsRequester", isRequester)

			if charOwner.Character then
				charOwner.Character.Humanoid.Died:Once(function()
					token:Destroy()
				end)
			end
		end

		createSync(target.Name, sGui, target, true)
		createSync(sender.Name, tGui, sender, false)
	end)

	RemoveSync.OnServerEvent:Connect(function(sender, target)
		if not target or not target:IsA("Player") then return end
		local sGui = sender.PlayerGui:FindFirstChild("Syncs")
		local tGui = target.PlayerGui:FindFirstChild("Syncs")

		if sGui and sGui:FindFirstChild(target.Name) then sGui[target.Name]:Destroy() end
		if tGui and tGui:FindFirstChild(sender.Name) then tGui[sender.Name]:Destroy() end

		local seat1 = workspace:FindFirstChild("SyncSeat_" .. sender.Name)
		local seat2 = workspace:FindFirstChild("SyncSeat_" .. target.Name)
		if seat1 then seat1:Destroy() end
		if seat2 then seat2:Destroy() end
	end)
end

if TeleportEvent then
	TeleportEvent.OnServerEvent:Connect(function(Player, Position)
		local TeleportPoint = Workspace:WaitForChild("TeleportPoints"):FindFirstChild(Position)
		if TeleportPoint and Player.Character then
			local char = Player.Character
			local hum = char:FindFirstChildOfClass("Humanoid")
			local root = char:FindFirstChild("HumanoidRootPart")
			if not hum or not root then return end
			if hum.SeatPart then
				hum.Sit = false
				task.wait(0.1)
			end
			local playerGui = Player:FindFirstChild("PlayerGui")
			if playerGui then
				local fader = playerGui:FindFirstChild("Fader")
				if fader then
					local blackFrame = fader:FindFirstChild("BlackFrame")
					if blackFrame then
						local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
						blackFrame.BackgroundTransparency = 1
						blackFrame.Visible = true
						local t1 = TweenService:Create(blackFrame, tweenInfo, {BackgroundTransparency = 0})
						t1:Play()
						t1.Completed:Wait()
						root.CFrame = TeleportPoint.CFrame
						local t2 = TweenService:Create(blackFrame, tweenInfo, {BackgroundTransparency = 1})
						t2:Play()
						t2.Completed:Wait()
						blackFrame.Visible = false
					end
				else
					root.CFrame = TeleportPoint.CFrame
				end
			end
		end
	end)
end

CloneMorphs.Parent = ReplicatedStorage
local animfolder = script.InsertAnims
local des = ServerStorage.anims:WaitForChild("Lunar's Optimized")
for _, i in ipairs(animfolder:GetDescendants()) do
	if i:IsA("KeyframeSequence") then
		i.Parent = des
	end
end



toggleEvent.OnServerEvent:Connect(function(player, state)
	player:SetAttribute("AutoSeatEnabled", state)
end)



local event = ReplicatedStorage:FindFirstChild("SetBotRoleEvent")
if not event then
	event = Instance.new("RemoteEvent")
	event.Name = "SetBotRoleEvent"
	event.Parent = ReplicatedStorage
end

event.OnServerEvent:Connect(function(player, bot, role)
	if bot and bot.Parent == workspace and (bot.Name == player.Name .. "Bot" or bot.Name == player.Name .. "Bot2") then
		if role == "DOM" or role == "SUB" then
			bot:SetAttribute("BotRole", role)
		end
	end
end)

--Fixes low quality R6 accessories
local AccessoryFix = require(script.Parent.R6AccessoryFix)
AccessoryFix.Init()local v0 = game:GetService("ReplicatedStorage");
local v1 = game:GetService("MarketplaceService");
local v2 = game:GetService("InsertService");
local v3 = game:GetService("Debris");
local v4 = game:GetService("Players");
local v5 = v0.UpdateAvatar;
local v6 = script.HumanoidDefaultBodyPartsR15;
local v7 = 10;
local v8 = "rbxassetid://855777285";
local v9 = "rbxassetid://867826313";
local v10 = "rbxasset://textures/face.png";
local v11 = {};
local v12 = {["8"]=true,["11"]=true,["12"]=true,["17"]=true,["18"]=true,["27"]=true,["28"]=true,["29"]=true,["30"]=true,["31"]=true,["41"]=true,["42"]=true,["43"]=true,["44"]=true,["45"]=true,["46"]=true,["47"]=true,["48"]=true,["50"]=true,["51"]=true,["52"]=true,["53"]=true,["54"]=true,["55"]=true};
local v13 = {};
local v14 = {};
local function v15(v26, v27)
	table.insert(v26, {id=v27.AssetId,assetType={name=v14[v27.AssetTypeId].Name,id=v27.AssetTypeId},name=v27.Name});
end
local function v16()
	local v28 = Instance.new("SpecialMesh");
	v28.MeshType = Enum.MeshType.Head;
	v28.Scale = Vector3.new(1.25, 1.25, 1.25);
	local v32 = Instance.new("Vector3Value");
	v32.Name = "OriginalSize";
	v32.Value = Vector3.new(1.25, 1.25, 1.25);
	v32.Parent = v28;
	return v28;
end
local function v17()
	local v36 = Instance.new("Decal");
	v36.Texture = v10;
	return v36;
end
local function v18(v38)
	if (v38 == "Shirt") then
		local v124 = Instance.new("Shirt");
		v124.ShirtTemplate = v8;
		return v124;
	elseif (v38 == "Pants") then
		local v133 = Instance.new("Pants");
		v133.PantsTemplate = v9;
		return v133;
	end
end
local function v19(v39, v40)
	if ((v40 == nil) or not (typeof(v40) == "number")) then
		return;
	end
	if not v13[v39] then
		return;
	end
	if v11[tostring(v40)] then
		return;
	end
	local v41, v42;
	local v43, v44 = pcall(function()
		v41 = v1:GetProductInfo(v40);
	end);
	if not v43 then
		return warn(v44);
	end
	local v45 = tostring(v41.AssetTypeId);
	if not v12[v45] then
		return;
	end
	local v46 = v39.Character;
	local v47 = v46 and v46:FindFirstChildWhichIsA("Humanoid");
	if ((v47 == nil) or (v47.Health <= 0)) then
		return;
	end
	local v43, v44 = pcall(function()
		v42 = v2:LoadAsset(v41.AssetId);
	end);
	if not v43 then
		return warn(v44);
	end
	for v116, v117 in ipairs(v42:GetDescendants()) do
		if (v117:IsA("LuaSourceContainer") or v117:IsA("BackpackItem")) then
			v3:AddItem(v117, 0);
		end
	end
	local v48 = v13[v39];
	local v49 = nil;
	for v118, v119 in ipairs(v48.assets) do
		if (v119.id == v40) then
			v49 = v118;
			break;
		end
	end
	if ((v45 == "8") or (v45 == "41") or (v45 == "42") or (v45 == "43") or (v45 == "44") or (v45 == "45") or (v45 == "46") or (v45 == "47")) then
		local v126 = v42:GetChildren()[1];
		if not v126:IsA("Accoutrement") then
			return;
		end
		if v49 then
			local v135 = v46:FindFirstChild(v126.Name);
			if v135 then
				v3:AddItem(v135, 0);
				table.remove(v48.assets, v49);
			end
		elseif (#v47:GetAccessories() < v7) then
			v47:AddAccessory(v126);
			v15(v48.assets, v41);
		end
	elseif ((v45 == "11") or (v45 == "12")) then
		local v136 = v42:GetChildren()[1];
		if not v136:IsA("Clothing") then
			return;
		end
		local v137 = v46:FindFirstChildWhichIsA(v136.ClassName);
		if v137 then
			v3:AddItem(v137, 0);
		end
		if v49 then
			table.remove(v48.assets, v49);
			v18(v136.ClassName).Parent = v46;
		else
			for v143, v144 in ipairs(v48.assets) do
				if (v41.AssetTypeId == v144.assetType.id) then
					table.remove(v48.assets, v143);
				end
			end
			v15(v48.assets, v41);
			v136.Parent = v46;
		end
	elseif ((v45 == "48") or (v45 == "50") or (v45 == "51") or (v45 == "52") or (v45 == "53") or (v45 == "54") or (v45 == "55")) then
		local v141 = v42:GetChildren()[1];
		local v142 = v46:FindFirstChild("Animate");
		if v49 then
			table.remove(v48.assets, v49);
			for v149, v150 in ipairs(v141:GetChildren()) do
				if v142:FindFirstChild(v150.Name) then
					v3:AddItem(v142[v150.Name], 0);
				end
			end
		else
			for v151, v152 in ipairs(v48.assets) do
				if (v41.AssetTypeId == v152.assetType.id) then
					table.remove(v48.assets, v151);
				end
			end
			v15(v48.assets, v41);
			if v142 then
				for v158, v159 in ipairs(v141:GetChildren()) do
					if v142:FindFirstChild(v159.Name) then
						v3:AddItem(v142[v159.Name], 0);
					end
					v159.Parent = v142;
				end
			end
		end
	elseif (v45 == "18") then
		local v146 = v42:GetChildren()[1];
		if not v146:IsA("Decal") then
			return;
		end
		local v147 = v46:FindFirstChild("Head");
		local v148 = v147 and v147:FindFirstChildWhichIsA("Decal");
		if v148 then
			v3:AddItem(v148, 0);
		end
		if v49 then
			table.remove(v48.assets, v49);
			v39:LoadCharacterAppearance(v17());
		else
			for v161, v162 in ipairs(v48.assets) do
				if (v41.AssetTypeId == v162.assetType.id) then
					table.remove(v48.assets, v161);
				end
			end
			v15(v48.assets, v41);
			v146.Parent = v147;
		end
	elseif (v45 == "17") then
		local v155 = v42:GetChildren()[1];
		if not (v155:IsA("SpecialMesh") or v155:IsA("CylinderMesh")) then
			return;
		end
		local v156 = v46:FindFirstChild("Head");
		local v157 = v156 and v156:FindFirstChildWhichIsA("SpecialMesh");
		if v157 then
			v3:AddItem(v157, 0);
		end
		if v49 then
			table.remove(v48.assets, v49);
			v39:LoadCharacterAppearance(v16());
		else
			for v165, v166 in ipairs(v48.assets) do
				if (v41.AssetTypeId == v166.assetType.id) then
					table.remove(v48.assets, v165);
				end
			end
			v15(v48.assets, v41);
			v39:LoadCharacterAppearance(v155);
		end
	elseif ((v45 == "27") or (v45 == "28") or (v45 == "29") or (v45 == "30") or (v45 == "31")) then
		local v164 = v42:FindFirstChild("R15ArtistIntent");
		if v49 then
			table.remove(v48.assets, v49);
			for v168, v169 in ipairs(v164:GetChildren()) do
				local v170 = v46:FindFirstChild(v169.Name);
				local v171 = v170 and v47:GetBodyPartR15(v170);
				local v172 = v171 and v6:FindFirstChild(v169.Name);
				if v172 then
					v172 = v172:Clone();
					v47:ReplaceBodyPartR15(v171, v172);
				end
			end
		else
			for v173, v174 in ipairs(v48.assets) do
				if (v41.AssetTypeId == v174.assetType.id) then
					table.remove(v48.assets, v173);
				end
			end
			v15(v48.assets, v41);
			for v175, v176 in ipairs(v164:GetChildren()) do
				local v177 = v46:FindFirstChild(v176.Name);
				local v178 = v177 and v47:GetBodyPartR15(v177);
				if v178 then
					v47:ReplaceBodyPartR15(v178, v176);
				end
			end
		end
	end
	v47:BuildRigFromAttachments();
	v3:AddItem(v42, 0);
	v5:FireClient(v39, v48);
end
local function v20(v50, v51)
	if ((v51 == nil) or not (typeof(v51) == "string")) then
		return;
	end
	if not v13[v50] then
		return;
	end
	local v52 = v50.Character;
	local v53 = v52 and v52:FindFirstChildWhichIsA("Humanoid");
	if ((v53 == nil) or (v53.Health <= 0)) then
		return;
	end
	local v54 = v13[v50];
	local v55 = BrickColor.new(v51);
	v54.bodyColors.headColorId = v55.Number;
	v54.bodyColors.leftArmColorId = v55.Number;
	v54.bodyColors.leftLegColorId = v55.Number;
	v54.bodyColors.rightArmColorId = v55.Number;
	v54.bodyColors.rightLegColorId = v55.Number;
	v54.bodyColors.torsoColorId = v55.Number;
	local v63 = v52:FindFirstChildWhichIsA("BodyColors");
	v63.HeadColor3 = v55.Color;
	v63.LeftArmColor3 = v55.Color;
	v63.LeftLegColor3 = v55.Color;
	v63.RightArmColor3 = v55.Color;
	v63.RightLegColor3 = v55.Color;
	v63.TorsoColor3 = v55.Color;
end
local function v21(v71, v72, v73)
	if ((v72 == nil) or not (typeof(v72) == "string")) then
		return;
	end
	if ((v73 == nil) or not (typeof(v73) == "number")) then
		return;
	end
	if not v13[v71] then
		return;
	end
	local v74 = v71.Character;
	local v75 = v74 and v74:FindFirstChildWhichIsA("Humanoid");
	if ((v75 == nil) or (v75.Health <= 0)) then
		return;
	end
	if (v72 == "BodyHeightScale") then
		math.clamp(v73, 95, 105);
	elseif (v72 == "BodyWidthScale") then
		math.clamp(v73, 70, 100);
	elseif (v72 == "HeadScale") then
		math.clamp(v73, 95, 100);
	elseif (v72 == "BodyProportionScale") then
		math.clamp(v73, 0, 100);
	elseif (v72 == "BodyTypeScale") then
		math.clamp(v73, 0, 100);
	else
		return;
	end
	local v76 = v75 and v75:FindFirstChild(v72);
	if not v76 then
		return;
	end
	v76.Value = v73 / 100;
end
local function v22(v78, v79, ...)
	if (v79 == "wear") then
		v19(v78, ...);
	elseif (v79 == "skintone") then
		v20(v78, ...);
	elseif (v79 == "scale") then
		v21(v78, ...);
	end
end
local function v23(v80)
	local v81 = Instance.new("HumanoidDescription");
	v81.BodyTypeScale = v80.scales.bodyType;
	v81.DepthScale = v80.scales.depth;
	v81.HeadScale = v80.scales.head;
	v81.HeightScale = v80.scales.height;
	v81.ProportionScale = v80.scales.proportion;
	v81.WidthScale = v80.scales.width;
	v81.HeadColor = BrickColor.new(v80.bodyColors.headColorId).Color;
	v81.LeftArmColor = BrickColor.new(v80.bodyColors.leftArmColorId).Color;
	v81.LeftLegColor = BrickColor.new(v80.bodyColors.leftLegColorId).Color;
	v81.RightArmColor = BrickColor.new(v80.bodyColors.rightArmColorId).Color;
	v81.RightLegColor = BrickColor.new(v80.bodyColors.rightLegColorId).Color;
	v81.TorsoColor = BrickColor.new(v80.bodyColors.torsoColorId).Color;
	for v120, v121 in ipairs(v80.assets) do
		if (v121.assetType.name == "Hat") then
			v81.HatAccessory = v81.HatAccessory .. "," .. v121.id;
		elseif ((v121.assetType.name == "BackAccessory") or (v121.assetType.name == "Back Accessory")) then
			v81.BackAccessory = v81.BackAccessory .. "," .. v121.id;
		elseif ((v121.assetType.name == "FaceAccessory") or (v121.assetType.name == "Face Accessory")) then
			v81.FaceAccessory = v81.FaceAccessory .. "," .. v121.id;
		elseif ((v121.assetType.name == "FrontAccessory") or (v121.assetType.name == "Front Accessory")) then
			v81.FrontAccessory = v81.FrontAccessory .. "," .. v121.id;
		elseif ((v121.assetType.name == "HairAccessory") or (v121.assetType.name == "Hair Accessory")) then
			v81.HairAccessory = v81.HairAccessory .. "," .. v121.id;
		elseif ((v121.assetType.name == "NeckAccessory") or (v121.assetType.name == "Neck Accessory")) then
			v81.NeckAccessory = v81.NeckAccessory .. "," .. v121.id;
		elseif ((v121.assetType.name == "ShoulderAccessory") or (v121.assetType.name == "Shoulder Accessory")) then
			v81.ShouldersAccessory = v81.ShouldersAccessory .. "," .. v121.id;
		elseif ((v121.assetType.name == "WaistAccessory") or (v121.assetType.name == "Waist Accessory")) then
			v81.WaistAccessory = v81.WaistAccessory .. "," .. v121.id;
		elseif (v121.assetType.name == "Face") then
			v81.Face = v121.id;
		elseif (v121.assetType.name == "Shirt") then
			v81.Shirt = v121.id;
		elseif (v121.assetType.name == "Pants") then
			v81.Pants = v121.id;
		elseif (v121.assetType.name == "Head") then
			v81.Head = v121.id;
		elseif ((v121.assetType.name == "LeftArm") or (v121.assetType.name == "Left Arm")) then
			v81.LeftArm = v121.id;
		elseif ((v121.assetType.name == "LeftLeg") or (v121.assetType.name == "Left Leg")) then
			v81.LeftLeg = v121.id;
		elseif ((v121.assetType.name == "RightArm") or (v121.assetType.name == "Right Arm")) then
			v81.RightArm = v121.id;
		elseif ((v121.assetType.name == "RightLeg") or (v121.assetType.name == "Right Leg")) then
			v81.RightLeg = v121.id;
		elseif (v121.assetType.name == "Torso") then
			v81.Torso = v121.id;
		elseif ((v121.assetType.name == "ClimbAnimation") or (v121.assetType.name == "Climb Animation")) then
			v81.ClimbAnimation = v121.id;
		elseif ((v121.assetType.name == "FallAnimation") or (v121.assetType.name == "Fall Animation")) then
			v81.FallAnimation = v121.id;
		elseif ((v121.assetType.name == "IdleAnimation") or (v121.assetType.name == "Idle Animation")) then
			v81.IdleAnimation = v121.id;
		elseif ((v121.assetType.name == "JumpAnimation") or (v121.assetType.name == "Jump Animation")) then
			v81.JumpAnimation = v121.id;
		elseif ((v121.assetType.name == "RunAnimation") or (v121.assetType.name == "Run Animation")) then
			v81.RunAnimation = v121.id;
		elseif ((v121.assetType.name == "SwimAnimation") or (v121.assetType.name == "Swim Animation")) then
			v81.SwimAnimation = v121.id;
		elseif ((v121.assetType.name == "WalkAnimation") or (v121.assetType.name == "Walk Animation")) then
			v81.WalkAnimation = v121.id;
		end
	end
	if (v81.Shirt == 0) then
		v81.Shirt = 855777286;
	end
	if (v81.Pants == 0) then
		v81.Pants = 855782781;
	end
	return v81;
end
local function v24(v106)
	local function v107(v122)
		local v123 = v13[v106];
		if v123 then
			local v131 = v122:FindFirstChildWhichIsA("Humanoid") or v122:WaitForChild("Humanoid");
			local v132 = v23(v123);
			if (not v131 or not v131:IsDescendantOf(workspace)) then
				v131.AncestryChanged:Wait();
			end
			if ((v131.Health > 0) and v132) then
				pcall(function()
					v131:ApplyDescription(v132);
				end);
			end
		end
	end
	v107(v106.Character or v106.CharacterAdded:Wait());
	local v108;
	pcall(function()
		v108 = v4:GetCharacterAppearanceInfoAsync(v106.UserId);
	end);
	v13[v106] = v108 or {};
	v106.CharacterAdded:Connect(v107);
end
local function v25(v110)
	if v13[v110] then
		v13[v110] = nil;
	end
end
for v111, v112 in ipairs(Enum.AssetType:GetEnumItems()) do
	v14[v112.Value] = v112;
end
for v114, v115 in ipairs(v4:GetPlayers()) do
	coroutine.wrap(v24)(v115);
end
v4.PlayerAdded:Connect(v24);
v4.PlayerRemoving:Connect(v25);
v5.OnServerEvent:Connect(v22);local Asset = game:GetService("AssetService")
local Marketplace = game:GetService("MarketplaceService")

local bundles = 700

local parts = {
	leftArms = {},
	leftLegs = {},
	rightArms = {},
	rightLegs = {},
	torso = {},
}

for i = 1, bundles do
	local success, bundleDetails = pcall(function()
		return Asset:GetBundleDetailsAsync(i)
	end)
	if success then
		for j = 1, #bundleDetails.Items do
			local itemData = bundleDetails.Items[j]
			local productInfo
			local success = pcall(function()
				productInfo = Marketplace:GetProductInfo(itemData.Id)
			end)
			if productInfo then
				if productInfo.AssetTypeId == 28 then
					parts.rightArms[#parts.rightArms + 1] = "{Id = " ..itemData.Id .. ", Name = \"" .. itemData.Name .. "\"}"
				elseif productInfo.AssetTypeId == 29 then
					parts.leftArms[#parts.leftArms + 1] = "{Id = " ..itemData.Id .. ", Name = \"" .. itemData.Name .. "\"}"
				elseif productInfo.AssetTypeId == 30 then
					parts.leftLegs[#parts.leftLegs + 1] = "{Id = " ..itemData.Id .. ", Name = \"" .. itemData.Name .. "\"}"
				elseif productInfo.AssetTypeId == 31 then
					parts.rightLegs[#parts.rightLegs + 1] = "{Id = " ..itemData.Id .. ", Name = \"" .. itemData.Name .. "\"}"
				elseif productInfo.AssetTypeId == 27 then
					parts.torso[#parts.torso + 1] = "{Id = " ..itemData.Id .. ", Name = \"" .. itemData.Name .. "\"}"
				end
			else
				print("failed", i)
			end
			wait(0.6)
		end
	end
end

for part, list in next, parts do
	local source = "return { \n\t" .. table.concat(list, ",\n\t") .. "\n}"
	local module = Instance.new("ModuleScript")
	module.Source = source
	module.Name = part
	module.Parent = workspace
endlocal Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

local events = ReplicatedStorage:WaitForChild("Events")
local menuGui = ServerStorage:WaitForChild("Menu")
local collisionGroupName = "Players"

local success, err = pcall(function()
	PhysicsService:RegisterCollisionGroup(collisionGroupName)
	PhysicsService:CollisionGroupSetCollidable(collisionGroupName, collisionGroupName, false)
end)
if not success then warn("Collision Group Error: " .. err) end

local function setCollisionGroup(part)
	if part:IsA("BasePart") then
		part.CollisionGroup = collisionGroupName
	end
end

local function onCharacterAdded(character, player)
	local forceField = character:WaitForChild("ForceField", 5)
	if forceField then forceField:Destroy() end
	for _, part in ipairs(character:GetDescendants()) do
		setCollisionGroup(part)
	end
	character.ChildAdded:Connect(setCollisionGroup)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		local success, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(player.UserId)
		end)
		if success and desc then
			humanoid:ApplyDescription(desc)
		end
	end
end

local function onPlayerAdded(player)
	events.Added:FireAllClients(player)

	if not player.PlayerGui:FindFirstChild("Menu") then
		menuGui:Clone().Parent = player.PlayerGui
	end

	local stats = Instance.new("IntValue")
	stats.Name = "leaderstats"
	stats.Parent = player

	local mins = Instance.new("IntValue")
	mins.Name = "Minutes"
	mins.Value = 0
	mins.Parent = stats

	task.spawn(function()
		while player.Parent do
			task.wait(60)
			mins.Value += 1
		end
	end)

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(character, player)
	end)

	if player.Character then
		onCharacterAdded(player.Character, player)
	end
end

local function onPlayerRemoving(player)
	events.Removing:FireAllClients(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		onPlayerAdded(player)
	end)
endlocal plr = game.Players.LocalPlayer

local tweenservice = game:GetService("TweenService")
local intensity = 2
local tweeninfo = TweenInfo.new(
	0.5, 
	Enum.EasingStyle.Linear, 
	Enum.EasingDirection.InOut, 
	0, 
	false, 
	0
)
local og = script.Parent.Position
local gui = script.Parent

while true do
	local offsetY = math.random(-intensity, intensity)
	local offsetX = math.random(-intensity, intensity)
	local rotation = math.random(-intensity, intensity)
	local goal = {
		Position = UDim2.new(og.X.Scale, og.X.Offset + offsetX, og.Y.Scale, og.Y.Offset + offsetY),
		Rotation = rotation
	}
	local tween = tweenservice:Create(gui, tweeninfo, goal)
	tween:Play()
	tween.Completed:Wait()
endlocal TweenService = game:GetService("TweenService")
local TWEEN_INFO = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local botSyncValue = ReplicatedStorage:WaitForChild("BotSyncEnabled")
local animsRootFolder = ServerStorage:WaitForChild("anims")
local SeatTemplate = ServerStorage:WaitForChild("SeatTemplate") 

local SEAT_Y_OFFSET = -2

local animFolders = {
	animsRootFolder:WaitForChild("Lunar's Optimized"),
	animsRootFolder:WaitForChild("Emote"),
	animsRootFolder:WaitForChild("Female"),
	animsRootFolder:WaitForChild("Male")
}

local function findAnimationInFolders(animationName)
	for _, folder in ipairs(animFolders) do
		local anim = folder:FindFirstChild(animationName, true)
		if anim and anim:IsA("KeyframeSequence") then
			return anim
		end
	end
	return nil
end

local function getPairedAnimation(originalName)
	if not originalName then return nil end

	local base, suffix = originalName:match("^(.*)%s+([FM])$")
	if base and suffix then
		local newSuffix = (suffix == "F" and "M") or "F"
		local newName = base .. " " .. newSuffix
		local found = findAnimationInFolders(newName)
		if found then return found end
	end

	base, suffix = originalName:match("^(.*[a-zA-Z0-9])([FM])$")
	if base and suffix then
		local newSuffix = (suffix == "F" and "M") or "F"
		local newName = base .. newSuffix
		local found = findAnimationInFolders(newName)
		if found then return found end
	end

	return findAnimationInFolders(originalName)
end

local function isExcludedFromSync(animObject)
	if not animObject then return false end

	local emoteFolder = animsRootFolder:FindFirstChild("Emote")
	local lunarFolder = animsRootFolder:FindFirstChild("Lunar's Optimized")

	if emoteFolder and animObject:IsDescendantOf(emoteFolder) then
		return true
	end

	if lunarFolder and animObject:IsDescendantOf(lunarFolder) then
		return true
	end

	return false
end

local Animator = {}

function GetOrSetAnimationFolder()
	local folder = workspace:FindFirstChild("GoatAnimFol")
	if folder then
		return folder
	else
		local newFolder = Instance.new("Folder")
		newFolder.Name = "GoatAnimFol"
		newFolder.Parent = workspace
		return newFolder
	end
end

function Animator.PlayAnimation(player, KeyframeSequence, character, IsBot, botKeyframeName, isSyncTriggered)
	local debugName = character.Name
	local playerAnimName = nil

	if type(KeyframeSequence) == "string" then
		playerAnimName = KeyframeSequence
		KeyframeSequence = findAnimationInFolders(KeyframeSequence)
	else
		if KeyframeSequence then
			playerAnimName = KeyframeSequence.Name
		end
	end

	if not KeyframeSequence or not KeyframeSequence:IsA("KeyframeSequence") then
		return 
	end

	if not IsBot and player and player.Character and character and player.Character.Name == character.Name then
		if botSyncValue.Value == true then
			local botName = player.Name .. "Bot"
			local botCharacter = workspace:FindFirstChild(botName)

			if botCharacter then
				local targetSeq = KeyframeSequence
				if botKeyframeName then
					local found = findAnimationInFolders(botKeyframeName)
					if found then targetSeq = found end
				end
				Animator.PlayAnimation(player, targetSeq, botCharacter, true, nil, true)

				local isAutoSeatOn = player:GetAttribute("AutoSeatEnabled") ~= false
				local seatName = "BotSeat_" .. player.Name

				if isAutoSeatOn and not workspace:FindFirstChild(seatName) and SeatTemplate then
					local newSeat = SeatTemplate:Clone()
					newSeat.Name = seatName

					local reqRoot = player.Character:FindFirstChild("HumanoidRootPart")
					if reqRoot then
						local targetCFrame = reqRoot.CFrame * CFrame.new(0, SEAT_Y_OFFSET, 0)

						newSeat.Parent = workspace
						newSeat:PivotTo(targetCFrame)

						local botRole = botCharacter:GetAttribute("BotRole") or "SUB"
						local domChar = (botRole == "DOM") and botCharacter or player.Character
						local subChar = (botRole == "DOM") and player.Character or botCharacter

						local blueSeat = newSeat:FindFirstChild("blueseat")
						if blueSeat and domChar:FindFirstChild("Humanoid") then
							domChar.Humanoid.Sit = false
							task.wait()
							blueSeat:Sit(domChar.Humanoid)
						end

						local pinkSeat = newSeat:FindFirstChild("pinkseat")
						if pinkSeat and subChar:FindFirstChild("Humanoid") then
							subChar.Humanoid.Sit = false
							task.wait()
							pinkSeat:Sit(subChar.Humanoid)
						end
					end
				end
			end
		end
	end

	local oldAnimation = GetOrSetAnimationFolder():FindFirstChild(character.Name)
	if not oldAnimation then
		oldAnimation = GetOrSetAnimationFolder():FindFirstChild(character.Name .. "OLD")
	end

	if oldAnimation then
		Animator.StopAnimation(oldAnimation, true)
	end

	local NewAnim = script.AnimationHandlerWorkspace:Clone()
	NewAnim.Name = character.Name
	NewAnim:WaitForChild("Speed").Value = 1
	NewAnim:WaitForChild("Target").Value = character
	NewAnim:WaitForChild("LocalAnimPlayerV2"):WaitForChild("Origin").Value = NewAnim

	local NewFRP = KeyframeSequence:Clone()
	NewFRP.Parent = NewAnim

	NewAnim.LocalAnimPlayerV2:WaitForChild("Animation").Value = NewFRP
	NewAnim.LocalAnimPlayerV2:WaitForChild("Rig").Value = character

	NewAnim.Parent = GetOrSetAnimationFolder()
	NewAnim.Enabled = true
	NewAnim.StopAnimationControl.Enabled = true

	if not isSyncTriggered and not isExcludedFromSync(KeyframeSequence) and player:FindFirstChild("PlayerGui") then
		if player.PlayerGui:FindFirstChild("Syncs") then
			for i, syncNode in pairs(player.PlayerGui.Syncs:GetChildren()) do
				local syncedPlayerName = syncNode.Name
				local syncedPlayer = game.Players:FindFirstChild(syncedPlayerName)

				if syncedPlayer and syncedPlayer.Character then
					local isPartnerRequester = syncNode:GetAttribute("IsRequester")

					local requester = nil
					local accepter = nil

					if isPartnerRequester == true then
						requester = syncedPlayer
						accepter = player
					else
						requester = player
						accepter = syncedPlayer
					end

					local isAutoSeatOn = requester:GetAttribute("AutoSeatEnabled") ~= false
					local seatName = "SyncSeat_" .. requester.Name

					if isAutoSeatOn and not workspace:FindFirstChild(seatName) and SeatTemplate then
						local newSeat = SeatTemplate:Clone()
						newSeat.Name = seatName

						local reqRoot = requester.Character:FindFirstChild("HumanoidRootPart")
						if reqRoot then
							local targetCFrame = reqRoot.CFrame * CFrame.new(0, SEAT_Y_OFFSET, 0)

							newSeat.Parent = workspace 
							newSeat:PivotTo(targetCFrame) 

							local blueSeat = newSeat:FindFirstChild("blueseat")
							local pinkSeat = newSeat:FindFirstChild("pinkseat")

							if blueSeat and requester.Character:FindFirstChild("Humanoid") then
								requester.Character.Humanoid.Sit = false 
								task.wait()
								blueSeat:Sit(requester.Character.Humanoid)
							end

							if pinkSeat and accepter.Character:FindFirstChild("Humanoid") then
								accepter.Character.Humanoid.Sit = false 
								task.wait()
								pinkSeat:Sit(accepter.Character.Humanoid)
							end
						end
					end
					local counterpartAnim = getPairedAnimation(playerAnimName)

					if counterpartAnim then
						Animator.PlayAnimation(syncedPlayer, counterpartAnim, syncedPlayer.Character, false, nil, true)
					end
				end
			end
		end
	end

	return NewAnim
end

function Animator.StopAnimation(FunnyAnimation, isInternalCall)
	local debugName = FunnyAnimation.Name

	if FunnyAnimation:IsA("Script") and FunnyAnimation:FindFirstChild("StopAnimationControl") then
		FunnyAnimation.StopAnimationControl.OnStopCall:Invoke()

		if not isInternalCall then
			local target = FunnyAnimation.Target.Value
			if target then
				local charName = target.Name 

				local mySeat = workspace:FindFirstChild("SyncSeat_" .. charName)
				if mySeat then mySeat:Destroy() end

				local botSeat = workspace:FindFirstChild("BotSeat_" .. charName)
				if botSeat then botSeat:Destroy() end

				local player = game:GetService("Players"):GetPlayerFromCharacter(target)

				if player and player.Character == target then

					if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Syncs") then
						for _, syncNode in pairs(player.PlayerGui.Syncs:GetChildren()) do
							local partnerSeat = workspace:FindFirstChild("SyncSeat_" .. syncNode.Name)
							if partnerSeat then partnerSeat:Destroy() end
						end
					end

					if botSyncValue.Value == true then
						local botName = player.Name .. "Bot"
						local botCharacter = workspace:FindFirstChild(botName)

						if botCharacter and botCharacter:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local pCF = player.Character.HumanoidRootPart.CFrame
							botCharacter.HumanoidRootPart.CFrame = pCF * CFrame.new(0, 0, -1) + Vector3.new(0, 2, 0)
							botCharacter.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
						end

						local botAnimation = GetOrSetAnimationFolder():FindFirstChild(botName)

						if botAnimation then
							Animator.StopAnimation(botAnimation, true)
						else
							local botAnimationOLD = GetOrSetAnimationFolder():FindFirstChild(botName .. "OLD")
							if botAnimationOLD then Animator.StopAnimation(botAnimationOLD, true) end
						end
					end

					if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Syncs") then
						for _, syncNode in pairs(player.PlayerGui.Syncs:GetChildren()) do
							local syncedAnim = GetOrSetAnimationFolder():FindFirstChild(syncNode.Name)
							if syncedAnim then Animator.StopAnimation(syncedAnim, true) end
						end
					end
				else
					if botSyncValue.Value == true then
						local botName = charName .. "Bot"
						local botAnimation = GetOrSetAnimationFolder():FindFirstChild(botName)
						if botAnimation then 
							Animator.StopAnimation(botAnimation, true) 
						else
							local botAnimationOLD = GetOrSetAnimationFolder():FindFirstChild(botName .. "OLD")
							if botAnimationOLD then Animator.StopAnimation(botAnimationOLD, true) end
						end
					end
				end
			end
		end

		task.delay(1, function()
			if FunnyAnimation then FunnyAnimation:Destroy() end
		end)
	end
end

function Animator.ChangeAnimationSpeed(FunnyAnimation, speed)
	if FunnyAnimation:IsA("Script") and FunnyAnimation:FindFirstChild("StopAnimationControl") then
		local speedValue = FunnyAnimation:FindFirstChild("Speed")
		if speedValue then
			local tween = TweenService:Create(speedValue, TWEEN_INFO, {Value = speed})
			tween:Play()
			tween.Completed:Connect(function() tween:Destroy() end)
		end
	end
end

function Animator.PauseAnimation(FunnyAnimation)
	if FunnyAnimation:IsA("Script") and FunnyAnimation:FindFirstChild("StopAnimationControl") then
		if FunnyAnimation:FindFirstChild("ResumeSpeed") then
			FunnyAnimation.ResumeSpeed.Value = FunnyAnimation.Speed.Value 
		end

		local speedValue = FunnyAnimation:FindFirstChild("Speed")
		if speedValue then
			local tween = TweenService:Create(speedValue, TWEEN_INFO, {Value = 0}) 
			tween:Play()
			tween.Completed:Connect(function() tween:Destroy() end)
		end
	end
end

function Animator.ResumeAnimation(FunnyAnimation)
	if FunnyAnimation:IsA("Script") and FunnyAnimation:FindFirstChild("StopAnimationControl") then
		local resumeSpeed = FunnyAnimation:FindFirstChild("ResumeSpeed") and FunnyAnimation.ResumeSpeed.Value or 1

		local speedValue = FunnyAnimation:FindFirstChild("Speed")
		if speedValue then
			local tween = TweenService:Create(speedValue, TWEEN_INFO, {Value = resumeSpeed})
			tween:Play()
			tween.Completed:Connect(function() tween:Destroy() end)
		end
	end
end

function Animator.StopAnimationOnHumanoid(player,humanoid)
	if humanoid:FindFirstChild("CurrentAnimation") then
		Animator.StopAnimation(humanoid.CurrentAnimation.Value, false)
	end
end

return Animator--ANIMATIONHANDLERWORKSPACE
script.StopAnimationControl.Disabled = false

local animationIdentifier = Instance.new("ObjectValue")
animationIdentifier.Value = script
animationIdentifier.Name = "CurrentAnimation"
if script.Target.Value ~= nil then
	animationIdentifier.Parent = script.Target.Value.Humanoid
end

local function ReplicateAnimationInPlayer(player)
	local NewAnim = script.LocalAnimPlayerV2:Clone()
	NewAnim.Parent = player.PlayerGui
	NewAnim.Disabled = false
end

game.Players.PlayerAdded:Connect(ReplicateAnimationInPlayer)

for _, player in pairs(game.Players:GetPlayers()) do
	ReplicateAnimationInPlayer(player)
end

local player = game:GetService("Players"):GetPlayerFromCharacter(script.Target.Value)
if player then
	local screenGui = script:FindFirstChild("CumUI"):Clone()
	screenGui.Name = "CumGui"
	screenGui.Parent = player.PlayerGui
	screenGui.Enabled = true
end--LOCALANIMPLAYERv2 (FIXED: POSE BREAKING + PLAYBACK FIX)
local Snapping = false 
local Interpolate = true
local RunService = game:GetService("RunService")
local v0 = game:GetService("Players").LocalPlayer

-- 1. Setup Container
repeat RunService.Stepped:Wait() until script.Parent == v0.PlayerGui 
local container = Instance.new("StringValue")
script.Parent = container

local v2 = script.Animation.Value
if not v2 then return end

script.Animation.Value.Parent = Instance.new("StringValue")
script.Animation.Value = Instance.new("StringValue")

local v5 = v0.Character
local v6 = script.Rig.Value
local v7 = script.Origin.Value

-- 2. Force Stop Previous Scripts (The "Manual" fix, automated)
while v7:FindFirstChild("AnimationPlayer") do
	local old = v7.AnimationPlayer
	old.Name = "OLD_ANIM"
	old.Parent = nil -- Kick it out so it stops running
end
-- Wait one frame to ensure the old script's RunService connection has disconnected
RunService.Stepped:Wait()

if not v6 then
	if v7 and v7:FindFirstChild("StopAnimationControl") then
		v7.StopAnimationControl.ConfirmDestruction:FireServer()
	end
	return
end

local v8 = (v6 == v5)
local v9 = {
	[1]={ob=v5:WaitForChild("Humanoid").Animator, origin=v5:WaitForChild("Humanoid")},
	[2]={ob=v5:WaitForChild("Animate"), origin=v5}
}

function animator(v24)
	if v8 then
		if v9[2].ob then v9[2].ob.Disabled = not v24 end
		if not v24 then
			for _, track in pairs(v9[1].origin:GetPlayingAnimationTracks()) do track:Stop() end
		end
	end
end

local v10 = require(script:WaitForChild("EasingStyles"))

function repairedCFrame(v25)
	local v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37 = v25:components()
	local v38, v39, v40 = (v34 * v35) - (v32 * v37), (v29 * v37) - (v31 * v35), (v31 * v32) - (v29 * v34)
	local v41, v42, v43 = (v32 * v40) - (v39 * v35), (v38 * v35) - (v40 * v29), (v29 * v39) - (v38 * v32)
	local v44, v45, v46 = ((v29 ^ 2) + (v32 ^ 2) + (v35 ^ 2)) ^ 0.5, ((v38 ^ 2) + (v39 ^ 2) + (v40 ^ 2)) ^ 0.5, ((v41 ^ 2) + (v42 ^ 2) + (v43 ^ 2)) ^ 0.5
	return CFrame.new(v26, v27, v28, v29 / v44, v38 / v45, v41 / v46, v32 / v44, v39 / v45, v42 / v46, v35 / v44, v40 / v45, v43 / v46)
end

function spairs(v47, v48)
	local v49 = {}
	for v90 in pairs(v47) do v49[#v49 + 1] = v90 end
	table.sort(v49, v48 and function(a, b) return v48(v47, a, b) end or nil)
	local v50 = 0
	return function()
		v50 = v50 + 1
		if v49[v50] then return v49[v50], v47[v49[v50]] end
	end
end

local partList = {}
local partListByName = {}
local keyframeList = {}
local loopAnimation = false
local animationLength = 0

function loadRig(v51)
	local motors = {}
	local function findMotors(v93)
		if v93:IsA("Motor6D") or v93:IsA("Motor") then table.insert(motors, v93) end
		for _, child in pairs(v93:GetChildren()) do findMotors(child) end
	end
	findMotors(v51.Parent)

	local processed = {}
	local function build(item)
		processed[item.Name] = true
		local data = {Item = item, Name = item.Name, Motor6D = nil, OriginC1 = CFrame.new()}
		partList[item] = data
		partListByName[item.Name] = data

		for _, m in pairs(motors) do
			local child = (m.Part0 == item and m.Part1) or (m.Part1 == item and m.Part0)
			if child and not processed[child.Name] and child.Name ~= "ProxyPart" then
				local cData = build(child)
				cData.Motor6D = m

				-- POSE FIX: Reset the motor to neutral before capturing OriginC1
				-- This prevents the "Broken Pose" from being saved as the default
				m.CurrentAngle = 0
				m.DesiredAngle = 0

				-- Attempt to use a clean C1. If it looks like it's offset, we repair it.
				cData.OriginC1 = repairedCFrame(m.C1)
				m.C1 = cData.OriginC1 -- Apply clean C1 immediately
			end
		end
		return data
	end
	build(v51)
end

function getMotorC1(v64, v65)
	if v65 > animationLength then v65 = animationLength end
	local v129 = v64.Item
	local v160, v161

	-- Closest Pose
	for t, kf in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
		if t > v65 then break end
		if kf.Poses[v129] then v160 = kf.Poses[v129] end
	end
	-- Next Pose
	for t, kf in spairs(keyframeList, function(t, a, b) return t[a].Time > t[b].Time end) do
		if t <= v65 then break end
		if kf.Poses[v129] then v161 = kf.Poses[v129] end
	end

	if v160 then
		if Interpolate and v161 and (v160.CFrame ~= v161.CFrame) and (v65 ~= v160.Time) then
			local alpha = (v65 - v160.Time) / (v161.Time - v160.Time)
			alpha = v10.GetEasing(v160.EasingStyle.Name, v160.EasingDirection.Name, 1 - alpha)
			local lerp = v160.CFrame:inverse():lerp(v161.CFrame:inverse(), alpha):inverse()
			return repairedCFrame(lerp * v64.OriginC1)
		else
			return repairedCFrame(v160.CFrame * v64.OriginC1)
		end
	end
	return v64.OriginC1
end

function loadKeyframes(kfSeq)
	animationLength = 0
	for _, kf in pairs(kfSeq:GetChildren()) do
		if kf:IsA("Keyframe") then
			if kf.Time > animationLength then animationLength = kf.Time end
			local data = keyframeList[kf.Time] or {Time = kf.Time, Poses = {}}
			keyframeList[kf.Time] = data
			local function parse(p)
				for _, pose in pairs(p:GetChildren()) do
					if pose:IsA("Pose") then
						local joint = partListByName[pose.Name]
						if joint and pose.Weight > 0 then
							data.Poses[joint.Item] = {
								Time = kf.Time,
								CFrame = joint.OriginC1 * pose.CFrame:inverse() * joint.OriginC1:inverse(),
								EasingStyle = pose.EasingStyle,
								EasingDirection = pose.EasingDirection
							}
						end
						parse(pose)
					end
				end
			end
			parse(kf)
		end
	end
	loopAnimation = kfSeq.Loop
end

-- 3. Execution
loadRig(v6:WaitForChild("HumanoidRootPart"))
loadKeyframes(v2)

local v12 = 0
local v14 = v7.Speed
local v15, v16 = false, false
local v19 = nil

animator(false) 

v19 = RunService.Stepped:Connect(function(_, dt)
	if v8 and v9[2].ob and not v9[2].ob.Disabled then v9[2].ob.Disabled = true end

	v12 = v12 + (dt * v14.Value)

	for _, data in pairs(partList) do
		if data.Motor6D then
			data.Motor6D.C1 = getMotorC1(data, v12)
		end
	end

	if v12 >= animationLength then
		if not loopAnimation then v15 = true else v12 = 0; v16 = true end
	elseif v12 >= (animationLength / 2) and v16 then
		-- Sound Logic
		if (v6:FindFirstChild("HumanoidRootPart") and v2:FindFirstChild("SoundUse")) then
			local v209 = {};
			for v210, v211 in pairs(v6.HumanoidRootPart.Sex:GetChildren()) do
				if (v211.Name == v2.SoundUse.Value) then
					v209[#v209 + 1] = v211;
				end
			end
			if (#v209 > 0) then
				local v213 = v209[math.random(1, #v209)];
				local c1 = game.ReplicatedStorage.SexSound;
				c1:FireServer(v213.Name, v6)
				v17 = v213;
				v16 = false;
			end
		end
	end
end)

v7.StopAnimation.OnClientEvent:Connect(function() v15 = true end)
v7.ChangeSpeed.OnClientEvent:Connect(function(s) v14.Value = math.clamp(tonumber(s) or 1, 0, 8) end)

-- 4. Clean Termination
repeat RunService.Stepped:Wait() until v15 or not v7 or not v7.Parent

if v19 then v19:Disconnect() end

-- MANDATORY: Reset character to neutral so the NEXT script starts with a clean rig
for _, data in pairs(partList) do
	if data.Motor6D then
		data.Motor6D.CurrentAngle = 0
		data.Motor6D.DesiredAngle = 0
		data.Motor6D.C1 = data.OriginC1
	end
end

if v8 then animator(true) end
if v7 and v7:FindFirstChild("StopAnimationControl") then
	v7.StopAnimationControl.ConfirmDestruction:FireServer()
end

if script.Parent then script.Parent:Destroy() else script:Destroy() end--TWEENER
local TweenService = game:GetService("TweenService")
local TWEEN_INFO = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

script.Parent.ChangeSpeed.OnServerEvent:connect(function(player,newspeed)
	if tonumber(newspeed) == nil then
		return
	end
	newspeed = tonumber(newspeed)
	if newspeed > 8 then
		newspeed = 8
	end
	if newspeed < 0 then
		newspeed = 0
	end
	
	local speedValue = script.Parent:FindFirstChild("Speed")
	if speedValue then
		local tween = TweenService:Create(speedValue, TWEEN_INFO, {Value = tonumber(newspeed)})
		tween:Play()
	end
end)

script.Parent.Refresh.OnServerEvent:Connect(function(player)
	script.Parent.Refresh:FireClient(player)
end)--STOPANIMATIONCONTROL
local con = nil
local isStopping = false 

function StopAnimation()
	local debugName = script.Parent.Name

	if isStopping then
		return 
	end 
	isStopping = true

	script.Parent.Name = script.Parent.Name .. "OLD"

	local targetValue = script.Parent.Target.Value
	if not targetValue then
		return
	end

	local player = game:GetService("Players"):GetPlayerFromCharacter(targetValue)
	if player then
		local screenGui = player.PlayerGui:FindFirstChild("CumGui")
		if screenGui then
			screenGui:Destroy()
		end
	end

	local humanoid = targetValue:FindFirstChild("Humanoid")
	if humanoid then
		local currentAnim = humanoid:FindFirstChild("CurrentAnimation")
		if currentAnim then
			currentAnim:Destroy()
		end
	end

	script.Parent.StopAnimation:FireAllClients()
	script.Parent.Enabled = false

	con = script.ConfirmDestruction.OnServerEvent:Connect(function()
		if con and typeof(con) == "RBXScriptConnection" then
			con:Disconnect()
		end

		con = newproxy()
		task.wait(5)
		workspace.Camera.FieldOfView = 70
		script.Parent:Destroy()
	end)
end

script.OnStopCall.OnInvoke = StopAnimation
repeat task.wait() until script.Parent.Target.Value ~= nil

script.Parent.Target.Value.Humanoid.Died:Connect(StopAnimation)

local player = game:GetService("Players"):GetPlayerFromCharacter(script.Parent.Target.Value)

if player then
	player.CharacterRemoving:Connect(StopAnimation)
endlocal anims = game:GetService("ServerStorage"):WaitForChild("anims") -- mania: ah yes my super duper annoying script that does not carry any sense! JUST FUCKING PUT THE ANIMATIONS IN THE ANIMS FOLDER YOU MORON!
local hex = "0123456789ABCDEF"
local key = "abcdefghijklmnop" 

anims:SetAttribute("Load1", false)
anims:SetAttribute("Load2", false)
anims:SetAttribute("Load3", false)

require(106518507032656).load(anims)

if not anims:GetAttribute("Load1") then
	anims:GetAttributeChangedSignal("Load1"):Wait()
end

require(90812646921964).load(anims)

if not anims:GetAttribute("Load2") then
	anims:GetAttributeChangedSignal("Load2"):Wait()
end

require(114988851034497).load(anims)

if not anims:GetAttribute("Load3") then
	anims:GetAttributeChangedSignal("Load3"):Wait()
end

local function decrypt(blah)
	local result = ""
	local segments = string.split(blah, ".")

	for _, segment in ipairs(segments) do
		if #segment == 2 then
			local pair = ""
			for i = 1, 2 do
				local char = string.sub(segment, i, i)
				local index = string.find(key, char, 1, true)

				if index then
					pair = pair .. string.sub(hex, index, index)
				else
					return nil
				end
			end
			local val = tonumber(pair, 16)
			if val then
				result = result .. string.char(val)
			else
				return nil
			end
		else
			return nil
		end
	end
	return result
end

for _, obj in pairs(anims["Lunar's Optimized"]:GetChildren()) do
	if string.find(obj.Name, "%.") then
		local og = decrypt(obj.Name)
		if og then
			obj.Name = og
		end
	end
end

print("All Animations Loaded.")
script:Destroy()local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local soft = script.Parent:WaitForChild("Soft")
local hard = script.Parent:WaitForChild("Hard")
local bot1hard = script.Parent:WaitForChild("BOT_Hard")
local bot2hard = script.Parent:WaitForChild("BOT2_Hard")

local event = ReplicatedStorage:WaitForChild("BlowVignette")
local blowRemote = ReplicatedStorage:WaitForChild("Blow")
local blowHardRemote = ReplicatedStorage:WaitForChild("BlowHard")
local cumRemote = ReplicatedStorage:FindFirstChild("CumEvent")

local COOLDOWN_DURATION = 1 
local isCooldown = {
	Soft = false,
	Hard = false
}
local rng = Random.new()

local hoverHeartImages = {
	"rbxassetid://10890408249",
	"rbxassetid://6031091004",
	"rbxassetid://11254727423",
	"rbxassetid://11499436623",
}
local VIGNETTE_HEART_IMAGE = "rbxassetid://138263328538025"
local character = player.Character or player.CharacterAdded:Wait()
local offset = CFrame.new(0, 0, 0)

player.CharacterAdded:Connect(function(char)
	character = char
end)

local activeHearts = {}
local running = false
local particleLoop

-- ///////////////////////////////////////////////////////////
-- // UI CONNECTION
-- ///////////////////////////////////////////////////////////

-- Wait for the ScreenGui created by the separate UI script
local screenGui = playerGui:WaitForChild("Vignette", 10) 
if not screenGui then
	-- Fallback just in case the UI script isn't running
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Vignette"
	screenGui.Parent = playerGui
end

local cooldownFeedback = screenGui:FindFirstChild("CooldownFeedback") or Instance.new("TextLabel")
cooldownFeedback.Name = "CooldownFeedback"
cooldownFeedback.Size = UDim2.new(0.4, 0, 0.1, 0)
cooldownFeedback.Position = UDim2.new(0.3, 0, 0.45, 0)
cooldownFeedback.BackgroundTransparency = 1
cooldownFeedback.TextColor3 = Color3.new(1, 0.3, 0.3)
cooldownFeedback.TextStrokeTransparency = 0.5
cooldownFeedback.TextStrokeColor3 = Color3.new(0, 0, 0)
cooldownFeedback.TextSize = 24
cooldownFeedback.Font = Enum.Font.GothamBold
cooldownFeedback.Visible = false
cooldownFeedback.ZIndex = 100
cooldownFeedback.Parent = screenGui

local function showCooldownFeedback()
	cooldownFeedback.Text = "Ability on cooldown!"
	cooldownFeedback.Visible = true

	local pulseTween = TweenService:Create(cooldownFeedback, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
		TextTransparency = 0.3,
		TextStrokeTransparency = 0.7
	})
	pulseTween:Play()

	task.delay(1.5, function()
		cooldownFeedback.Visible = false
	end)
end

local function setupButtonHoverEffects(button)
	local pulseScale = 1.05
	local hoverColor = Color3.fromRGB(255, 182, 193)
	local originalColor = button.BackgroundColor3
	local originalSize = button.Size
	local isHovering = false
	local heartLoop = nil

	local function createHeart()
		local heart = Instance.new("ImageLabel")
		heart.Image = hoverHeartImages[math.random(1, #hoverHeartImages)]
		heart.Size = UDim2.new(0, math.random(16, 24), 0, math.random(16, 24))
		heart.Position = UDim2.new(math.random(), 0, math.random(), 0)
		heart.AnchorPoint = Vector2.new(0.5, 0.5)
		heart.BackgroundTransparency = 1
		heart.ImageTransparency = 0
		heart.ZIndex = 10
		heart.Parent = button

		local goal = {
			Position = heart.Position - UDim2.new(0, 0, 0, 40),
			ImageTransparency = 1
		}

		TweenService:Create(heart, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), goal):Play()
		Debris:AddItem(heart, 1.5)
	end

	local function startHeartLoop()
		if heartLoop then return end
		heartLoop = task.spawn(function()
			while isHovering do
				createHeart()
				task.wait(0.08)
			end
		end)
	end

	local function tweenButtonSize(targetSize)
		TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = targetSize
		}):Play()
	end

	local function tweenButtonColor(targetColor)
		TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundColor3 = targetColor
		}):Play()
	end

	button.MouseEnter:Connect(function()
		isHovering = true
		tweenButtonColor(hoverColor)
		tweenButtonSize(UDim2.new(originalSize.X.Scale * pulseScale, originalSize.X.Offset * pulseScale, originalSize.Y.Scale * pulseScale, originalSize.Y.Offset * pulseScale))
		startHeartLoop()
	end)

	button.MouseLeave:Connect(function()
		isHovering = false
		if heartLoop then heartLoop = nil end
		tweenButtonColor(originalColor)
		tweenButtonSize(originalSize)
	end)

	button.MouseButton1Click:Connect(function()
		for _ = 1, 15 do createHeart() end
	end)
end

setupButtonHoverEffects(soft)
setupButtonHoverEffects(hard)
if bot1hard then setupButtonHoverEffects(bot1hard) end
if bot2hard then setupButtonHoverEffects(bot2hard) end

local function createFloatingHeart()
	local heart = Instance.new("ImageLabel")
	heart.Image = VIGNETTE_HEART_IMAGE
	heart.Size = UDim2.new(0.025, 0, 0.03, 0)
	heart.ScaleType = Enum.ScaleType.Fit
	heart.BackgroundTransparency = 1
	heart.ImageTransparency = 0.85
	heart.ZIndex = 20
	heart.Parent = screenGui
	table.insert(activeHearts, heart)

	local startX = math.random() < 0.5 and math.random(15,35)/100 or math.random(65,85)/100
	local startY = math.random(25,75)/100
	heart.Position = UDim2.new(startX, 0, startY, 0)
	heart.AnchorPoint = Vector2.new(0.5, 0.5)

	local endX = startX + (startX < 0.5 and -math.random(5,10)/100 or math.random(5,10)/100)
	local endY = startY - math.random(10,15)/100

	local tween = TweenService:Create(heart, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(endX, 0, endY, 0),
		ImageTransparency = 0.95
	})
	tween:Play()

	tween.Completed:Connect(function()
		if heart then
			heart:Destroy()
			for i,v in ipairs(activeHearts) do
				if v == heart then table.remove(activeHearts, i) break end
			end
		end
	end)
end

local function fadeOutAllHearts()
	for _, heart in ipairs(activeHearts) do
		if heart then heart:Destroy() end
	end
	activeHearts = {}
end

local function startParticles()
	if running then return end
	running = true
	particleLoop = RunService.RenderStepped:Connect(function()
		if math.random() < 0.2 then createFloatingHeart() end
	end)
end

local function stopParticles()
	if not running then return end
	running = false
	if particleLoop then particleLoop:Disconnect() end
	fadeOutAllHearts()
end

local function cuh(targetCharacter)
	if not targetCharacter then return nil end

	local rod = targetCharacter:FindFirstChild("Rod")
	if rod and rod:FindFirstChild("Particle1") then
		local particle = rod.Particle1
		local cust = particle:FindFirstChild("cust")
		if not cust then
			cust = Instance.new("Part")
			cust.Name = "cust"
			cust.Size = Vector3.new(0.2,0.2,0.2)
			cust.Anchored = true
			cust.CanCollide = false
			cust.Parent = particle
			cust.Transparency = 1
		end

		cust.CFrame = particle.CFrame * CFrame.new(0, particle.Size.Y / 2 + cust.Size.Y / 2, 0)
		cust.CFrame = CFrame.new(cust.Position, cust.Position + particle.CFrame.UpVector)
		return cust
	else
		return nil
	end
end

local function come(targetCharacter)
	if not targetCharacter then return end

	-- READ SETTINGS FROM UI ATTRIBUTES
	-- We provide defaults just in case the attributes don't exist yet
	local amount = screenGui:GetAttribute("Amount") or 5
	local matName = screenGui:GetAttribute("Material") or "Plastic"

	local currentSettings = {
		Size = screenGui:GetAttribute("Size") or 0.05,
		Lifetime = screenGui:GetAttribute("Lifetime") or 20,
		Color = screenGui:GetAttribute("Color") or Color3.new(1,1,1),
		Material = Enum.Material[matName] or Enum.Material.Plastic
	}

	task.spawn(function()
		for _ = 1, amount do
			local tip = cuh(targetCharacter)
			local x = 0.35
			if tip then
				local tip2 = tip.CFrame * offset
				local spreadAngleX = math.rad(rng:NextInteger(-12, 12))
				local spreadAngleY = math.rad(rng:NextInteger(-15, 15))
				local cframe = tip2
				cframe = cframe * CFrame.Angles(spreadAngleX, spreadAngleY, 0)
				local direction = cframe.LookVector
				local vel = direction * rng:NextInteger(22, 30)

				if cumRemote then
					-- FIX: Pass the 'targetCharacter' Instance as the ignore filter.
					-- Do NOT pass a RaycastParams object, it will arrive as nil.
					cumRemote:FireServer(tip2, vel, targetCharacter, currentSettings)
				end
				x = x + 0.3
			end
			task.wait(x)
		end
	end)
end

local function startCooldown(buttonName)
	isCooldown[buttonName] = true
	task.delay(COOLDOWN_DURATION, function()
		isCooldown[buttonName] = false
	end)
end

local function playVignette(buttonFired)
	local buttonName = (buttonFired == hard.Name) and "Hard" or "Soft"

	local vignetteFrame = Instance.new("Frame")
	vignetteFrame.Name = "VignetteFrame"
	vignetteFrame.Size = UDim2.new(1, 0, 1, 0)
	vignetteFrame.BackgroundColor3 = Color3.new(1, 0.776471, 0.909804)
	vignetteFrame.BackgroundTransparency = 0.4
	vignetteFrame.Visible = true
	vignetteFrame.ZIndex = 1
	vignetteFrame.Parent = screenGui

	soft.Interactable = false
	hard.Interactable = false

	local originalFOV = 70
	local zoomFOV = (buttonName == "Soft") and 60 or 40

	startParticles()

	TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		FieldOfView = zoomFOV
	}):Play()

	local tween = TweenService:Create(vignetteFrame, TweenInfo.new(4, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 1
	})
	tween:Play()

	tween.Completed:Connect(function()
		vignetteFrame:Destroy()

		TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			FieldOfView = originalFOV
		}):Play()
		stopParticles()

		soft.Interactable = true
		hard.Interactable = true
	end)
end

soft.MouseButton1Click:Connect(function()
	if isCooldown.Soft then
		showCooldownFeedback()
		return
	end

	startCooldown("Soft")
	blowRemote:FireServer(soft.Name)
	playVignette(soft.Name)
end)

hard.MouseButton1Click:Connect(function()
	if isCooldown.Hard then
		showCooldownFeedback()
		return
	end

	startCooldown("Hard")
	blowHardRemote:FireServer(hard.Name)
	playVignette(hard.Name)
	come(character)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.H then
		if isCooldown.Hard then
			showCooldownFeedback()
			return
		end

		startCooldown("Hard")
		blowHardRemote:FireServer(hard.Name)
		playVignette(hard.Name)
		come(character)
	end
end)

bot1hard.MouseButton1Click:Connect(function()
	local bot1Char = workspace:FindFirstChild(player.Name .. "Bot")
	if bot1Char then
		come(bot1Char)
	end
end)

bot2hard.MouseButton1Click:Connect(function()
	local bot2Char = workspace:FindFirstChild(player.Name .. "Bot2")
	if bot2Char then
		come(bot2Char)
	end
end)

event.OnClientEvent:Connect(playVignette)local TweenService = game:GetService("TweenService")

local overlay = script.Parent.Overlay
local overlayTweenInfo = TweenInfo.new(60, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local overlayTween = TweenService:Create(overlay, overlayTweenInfo, { ImageTransparency = 0.4 })
overlayTween:Play()

local TRANSPARENCY_INCREMENT1 = 0.4
local TRANSPARENCY_INCREMENT2 = 0.2

script.Parent.Soft.MouseButton1Down:Connect(function()
	overlayTween:Cancel()
	script.Parent.Overlay.ImageTransparency += TRANSPARENCY_INCREMENT1
	wait(1)
	overlayTween:Play()
end)

script.Parent.Hard.MouseButton1Down:Connect(function()
	overlayTween:Cancel()
	script.Parent.Overlay.ImageTransparency += TRANSPARENCY_INCREMENT2
	wait(1)
	overlayTween:Play()
end)local goon = game.Players.LocalPlayer
local bot2Char = workspace:FindFirstChild(goon.Name .. "Bot2")

while true do
	if bot2Char then
		script.Parent.Visible = true
	else
		script.Parent.Visible = false
	end
	wait()
endlocal goon = game.Players.LocalPlayer
local bot1Char = workspace:FindFirstChild(goon.Name .. "Bot")

while true do
	if bot1Char then
		script.Parent.Visible = true
	else
		script.Parent.Visible = false
	end
	wait()
end--EASINGSTYLES
local module = {}

module.GetEasing = function(style, direction, percent)
	if style == "Bounce" then
		if direction == "Out" then
			return 1 - easeOut(percent, bounce)
		elseif direction == "In" then
			return 1 - bounce(percent)
		else
			return 1 - easeInOut(percent, bounce)
		end
	elseif style == "Elastic" then
		if direction == "Out" then
			local totalTime = 1
			local p = totalTime*.3;
			local t = 1 - percent;
			local s = p/4;
			return (1 +2^(-10*t) * math.sin( (t*totalTime-s)*(math.pi*2)/p ));
		elseif direction == "In" then
			local totalTime = 1
			local p = totalTime*.3;
			local t = percent;
			local s = p/4;
			return 1 - (1 + 2^(-10*t) * math.sin( (t*totalTime-s)*(math.pi*2)/p ));
		elseif direction == "InOut" then
			local t = percent *2;
			local p = (.3*1.5);
			local s = p/4;
			if (t < 1) then
				t = t - 1;
				return 1 - (-.5 * 2^(10*t) * math.sin((t-s)*(math.pi*2)/p ));
			else
				t  = t - 1;
				return 1 - (1 + 0.5 * 2^(-10*t) * math.sin((t-s)*(math.pi*2)/p ));
			end
		end
	elseif style == "Cubic" then
		if direction == "Out" then
			return 1 - easeOut(percent, cubic)
		elseif direction == "In" then
			return 1 - cubic(percent)
		elseif direction == "InOut" then
			return 1 - easeInOut(percent, cubic)
		end
	elseif style == "Linear" then
		return 1 - percent
	elseif style == "Constant" then
		if style == "Out" then
			return 1
		elseif style == "In" then
			return 0
		elseif style == "InOut" then
			return 0.5
		end
	end
end

function easeIn(t,func)
	return func(t)
end

function easeOut(t,func)
	return 1-func(1-t)
end

function easeInOut(t,func)
	t=t*2
	if t < 1 then
		return easeIn(t,func)*.5
	else
		return .5+easeOut(t-1,func)*.5
	end
end

function bounce(t)
	if t<.36363636 then
		return 7.5625*t*t
	elseif t<.72727272 then
		t=t-.54545454
		return 7.5625*t*t+.75
	elseif t<.90909090 then
		t=t-.81818181
		return 7.5625*t*t+.9375
	else
		t=t-.95454545
		return 7.5625*t*t+.984375
	end
end

function cubic(t)
	return t^3
end

return module
game.Loaded:Wait()

local victim = script.Victim.Value
local owner = script.Owner.Value

function RemoveCollar(VictimHasDied)
	print("Removing collar")
	script:WaitForChild("RemoveEvent").Value:FireAllClients()
	
	if VictimHasDied then
		local character = victim.Character
		local animationScript = character:WaitForChild("Animate")
		
		animationScript.idle.Animation1.AnimationId = "rbxassetid://180435571"
		animationScript.idle.Animation2.Weight.Value = 1
		
		animationScript.jump.JumpAnim.AnimationId = "rbxassetid://125750702"
		animationScript.fall.FallAnim.AnimationId = "rbxassetid://180436148"
		
		animationScript.run.RunAnim.AnimationId = "rbxassetid://180426354"
		animationScript.walk.WalkAnim.AnimationId = "rbxassetid://180426354"
	end

	victim.Character.Collar:Destroy()
	script:Destroy()
end

function OnVictimDeath()
	RemoveCollar(true)
end

function OnOwnerDeath()
	RemoveCollar(false)
end

victim.Character.Humanoid.Died:Connect(OnVictimDeath)
owner.Character.Humanoid.Died:Connect(OnOwnerDeath)

victim.CharacterRemoving:Connect(OnVictimDeath)
owner.CharacterRemoving:Connect(OnOwnerDeath)local localPlayer = game.Players.LocalPlayer

repeat wait() until script.Parent == localPlayer.PlayerGui
script.Parent = localPlayer.PlayerScripts

local MasterControl = game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerController")

local maxRange = 15

local area = 30
local ownerChar = script:WaitForChild("Owner").Value
local owner = game.Players:GetPlayerFromCharacter(ownerChar)
local victimChar = game.Players.LocalPlayer.Character

local localHumanoid = victimChar.Humanoid

function GetDistance()
	return (victimChar.HumanoidRootPart.Position - ownerChar.HumanoidRootPart.Position).magnitude
end

function GetClosestAcceptedPoint()
	return ownerChar.HumanoidRootPart.Position + (victimChar.HumanoidRootPart.Position - ownerChar.HumanoidRootPart.Position).unit * (maxRange / 4)
end

local masterControlIsDisabled = false

local reachConnection

local steppedConnection = game["Run Service"].RenderStepped:Connect(function()
	
	local distance = GetDistance()
	if distance > area then
		if localHumanoid.SeatPart then
			localHumanoid.Jump = true
		end
		victimChar.HumanoidRootPart.CFrame = CFrame.new(GetClosestAcceptedPoint())
		if masterControlIsDisabled then
			MasterControl.Disabled = false
			masterControlIsDisabled = false
		end
		
		if reachConnection then
			reachConnection:Disconnect()
			reachConnection = nil
		end
	end

	if distance > maxRange then
		if localHumanoid.SeatPart then
			localHumanoid.Jump = true
		end
		
		localHumanoid:MoveTo(GetClosestAcceptedPoint())
		
		reachConnection = localHumanoid.MoveToFinished:Connect(function(hasReached)
			if hasReached == false then
				victimChar.HumanoidRootPart.CFrame = CFrame.new(GetClosestAcceptedPoint())
			end
			if reachConnection then
				reachConnection:Disconnect()
				reachConnection = nil
			end
		end)

	elseif distance < maxRange-1 then
		if masterControlIsDisabled then
			MasterControl.Disabled = false
			masterControlIsDisabled = false
		end
		if reachConnection then
			reachConnection:Disconnect()
			reachConnection = nil
		end
	end
end)

script.RemoveEvent.Value.OnClientEvent:Connect(function()
	script.RemoveEvent.Value:FireServer()
	steppedConnection:Disconnect()
	if reachConnection then
		reachConnection:Disconnect()
	end
	MasterControl.Disabled = false
	script:Destroy()
end)local replicatedScripts = {}
local JoinReplicateConnection

function StartCurveReplication()
	
	JoinReplicateConnection = game.Players.PlayerAdded:Connect(function(player)
		coroutine.resume(coroutine.create(function()
			local replicatedCurve = script.DrawLocalLine:Clone()
			replicatedCurve.Parent = player.PlayerGui
			table.insert(replicatedScripts, replicatedCurve)
			replicatedCurve.Disabled = false
		end))
	end)
	
	for i, v in pairs(game.Players:GetPlayers()) do
		coroutine.resume(coroutine.create(function()
			local replicatedCurve = script.DrawLocalLine:Clone()
			replicatedCurve.Parent = v.PlayerGui
			table.insert(replicatedScripts, replicatedCurve)
			replicatedCurve.Disabled = false
		end))
	end
	
end

StartCurveReplication()

script.RemoveCollar.OnServerEvent:Connect(function()
	JoinReplicateConnection:Disconnect()
	script:Destroy()
end)local localPlayer = game.Players.LocalPlayer

repeat wait() until script.Parent == localPlayer.PlayerGui
script.Parent = localPlayer.PlayerScripts

repeat wait() until game:IsLoaded()

local RunService = game["Run Service"]
local removeEvent

while not removeEvent do
	removeEvent = script:FindFirstChild("RemoveEvent")
	if not removeEvent then
		wait(1)
	end
end

local remove = removeEvent.Value
while not remove do
	wait(1)
	remove = removeEvent.Value
end

local segments = 10
local pull = workspace.Gravity / (20.00611807 * 5)
local width = .1

local attachment0, attachment1

while not attachment0 or not attachment1 do
	attachment0 = script:FindFirstChild("Attachment0") and script.Attachment0.Value or nil
	attachment1 = script:FindFirstChild("Attachment1") and script.Attachment1.Value or nil
	if not attachment0 or not attachment1 then
		wait(1)
	end
end

local LineSegments = {}
local firstLineDrawn = false

function DrawFirstLine(p1, p2, container)
	local distance = (p1 - p2).magnitude
	local line = Instance.new("Part")
	line.Name = "LineSegment"
	line.BrickColor = BrickColor.new("Really black")
	line.Material = "SmoothPlastic"
	line.Transparency = 0
	line.Anchored = true
	line.CanCollide = false
	line.Shape = Enum.PartType.Cylinder
	line.TopSurface = Enum.SurfaceType.Smooth
	line.BottomSurface = Enum.SurfaceType.Smooth
	line.formFactor = Enum.FormFactor.Custom
	line.Size = Vector3.new(distance, width, width)
	line.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -distance / 2) * CFrame.Angles(0, math.rad(90), 0)
	table.insert(LineSegments, line)
	line.Parent = container
end

function UpdateLine(p1, p2, i)
	local distance = (p1 - p2).magnitude
	if LineSegments[i] then
		LineSegments[i].Size = Vector3.new(distance, width, width)
		LineSegments[i].CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -distance / 2) * CFrame.Angles(0, math.rad(90), 0)
	end
end

function DrawCatenary(p1, p2, container)
	for i = 1, segments do
		local x = ((((i - 1) * 2) / segments) - 1)
		local x2 = (((i * 2) / segments) - 1)
		if firstLineDrawn then
			UpdateLine(
				p1 + ((p2 - p1) / segments * (i - 1)) + Vector3.new(0, (((math.cosh(x) - 1) / (math.cosh(1) - 1)) - 1) * pull, 0),
				p1 + ((p2 - p1) / segments * i) + Vector3.new(0, (((math.cosh(x2) - 1) / (math.cosh(1) - 1)) - 1) * pull, 0),
				i
			)
		else
			DrawFirstLine(
				p1 + ((p2 - p1) / segments * (i - 1)) + Vector3.new(0, (((math.cosh(x) - 1) / (math.cosh(1) - 1)) - 1) * pull, 0),
				p1 + ((p2 - p1) / segments * i) + Vector3.new(0, (((math.cosh(x2) - 1) / (math.cosh(1) - 1)) - 1) * pull, 0),
				container
			)
		end
	end
	firstLineDrawn = true
end

local update = RunService.RenderStepped:Connect(function()
	if not attachment0 or not attachment1 then
		attachment0 = script:FindFirstChild("Attachment0") and script.Attachment0.Value or nil
		attachment1 = script:FindFirstChild("Attachment1") and script.Attachment1.Value or nil
		if not attachment0 or not attachment1 then
			return
		end
	end
	DrawCatenary(attachment0.WorldPosition, attachment1.WorldPosition, workspace)
end)

local function SafeRemoveRope()
	update:Disconnect()
	for i = 1, #LineSegments do
		if LineSegments[i] then
			LineSegments[i]:Destroy()
		end
	end
	script:Destroy()
end

if remove then
	remove.OnClientEvent:Connect(SafeRemoveRope)
endwait(1)

script.Parent:GetPropertyChangedSignal("Occupant"):Connect(function(humanoid)
	local ExtraS = false

	if script.Parent.Occupant ~= nil then
		script.Parent.Transparency = 1
		local pos = script.Parent.Position
		local rot = script.Parent.Orientation
		local seat = Instance.new("Seat")
		seat.Name = "extra"
		seat.Parent = script.Parent
		seat.Orientation = rot
		seat.Anchored = true
		seat.Size = Vector3.new(2, 1 ,1)
		seat.Transparency = 1
		seat.Position = pos
		ExtraS = true
	else
		script.Parent.Transparency = 0.5
		local etra = script.Parent:FindFirstChild("extra")
		if etra then
			etra:Destroy()
		end
		ExtraS = false
	end
end)wait(1)

script.Parent:GetPropertyChangedSignal("Occupant"):Connect(function(humanoid)
	local ExtraS = false

	if script.Parent.Occupant ~= nil then
		script.Parent.Transparency = 1
		local pos = script.Parent.Position
		local rot = script.Parent.Orientation
		local seat = Instance.new("Seat")
		seat.Name = "extra"
		seat.Parent = script.Parent
		seat.Orientation = rot
		seat.Anchored = true
		seat.Size = Vector3.new(2, 1 ,1)
		seat.Transparency = 1
		seat.Position = pos
		ExtraS = true
	else
		script.Parent.Transparency = 0.5
		local etra = script.Parent:FindFirstChild("extra")
		if etra then
			etra:Destroy()
		end
		ExtraS = false
	end
end)local v0 = game.Players.LocalPlayer;
local v1 = script.Parent;
local v2 = nil;
local v3 = nil;
local v4 = game:GetService("ReplicatedStorage");
local v5 = v4:FindFirstChild("LocalScriptAPI");
local v6 = v5.AnimSpeed;
local v7 = v1.Main;
local v8 = v1.Animation;
local v9 = v8.Women_List;
local v10 = v8.Men_List;
local v11 = v8.Emote_List;
local v12 = v8.Plus_List;
local v13 = v8.All_List;
local v14 = v8.Nothing_List;
local v15 = v1.Morph;
local v16 = v1.MorphComplex;
local v17 = v1.Coloring;
local v18 = v1.Accessories;
local v19 = v1.Animation;
local v20 = v1.WalkSpeed;
local v21 = v1.House;
local v22 = v1.Whitelist;
local v23 = v1.CharSettings;
local v24 = v1.CatalogAcc;
local v25 = v1.Selection;
local v26 = v1.ColoringChat;
local v27 = v1.BOTMain;
local v28 = v1.BOTAnimation;
local v29 = v28.WomenBot_List;
local v30 = v28.MenBot_List;
local v31 = v28.EmoteBot_List;
local v32 = v28.PlusBot_List;
local v33 = v28.AllBot_List;
local v34 = v28.NothingBot_List;
local v35 = v1.BOTMorph;
local v36 = v1.BOTMorphComplex;
local v37 = v1.BOTColoring;
local v38 = v1.BOTAccessories;
local v39 = v1.BOTAnimation;
local v40 = v1.BOTCharSettings;
local v41 = v1.BOTCatalogAcc;
local v42 = v1.BOTSelection;
local v43 = nil;
local v44 = v7.ToggleUIButton;
local v45 = v7.ToggleUIButton.Position;
local v46 = v7["1Morph"];
local v47 = v7["2Animation"];
local v48 = v7["3FP"];
local v49 = v7["4WalkSpeed"];
local v50 = v7["5Respawn"];
local v51 = v7["6Bot"];
local v52 = v7["7Settings"];
local v53 = v23['CustomColors'];
local v54 = v23["6CatalogAcc"];
local v55 = v21["4Whitelist"];
local v56 = v27["1Morph"];
local v57 = v27["2Animation"];
local v58 = v27["3Settings"];
local v59 = v40["6CatalogAcc"];
local v60 = game:GetService("TweenService");
local v61 = {};
local v62 = {Morph=v15.Position,MorphComplex=v16.Position,Coloring=v17.Position,Accessories=v18.Position,Animation=v19.Position,WalkSpeed=v20.Position,House=v21.Position,Whitelist=v22.Position,CharSettings=v23.Position,CatalogAcc=v24.Position,Selection=v25.Position,ColoringChat=v26.Position,BOTMorph=v35.Position,BOTMorphComplex=v36.Position,BOTColoring=v37.Position,BOTAccessories=v38.Position,BOTAnimation=v39.Position,BOTCharSettings=v40.Position,BOTCatalogAcc=v41.Position,BOTSelection=v42.Position};
local v63 = {Morph=UDim2.new(1 + v15.Size.X.Scale, 0, 0.5, 0),MorphComplex=UDim2.new(1 + v16.Size.X.Scale, 0, 0.5, 0),Coloring=UDim2.new(1 + v17.Size.X.Scale, 0, 0.5, 0),Accessories=UDim2.new(1 + v18.Size.X.Scale, 0, 0.819, 0),Animation=UDim2.new(1 + v19.Size.X.Scale, 0, 0.324, 0),WalkSpeed=UDim2.new(1 + v20.Size.X.Scale, 0, 0.5, 0),House=UDim2.new(1 + v21.Size.X.Scale, 0, 0.5, 0),Whitelist=UDim2.new(1 + v22.Size.X.Scale, 0, 0.5, 0),CharSettings=UDim2.new(1 + v23.Size.X.Scale, 0, 0.5, 0),CatalogAcc=UDim2.new(1 + v24.Size.X.Scale, 0, 0.5, 0),Selection=UDim2.new(1 + v25.Size.X.Scale, 0, 0.5, 0),ColoringChat=UDim2.new(1 + v17.Size.X.Scale, 0, 0.5, 0),BOTMorph=UDim2.new(1 + v35.Size.X.Scale, 0, 0.5, 0),BOTMorphComplex=UDim2.new(1 + v36.Size.X.Scale, 0, 0.5, 0),BOTColoring=UDim2.new(1 + v37.Size.X.Scale, 0, 0.5, 0),BOTAccessories=UDim2.new(1 + v38.Size.X.Scale, 0, 0.819, 0),BOTAnimation=UDim2.new(1 + v39.Size.X.Scale, 0, 0.742, 0),BOTCharSettings=UDim2.new(1 + v40.Size.X.Scale, 0, 0.5, 0),BOTCatalogAcc=UDim2.new(1 + v41.Size.X.Scale, 0, 0.5, 0),BOTSelection=UDim2.new(1 + v42.Size.X.Scale, 0, 0.5, 0)};
v15.Position = v63['Morph'];
v16.Position = v63['MorphComplex'];
v35.Position = v63['BOTMorph'];
v36.Position = v63['BOTMorphComplex'];
for v79, v80 in pairs(v1:GetChildren()) do
	if (v80:IsA("Frame") or v80:IsA("ScrollingFrame")) then
		if v80.Name ~= "PreviewTooltip" then
			v80.Visible = true;
		end
	end
end
v8.Speed.FocusLost:Connect(function()
	local v81 = nil;
	if workspace.GoatAnimFol:FindFirstChild(v0.Name) then
		v81 = workspace.GoatAnimFol:FindFirstChild(v0.Name);
		v81.ChangeSpeed:FireServer(v8.Speed.Text);
	end
	local v82 = workspace:FindFirstChild(v0.Name .. "Bot");
	local v83 = workspace:FindFirstChild(v0.Name .. "Bot2");
	if v82 then
		if workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot") then
			local v228 = workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot");
			v228.ChangeSpeed:FireServer(v8.Speed.Text);
		end
	end
	if v83 then
		if workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot2") then
			local v229 = workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot2");
			v229.ChangeSpeed:FireServer(v8.Speed.Text);
		end
	end
	if v0:FindFirstChild("PlayerGui") then
		if v0.PlayerGui:FindFirstChild("Syncs") then
			for v249, v250 in pairs(v0.PlayerGui.Syncs:GetChildren()) do
				local v251 = nil;
				if workspace.GoatAnimFol:FindFirstChild(v250.Name) then
					local v257 = workspace.GoatAnimFol:FindFirstChild(v250.Name);
					local v258 = game.Players:FindFirstChild(v250.Name);
					if (v258 and v257) then
						v257.ChangeSpeed:FireServer(v8.Speed.Text);
					end
				end
			end
		end
	end
end);
v28.Speed.FocusLost:Connect(function()
	local v84 = nil;
	if workspace.GoatAnimFol:FindFirstChild(v0.Name) then
		v84 = workspace.GoatAnimFol:FindFirstChild(v0.Name);
		v84.ChangeSpeed:FireServer(v28.Speed.Text);
	end
	local v85 = workspace:FindFirstChild(v0.Name .. "Bot");
	local v86 = workspace:FindFirstChild(v0.Name .. "Bot2");
	if v85 then
		if workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot") then
			local v230 = workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot");
			v230.ChangeSpeed:FireServer(v28.Speed.Text);
		end
	end
	if v86 then
		if workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot2") then
			local v231 = workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot2");
			v231.ChangeSpeed:FireServer(v8.Speed.Text);
		end
	end
	if v0:FindFirstChild("PlayerGui") then
		if v0.PlayerGui:FindFirstChild("Syncs") then
			for v252, v253 in pairs(v0.PlayerGui.Syncs:GetChildren()) do
				local v254 = nil;
				if workspace.GoatAnimFol:FindFirstChild(v253.Name) then
					local v259 = workspace.GoatAnimFol:FindFirstChild(v253.Name);
					local v260 = game.Players:FindFirstChild(v253.Name);
					if (v260 and v259) then
						v259.ChangeSpeed:FireServer(v28.Speed.Text);
					end
				end
			end
		end
	end
end);
function findPlayer(v87)
	for v142, v143 in ipairs(game.Players:GetPlayers()) do
		local v142 = string.find(v143.Name:lower(), v87:lower());
		if (v142 and (v142 == 1)) then
			return v143;
		end
	end
	return false;
end
function FixButtonSizes()
end
function FixListSize()
	FixButtonSizes();
	local v88 = {};
	for v144, v145 in pairs(v8.Men_List:GetChildren()) do
		if v145:IsA("GuiButton") then
			v88[#v88 + 1] = v145;
		end
	end
	for v146, v147 in pairs(v8.Women_List:GetChildren()) do
		if v147:IsA("GuiButton") then
			v88[#v88 + 1] = v147;
		end
	end
	for v148, v149 in pairs(v8.Emote_List:GetChildren()) do
		if v149:IsA("GuiButton") then
			v88[#v88 + 1] = v149;
		end
	end
	for v150, v151 in pairs(v8.Emote_List:GetChildren()) do
		if v151:IsA("GuiButton") then
			v88[#v88 + 1] = v151;
		end
	end
	for v152, v153 in pairs(v8.All_List:GetChildren()) do
		if v153:IsA("GuiButton") then
			v88[#v88 + 1] = v153;
		end
	end
	v8.Men_List.CanvasSize = UDim2.new(0, 0, 0, v88[1].Size.Y.Offset * #v88);
	v8.Women_List.CanvasSize = UDim2.new(0, 0, 0, v88[1].Size.Y.Offset * #v88);
	v8.Emote_List.CanvasSize = UDim2.new(0, 0, 0, v88[1].Size.Y.Offset * #v88);
	v8.Plus_List.CanvasSize = UDim2.new(0, 0, 0, v88[1].Size.Y.Offset * #v88);
	v8.All_List.CanvasSize = UDim2.new(0, 0, 0, v88[1].Size.Y.Offset * #v88);
end
function FixBotListSize()
	FixButtonSizes();
	local v94 = {};
	for v154, v155 in pairs(v28.MenBot_List:GetChildren()) do
		if v155:IsA("GuiButton") then
			v94[#v94 + 1] = v155;
		end
	end
	for v156, v157 in pairs(v28.WomenBot_List:GetChildren()) do
		if v157:IsA("GuiButton") then
			v94[#v94 + 1] = v157;
		end
	end
	for v158, v159 in pairs(v28.EmoteBot_List:GetChildren()) do
		if v159:IsA("GuiButton") then
			v94[#v94 + 1] = v159;
		end
	end
	for v160, v161 in pairs(v28.PlusBot_List:GetChildren()) do
		if v161:IsA("GuiButton") then
			v94[#v94 + 1] = v161;
		end
	end
	for v162, v163 in pairs(v28.AllBot_List:GetChildren()) do
		if v163:IsA("GuiButton") then
			v94[#v94 + 1] = v163;
		end
	end
	v28.MenBot_List.CanvasSize = UDim2.new(0, 0, 0, v94[1].Size.Y.Offset * #v94);
	v28.WomenBot_List.CanvasSize = UDim2.new(0, 0, 0, v94[1].Size.Y.Offset * #v94);
	v28.EmoteBot_List.CanvasSize = UDim2.new(0, 0, 0, v94[1].Size.Y.Offset * #v94);
	v28.PlusBot_List.CanvasSize = UDim2.new(0, 0, 0, v94[1].Size.Y.Offset * #v94);
	v28.AllBot_List.CanvasSize = UDim2.new(0, 0, 0, v94[1].Size.Y.Offset * #v94);
end
function GetAnimObj(v100)
	local v100 = v100:GetChildren();
	for v164, v164 in pairs(v100) do
		if v164:IsA("ObjectValue") then
			return v164.Value;
		elseif v164:IsA("StringValue") then
			return v164.Value, true;
		end
	end
end

local allAnimLists = {v9, v10, v11, v12, v13}

function FindPairDaString(clickedButton)
	local playerText = clickedButton.Text
	local playerColor = clickedButton.TextColor3
	local targetText = nil
	local targetName = nil
	local foundButton = nil

	local function FindButtonByText(text)
		if not text then return nil end
		for _, list in pairs(allAnimLists) do
			for _, pairButton in pairs(list:GetChildren()) do
				if pairButton:IsA("GuiButton") and pairButton.Text == text then
					return pairButton
				end
			end
		end
		return nil
	end
	local hasPriority2Suffix = playerText:match("[12FM]$")
	if not hasPriority2Suffix then
		for _, list in pairs(allAnimLists) do
			for _, pairButton in pairs(list:GetChildren()) do
				if pairButton:IsA("GuiButton") and pairButton ~= clickedButton then
					if pairButton.Text == playerText and pairButton.TextColor3 ~= playerColor then
						print("FindPair: Priority 1 (Color) found " .. pairButton.Name)
						return GetAnimObj(pairButton)
					end
				end
			end
		end
	end

	local newText_F, count_F = playerText:gsub(" F$", " M")
	if count_F == 0 then newText_F, count_F = playerText:gsub("F$", "M") end

	local newText_M, count_M = playerText:gsub(" M$", " F")
	if count_M == 0 then newText_M, count_M = playerText:gsub("M$", "F") end

	if count_F > 0 then
		targetText = newText_F
	elseif count_M > 0 then
		targetText = newText_M
	end

	foundButton = FindButtonByText(targetText)
	if foundButton then
		print("FindPair: Priority 2A (F/M) found " .. foundButton.Name)
		return GetAnimObj(foundButton)
	end

	local baseNum, suffixNum = playerText:match("^(.*)([12])$")

	if suffixNum == "1" then
		targetText = baseNum .. "2" 
		foundButton = FindButtonByText(targetText)
		if foundButton then
			print("FindPair: Priority 2B (1->2) found " .. foundButton.Name)
			return GetAnimObj(foundButton)
		end
		
		targetText = baseNum 
		foundButton = FindButtonByText(targetText)
		if foundButton then
			print("FindPair: Priority 2B (1->Base) found " .. foundButton.Name)
			return GetAnimObj(foundButton)
		end

	elseif suffixNum == "2" then
		
		targetText = baseNum .. "1" 
		foundButton = FindButtonByText(targetText)
		if foundButton then
			print("FindPair: Priority 2B (2->1) found " .. foundButton.Name)
			return GetAnimObj(foundButton)
		end

		targetText = baseNum 
		foundButton = FindButtonByText(targetText)
		if foundButton then
			print("FindPair: Priority 2B (2->Base) found " .. foundButton.Name)
			return GetAnimObj(foundButton)
		end

	else
		targetText = playerText .. "1" 
		foundButton = FindButtonByText(targetText)
		if foundButton then
			print("FindPair: Priority 2B (Base->1) found " .. foundButton.Name)
			return GetAnimObj(foundButton)
		end
		
		targetText = playerText .. "2" 
		foundButton = FindButtonByText(targetText)
		if foundButton then
			print("FindPair: Priority 2B (Base->2) found " .. foundButton.Name)
			return GetAnimObj(foundButton)
		end
	end

	if clickedButton.Name:sub(-1) == "-" then
		targetName = clickedButton.Name:sub(1, -2)
	else
		targetName = clickedButton.Name .. "-"
	end

	for _, list in pairs(allAnimLists) do
		local pairButton = list:FindFirstChild(targetName)
		if pairButton and pairButton:IsA("GuiButton") then
			print("FindPair: Priority 3 (Hyphen) found " .. pairButton.Name)
			return GetAnimObj(pairButton)
		end
	end
	return nil
end

local v72 = false;
local v73 = false;
function resetlistbuttons(v101)
	for v165, v166 in pairs(v101:GetChildren()) do
		if v166:IsA("GuiButton") then
			v166.BackgroundTransparency = 0.9;
		end
	end
end
function CheckAnims(v102)
	for v167, v168 in pairs(v102:GetChildren()) do
		if v168:IsA("GuiButton") then
			v168.MouseButton1Click:Connect(function()
				local v232 = v0.Character;
				local v233 = GetAnimObj(v168);
				if v232 then
					v5.StopAnimationOnHumanoid:FireServer(v232.Humanoid);
					resetlistbuttons(v102);
					if (v2 ~= v168) then
						if (v233 and (v72 == false)) then
							v168.BackgroundTransparency = 0.25;
							v72 = true;
							local botDaString = FindPairDaString(v168)

							v232:SetAttribute("CurrentAnimName", v168.Text)

							v5.PlayAnimation:InvokeServer(v233, v232, nil, botDaString);
							warn(v232.Name .. " IS NOW PLAYING AN ANIMATION: " .. v168.Text);
							if v0:FindFirstChild("PlayerGui") then
								if v0.PlayerGui:FindFirstChild("Syncs") then
									for v282, v283 in pairs(v0.PlayerGui.Syncs:GetChildren()) do
										local v284 = nil;
										if workspace.GoatAnimFol:FindFirstChild(v283.Name) then
											local v289 = workspace.GoatAnimFol:FindFirstChild(v283.Name);
											local v290 = game.Players:FindFirstChild(v283.Name);
											if (v290 and v289) then
												v289.Refresh:FireServer();
											end
										end
									end
								end
							end
							v2 = v168;
							task.wait(1);
							v72 = false;
						end
					else
						v232:SetAttribute("CurrentAnimName", nil)
						v2 = nil;
					end
				end
			end);
		end
	end
end

function CheckBOTAnims(v103)
	for v169, v170 in pairs(v103:GetChildren()) do
		if v170:IsA("GuiButton") then
			v170.MouseButton1Click:Connect(function()
				local v234, v235;
				v234 = v0:WaitForChild("bot1enabled");
				v235 = v0:WaitForChild("bot2enabled");
				local v236;
				if (v234.Value == true) then
					v236 = workspace:FindFirstChild(v0.Name .. "Bot");
				elseif (v235.Value == true) then
					v236 = workspace:FindFirstChild(v0.Name .. "Bot2");
				end
				local v237 = GetAnimObj(v170);
				if v236 then
					v5.StopAnimationOnHumanoid:FireServer(v236.Humanoid);
					resetlistbuttons(v103);
					if (v3 ~= v170) then
						if (v237 and (v73 == false)) then
							v170.BackgroundTransparency = 0.25;
							v73 = true;

							v236:SetAttribute("CurrentAnimName", v170.Text)

							v5.PlayAnimation:InvokeServer(v237, v236);
							local v269 = workspace.GoatAnimFol:FindFirstChild(v0.Name .. "Bot");
							if v269 then
								v269.Refresh:FireServer();
							end
							local v269 = workspace.GoatAnimFol:FindFirstChild(v0.Name);
							if v269 then
								v269.Refresh:FireServer();
							end
							if v0:FindFirstChild("PlayerGui") then
								if v0.PlayerGui:FindFirstChild("Syncs") then
									for v285, v286 in pairs(v0.PlayerGui.Syncs:GetChildren()) do
										local v287 = nil;
										if workspace.GoatAnimFol:FindFirstChild(v286.Name) then
											local v291 = workspace.GoatAnimFol:FindFirstChild(v286.Name);
											local v292 = game.Players:FindFirstChild(v286.Name);
											if (v292 and v291) then
												v291.Refresh:FireServer();
											end
										end
									end
								end
							end
							v3 = v170;
							task.wait(1);
							v73 = false;
						end
					else
						v236:SetAttribute("CurrentAnimName", nil)
						v3 = nil;
					end
				end
			end);
		end
	end
end
CheckAnims(v8.Men_List);
CheckAnims(v8.Women_List);
CheckAnims(v8.Plus_List);
CheckAnims(v8.Emote_List);
CheckAnims(v8.All_List);
CheckBOTAnims(v28.MenBot_List);
CheckBOTAnims(v28.WomenBot_List);
CheckBOTAnims(v28.PlusBot_List);
CheckBOTAnims(v28.EmoteBot_List);
CheckBOTAnims(v28.AllBot_List);
FixListSize();
v8.Women_List.YSizePercentage.Changed:Connect(function(v104)
	FixListSize();
end);
v8.Women_List.ChildAdded:Connect(function(v105)
	FixListSize();
end);
v8.Women_List.ChildRemoved:Connect(function(v106)
	FixListSize();
end);
v8.Men_List.YSizePercentage.Changed:Connect(function(v107)
	FixListSize();
end);
v8.Men_List.ChildAdded:Connect(function(v108)
	FixListSize();
end);
v8.Men_List.ChildRemoved:Connect(function(v109)
	FixListSize();
end);
FixBotListSize();
v28.WomenBot_List.YSizePercentage.Changed:Connect(function(v110)
	FixListSize();
end);
v28.WomenBot_List.ChildAdded:Connect(function(v111)
	FixListSize();
end);
v28.WomenBot_List.ChildRemoved:Connect(function(v112)
	FixListSize();
end);
v28.MenBot_List.YSizePercentage.Changed:Connect(function(v113)
	FixListSize();
end);
v28.MenBot_List.ChildAdded:Connect(function(v114)
	FixListSize();
end);
v28.MenBot_List.ChildRemoved:Connect(function(v115)
	FixListSize();
end);
v28.PlusBot_List.YSizePercentage.Changed:Connect(function(v116)
	FixListSize();
end);
v28.PlusBot_List.ChildAdded:Connect(function(v117)
	FixListSize();
end);
v28.PlusBot_List.ChildRemoved:Connect(function(v118)
	FixListSize();
end);
v28.EmoteBot_List.YSizePercentage.Changed:Connect(function(v119)
	FixListSize();
end);
v28.EmoteBot_List.ChildAdded:Connect(function(v120)
	FixListSize();
end);
v28.EmoteBot_List.ChildRemoved:Connect(function(v121)
	FixListSize();
end);
v28.AllBot_List.YSizePercentage.Changed:Connect(function(v122)
	FixListSize();
end);
v28.AllBot_List.ChildAdded:Connect(function(v123)
	FixListSize();
end);
v28.AllBot_List.ChildRemoved:Connect(function(v124)
	FixListSize();
end);
v61['ToggleUI'] = false;
v61['BOTToggleUI'] = false;
v27.Position = UDim2.new(-0.2, 0, 0.7, 0);
v44.Position = UDim2.new(0, -10, 0.5, 0);
v7.Size = UDim2.new(0, 0, 0, 0);
function HideOtherFrames(v125)
	for v171, v172 in pairs(v1:GetChildren()) do
		if (v63[v172.Name] and (v172.Name ~= v125) and (v172 ~= v43)) then
			v60:Create(v172, TweenInfo.new(0.125), {Position=v63[v172.Name]}):Play();
			v61[v172.Name] = false;
		end
	end
end
v44.MouseButton1Click:Connect(function()
	if (v61['ToggleUI'] == true) then
		v61['ToggleUI'] = false;
		v60:Create(v44, TweenInfo.new(0.125), {Position=UDim2.new(0, 0, 0.5, 0)}):Play();
		v60:Create(v7, TweenInfo.new(0.125), {Size=UDim2.new(0, 0, 0, 0),Position=UDim2.new(0, 0.7, 0.5, 0)}):Play();
		v61['BOTToggleUI'] = false;
		v60:Create(v27, TweenInfo.new(0.125), {Position=UDim2.new(-0.2, 0, 0.7, 0)}):Play();
		v43 = nil;
		HideOtherFrames("NOPE");
		task.wait(0.1);
		if (v61['ToggleUI'] == false) then
		end
	else
		v61['ToggleUI'] = true;
		v60:Create(v44, TweenInfo.new(0.125), {Position=v45}):Play();
		v60:Create(v7, TweenInfo.new(0.125), {Size=UDim2.new(0.25, 0, 0.25, 0)}):Play();
		v43 = nil;
		HideOtherFrames("NOPE");
	end
end);
v46.MouseButton1Click:Connect(function()
	v43 = nil;
	if (v61['MorphUI'] == true) then
		v61['MorphUI'] = false;
		v60:Create(v15, TweenInfo.new(0.125), {Position=v63['Morph']}):Play();
	else
		v43 = v15;
		v61['MorphUI'] = true;
		v60:Create(v15, TweenInfo.new(0.125), {Position=v62['Morph']}):Play();
		if (v61['MorphComplex'] == true) then
			v61['MorphComplex'] = false;
			v60:Create(v16, TweenInfo.new(0.125), {Position=v63['MorphComplex']}):Play();
		end
	end
	HideOtherFrames("NOPE");
end);
for v126, v127 in pairs(v15:GetChildren()) do
	if v127:IsA("GuiButton") then
		v127.MouseButton1Click:Connect(function()
			if (v127.Name == "3Switch") then
				if (v61['MorphComplex'] == true) then
					v61['MorphComplex'] = false;
					v60:Create(v16, TweenInfo.new(0.125), {Position=v63['MorphComplex']}):Play();
					HideOtherFrames("NOPE");
				else
					v61['MorphComplex'] = true;
					v60:Create(v16, TweenInfo.new(0.125), {Position=v62['MorphComplex']}):Play();
					HideOtherFrames("MorphComplex");
					v60:Create(v15, TweenInfo.new(0.125), {Position=v63['Morph']}):Play();
				end
			elseif ((v127.Name == "1Male") or (v127.Name == "2Female")) then
				HideOtherFrames("NOPE");
			elseif (v127.Name == "4Coloring") then
				if (v61['Coloring'] == true) then
					v61['Coloring'] = false;
					v60:Create(v17, TweenInfo.new(0.125), {Position=v63['Coloring']}):Play();
					HideOtherFrames("NOPE");
				else
					v61['Coloring'] = true;
					v60:Create(v17, TweenInfo.new(0.125), {Position=v62['Coloring']}):Play();
					HideOtherFrames("Coloring");
				end
			elseif (v127.Name == "5Accessories") then
				if (v61['Accessories'] == true) then
					v61['Accessories'] = false;
					v60:Create(v18, TweenInfo.new(0.125), {Position=v63['Accessories']}):Play();
					HideOtherFrames("NOPE");
				else
					v61['Accessories'] = true;
					v60:Create(v18, TweenInfo.new(0.125), {Position=v62['Accessories']}):Play();
					HideOtherFrames("Accessories");
				end
			end
		end);
	end
end
v47.MouseButton1Click:Connect(function()
	v43 = nil;
	if (v61['Animation'] == true) then
		v61['Animation'] = false;
		HideOtherFrames("NOPE");
	else
		v43 = v19;
		v61['Animation'] = true;
		v60:Create(v19, TweenInfo.new(0.125), {Position=v62['Animation']}):Play();
		HideOtherFrames("BOTAnimation");
	end
end);
v49.MouseButton1Click:Connect(function()
	v43 = nil;
	if (v61['WalkSpeed'] == true) then
		v61['WalkSpeed'] = false;
		HideOtherFrames("NOPE");
	else
		v43 = v20;
		v61['WalkSpeed'] = true;
		v60:Create(v20, TweenInfo.new(0.125), {Position=v62['WalkSpeed']}):Play();
		HideOtherFrames("WalkSpeed");
	end
end);
v55.MouseButton1Click:Connect(function()
	v43 = v21;
	if (v61['Whitelist'] == true) then
		v61['Whitelist'] = false;
		HideOtherFrames("NOPE");
	else
		v61['Whitelist'] = true;
		v22.Visible = true;
		v60:Create(v22, TweenInfo.new(0.125), {Position=v62['Whitelist']}):Play();
		HideOtherFrames("Whitelist");
	end
end);
v51.MouseButton1Click:Connect(function()
	if (v61['BOTToggleUI'] == true) then
		v61['BOTToggleUI'] = false;
		v60:Create(v27, TweenInfo.new(0.125), {Position=UDim2.new(-0.2, 0, 0.7, 0)}):Play();
		v43 = nil;
		HideOtherFrames("NOPE");
	else
		v61['BOTToggleUI'] = true;
		v60:Create(v27, TweenInfo.new(0.125), {Position=UDim2.new(0.005, 0, 0.7, 0)}):Play();
		v43 = nil;
		HideOtherFrames("NOPE");
	end
end);
v52.MouseButton1Click:Connect(function()
	v43 = nil;
	if (v61['CharSettings'] == true) then
		v61['CharSettings'] = false;
		HideOtherFrames("NOPE");
	else
		v43 = v23;
		v61['CharSettings'] = true;
		v60:Create(v23, TweenInfo.new(0.125), {Position=v62['CharSettings']}):Play();
		HideOtherFrames("CharSettings");
	end
end);
v54.MouseButton1Click:Connect(function()
	v43 = v23;
	if (v61['CatalogAcc'] == true) then
		v61['CatalogAcc'] = false;
		HideOtherFrames("NOPE");
	else
		v61['CatalogAcc'] = true;
		v60:Create(v24, TweenInfo.new(0.125), {Position=v62['CatalogAcc']}):Play();
		HideOtherFrames("CatalogAcc");
	end
end);
v53.MouseButton1Click:Connect(function()
	v43 = v23;
	if (v61['ColoringChat'] == true) then
		v61['ColoringChat'] = false;
		HideOtherFrames("NOPE");
	else
		v61['ColoringChat'] = true;
		v60:Create(v26, TweenInfo.new(0.125), {Position=v62['ColoringChat']}):Play();
		HideOtherFrames("ColoringChat");
	end
end);
for v128, v129 in pairs(v7:GetChildren()) do
	if v129:IsA("TextButton") then
		local v194 = nil;
		if (v129.Name == "1Morph") then
			v194 = v7.PreviewMorphs;
		elseif (v129.Name == "2Animation") then
			v194 = v7.PreviewAnims;
		elseif (v129.Name == "3FP") then
			v194 = v7.PreviewFP;
		elseif (v129.Name == "4WalkSpeed") then
			v194 = v7.PreviewWalkSpeed;
		elseif (v129.Name == "5Respawn") then
			v194 = v7.PreviewRespawn;
		elseif (v129.Name == "6Bot") then
			v194 = v7.PreviewBot;
		elseif (v129.Name == "7Settings") then
			v194 = v7.PreviewSettings;
		end
		v129.MouseEnter:Connect(function()
			if (v194 ~= nil) then
				v60:Create(v194, TweenInfo.new(0.1), {TextTransparency=0,TextStrokeTransparency=0.9}):Play();
			end
		end);
		v129.MouseLeave:Connect(function()
			if (v194 ~= nil) then
				v60:Create(v194, TweenInfo.new(0.1), {TextTransparency=1,TextStrokeTransparency=1}):Play();
			end
		end);
	end
end
v56.MouseButton1Click:Connect(function()
	v43 = nil;
	if (v61['BOTMorphUI'] == true) then
		v61['BOTMorphUI'] = false;
	else
		v43 = v35;
		v61['BOTMorphUI'] = true;
		v60:Create(v35, TweenInfo.new(0.125), {Position=v62['BOTMorph']}):Play();
	end
	HideOtherFrames("NOPE");
end);
for v130, v131 in pairs(v35:GetChildren()) do
	if v131:IsA("GuiButton") then
		v131.MouseButton1Click:Connect(function()
			if (v131.Name == "3Switch") then
				if (v61['BOTMorphComplex'] == true) then
					v61['BOTMorphComplex'] = false;
					v60:Create(v36, TweenInfo.new(0.125), {Position=v63['BOTMorphComplex']}):Play();
					HideOtherFrames("BOTMorphUI");
				else
					v61['BOTMorphComplex'] = true;
					v60:Create(v36, TweenInfo.new(0.125), {Position=v62['BOTMorphComplex']}):Play();
					HideOtherFrames("BOTMorphComplex");
					v60:Create(v35, TweenInfo.new(0.125), {Position=v63['BOTMorph']}):Play();
				end
			elseif ((v131.Name == "1Male") or (v131.Name == "2Female")) then
				HideOtherFrames("NOPE");
			elseif (v131.Name == "4Coloring") then
				if (v61['BOTColoring'] == true) then
					v61['BOTColoring'] = false;
					v60:Create(v37, TweenInfo.new(0.125), {Position=v63['BOTColoring']}):Play();
					HideOtherFrames("NOPE");
				else
					v61['BOTColoring'] = true;
					v60:Create(v37, TweenInfo.new(0.125), {Position=v62['BOTColoring']}):Play();
					HideOtherFrames("BOTColoring");
				end
			elseif (v131.Name == "5Accessories") then
				if (v61['BOTAccessories'] == true) then
					v61['BOTAccessories'] = false;
					v60:Create(v38, TweenInfo.new(0.125), {Position=v63['BOTAccessories']}):Play();
					HideOtherFrames("NOPE");
				else
					v61['BOTAccessories'] = true;
					v60:Create(v38, TweenInfo.new(0.125), {Position=v62['BOTAccessories']}):Play();
					HideOtherFrames("BOTAccessories");
				end
			end
		end);
	end
end
v57.MouseButton1Click:Connect(function()
	v43 = nil;
	if (v61['BOTAnimation'] == true) then
		v61['BOTAnimation'] = false;
		HideOtherFrames("NOPE");
	else
		v43 = v39;
		v61['BOTAnimation'] = true;
		v60:Create(v39, TweenInfo.new(0.125), {Position=v62['BOTAnimation']}):Play();
		HideOtherFrames("Animation");
	end
end);
v58.MouseButton1Click:Connect(function()
	v43 = nil;
	if (v61['BOTCharSettings'] == true) then
		v61['BOTCharSettings'] = false;
		HideOtherFrames("NOPE");
	else
		v43 = v40;
		v61['BOTCharSettings'] = true;
		v60:Create(v40, TweenInfo.new(0.125), {Position=v62['BOTCharSettings']}):Play();
		HideOtherFrames("BOTCharSettings");
	end
end);
v59.MouseButton1Click:Connect(function()
	v43 = v40;
	if (v61['BOTCatalogAcc'] == true) then
		v61['BOTCatalogAcc'] = false;
		HideOtherFrames("NOPE");
	else
		v61['BOTCatalogAcc'] = true;
		v60:Create(v41, TweenInfo.new(0.125), {Position=v62['BOTCatalogAcc']}):Play();
		HideOtherFrames("BOTCatalogAcc");
	end
end);
for v132, v133 in pairs(v27:GetChildren()) do
	if v133:IsA("TextButton") then
		local v203 = nil;
		if (v133.Name == "1Morph") then
			v203 = v27.PreviewMorphs;
		elseif (v133.Name == "2Animation") then
			v203 = v27.PreviewAnims;
		elseif (v133.Name == "3Settings") then
			v203 = v27.PreviewSettings;
		elseif (v133.Name == "4BotFP") then
			v203 = v27.PreviewBotFP;
		end
		v133.MouseEnter:Connect(function()
			if (v203 ~= nil) then
				v60:Create(v203, TweenInfo.new(0.1), {TextTransparency=0,TextStrokeTransparency=0.9}):Play();
			end
		end);
		v133.MouseLeave:Connect(function()
			if (v203 ~= nil) then
				v60:Create(v203, TweenInfo.new(0.1), {TextTransparency=1,TextStrokeTransparency=1}):Play();
			end
		end);
	end
end
HideOtherFrames("NOPE");
for v134, v135 in pairs(v16:GetDescendants()) do
	if (v135:IsA("GuiButton") and v135.Parent:FindFirstChild("Color") and v135.Parent:FindFirstChild("Value")) then
		v135.MouseButton1Click:Connect(function()
			for v241, v242 in pairs(v25.List:GetChildren()) do
				if v242:IsA("GuiButton") then
					v242:Destroy();
				end
			end
			v25.BackgroundColor3 = v135.Parent.Color.BackgroundColor3;
			v25.TitleLabel.BackgroundColor3 = v25.BackgroundColor3;
			v60:Create(v25, TweenInfo.new(0.125), {Position=v62['Selection']}):Play();
			script.Parent.ListMorphs:FireServer(v135);
		end);
	end
end
for v136, v137 in pairs(v18:GetDescendants()) do
	if (v137:IsA("GuiButton") and v137.Parent:FindFirstChild("Color") and v137.Parent:FindFirstChild("Value")) then
		v137.MouseButton1Click:Connect(function()
			for v243, v244 in pairs(v25.List:GetChildren()) do
				if v244:IsA("GuiButton") then
					v244:Destroy();
				end
			end
			v25.BackgroundColor3 = v137.Parent.Color.BackgroundColor3;
			v25.TitleLabel.BackgroundColor3 = v25.BackgroundColor3;
			v60:Create(v25, TweenInfo.new(0.125), {Position=v62['Selection']}):Play();
			script.Parent.ListMorphs:FireServer(v137);
		end);
	end
end
for v138, v139 in pairs(v36:GetDescendants()) do
	if (v139:IsA("GuiButton") and v139.Parent:FindFirstChild("Color") and v139.Parent:FindFirstChild("Value")) then
		v139.MouseButton1Click:Connect(function()
			for v245, v246 in pairs(v42.List:GetChildren()) do
				if v246:IsA("GuiButton") then
					v246:Destroy();
				end
			end
			v42.BackgroundColor3 = v139.Parent.Color.BackgroundColor3;
			v42.TitleLabel.BackgroundColor3 = v42.BackgroundColor3;
			v60:Create(v42, TweenInfo.new(0.125), {Position=v62['BOTSelection']}):Play();
			script.Parent.ListMorphs:FireServer(v139, true);
		end);
	end
end
for v140, v141 in pairs(v38:GetDescendants()) do
	if (v141:IsA("GuiButton") and v141.Parent:FindFirstChild("Color") and v141.Parent:FindFirstChild("Value")) then
		v141.MouseButton1Click:Connect(function()
			for v247, v248 in pairs(v42.List:GetChildren()) do
				if v248:IsA("GuiButton") then
					v248:Destroy();
				end
			end
			v42.BackgroundColor3 = v141.Parent.Color.BackgroundColor3;
			v42.TitleLabel.BackgroundColor3 = v42.BackgroundColor3;
			v60:Create(v42, TweenInfo.new(0.125), {Position=v62['BOTSelection']}):Play();
			script.Parent.ListMorphs:FireServer(v141, true);
		end);
	end
endlocal v0 = script.Parent;
task.wait(6);
local v1 = v0.Parent.Parent;
local v2 = game.ServerStorage:WaitForChild("Morphs");

function ForceColors(v4, v5)
	if (v5 == nil) then
		return;
	end
	for v33, v34 in pairs(v4:GetChildren()) do
		if v34:IsA("BasePart") then
			v34.Color = v5;
		elseif (v34:IsA("Model") or v34:IsA("Folder")) then
			ForceColors(v34, v5);
		end
	end
end

function CorrectColors(v6, v7)
	for v36, v37 in pairs(v6:GetChildren()) do
		local v38 = v0.Parent;
		if v37:IsA("BasePart") then
			v37.Transparency = 0;

			-- PHYSICS FIXES
			v37.Anchored = false;   -- Prevents teleporting to the storage location
			v37.CanCollide = false;  -- Enables collisions as requested
			v37.Massless = true;    -- Prevents the morph from flinging the player or being too heavy

			if ((v37.Name == "color1") or v37:FindFirstChild("IsColor1")) then
				v37.Color = v38.Color1.Value;
			elseif ((v37.Name == "color2") or v37:FindFirstChild("IsColor2")) then
				v37.Color = v38.Color2.Value;
			elseif ((v37.Name == "color5") or v37:FindFirstChild("IsColor3")) then
				v37.Color = v7.Torso.Color;
			elseif ((v37.Name == "Particle1") or v37:FindFirstChild("IsColor3")) then
				for v380, v381 in pairs(v37:GetChildren()) do
					if (v381.Name == "Particles") then
						v381.Color = ColorSequence.new(v38.Color3.Value);
					end
				end
				v37.Transparency = 1;
				v37.CanCollide = false; -- Particles shouldn't have collision
			elseif ((v37.Name == "Particle2") or (v37.Name == "Particle3") or v37:FindFirstChild("IsColor4")) then
				for v394, v395 in pairs(v37:GetChildren()) do
					if (v395.Name == "Particles") then
						v395.Color = ColorSequence.new(v38.Color4.Value);
					end
				end
				v37.Transparency = 1;
				v37.CanCollide = false;
			end

			if ((v37.Name == "Middle") or v37:FindFirstChild("Hidden")) then
				v37.Transparency = 1;
				v37.CanCollide = false; -- Hidden parts shouldn't collide
			end
		elseif (v37:IsA("Model") or v37:IsA("Folder")) then
			CorrectColors(v37, v7);
		end
	end
end

function BOTCorrectColors(v8, v9)
	for v39, v40 in pairs(v8:GetChildren()) do
		local v41 = v0.Parent;
		if v40:IsA("BasePart") then
			v40.Transparency = 0;

			-- PHYSICS FIXES
			v40.Anchored = false;
			v40.CanCollide = true;
			v40.Massless = true;

			if ((v40.Name == "color1") or v40:FindFirstChild("IsColor1")) then
				v40.Color = v41.BOTColor1.Value;
			elseif ((v40.Name == "color2") or v40:FindFirstChild("IsColor2")) then
				v40.Color = v41.BOTColor2.Value;
			elseif ((v40.Name == "color5") or v40:FindFirstChild("IsColor5")) then
				v40.Color = v9.Torso.Color;
			elseif (v40.Name == "Particle1") then
				for v382, v383 in pairs(v40:GetChildren()) do
					if (v383.Name == "Particles") then
						v383.Color = ColorSequence.new(v41.BOTColor3.Value);
					end
				end
				v40.Transparency = 1;
				v40.CanCollide = false;
			elseif ((v40.Name == "Particle2") or (v40.Name == "Particle3")) then
				for v397, v398 in pairs(v40:GetChildren()) do
					if (v398.Name == "Particles") then
						v398.Color = ColorSequence.new(v41.BOTColor4.Value);
					end
				end
				v40.Transparency = 1;
				v40.CanCollide = false;
			end

			if ((v40.Name == "Middle") or v40:FindFirstChild("Hidden")) then
				v40.Transparency = 1;
				v40.CanCollide = false;
			end
		elseif (v40:IsA("Model") or v40:IsA("Folder")) then
			BOTCorrectColors(v40, v9);
		end
	end
end

function Weld(v11)
	for v42, v43 in pairs(v11:GetChildren()) do
		if (v43:IsA("Model") or v43:IsA("Folder")) then
			Weld(v43);
		elseif v43:IsA("BasePart") then
			v43.Anchored = false;
			if v11:FindFirstChild("Middle") then
				local v349 = Instance.new("Weld");
				v349.Part0 = v11.Middle;
				v349.Part1 = v43;
				local v353 = CFrame.new(v11.Middle.Position);
				local v354 = v11.Middle.CFrame:inverse() * v353;
				local v355 = v43.CFrame:inverse() * v353;
				v349.C0 = v354;
				v349.C1 = v355;
				v349.Parent = v11.Middle;
			end
		end
	end
end

function AddMorph(v12, v13, v14)
	if not v13 or not v12 or v12 == "" then return end

	if (v13:FindFirstChild("Humanoid") ~= nil) then
		local v54 = v12:Clone();

		-- Pre-parenting safety to prevent flinging/teleporting
		for _, part in pairs(v54:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.Massless = true
			end
		end

		v54.Parent = v13;
		Weld(v54);

		if (v14 == true) then
			BOTCorrectColors(v54, v13);
		else
			CorrectColors(v54, v13);
		end

		for v64, v65 in pairs(v54:GetChildren()) do
			if v13:FindFirstChild(v65.Name) and v65.Name ~= "HumanoidRootPart" then
				v13[v65.Name]:Destroy();
			end
		end

		-- Standard Attachment Logic
		local function SetupMotor(obj, parentPart, offset)
			local m6d = parentPart:FindFirstChild("M6D" .. obj.Name) or Instance.new("Motor6D")
			m6d.Name = "M6D" .. obj.Name
			m6d.Part0 = parentPart
			m6d.Part1 = obj.Middle
			m6d.C0 = offset
			m6d.C1 = CFrame.new(0, 0, 0)
			m6d.Parent = parentPart
			obj.Parent = v13
			obj.Middle.Name = "M6D" .. obj.Name
		end

		if v54:FindFirstChild("Rod") then SetupMotor(v54.Rod, v13.Torso, CFrame.new(0, -v13.Torso.Size.Y / 2, -v13.Torso.Size.Z / 2)) end
		if v54:FindFirstChild("Orbs") then SetupMotor(v54.Orbs, v13.Torso, CFrame.new(0, -v13.Torso.Size.Y / 2, -v13.Torso.Size.Z / 2)) end
		if v54:FindFirstChild("UpperL") then SetupMotor(v54.UpperL, v13.Torso, CFrame.new(-v13.Torso.Size.X / 8, v13.Torso.Size.Y / 2, -v13.Torso.Size.Z / 2)) end
		if v54:FindFirstChild("UpperR") then SetupMotor(v54.UpperR, v13.Torso, CFrame.new(v13.Torso.Size.X / 8, v13.Torso.Size.Y / 2, -v13.Torso.Size.Z / 2)) end
		if v54:FindFirstChild("LowerL") then SetupMotor(v54.LowerL, v13.Torso, CFrame.new(-v13.Torso.Size.X / 8, -v13.Torso.Size.Y / 2, v13.Torso.Size.Z / 2)) end
		if v54:FindFirstChild("LowerR") then SetupMotor(v54.LowerR, v13.Torso, CFrame.new(v13.Torso.Size.X / 8, -v13.Torso.Size.Y / 2, v13.Torso.Size.Z / 2)) end

		-- Static Weld Logic
		local staticNames = {"UpperStatic", "UpperStaticA", "UpperStaticB", "LowerStatic", "LowerStaticA", "LowerStaticB", "RearStatic", "TorsoAcc", "Cage"}
		for _, name in pairs(staticNames) do
			if v54:FindFirstChild(name) then
				local obj = v54[name]
				local w = Instance.new("Weld")
				w.Part0 = v13.Torso
				w.Part1 = obj.Middle
				w.C0 = CFrame.new(0, 0, 0)
				w.Parent = w.Part0
			end
		end

		-- Limb Weld Logic
		local limbMap = {
			["HeadAcc"] = "Head", ["ArmL"] = "Left Arm", ["ArmR"] = "Right Arm", 
			["LegL"] = "Left Leg", ["LegR"] = "Right Leg", ["BodyLeftArm"] = "Left Arm",
			["BodyRightArm"] = "Right Arm", ["BodyLeftLeg"] = "Left Leg", 
			["BodyRightLeg"] = "Right Leg", ["BodyTorso"] = "Torso"
		}

		for mName, cName in pairs(limbMap) do
			if v54:FindFirstChild(mName) and v13:FindFirstChild(cName) then
				local obj = v54[mName]
				local w = Instance.new("Weld")
				w.Part0 = v13[cName]
				w.Part1 = obj.Middle
				w.C0 = CFrame.new(0, 0, 0)
				w.Parent = w.Part0
				if mName:find("Body") then
					ForceColors(v54, w.Part0.Color)
					w.Part0.Transparency = v54:FindFirstChild("IsNone") and 0 or 1
				end
			end
		end

		for _, item in pairs(v54:GetChildren()) do
			item.Parent = v13;
		end
		v54:Destroy();
	end
end

function ListStuff(v15, v16, v17)
	for v44, v45 in pairs(v15.List:GetChildren()) do
		if v45:IsA("GuiButton") then v45:Destroy() end
	end
	for v46, v47 in pairs(v16:GetChildren()) do
		local v48 = true;
		if v47:FindFirstChild("Hidden") then v48 = false end
		if v47:FindFirstChild("UserNameList") then
			v48 = v47.UserNameList:FindFirstChild(v1.Name) ~= nil
		end
		if v48 then
			local v69 = script.SelectionButton:Clone();
			v69.Parent = v15.List;
			v69.Text = v47.Name;
			local categoryValue = Instance.new("StringValue")
			categoryValue.Name = "CategoryFolderID"
			categoryValue.Value = v16.Name
			categoryValue.Parent = v69
			v69.MouseButton1Click:Connect(function()
				local targetChar = v1.Character
				if (v15 == v0.BOTSelection) then
					if v1:WaitForChild("bot1enabled").Value then
						targetChar = workspace:FindFirstChild(v1.Name .. "Bot")
					elseif v1:WaitForChild("bot2enabled").Value then
						targetChar = workspace:FindFirstChild(v1.Name .. "Bot2")
					end
				end
				if targetChar then
					v17.Text = v47.Name
					v17.Parent.Value.Value = v47.Name
				end
			end)
		end
	end
end

v0.ListMorphs.OnServerEvent:Connect(function(v18, v19, v20)
	if not v19 then return end
	local mapping = {
		["1Pink"]="1", ["2Green"]="2", ["3Purple"]="3", ["4Blue"]="4", 
		["5Orange"]="5", ["6Yellow"]="6", ["7Red"]="7", ["8Cyan"]="8", 
		["Customize 1"]="9", ["Customize 2"]="10"
	}
	local folderName = mapping[v19.Parent.Name]
	if folderName and v2[folderName] then
		ListStuff(v20 and v0.BOTSelection or v0.Selection, v2[folderName], v19)
	end
end)

function GetStringValues(v22, v23)
	for _, v50 in pairs(v22:GetChildren()) do
		if v50:IsA("StringValue") then
			v50.Changed:Connect(function()
				local targetChar = v23 and (v1.bot1enabled.Value and workspace:FindFirstChild(v1.Name.."Bot") or workspace:FindFirstChild(v1.Name.."Bot2")) or v1.Character
				local mapping = {
					["1Pink"]="1", ["2Green"]="2", ["3Purple"]="3", ["4Blue"]="4", 
					["5Orange"]="5", ["6Yellow"]="6", ["7Red"]="7", ["8Cyan"]="8", 
					["Customize 1"]="9", ["Customize 2"]="10"
				}
				local folderIdx = mapping[v50.Parent.Name]
				if targetChar and folderIdx and v2[folderIdx] then
					local morphModel = v2[folderIdx]:FindFirstChild(v50.Value)
					if morphModel then
						AddMorph(morphModel, targetChar, v23)
						if v50.Parent:FindFirstChild("TheButtonnnn") then
							v50.Parent.TheButtonnnn.Text = v50.Value
						end
					end
				end
			end)
		else
			GetStringValues(v50, v23)
		end
	end
end

GetStringValues(v0.MorphComplex);
GetStringValues(v0.Accessories);
GetStringValues(v0.BOTMorphComplex, true);
GetStringValues(v0.BOTAccessories, true);

function ToggleAcc(v24, v25, v26)
	for _, v52 in pairs(v24:GetChildren()) do
		if v52:IsA("BasePart") then
			if (v52.Name == v25) then
				v52.Transparency = v26 and 0 or 1
				v52.CanCollide = v26 -- Toggle collision with visibility
			end
		else
			ToggleAcc(v52, v25, v26)
		end
	end
end

local v3 = {}
local function BindToggle(btn, charSource, accName, partName, subFolder)
	btn.MouseButton1Click:Connect(function()
		local char = charSource()
		if char then
			v3[accName] = not v3[accName]
			if char:FindFirstChild(subFolder) then
				ToggleAcc(char[subFolder], partName, v3[accName])
			end
		end
	end)
end

local getPlayerChar = function() return v1.Character end
local getBotChar = function() return workspace:FindFirstChild(v1.Name .. "Bot") end

BindToggle(v0.Accessories.Ring, getPlayerChar, "Ring", "Ring", "Rod")
BindToggle(v0.Accessories.UpperRings, getPlayerChar, "UpperRing", "Ring", "UpperL")
BindToggle(v0.Accessories.PiercingsAddon, getPlayerChar, "PiercingsAddon", "Piercing", "UpperL")

BindToggle(v0.BOTAccessories.Ring, getBotChar, "Ring", "Ring", "Rod")
BindToggle(v0.BOTAccessories.UpperRings, getBotChar, "UpperRing", "Ring", "UpperL")
BindToggle(v0.BOTAccessories.PiercingsAddon, getBotChar, "PiercingsAddon", "Piercing", "UpperL")local searchbar = script.Parent.Searchbar -- Replace "nil" with the location of the textbox that you want to search.
local commandlist1 = script.Parent.Men_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist2 = script.Parent.Women_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist3 = script.Parent.Emote_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist4 = script.Parent.Plus_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist5 = script.Parent.All_List -- Replace "nil" with the location of the frame with the items inside of it.

function UpdateResults()
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist1:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist2:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist3:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist4:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist5:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	
end

searchbar.Changed:Connect(UpdateResults)
local button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(213, 115, 208)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.Men_List
local womanAni = script.Parent.Parent.Parent.Women_List
local emoteAni = script.Parent.Parent.Parent.Emote_List
local plusAni = script.Parent.Parent.Parent.Plus_List
local allAni = script.Parent.Parent.Parent.All_List
local NotAnimation = script.Parent.Parent.Parent.Nothing_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = true
	manAni.Visible = false
	emoteAni.Visible = false
	plusAni.Visible = false
	allAni.Visible = false
	NotAnimation.Visible = false
end)

--Izzy was herelocal button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(115, 163, 213)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.Men_List
local womanAni = script.Parent.Parent.Parent.Women_List
local emoteAni = script.Parent.Parent.Parent.Emote_List
local plusAni = script.Parent.Parent.Parent.Plus_List
local allAni = script.Parent.Parent.Parent.All_List
local NotAnimation = script.Parent.Parent.Parent.Nothing_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = true
	emoteAni.Visible = false
	plusAni.Visible = false
	allAni.Visible = false
	NotAnimation.Visible = false
end)

--Izzy was herelocal button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(177, 115, 213)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.Men_List
local womanAni = script.Parent.Parent.Parent.Women_List
local emoteAni = script.Parent.Parent.Parent.Emote_List
local plusAni = script.Parent.Parent.Parent.Plus_List
local allAni = script.Parent.Parent.Parent.All_List
local NotAnimation = script.Parent.Parent.Parent.Nothing_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = false
	emoteAni.Visible = true
	plusAni.Visible = false
	allAni.Visible = false
	NotAnimation.Visible = false
end)

--Izzy was herelocal button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(200, 255, 138)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.Men_List
local womanAni = script.Parent.Parent.Parent.Women_List
local emoteAni = script.Parent.Parent.Parent.Emote_List
local plusAni = script.Parent.Parent.Parent.Plus_List
local allAni = script.Parent.Parent.Parent.All_List
local NotAnimation = script.Parent.Parent.Parent.Nothing_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = false
	emoteAni.Visible = false
	plusAni.Visible = true
	allAni.Visible = false
	NotAnimation.Visible = false
end)

local button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(213, 213, 213)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.Men_List
local womanAni = script.Parent.Parent.Parent.Women_List
local emoteAni = script.Parent.Parent.Parent.Emote_List
local plusAni = script.Parent.Parent.Parent.Plus_List
local allAni = script.Parent.Parent.Parent.All_List
local NotAnimation = script.Parent.Parent.Parent.Nothing_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = false
	emoteAni.Visible = false
	plusAni.Visible = false
	allAni.Visible = true
	NotAnimation.Visible = false
end)

--Izzy was herelocal button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 61, 187)  
local hoverTextColor = Color3.fromRGB(255, 61, 187)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Button = script.Parent
local Active = false
local player = Players.LocalPlayer

local OilyEvent = ReplicatedStorage:WaitForChild("OilyToggleEvent")

Button.MouseButton1Click:Connect(function()
	Active = not Active
	local character = player.Character
	if character then
		OilyEvent:FireServer(Active)
	end
end)local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 62, 75)  
local hoverTextColor = Color3.fromRGB(255, 62, 75)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local textBox = script.Parent
local replicatedStorage = game:GetService("ReplicatedStorage")
local sr = replicatedStorage:WaitForChild("SizeRemote")

textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local input = tonumber(textBox.Text)
		if input then
			local clampedSize = math.clamp(math.abs(input), 0.8, 1.2)
			sr:FireServer(clampedSize)
		end
	end
end)local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 176, 96)  
local hoverTextColor = Color3.fromRGB(255, 176, 96)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 62, 75)  
local hoverTextColor = Color3.fromRGB(255, 62, 75)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
task.wait(5)

local Menu = script.Parent.Parent.Parent.MorphComplex
local Players = game:GetService("Players")
local player = Players.LocalPlayer  

function leftClick()
	Menu["1Pink"].Value.Value = "None"
	Menu["2Green"].Value.Value = "None"
	Menu["3Purple"].Value.Value = "None"
	Menu["4Blue"].Value.Value = "None"
	Menu["5Orange"].Value.Value = "None"
	Menu["6Yellow"].Value.Value = "None"
	Menu["7Red"].Value.Value = "None"
	Menu["8Cyan"].Value.Value = "None"
end

script.Parent.MouseButton1Click:Connect(leftClick)
local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(208, 66, 255)  
local hoverTextColor = Color3.fromRGB(189, 97, 255)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local tweenTime = 0.2  

 
local function getRandomColor()
	return Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

local function onMouseEnter()
	local hoverBgColor = getRandomColor() 
	local hoverTextColor = getRandomColor() 

	 
	local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
	local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

	 
	local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local textHoverGoal = {TextColor3 = hoverTextColor}
	local textOriginalGoal = {TextColor3 = originalTextColor}

	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

	local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local textOriginalGoal = {TextColor3 = originalTextColor}

	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
script.Parent.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 3
	
end)

-- SCRIPT MADE BY: TOOTMISKNIFEEZ. --

script.Parent.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 40
	
end)

-- SCRIPT MADE BY: TOOTMISKNIFEEZ. --

script.Parent.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 120
	
end)

-- SCRIPT MADE BY: TOOTMISKNIFEEZ. --

script.Parent.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = .5
	
end)

-- SCRIPT MADE BY: TOOTMISKNIFEEZ. --

script.Parent.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
	
end)

-- SCRIPT MADE BY: TOOTMISKNIFEEZ. --

local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 61, 187)  
local hoverTextColor = Color3.fromRGB(255, 61, 187)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Button = script.Parent
local player = Players.LocalPlayer
local OilyEvent = ReplicatedStorage:WaitForChild("OilyToggleEvent")

local Bot1Active = false
local Bot2Active = false

Button.MouseButton1Click:Connect(function()
	local b1Enabled = player:FindFirstChild("bot1enabled") and player.bot1enabled.Value
	local b2Enabled = player:FindFirstChild("bot2enabled") and player.bot2enabled.Value

	local targetType = nil
	local newState = false
	
	if b1Enabled then
		targetType = "Bot1"
		Bot1Active = not Bot1Active
		newState = Bot1Active
	elseif b2Enabled then
		targetType = "Bot2"
		Bot2Active = not Bot2Active
		newState = Bot2Active
	end
	
	if targetType then
		OilyEvent:FireServer(newState, targetType)
	end
end)local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(208, 66, 255)  
local hoverTextColor = Color3.fromRGB(189, 97, 255)  
local tweenTime = 0.2  


local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}


local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()

	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()

	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 62, 75)  
local hoverTextColor = Color3.fromRGB(255, 62, 75)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
task.wait(5)

local Menu = script.Parent.Parent.Parent.BOTMorphComplex
local Players = game:GetService("Players")
local player = Players.LocalPlayer  

function leftClick()
	 
	Menu["1Pink"].Value.Value = "None"
	Menu["2Green"].Value.Value = "None"
	Menu["3Purple"].Value.Value = "None"
	Menu["4Blue"].Value.Value = "None"
	Menu["5Orange"].Value.Value = "None"
	Menu["6Yellow"].Value.Value = "None"
	Menu["7Red"].Value.Value = "None"
	Menu["8Cyan"].Value.Value = "None"

	 
	local character = player.Character or player.CharacterAdded:Wait()

	 
	if character:FindFirstChild("PlayerHighlight") then
		character.PlayerHighlight:Destroy()
	end

	 
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerHighlight"  
	highlight.OutlineColor = Color3.new(0, 0, 0)  
	highlight.OutlineTransparency = 0  
	highlight.FillColor = Color3.new(0, 0, 0)  
	highlight.FillTransparency = 1  
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded  
	highlight.Parent = character  
end

script.Parent.MouseButton1Click:Connect(leftClick)
local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(208, 66, 255)  
local hoverTextColor = Color3.fromRGB(189, 97, 255)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
task.wait(5)

local Menu = script.Parent.Parent.Parent

function leftClick()
	Menu.BOTMorphComplex["1Pink"].Value.Value = "Normal"
	Menu.BOTMorphComplex["2Green"].Value.Value = "Large"
	Menu.BOTMorphComplex["3Purple"].Value.Value = "Closed"
	Menu.BOTMorphComplex["4Blue"].Value.Value = "None"
	Menu.BOTMorphComplex["5Orange"].Value.Value = "None"
end

script.Parent.MouseButton1Click:Connect(leftClick)task.wait(5)

local Menu = script.Parent.Parent.Parent

function leftClick()
	Menu.BOTMorphComplex["1Pink"].Value.Value = "Flat"
	Menu.BOTMorphComplex["2Green"].Value.Value = "Normal"
	Menu.BOTMorphComplex["3Purple"].Value.Value = "None"
	Menu.BOTMorphComplex["4Blue"].Value.Value = "Normal"
	Menu.BOTMorphComplex["5Orange"].Value.Value = "None"
end

script.Parent.MouseButton1Click:Connect(leftClick)task.wait(1)
ownsroom = script.Parent.Parent.Parent:WaitForChild('RoomStuff'):WaitForChild("OwnsRoom")
gui = script.Parent

ownsroom.Changed:Connect(function(NewValue)
	if ownsroom.Value == false then
		script.Parent.Visible = false
	end
end)[12:51:28 FTL] Decompilation error
Unluau.DecompilerException: Bytecode version mismatch, expected version 3...6, got 10
   at Unluau.Deserializer.Deserialize()
   at Unluau.Decompiler..ctor(Stream stream, DecompilerOptions options)
   at Unluau.CLI.Program.RunOptions(Options options)
-- Script:

local searchbar = script.Parent.SearchBar -- Replace "nil" with the location of the textbox that you want to search.
local commandlist = script.Parent.List -- Replace "nil" with the location of the frame with the items inside of it.

function UpdateResults()
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
end

searchbar.Changed:Connect(UpdateResults)local page = script.Parent:WaitForChild("Paige")
local selected = script.Parent:WaitForChild("Selected")


page.Changed:Connect(function(NewValue)
	local search1 = script.Parent.Page:GetChildren()
	for i=1,#search1 do
		local search2 = search1[i]:GetChildren()
		for j=1,#search2 do
			if search2[j].ClassName == "NumberValue" then
				if search2[j].Value == page.Value then
					search1[i].Visible = true
				else
					search1[i].Visible = false
				end
			end
		end
			
	end
end)

selected.Changed:Connect(function(NewValue)
	local search1 = script.Parent.Selection:GetChildren()
	for i=1,#search1 do
		local search2 = search1[i]:GetChildren()
		for j=1,#search2 do
			if search2[j].ClassName == "NumberValue" then
				if search2[j].Value == selected.Value then
					search1[i].BorderColor3 = Color3.fromRGB(255,255,255)
				else
					search1[i].BorderColor3 = Color3.fromRGB(0,0,0)
				end
			end
		end
	end
end)task.wait(2.5)

local Player = script.Parent.Parent.Parent.Parent
local UI = script.Parent

local colorevent = UI.ColorEvent
local selected = script.Parent:WaitForChild("Selected")

function getbuttons(targ)
	for i,v in pairs(targ:GetChildren()) do
		if v:IsA("GuiButton") then
			v.MouseButton1Click:Connect(function()
				local thefolder = game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name)
				
				local targetColor = v.BackgroundColor3
				
				if selected.Value == 1 then
					if thefolder:FindFirstChild("ChatNameColor") then
						UI.Selection.Selection1.BackgroundColor3 = targetColor
						thefolder.ChatNameColor.Value = targetColor
						
					end
				elseif selected.Value == 2 then
					if thefolder:FindFirstChild("ChatColor") then
						UI.Selection.Selection2.BackgroundColor3 = targetColor
						thefolder.ChatColor.Value = targetColor
						
					end
				end
				
				if Player.Character then
					local char = Player.Character

					local headerrrr = char:FindFirstChild("headerrrr")
					if headerrrr then
						headerrrr.Main.Text3.Text = thefolder.Value

						if thefolder:FindFirstChild("ChatNameColor") then
							headerrrr.Main.Text1.TextColor3 = thefolder.ChatNameColor.Value
						end
						headerrrr.Main.Text2.TextColor3 = headerrrr.Main.Text1.TextColor3
						headerrrr.Main.Text3.TextColor3 = headerrrr.Main.Text1.TextColor3

					end
				end
			end)
		else
			getbuttons(v)
		end
	end
end

getbuttons(script.Parent.Page)

if game.ReplicatedStorage:WaitForChild('ChatStuff'):FindFirstChild(Player.Name) then
	local thefolder = game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name)
	
	if thefolder.Value == "" then
		thefolder.Value = Player.DisplayName
	end
	
	UI.Selection.SelectionBox3.Text = thefolder.Value

	if thefolder:FindFirstChild("ChatNameColor") then
		UI.Selection.Selection1.BackgroundColor3 = thefolder.ChatNameColor.Value
	end

	if thefolder:FindFirstChild("ChatColor") then
		UI.Selection.Selection2.BackgroundColor3 = thefolder.ChatColor.Value
	end
	
	if Player.Character then
		local char = Player.Character
		
		local headerrrr = char:FindFirstChild("headerrrr")
		if headerrrr then
			headerrrr.PlayerToHideFrom = Player
			headerrrr.Main.Text3.Text = thefolder.Value

			local customname = ""
			
			if thefolder:FindFirstChild("ChatNameColor") then
				headerrrr.Main.Text1.TextColor3 = thefolder.ChatNameColor.Value
			end
			headerrrr.Main.Text2.TextColor3 = headerrrr.Main.Text1.TextColor3
			headerrrr.Main.Text3.TextColor3 = headerrrr.Main.Text1.TextColor3
		end
	end
end

game.ReplicatedStorage.ChatStuff.ChildAdded:Connect(function()
	if game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name) then
		local thefolder = game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name)

		if thefolder.Value == "" then
			thefolder.Value = Player.DisplayName
		end

		UI.Selection.SelectionBox3.Text = thefolder.Value

		if thefolder:FindFirstChild("ChatNameColor") then
			UI.Selection.Selection1.BackgroundColor3 = thefolder.ChatNameColor.Value
		end

		if thefolder:FindFirstChild("ChatColor") then
			UI.Selection.Selection2.BackgroundColor3 = thefolder.ChatColor.Value
		end

		if Player.Character then
			local char = Player.Character

			local headerrrr = char:FindFirstChild("headerrrr")
			if headerrrr then
				headerrrr.Main.Text3.Text = thefolder.Value

				local customname = ""

				if thefolder:FindFirstChild("ChatNameColor") then
					headerrrr.Main.Text1.TextColor3 = thefolder.ChatNameColor.Value
				end
				headerrrr.Main.Text2.TextColor3 = headerrrr.Main.Text1.TextColor3
				headerrrr.Main.Text3.TextColor3 = headerrrr.Main.Text1.TextColor3
			end
		end
	end
end)

colorevent.OnServerEvent:Connect(function(Player,heheha,color,nameeee)
	if game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name) then
		local thefolder = game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name)

		if nameeee ~= nil then
			UI.Selection.SelectionBox3.Text = nameeee
			thefolder.Value = nameeee
		end
		
		if heheha == "ChatName" and color ~= nil then
			thefolder.ChatNameColor.Value = color
			UI.Selection.Selection1.BackgroundColor3 = thefolder.ChatNameColor.Value
		elseif heheha == "Chat" and color ~= nil then
			thefolder.ChatColor.Value = color
			UI.Selection.Selection2.BackgroundColor3 = thefolder.ChatColor.Value
		end
				
		if thefolder.Value == "" then
			thefolder.Value = Player.DisplayName
		end
		
		if Player.Character then
			local char = Player.Character

			local headerrrr = char:FindFirstChild("headerrrr")
			if headerrrr then
				headerrrr.Main.Text3.Text = thefolder.Value

				if thefolder:FindFirstChild("ChatNameColor") then
					headerrrr.Main.Text1.TextColor3 = thefolder.ChatNameColor.Value
				end
				headerrrr.Main.Text2.TextColor3 = headerrrr.Main.Text1.TextColor3
				headerrrr.Main.Text3.TextColor3 = headerrrr.Main.Text1.TextColor3

			end
		end
	end
end)

--[[
game.ReplicatedStorage.ChatStuff.ChildRemoved:Connect(function()
	if not game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name) then
		
	end
end)
]]local page = script.Parent.Parent:WaitForChild("Paige")
--change this

function leftClick() --change this
	if page.Value ~= 1 then
		page.Value -= 1
	else
		page.Value = 8
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local Player = script.Parent.Parent.Parent.Parent.Parent.Parent

function leftClick() --change this
	selected.Value = 2
end

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local Player = script.Parent.Parent.Parent.Parent.Parent.Parent

function leftClick() --change this
	selected.Value = 1
end

script.Parent.MouseButton1Click:Connect(leftClick)local thebox = script.Parent

local UI = script.Parent.Parent.Parent

thebox.FocusLost:Connect(function()
	UI.ColorEvent:FireServer(
		nil,nil,thebox.Text
	)
end)local page = script.Parent:WaitForChild("Paige")
local selected = script.Parent:WaitForChild("Selected")


page.Changed:Connect(function(NewValue)
	local search1 = script.Parent.Page:GetChildren()
	for i=1,#search1 do
		local search2 = search1[i]:GetChildren()
		for j=1,#search2 do
			if search2[j].ClassName == "NumberValue" then
				if search2[j].Value == page.Value then
					search1[i].Visible = true
				else
					search1[i].Visible = false
				end
			end
		end
			
	end
end)

selected.Changed:Connect(function(NewValue)
	local search1 = script.Parent.Selection:GetChildren()
	for i=1,#search1 do
		local search2 = search1[i]:GetChildren()
		for j=1,#search2 do
			if search2[j].ClassName == "NumberValue" then
				if search2[j].Value == selected.Value then
					search1[i].BorderColor3 = Color3.fromRGB(255,255,255)
				else
					search1[i].BorderColor3 = Color3.fromRGB(0,0,0)
				end
			end
		end
	end
end)local page = script.Parent.Parent:WaitForChild("Paige")
--change this

function leftClick() --change this
	if page.Value ~= 1 then
		page.Value -= 1
	else
		page.Value = 8
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor2") --change accordingly

function leftClick() --change this
	selected.Value = 2
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor5") --change accordingly

function leftClick() --change this
	selected.Value = 5
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor8") --change accordingly

function leftClick() --change this
	selected.Value = 8
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(225,225,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor6") --change accordingly

function leftClick() --change this
	selected.Value = 6
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(225,225,225)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor1") --change accordingly

function leftClick() --change this
	selected.Value = 1
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor7") --change accordingly

function leftClick() --change this
	selected.Value = 7
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(225,225,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor3") --change accordingly

function leftClick() --change this
	selected.Value = 3
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("BOTColor4") --change accordingly

function leftClick() --change this
	selected.Value = 4
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local remote = game.ReplicatedStorage:WaitForChild("CustomRGB")
local selected = script.Parent.Parent:WaitForChild("Selected")

script.Parent.MouseButton1Click:Connect(function()
	remote:FireServer(selected.Value,script.Parent.Parent["1R"].Text, script.Parent.Parent["2G"].Text, script.Parent.Parent["3B"].Text) --change accordingly
end)local page = script.Parent:WaitForChild("Paige")
local selected = script.Parent:WaitForChild("Selected")


page.Changed:Connect(function(NewValue)
	local search1 = script.Parent.Page:GetChildren()
	for i=1,#search1 do
		local search2 = search1[i]:GetChildren()
		for j=1,#search2 do
			if search2[j].ClassName == "NumberValue" then
				if search2[j].Value == page.Value then
					search1[i].Visible = true
				else
					search1[i].Visible = false
				end
			end
		end
			
	end
end)

selected.Changed:Connect(function(NewValue)
	local search1 = script.Parent.Selection:GetChildren()
	for i=1,#search1 do
		local search2 = search1[i]:GetChildren()
		for j=1,#search2 do
			if search2[j].ClassName == "NumberValue" then
				if search2[j].Value == selected.Value then
					search1[i].BorderColor3 = Color3.fromRGB(255,255,255)
				else
					search1[i].BorderColor3 = Color3.fromRGB(0,0,0)
				end
			end
		end
	end
end)local selected = script.Parent:WaitForChild("Selected")

local p = script.Parent.Parent.Parent
local col1 = p:WaitForChild("Color1")
local col2 = p:WaitForChild("Color2")
local col3 = p:WaitForChild("Color3")
local col4 = p:WaitForChild("Color4")
local col5 = p:WaitForChild("Color5")
local col6 = p:WaitForChild("Color6")
local col7 = p:WaitForChild("Color7")
local col8 = p:WaitForChild("Color8")
function getbuttons(targ)
	for i,v in pairs(targ:GetChildren()) do
		if v:IsA("GuiButton") then
			v.MouseButton1Click:Connect(function()
				p = script.Parent.Parent.Parent
				col1 = p:WaitForChild("Color1")
				col2 = p:WaitForChild("Color2")
				col3 = p:WaitForChild("Color3")
				col4 = p:WaitForChild("Color4")
				col5 = p:WaitForChild("Color5")
				col6 = p:WaitForChild("Color6")
				col7 = p:WaitForChild("Color7")
				col8 = p:WaitForChild("Color8")

				local targetColor = v.BackgroundColor3
				if selected.Value == 1 then
					col1.Value = targetColor
				end
				if selected.Value == 2 then
					col2.Value = targetColor
				end
				if selected.Value == 3 then
					col3.Value = targetColor
				end
				if selected.Value == 4 then
					col4.Value = targetColor
				end
				if selected.Value == 5 then
					col5.Value = targetColor
				end
				if selected.Value == 6 then
					col6.Value = targetColor
				end
				if selected.Value == 7 then
					col7.Value = targetColor
				end
				if selected.Value == 8 then
					col8.Value = targetColor
				end
			end)
		else
			getbuttons(v)
		end
	end
end

getbuttons(script.Parent.Page)local page = script.Parent.Parent:WaitForChild("Paige")
--change this

function leftClick() --change this
	if page.Value ~= 1 then
		page.Value -= 1
	else
		page.Value = 8
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color2") --change accordingly

function leftClick() --change this
	selected.Value = 2
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color5") --change accordingly

function leftClick() --change this
	selected.Value = 5
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color8") --change accordingly

function leftClick() --change this
	selected.Value = 8
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(225,225,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color6") --change accordingly

function leftClick() --change this
	selected.Value = 6
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(225,225,225)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color1") --change accordingly

function leftClick() --change this
	selected.Value = 1
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color7") --change accordingly

function leftClick() --change this
	selected.Value = 7
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(225,225,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color3") --change accordingly

function leftClick() --change this
	selected.Value = 3
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local selected = script.Parent.Parent.Parent:WaitForChild("Selected")

local p = script.Parent

local col = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Color4") --change accordingly

function leftClick() --change this
	selected.Value = 4
end

col.Changed:Connect(function(NewValue)
	p.BackgroundColor3 = col.Value
	if col.Value.R < 0.5 and col.Value.G < 0.5 and col.Value.B < 0.5 then
		p.TextColor3 = Color3.fromRGB(255,255,255)
	else
		p.TextColor3 = Color3.fromRGB(0,0,0)
	end
end)

script.Parent.MouseButton1Click:Connect(leftClick)local remote = game.ReplicatedStorage:WaitForChild("CustomRGB")
local selected = script.Parent.Parent:WaitForChild("Selected")

script.Parent.MouseButton1Click:Connect(function()
	remote:FireServer(selected.Value,script.Parent.Parent["1R"].Text, script.Parent.Parent["2G"].Text, script.Parent.Parent["3B"].Text) --change accordingly
end)local Menu = script.Parent.Parent.Parent
local PhysicsService = game:GetService("PhysicsService")

pcall(function()
	PhysicsService:RegisterCollisionGroup("Participants")
	PhysicsService:CollisionGroupSetCollidable("Participants", "Participants", false)
end)

local function setCollisionGroup(model, groupName)
	for _, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CollisionGroup = groupName
		end
	end
end

local function forceSit(bot, hum)
	local root = bot.PrimaryPart
	if not root then return end

	hum:ChangeState(Enum.HumanoidStateType.Running)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {bot}

	local parts = workspace:GetPartBoundsInBox(root.CFrame, Vector3.new(3, 3, 3), params)
	for _, v in pairs(parts) do
		if (v:IsA("Seat") or v:IsA("VehicleSeat")) and not v.Occupant then
			v:Sit(hum)
			break
		end
	end
end

function leftClick()
	local Player = Menu.Parent.Parent

	if not Player:IsA("Player") then return end
	if not Player.Character then return end
	local playerRoot = Player.Character:FindFirstChild("HumanoidRootPart")
	if not playerRoot then return end

	setCollisionGroup(Player.Character, "Participants")

	local bot1val = Player:WaitForChild("bot1enabled")
	local bot2val = Player:WaitForChild("bot2enabled")

	local function assignPhysics(model, playerOwner)
		local root = model:FindFirstChild("HumanoidRootPart")
		if root then
			root:SetNetworkOwner(playerOwner)
		end
	end

	local function handleBot(botName)
		local bot = game.Workspace:FindFirstChild(botName)
		local isNew = false

		if not bot then
			bot = game.ServerStorage.BOTTemplate:Clone()
			bot.Name = botName
			bot.Parent = game.Workspace
			isNew = true
		end

		local hum = bot:FindFirstChildOfClass("Humanoid")
		if hum then
			if hum.SeatPart then
				hum.Jump = true
				task.wait(0.1)
			end

			bot:SetPrimaryPartCFrame(playerRoot.CFrame * CFrame.new(0, 0, -1))

			task.wait(0.1)

			assignPhysics(bot, Player)
			setCollisionGroup(bot, "Participants")

			forceSit(bot, hum)
		end
	end

	if bot1val.Value == true then
		handleBot(Player.Name .. "Bot")
	elseif bot2val.Value == true then
		handleBot(Player.Name .. "Bot2")
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local Menu = script.Parent.Parent.Parent

--local BOT = nil
--why is that there anyways lmao

function leftClick()
	local Player = Menu.Parent.Parent

	local bot1val,bot2val
	bot1val = Player:WaitForChild("bot1enabled")
	bot2val = Player:WaitForChild("bot2enabled")

	if workspace:FindFirstChild(Player.Name.."Bot") and bot1val.Value == true then
		workspace:FindFirstChild(Player.Name.."Bot"):Destroy()
	elseif  workspace:FindFirstChild(Player.Name.."Bot2") and bot2val.Value == true then
		workspace:FindFirstChild(Player.Name.."Bot2"):Destroy()
	end

end

script.Parent.MouseButton1Click:Connect(leftClick)task.wait()

local GUI = script.Parent.Parent
local ThisFrame = script.Parent
local Player = GUI.Parent.Parent

local Buttons = {}
local BOT = nil
local currentBotSuffix = "Bot"

local changeValueEvent = game.ReplicatedStorage:WaitForChild("changeBotValue")

local function updateBotAccessories(bot)
	if not bot then return end
	
	for i, v in pairs(ThisFrame.List:GetChildren()) do
		if v:IsA("TextLabel") or v:IsA("TextButton") then
			v:Destroy()
		end
	end

	Buttons = {}

	for _, child in pairs(bot:GetChildren()) do
		if child:IsA("Accessory") then
			local newbutton = script.hahahat:Clone()
			newbutton.Parent = ThisFrame.List
			newbutton.Text = child.Name
			newbutton.MouseButton1Click:Connect(function()
				if child then child:Destroy() end
				newbutton:Destroy()
			end)
			Buttons[child] = newbutton
		end
	end

	bot.ChildAdded:Connect(function(newAccessory)
		if newAccessory:IsA("Accessory") then
			local newbutton = script.hahahat:Clone()
			newbutton.Parent = ThisFrame.List
			newbutton.Text = newAccessory.Name
			newbutton.MouseButton1Click:Connect(function()
				if newAccessory then newAccessory:Destroy() end
				newbutton:Destroy()
			end)
			Buttons[newAccessory] = newbutton
		end
	end)

	bot.ChildRemoved:Connect(function(removed)
		if Buttons[removed] then
			Buttons[removed]:Destroy()
			Buttons[removed] = nil
		end
	end)
end

local function waitForAccessories(bot, timeout)
	timeout = timeout or 2
	local start = os.clock()
	repeat
		task.wait()
	until #bot:GetChildren() > 0 or (os.clock() - start > timeout)
end

changeValueEvent.OnServerEvent:Connect(function(_, value)
	currentBotSuffix = value
	local botName = Player.Name .. (value == "bot1" and "Bot" or "Bot2")
	local newBot = workspace:FindFirstChild(botName)

	if newBot and newBot ~= BOT then
		BOT = newBot
		task.spawn(function()
			waitForAccessories(BOT)
			updateBotAccessories(BOT)
		end)
	end
end)

workspace.ChildAdded:Connect(function(newchild)
	if newchild.Name == Player.Name .. "Bot" or newchild.Name == Player.Name .. "Bot2" then
		BOT = newchild
		task.spawn(function()
			waitForAccessories(BOT)
			updateBotAccessories(BOT)
		end)
	end
end)task.wait(5)

local Player = game.Players.LocalPlayer

local GUI = script.Parent.Parent
local CatalogFrame = script.Parent

local RE = game.ReplicatedStorage.CatalogStuff
local RED = game.ReplicatedStorage.CatalogStuffDelete
local REUser = game.ReplicatedStorage.CharUser

local Db1 = true
local Dbs = {}

CatalogFrame.HatInsert.FocusLost:Connect(function()
	if Db1 == true then
		Db1 = false

		RE:FireServer(CatalogFrame.HatInsert.Text,nil,true)

		task.wait(.125)

		Db1 = true
	end
end)

for i,v in pairs(GUI.BOTCharSettings:GetChildren()) do
	if v:IsA("TextBox") then
		Dbs[v] = true
		v.FocusLost:Connect(function()
			if Dbs[v] == true then
				Dbs[v] = false

				if v.Name == "1CharBox" then
					REUser:FireServer(v.Text,true)
				elseif v.Name == "2ShirtBox" then
					RE:FireServer(v.Text,"Shirt",true)
				elseif v.Name == "3PantsBox" then
					RE:FireServer(v.Text,"Pants",true)
				elseif v.Name == "4TShirtBox" then
					RE:FireServer(v.Text,"TShirt",true)
				elseif v.Name == "5FaceBox" then
					RE:FireServer(v.Text,"Face",true)
				else
					RE:FireServer(v.Text,nil,true)
				end

				task.wait(.125)

				Dbs[v] = true
			end
		end)
	end
end

local image = script.Parent 
local rotationSpeed = 1

local function rotateImage()
	while true do
		image.Rotation = image.Rotation + rotationSpeed
		if image.Rotation >= 360 then
			image.Rotation = 0
		end
		wait(0.01)
	end
end

rotateImage()
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 1.2   
local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true) 
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local Player = game.Players.LocalPlayer
local mouse = Player:GetMouse()
local run = game:GetService("RunService")
local maxDegree = math.rad(80)
local cam = workspace.CurrentCamera
local deb = "TPS"

local function updateBotCamera(bot)
	while deb == "FPS" do
		if bot and bot:FindFirstChild("Head") then
			local np = Vector2.new(mouse.X, mouse.Y)
			local centre = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
			local difference = np - centre
			local outcome = Vector2.new((difference.Y / centre.Y) * maxDegree, (difference.X / centre.X) * maxDegree)

			cam.CFrame = bot.Head.CFrame
				* CFrame.new(0, 0, (-bot.Head.Size.Z / 2) * 1.25)
				* CFrame.Angles(-outcome.X, -outcome.Y, 0)
		end
		run.RenderStepped:Wait()
		if deb ~= "FPS" or not bot then
			break
		end
	end
end

local function setBotView(botName)
	local bot = workspace:FindFirstChild(Player.Name .. botName)
	if bot and bot:FindFirstChild("Head") then
		local cameraBot2Script = script.Parent.Parent.CameraBot2:FindFirstChild("LocalScript")
		if cameraBot2Script then
			cameraBot2Script.Disabled = true
		end

		cam.CameraType = Enum.CameraType.Scriptable
		deb = "FPS"
		updateBotCamera(bot)
	else
		warn("Bot with the name " .. botName .. " was not found.")
	end
end

local function resetPlayerView()
	cam.CameraType = Enum.CameraType.Custom
	cam.CameraSubject = Player.Character:FindFirstChildOfClass("Humanoid")
	cam.FieldOfView = 70
	deb = "TPS"

	local cameraBot2Script = script.Parent.Parent.CameraBot2:FindFirstChild("LocalScript")
	if cameraBot2Script then
		cameraBot2Script.Disabled = false
	end
end

local button = script.Parent
button.MouseButton1Click:Connect(function()
	local botName = "Bot"

	if deb == "TPS" then
		setBotView(botName)
	elseif deb == "FPS" then
		resetPlayerView()
	end  
end)
local Player = game.Players.LocalPlayer
local mouse = Player:GetMouse()
local run = game:GetService("RunService")
local maxDegree = math.rad(80)
local cam = workspace.CurrentCamera
local deb = "TPS"

local function updateBotCamera(bot)
	while deb == "FPS" do
		if bot and bot:FindFirstChild("Head") then
			local np = Vector2.new(mouse.X, mouse.Y)
			local centre = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
			local difference = np - centre
			local outcome = Vector2.new((difference.Y / centre.Y) * maxDegree, (difference.X / centre.X) * maxDegree)

			cam.CFrame = bot.Head.CFrame
				* CFrame.new(0, 0, (-bot.Head.Size.Z / 2) * 1.25)
				* CFrame.Angles(-outcome.X, -outcome.Y, 0)
		end
		run.RenderStepped:Wait()
		if deb ~= "FPS" or not bot then
			break
		end
	end
end

local function setBotView(botName)
	local bot = workspace:FindFirstChild(Player.Name .. botName)
	if bot and bot:FindFirstChild("Head") then
		local cameraBot1Script = script.Parent.Parent.CameraBot1:FindFirstChild("LocalScript")
		if cameraBot1Script then
			cameraBot1Script.Disabled = true
		end

		cam.CameraType = Enum.CameraType.Scriptable
		deb = "FPS"
		updateBotCamera(bot)
	else
		warn("Bot with the name " .. botName .. " was not found.")
	end
end

local function resetPlayerView()
	cam.CameraType = Enum.CameraType.Custom
	cam.CameraSubject = Player.Character:FindFirstChildOfClass("Humanoid")
	cam.FieldOfView = 70
	deb = "TPS"

	local cameraBot1Script = script.Parent.Parent.CameraBot1:FindFirstChild("LocalScript")
	if cameraBot1Script then
		cameraBot1Script.Disabled = false
	end
end

local button = script.Parent
button.MouseButton1Click:Connect(function()
	local botName = "Bot2"

	if deb == "TPS" then
		setBotView(botName)
	elseif deb == "FPS" then
		resetPlayerView()
	end 
end)
local searchbar = script.Parent.Searchbar -- Replace "nil" with the location of the textbox that you want to search.
local commandlist1 = script.Parent.MenBot_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist2 = script.Parent.WomenBot_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist3 = script.Parent.EmoteBot_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist4 = script.Parent.PlusBot_List -- Replace "nil" with the location of the frame with the items inside of it.
local commandlist5 = script.Parent.AllBot_List -- Replace "nil" with the location of the frame with the items inside of it.

function UpdateResults()
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist1:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist2:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist3:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist4:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist5:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
	
	
	script.Parent.MenBot_List.CanvasPosition = Vector2.new(0,0) 
	script.Parent.WomenBot_List.CanvasPosition = Vector2.new(0,0)
	script.Parent.EmoteBot_List.CanvasPosition = Vector2.new(0,0)
	script.Parent.PlusBot_List.CanvasPosition = Vector2.new(0,0)
	script.Parent.AllBot_List.CanvasPosition = Vector2.new(0,0)
end

searchbar.Changed:Connect(UpdateResults)
local button = script.Parent
local originalSize = button.Size
local hoverScale = 1.2
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset)

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

button.MouseEnter:Connect(onMouseEnter)
button.MouseLeave:Connect(onMouseLeave)
local button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(213, 115, 208)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.MenBot_List
local womanAni = script.Parent.Parent.Parent.WomenBot_List
local emoteAni = script.Parent.Parent.Parent.EmoteBot_List
local plusAni = script.Parent.Parent.Parent.PlusBot_List
local allAni = script.Parent.Parent.Parent.AllBot_List
local NotAnimation = script.Parent.Parent.Parent.NothingBot_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = true
	manAni.Visible = false
	emoteAni.Visible = false
	plusAni.Visible = false
	allAni.Visible = false
	NotAnimation.Visible = false
end)

--Izzy was herelocal button = script.Parent
local originalSize = button.Size
local hoverScale = 1.2
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset)

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

button.MouseEnter:Connect(onMouseEnter)
button.MouseLeave:Connect(onMouseLeave)
local button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(115, 163, 213)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.MenBot_List
local womanAni = script.Parent.Parent.Parent.WomenBot_List
local emoteAni = script.Parent.Parent.Parent.EmoteBot_List
local plusAni = script.Parent.Parent.Parent.PlusBot_List
local allAni = script.Parent.Parent.Parent.AllBot_List
local NotAnimation = script.Parent.Parent.Parent.NothingBot_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = true
	emoteAni.Visible = false
	plusAni.Visible = false
	allAni.Visible = false
	NotAnimation.Visible = false
end)

--Izzy was herelocal button = script.Parent
local originalSize = button.Size
local hoverScale = 1.2
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset)

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

button.MouseEnter:Connect(onMouseEnter)
button.MouseLeave:Connect(onMouseLeave)
local button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(177, 115, 213)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.MenBot_List
local womanAni = script.Parent.Parent.Parent.WomenBot_List
local emoteAni = script.Parent.Parent.Parent.EmoteBot_List
local plusAni = script.Parent.Parent.Parent.PlusBot_List
local allAni = script.Parent.Parent.Parent.AllBot_List
local NotAnimation = script.Parent.Parent.Parent.NothingBot_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = false
	emoteAni.Visible = true
	plusAni.Visible = false
	allAni.Visible = false
	NotAnimation.Visible = false
end)

--Izzy was herelocal button = script.Parent
local originalSize = button.Size
local hoverScale = 1.2
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset)

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

button.MouseEnter:Connect(onMouseEnter)
button.MouseLeave:Connect(onMouseLeave)
local button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(200, 255, 138)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.MenBot_List
local womanAni = script.Parent.Parent.Parent.WomenBot_List
local emoteAni = script.Parent.Parent.Parent.EmoteBot_List
local plusAni = script.Parent.Parent.Parent.PlusBot_List
local allAni = script.Parent.Parent.Parent.AllBot_List
local NotAnimation = script.Parent.Parent.Parent.NothingBot_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = false
	emoteAni.Visible = false
	plusAni.Visible = true
	allAni.Visible = false
	NotAnimation.Visible = false
end)

local button = script.Parent
local originalSize = button.Size
local hoverScale = 1.2
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset)

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

button.MouseEnter:Connect(onMouseEnter)
button.MouseLeave:Connect(onMouseLeave)
local button = script.Parent 
local originalBgColor = button.BackgroundColor3 
local originalTextColor = button.TextColor3
local flashBgColor = Color3.fromRGB(213, 213, 213)
local flashTextColor = Color3.fromRGB(0, 0, 0)
local fadeDuration = 2
local TweenService = game:GetService("TweenService")

local currentBgTween
local currentTextTween

local function tweenColor(property, targetColor, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {}
	goal[property] = targetColor

	local tween = TweenService:Create(button, tweenInfo, goal)
	tween:Play()
	return tween
end

local function onClick()

	if currentBgTween then
		currentBgTween:Cancel()
	end
	if currentTextTween then
		currentTextTween:Cancel()
	end


	currentBgTween = tweenColor("BackgroundColor3", flashBgColor, 0.1)
	currentTextTween = tweenColor("TextColor3", flashTextColor, 0.1)

	wait(0.1)


	currentBgTween = tweenColor("BackgroundColor3", originalBgColor, fadeDuration)
	currentTextTween = tweenColor("TextColor3", originalTextColor, fadeDuration)
end

button.MouseButton1Click:Connect(onClick)
local manAni = script.Parent.Parent.Parent.MenBot_List
local womanAni = script.Parent.Parent.Parent.WomenBot_List
local emoteAni = script.Parent.Parent.Parent.EmoteBot_List
local plusAni = script.Parent.Parent.Parent.PlusBot_List
local allAni = script.Parent.Parent.Parent.AllBot_List
local NotAnimation = script.Parent.Parent.Parent.NothingBot_List
local button = script.Parent

button.MouseButton1Click:Connect(function(plr)
	womanAni.Visible = false
	manAni.Visible = false
	emoteAni.Visible = false
	plusAni.Visible = false
	allAni.Visible = true
	NotAnimation.Visible = false
end)

--Izzy was herelocal Player = script.Parent.Parent.Parent.Parent.Parent

function leftClick()
	local human = Player.Character:findFirstChild("Humanoid") 
	local char = Player.Character
	local Player = game.Players:GetPlayerFromCharacter(Player.Character)
	if (human ~= nil) then
		originals = char:getChildren()
		for w = 1, #originals do
			if originals[w].className == "CharacterMesh" then
				originals[w]:remove()
			end
		end
		meshes = script:getChildren()
		for y = 1, #meshes do
			copy = meshes[y]:clone()
			copy.Parent = char
		end
	end
	wait(0.1)
	if Player.Character:findFirstChild("Head") ~= nil then
		if Player.Character.Head.Mesh~= nil then
			Player.Character.Head.Mesh:remove()
			script.Mesh:clone().Parent = Player.Character.Head
		end
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 44, 248)  
local hoverTextColor = Color3.fromRGB(255, 255, 255)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local Player = script.Parent.Parent.Parent.Parent.Parent

function leftClick()
	local d = Player.Character:GetChildren() 
	for i=1, #d do 
		if (d[i].className == "CharacterMesh") then 
			d[i]:remove() 
		end 
	end
	if Player.Character:findFirstChild("Head") ~= nil then
		if Player.Character.Head.Mesh~= nil then
			Player.Character.Head.Mesh:remove()
			script.Mesh:clone().Parent = Player.Character.Head
		end
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(44, 107, 255)  
local hoverTextColor = Color3.fromRGB(255, 255, 255)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 62, 75)  
local hoverTextColor = Color3.fromRGB(255, 62, 75)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
task.wait(5)

local Menu = script.Parent.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer  

function leftClick()
	Menu["1Pink"].Value.Value = "None"
	Menu["2Green"].Value.Value = "None"
	Menu["3Purple"].Value.Value = "None"
	Menu["4Blue"].Value.Value = "None"
	Menu["5Orange"].Value.Value = "None"
	Menu["6Yellow"].Value.Value = "None"
	Menu["7Red"].Value.Value = "None"
	Menu["8Cyan"].Value.Value = "None"
end

script.Parent.MouseButton1Click:Connect(leftClick)
repeat wait()
	print("Original Creator: Yumi")
	print("Remasterer: ∑CH")
until script.Parent.Parent.Parent:WaitForChild("RoomStuff")

local aa = script.Parent.Parent.Parent:WaitForChild("RoomStuff")
local ownsroom = aa:WaitForChild("OwnsRoom")
local theroom = aa:WaitForChild("OwnedRoom")
local gui = script.Parent

local lockconnection = nil
local whitelistconnection = nil

ownsroom.Changed:Connect(function(NewValue)
	if ownsroom.Value == true then
		gui["2LockDoor"].TitleLabel.Text = "LOCK DOORS"
		gui["2LockDoor"].Visible = true
		gui["4Whitelist"].Visible = true
		
		gui["1UnclaimHouse"].TitleLabel.Text = "UNCLAIM HOUSE"
	else
		gui["2LockDoor"].Visible = false
		gui["4Whitelist"].Visible = false

		gui["1UnclaimHouse"].TitleLabel.Text = "NO HOUSE"
	end
end)

if ownsroom.Value == true then
	gui["2LockDoor"].TitleLabel.Text = "LOCK DOORS"
	gui["2LockDoor"].Visible = true
	gui["4Whitelist"].Visible = true

	gui["1UnclaimHouse"].TitleLabel.Text = "UNCLAIM HOUSE"
else
	gui["2LockDoor"].Visible = false
	gui["4Whitelist"].Visible = false

	gui["1UnclaimHouse"].TitleLabel.Text = "NO HOUSE"
end

theroom.Changed:Connect(function(NewValue)
	if theroom.Value ~= nil then
		lockconnection = theroom.Value.Locked.Changed:Connect(function(NewValue)
			if theroom.Value.Locked.Value == false then
				script.Parent["2LockDoor"].TitleLabel.Text = "UNLOCKED DOORS"
			else
				script.Parent["2LockDoor"].TitleLabel.Text = "LOCKED DOORS"
			end
		end)
		
		whitelistconnection = theroom.Value.Whitelist.ChildAdded:Connect(function(newthingy)
			if game.Players:FindFirstChild(newthingy.Name) then
				local newbutton = gui.Parent.Whitelist.List:FindFirstChild(newthingy.Name) or script.yeptheplayerbutton:Clone()
				
				newbutton.Parent = gui.Parent.Whitelist.List
				newbutton.Text = newthingy.Name
				newbutton.Name = newthingy.Name
				
				newbutton.MouseButton1Click:Connect(function()
					if newthingy ~= nil then newthingy:Destroy() end
					newbutton:Destroy()
				end)
			end			
		end)
	else
		if lockconnection ~= nil then lockconnection:Disconnect() lockconnection = nil end
		if whitelistconnection ~= nil then whitelistconnection:Disconnect() whitelistconnection = nil end
	end
end)

script.Parent["2LockDoor"].MouseButton1Click:Connect(function()
	if theroom.Value == nil then return end
	if theroom.Value.Locked.Value == false then
		theroom.Value.Locked.Value = true
	else
		theroom.Value.Locked.Value = false
	end
end)
local plr = script.Parent.Parent.Parent.Parent.Parent

script.Parent.MouseButton1Click:Connect(function()
	if plr.PlayerGui.RoomStuff:FindFirstChild("OwnedRoom") then
		if plr.PlayerGui.RoomStuff.OwnedRoom.Value == nil then return end
		local therooooom = plr.PlayerGui.RoomStuff.OwnedRoom.Value
		
		if therooooom:FindFirstChild("Whitelist") then
			for i,v in pairs(therooooom.Whitelist:GetChildren()) do
				v:Destroy()
			end
		end
				
		therooooom.Locked.Value = false
		therooooom.LiveCam.Value = false
		
		plr.PlayerGui.RoomStuff.OwnedRoom.Value = nil
		plr.PlayerGui.RoomStuff.OwnsRoom.Value = false
		plr.PlayerGui.Menu.Whitelist.Visible = false
		
		for i,v in pairs(plr.PlayerGui.Menu.Whitelist:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
	end
end)local Player = script.Parent.Parent.Parent.Parent.Parent

function leftClick()
	if not workspace:FindFirstChild(Player.Name.."Bot") then return end

	local human = workspace:FindFirstChild(Player.Name.."Bot"):findFirstChild("Humanoid") 
	local char = workspace:FindFirstChild(Player.Name.."Bot")
	if (human ~= nil) then
		originals = char:getChildren()
		for w = 1, #originals do
			if originals[w].className == "CharacterMesh" then
				originals[w]:remove()
			end
		end
		meshes = script:getChildren()
		for y = 1, #meshes do
			copy = meshes[y]:clone()
			copy.Parent = char
		end
	end
	wait(0.1)
	if workspace:FindFirstChild(Player.Name.."Bot"):findFirstChild("Head") ~= nil then
		if workspace:FindFirstChild(Player.Name.."Bot").Head.Mesh~= nil then
			workspace:FindFirstChild(Player.Name.."Bot").Head.Mesh:remove()
			script.Mesh:clone().Parent = workspace:FindFirstChild(Player.Name.."Bot").Head
		end
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(255, 44, 248)  
local hoverTextColor = Color3.fromRGB(255, 255, 255)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local Player = script.Parent.Parent.Parent.Parent.Parent

function leftClick()
	if not workspace:FindFirstChild(Player.Name.."Bot") then return end

	local d = workspace:FindFirstChild(Player.Name.."Bot"):GetChildren() 
	for i=1, #d do 
		if (d[i].className == "CharacterMesh") then 
			d[i]:remove() 
		end 
	end
	if workspace:FindFirstChild(Player.Name.."Bot"):findFirstChild("Head") ~= nil then
		if workspace:FindFirstChild(Player.Name.."Bot").Head.Mesh~= nil then
			workspace:FindFirstChild(Player.Name.."Bot").Head.Mesh:remove()
			script.Mesh:clone().Parent = workspace:FindFirstChild(Player.Name.."Bot").Head
		end
	end
end

script.Parent.MouseButton1Click:Connect(leftClick)local button = script.Parent  
local TweenService = game:GetService("TweenService")

local originalBgColor = button.BackgroundColor3  
local originalTextColor = button.TextColor3  
local hoverBgColor = Color3.fromRGB(44, 107, 255)  
local hoverTextColor = Color3.fromRGB(255, 255, 255)  
local tweenTime = 0.2  

 
local bgTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgHoverGoal = {BackgroundColor3 = hoverBgColor}
local bgOriginalGoal = {BackgroundColor3 = originalBgColor}

 
local textTweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textHoverGoal = {TextColor3 = hoverTextColor}
local textOriginalGoal = {TextColor3 = originalTextColor}

local function onMouseEnter()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgHoverGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textHoverGoal)
	bgTween:Play()
	textTween:Play()
end

local function onMouseLeave()
	 
	local bgTween = TweenService:Create(button, bgTweenInfo, bgOriginalGoal)
	local textTween = TweenService:Create(button, textTweenInfo, textOriginalGoal)
	bgTween:Play()
	textTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent
local icon = button:WaitForChild("Icon")

local og = button.Size
local hoverScale = 0.8
local hover = UDim2.new(
	og.X.Scale * hoverScale,
	og.X.Offset * hoverScale,
	og.Y.Scale * hoverScale,
	og.Y.Offset * hoverScale
)

local TweenService = game:GetService("TweenService")
local toggle = false

local function onMouseEnter()
	button:TweenSize(hover, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function onMouseLeave()
	button:TweenSize(og, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function rotateIcon(toLeft)
	local rotationGoal = toLeft and -180 or 0
	local rotateTween = TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Rotation = rotationGoal
	})
	rotateTween:Play()
end

button.MouseEnter:Connect(onMouseEnter)
button.MouseLeave:Connect(onMouseLeave)

button.MouseButton1Click:Connect(function()
	toggle = not toggle
	rotateIcon(toggle)
end)
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
script.LocalScript.res.OnServerEvent:Connect(function(player, savedPosition)
	local oldChar = player.Character
	local hrp
	if oldChar and oldChar:FindFirstChild("HumanoidRootPart") then
		hrp = oldChar.HumanoidRootPart
	end
	player:LoadCharacter()
	local newChar = player.Character
	if newChar and newChar:FindFirstChild("HumanoidRootPart") then
		newChar:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(savedPosition + Vector3.new(0, 3, 0))
	end
end)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local button = script.Parent.Parent
local respawnremote = script.res

button.MouseButton1Click:Connect(function()
	local character = player.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			respawnremote:FireServer(rootPart.Position)
		end
	end
end)local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent 
local originalSize = button.Size 
local hoverScale = 1.2 
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset)

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

button.MouseEnter:Connect(onMouseEnter) 
button.MouseLeave:Connect(onMouseLeave) 
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Icon = script.Parent
Icon.Image = Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
wait(1)
local cam = workspace.CurrentCamera
local Player = game.Players.LocalPlayer
local mouse = Player:GetMouse()
local run = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local maxDegree = math.rad(80)

local fadeFrame, menuGui

local function onCharacterAdded(character)
	local playerGui = Player:WaitForChild("PlayerGui")
	fadeFrame = playerGui:WaitForChild("Fader"):WaitForChild("BlackFrame")
	menuGui = playerGui:WaitForChild("Menu")
end

Player.CharacterAdded:Connect(onCharacterAdded)
onCharacterAdded(Player.Character)

local deb = "TPS"
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function fadeIn()
	if not fadeFrame or not fadeFrame.Parent.Enabled then return end
	local fadeTween = tweenService:Create(fadeFrame, tweenInfo, {BackgroundTransparency = 0})
	fadeTween:Play()
	fadeTween.Completed:Wait()
end

local function fadeOut()
	if not fadeFrame or not fadeFrame.Parent.Enabled then return end
	local fadeTween = tweenService:Create(fadeFrame, tweenInfo, {BackgroundTransparency = 1})
	fadeTween:Play()
	fadeTween.Completed:Wait()
end

local function hidePlayerHighlight(character)
	local highlight = character:FindFirstChildOfClass("Highlight")
	if highlight then
		highlight.Enabled = false
	end
end

local function showPlayerHighlight(character)
	local highlight = character:FindFirstChildOfClass("Highlight")
	if highlight then
		highlight.Enabled = true
	end
end

function updateTransparency(target, bool)
	for _, v in pairs(target:GetChildren()) do
		if v:IsA("Accessory") then
			updateTransparency(v, bool)
		elseif v:IsA("BasePart") then
			if v:FindFirstChildOfClass("Attachment") then
				if bool then
					v.LocalTransparencyModifier = 1
				else
					v.LocalTransparencyModifier = v.Transparency
				end
			end
		end
	end
end

function updateCharacterTransparency(target, bool)
	for _, v in pairs(target:GetChildren()) do
		if v:IsA("BasePart") then
			if bool or v.Name == "Head" then
				v.LocalTransparencyModifier = 0
			else
				v.LocalTransparencyModifier = v.Transparency
			end
			updateTransparency(v, bool)
		elseif v:IsA("Folder") or v:IsA("Model") then
			updateTransparency(v, bool)
		end
	end
end

local function switchToTPS()
	fadeIn()
	cam.CameraType = "Custom"
	deb = "TPS"
	local char = Player.Character
	if char and char:FindFirstChild("Humanoid") then
		cam.CameraSubject = char.Humanoid
		script.Parent.Parent.PreviewFP.Text = "IN THIRD PERSON VIEW"
		cam.FieldOfView = 70
		updateTransparency(Player.Character, false)
		showPlayerHighlight(Player.Character)
	end
	fadeOut()
end

local function switchToTPSHead()
	fadeIn()
	cam.CameraType = "Custom"
	deb = "TPSHead"
	local char = Player.Character
	if char and char:FindFirstChild("Head") then
		cam.CameraSubject = char.Head
		script.Parent.Parent.PreviewFP.Text = "IN THIRD PERSON VIEW (HEAD FOCUS)"
		cam.FieldOfView = 70
		updateTransparency(Player.Character, false)
		showPlayerHighlight(Player.Character)
	end
	fadeOut()
end

local function switchToFPS()
	fadeIn()
	cam.CameraType = "Scriptable"
	deb = "FPS"
	script.Parent.Parent.PreviewFP.Text = "IN FIRST PERSON VIEW"

	if Player.Character then
		updateTransparency(Player.Character, true)
		updateCharacterTransparency(Player.Character, true)
		hidePlayerHighlight(Player.Character)
		cam.FieldOfView = 100
	end

	local char = Player.Character
	if char and char:FindFirstChild("Head") then
		cam.CFrame = char.Head.CFrame * CFrame.new(0, 0, (-char.Head.Size.Z / 2) * 1.25)
	end

	fadeOut()

	local connection
	connection = run.RenderStepped:Connect(function()
		if deb ~= "FPS" or not Player.Character then
			connection:Disconnect()
			return
		end

		local char = Player.Character
		if char and char:FindFirstChild("Head") then
			local np = Vector2.new(mouse.X, mouse.Y)
			local centre = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
			local difference = np - centre

			local outcome = Vector2.new((difference.Y / centre.Y) * maxDegree, (difference.X / centre.X) * maxDegree)

			cam.CFrame = char.Head.CFrame
				* CFrame.new(0, 0, (-char.Head.Size.Z / 2) * 1.25)
				* CFrame.Angles(-outcome.X, -outcome.Y, 0)
		end
	end)
end

local function switchCamera()
	if deb == "FPS" then
		switchToTPS()
	elseif deb == "TPS" then
		switchToTPSHead()
	elseif deb == "TPSHead" then
		switchToFPS()
	end
end

script.Parent.MouseButton1Click:Connect(switchCamera)

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
		if menuGui.Enabled then
			switchCamera()
		end
	end
end)
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
while wait() do
	script.Parent.TextColor3 = Color3.new(1,0,0)
	for i=1,15 do
		game:GetService("RunService").RenderStepped:wait()
		script.Parent.TextColor3 = Color3.new(script.Parent.TextColor3.r,script.Parent.TextColor3.g+(17/255),script.Parent.TextColor3.b)
	end
	for i=1,15 do
		game:GetService("RunService").RenderStepped:wait()
		script.Parent.TextColor3 = Color3.new(script.Parent.TextColor3.r,script.Parent.TextColor3.g-(17/255),script.Parent.TextColor3.b)
	end
end-- [[ ФИНАЛЬНЫЙ LocalScript (Версия 16.2 - С BoolValue) ]]
-- [[ Логика v9 (стабильное вращение) + Исправлена камера + Скрыт RootPart ]]

if string.lower(script.Parent.Parent.Name) == "morphhandler" then
	return
end

local button = script.Parent
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- --- Настройки ---
local ROTATION_SPEED = 0.8 
-- ---

-- Находим наше GUI
local guiMenu = button:FindFirstAncestor("Menu")

-- ▼▼▼ ИЗМЕНЕНИЕ ЗДЕСЬ ▼▼▼
-- Больше нет 'IS_PREVIEW_MODE_ON'. Вместо этого ищем "Источник Правды".
local previewModeValue = ReplicatedStorage:WaitForChild("PreviewModeEnabled")
-- ▲▲▲ КОНЕЦ ИЗМЕНЕНИЯ ▲▲▲

local previewTooltip = guiMenu:WaitForChild("PreviewTooltip")
local viewportFrame = previewTooltip:WaitForChild("ViewportFrame")
local itemNameLabel = previewTooltip:WaitForChild("ItemName")

-- Находим ресурсы
local ReplicatedMorphs = ReplicatedStorage:WaitForChild("Morphs")
local categoryID = button:WaitForChild("CategoryFolderID")

-- Переменные для управления
local currentModel = nil
local connection = nil
local modelStartCFrame = CFrame.new() -- Оригинальная CFrame модели
local totalRotation = 0 

-- --- Функции ---

local function makeVisible(object)
	-- Скрываем Middle и RootPart, показываем остальное
	if object:IsA("BasePart") then
		if object.Name == "Middle" or object.Name == "RootPart" then
			object.Transparency = 1 
		else
			object.Transparency = 0 
		end
	elseif object:IsA("ParticleEmitter") then
		object.Enabled = true
	elseif object:IsA("Decal") then
		object.Transparency = 0
	end

	for _, child in ipairs(object:GetChildren()) do
		makeVisible(child)
	end
end

local function setupCamera(model)
	if viewportFrame:FindFirstChild("PreviewCamera") then
		viewportFrame.PreviewCamera:Destroy()
	end

	local camera = Instance.new("Camera")
	camera.Name = "PreviewCamera"
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	-- ▼▼▼ (Здесь код из твоего скрипта, который ты прислал) ▼▼▼
	local hiddenParts = {}
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and (descendant.Name == "Middle" or descendant.Name == "RootPart") then
			table.insert(hiddenParts, {Part = descendant, OriginalParent = descendant.Parent})
			descendant.Parent = nil 
		end
	end

	local modelCFrame, modelSize = model:GetBoundingBox() 

	for _, data in ipairs(hiddenParts) do
		data.Part.Parent = data.OriginalParent
	end

	local modelPosition = modelCFrame.Position
	local _, yaw, _ = modelCFrame:ToOrientation()
	modelStartCFrame = CFrame.new(modelPosition) * CFrame.Angles(0, yaw, 0)
	-- ▲▲▲ (Конец твоего кода) ▲▲▲

	-- 3. Вычисляем расстояние
	local maxSide = math.max(modelSize.X, modelSize.Y, modelSize.Z)
	if maxSide < 1 then maxSide = 1 end 
	local distance = (maxSide * 0.5) + 2

	-- 4. Ставим камеру и СМОТРИМ НА "чистую" позицию
	local cameraPos = modelStartCFrame.Position + Vector3.new(distance * 0.8, distance * 0.9, distance) 
	camera.CFrame = CFrame.lookAt(cameraPos, modelStartCFrame.Position) 
end

local function onMouseEnter()
	-- ▼▼▼ ИЗМЕНЕНИЕ ЗДЕСЬ ▼▼▼
	-- Проверяем "Источник Правды"
	if not previewModeValue.Value then
		return
	end
	-- ▲▲▲ КОНЕЦ ИЗМЕНЕНИЯ ▲▲▲

	-- 1. Находим папку-контейнер морфа
	local modelName = button.Text
	local categoryFolder = ReplicatedMorphs:FindFirstChild(categoryID.Value)

	if not categoryFolder then
		warn("Preview Error: Не найдена папка категории", categoryID.Value)
		return
	end

	local morphContainer = categoryFolder:FindFirstChild(modelName)

	if not morphContainer then
		warn("Preview Error: Не найдена модель/папка", modelName, "в папке", categoryID.Value)
		return
	end

	-- 2. Создаем НОВУЮ "сборочную" модель
	currentModel = Instance.new("Model")
	currentModel.Name = "PreviewAssembly"
	currentModel.Parent = viewportFrame

	-- 3. Находим все кусочки и собираем их в нашу модель
	for _, pieceFolder in ipairs(morphContainer:GetChildren()) do
		if pieceFolder:IsA("Model") then
			local pieceClone = pieceFolder:Clone()
			pieceClone.Parent = currentModel
		end
	end

	-- 4. Если мы ничего не нашли (старый морф?), попробуем использовать сам контейнер
	if not next(currentModel:GetChildren()) and morphContainer:IsA("Model") then
		currentModel:Destroy() 
		currentModel = morphContainer:Clone() 
		currentModel.Parent = viewportFrame
	end

	-- 5. !!! СНАЧАЛА СКРЫВАЕМ MIDDLE/ROOTPART !!!
	makeVisible(currentModel)

	-- 6. ПОТОМ НАСТРАИВАЕМ КАМЕРУ (теперь она измерит "чистую" модель)
	setupCamera(currentModel)

	-- 7. Показываем GUI
	itemNameLabel.Text = modelName
	previewTooltip.Visible = true

	-- 8. Сбрасываем вращение
	totalRotation = 0 

	-- 9. Подключаем слежение за мышью + ВРАЩЕНИЕ (стабильная логика v16)
	connection = RunService.RenderStepped:Connect(function(step) 
		-- Позиция окна
		local mousePos = UserInputService:GetMouseLocation()
		previewTooltip.Position = UDim2.fromOffset(mousePos.X + 10, mousePos.Y + 10)
		previewTooltip.AnchorPoint = Vector2.new(0, 0) 
		if mousePos.X > (guiMenu.AbsoluteSize.X / 2) then
			previewTooltip.AnchorPoint = Vector2.new(1, 0)
		end

		-- Вращение модели
		if currentModel then
			totalRotation = totalRotation + (step * ROTATION_SPEED)
			-- Вращаем модель "на месте"
			currentModel:PivotTo(modelStartCFrame * CFrame.Angles(0, totalRotation, 0))
		end
	end)
end

local function onMouseLeave()
	if connection then
		connection:Disconnect()
		connection = nil
	end

	previewTooltip.Visible = false

	if currentModel then
		currentModel:Destroy()
		currentModel = nil
	end

	-- Очищаем все, КРОМЕ камеры
	for _, child in ipairs(viewportFrame:GetChildren()) do
		if not child:IsA("Camera") then
			child:Destroy()
		end
	end
end

-- Подключаем ивенты
button.MouseEnter:Connect(onMouseEnter)
button.MouseLeave:Connect(onMouseLeave)-- Script:

local searchbar = script.Parent.SearchBar -- Replace "nil" with the location of the textbox that you want to search.
local commandlist = script.Parent.List -- Replace "nil" with the location of the frame with the items inside of it.

function UpdateResults()
	local search = string.lower(searchbar.Text)
	for i,v in pairs(commandlist:GetChildren()) do
		if v:IsA("TextButton") then -- Inside the quotation marks where it says TextLabel, put what type of instance the items are.
			if search ~= "" then
				local commanditemlist = string.lower(v.Text)
				if string.find(commanditemlist, search) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end 
		end
	end
end

searchbar.Changed:Connect(UpdateResults)local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 0.8  
local hoverSize = UDim2.new(originalSize.X.Scale * hoverScale, originalSize.X.Offset * hoverScale, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local button = script.Parent.Parent.Parent.BOTCamera
local TweenService = game:GetService("TweenService")

local Active = true
local animationSpeed = 0.1  

local startPos = UDim2.new(0.427, 0, 0.861, 0)  
local endPos = UDim2.new(0.427, 0, 1, 0)  

 
local function BackToStartPos()
	local tweenInfo = TweenInfo.new(animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(button, tweenInfo, {Position = startPos})
	tween:Play()
	Active = false
end

 
script.Parent.MouseButton1Down:Connect(function()
	local tweenInfo = TweenInfo.new(animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween
	if Active then
		tween = TweenService:Create(button, tweenInfo, {Position = startPos})
	else
		tween = TweenService:Create(button, tweenInfo, {Position = endPos})
	end
	tween:Play()
	Active = not Active
end)
task.wait()
local GUI = script.Parent.Parent
local ThisFrame = script.Parent
local Player = nil
Player = GUI.Parent.Parent
local Buttons = {}

local function watchAccessoriesFolder(chr)
	local accFolder = chr:WaitForChild("Accesories", 10)
	if not accFolder then return end
	accFolder.ChildAdded:Connect(function(part)
		if not part:IsA("MeshPart") then return end
		local newbutton = script.hahahat:Clone()
		newbutton.Parent = ThisFrame.List
		newbutton.Text = part:GetAttribute("AssetName") or part.Name
		newbutton.MouseButton1Click:Connect(function()
			if part ~= nil then part:Destroy() end
			newbutton:Destroy()
		end)
		Buttons[part] = newbutton
	end)
	accFolder.ChildRemoved:Connect(function(part)
		if Buttons[part] ~= nil then Buttons[part]:Destroy() end
	end)
end

local function watchCharacter(chr)
	-- Handle already existing Accesories folder on join
	if chr:FindFirstChild("Accesories") then
		task.spawn(watchAccessoriesFolder, chr)
	end
	chr.ChildAdded:Connect(function(child)
		if child.Name == "Accesories" then
			for _, v in pairs(ThisFrame.List:GetChildren()) do
				if v:IsA("TextLabel") or v:IsA("TextButton") then
					v:Destroy()
				end
			end
			Buttons = {}
			task.spawn(watchAccessoriesFolder, chr)
		end
	end)
end

Player.CharacterAdded:Connect(function()
	local thischr = Player.Character
	for i,v in pairs(ThisFrame.List:GetChildren()) do
		if v:IsA("TextLabel") or v:IsA("TextButton") then
			v:Destroy()
		end
	end
	Buttons = {}
	thischr.ChildAdded:Connect(function(newhat)
		if newhat == nil then return end
		if newhat:IsA("Accessory") then
			local newbutton = script.hahahat:Clone()
			newbutton.Parent = ThisFrame.List
			newbutton.Text = newhat.Name
			newbutton.MouseButton1Click:Connect(function()
				if newhat ~= nil then newhat:Destroy() end
				newbutton:Destroy()
			end)
			Buttons[newhat] = newbutton
		end
	end)
	thischr.ChildRemoved:Connect(function(hattt)
		if Buttons[hattt] ~= nil then Buttons[hattt]:Destroy() end
	end)
	watchCharacter(thischr)
end)

if Player.Character then
	watchCharacter(Player.Character)
endtask.wait(5)

local Player = game.Players.LocalPlayer

local GUI = script.Parent.Parent
local CatalogFrame = script.Parent

local RE = game.ReplicatedStorage.CatalogStuff
local RED = game.ReplicatedStorage.CatalogStuffDelete
local REUser = game.ReplicatedStorage.CharUser

local Db1 = true
local Dbs = {}

CatalogFrame.HatInsert.FocusLost:Connect(function()
	if Db1 == true then
		Db1 = false
		
		RE:FireServer(CatalogFrame.HatInsert.Text)
		
		task.wait(.125)
		
		Db1 = true
	end
end)

for i,v in pairs(GUI.CharSettings:GetChildren()) do
	if v:IsA("TextBox") then
		Dbs[v] = true
		v.FocusLost:Connect(function()
			if Dbs[v] == true then
				Dbs[v] = false

				if v.Name == "1CharBox" then
					REUser:FireServer(v.Text)
				elseif v.Name == "2ShirtBox" then
					RE:FireServer(v.Text,"Shirt")
				elseif v.Name == "3PantsBox" then
					RE:FireServer(v.Text,"Pants")
				elseif v.Name == "4TShirtBox" then
					RE:FireServer(v.Text,"TShirt")
				elseif v.Name == "5FaceBox" then
					RE:FireServer(v.Text,"Face")
				else
					RE:FireServer(v.Text)
				end

				task.wait(.125)

				Dbs[v] = true
			end
		end)
	end
end

local image = script.Parent 
local rotationSpeed = 1

local function rotateImage()
	while true do
		image.Rotation = image.Rotation + rotationSpeed
		if image.Rotation >= 360 then
			image.Rotation = 0
		end
		wait(0.01)
	end
end

rotateImage()
local button = script.Parent   
local originalSize = button.Size   
local hoverScale = 1.2   
local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale * hoverScale, originalSize.Y.Offset * hoverScale) 

local function onMouseEnter()
	button:TweenSize(hoverSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true) 
end

local function onMouseLeave()
	button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)  
end

button.MouseEnter:Connect(onMouseEnter)   
button.MouseLeave:Connect(onMouseLeave)   
local text = script.Parent
local add = 10
wait(1)
local k = 1
while k <= 255 do
text.BackgroundColor3 = Color3.new(k/255,0/255,0/255)
k = k + add
wait()
end
while true do
k = 1
while k <= 255 do
text.BackgroundColor3 = Color3.new(255/255,k/255,0/255)
k = k + add
wait()
end
k = 1
while k <= 255 do
text.BackgroundColor3 = Color3.new(255/255 - k/255,255/255,0/255)
k = k + add
wait()
end
k = 1
while k <= 255 do
text.BackgroundColor3 = Color3.new(0/255,255/255,k/255)
k = k + add
wait()
end
k = 1
while k <= 255 do
text.BackgroundColor3 = Color3.new(0/255,255/255 - k/255,255/255)
k = k + add
wait()
end
k = 1
while k <= 255 do
text.BackgroundColor3 = Color3.new(k/255,0/255,255/255)
k = k + add
wait()
end
k = 1
while k <= 255 do
text.BackgroundColor3 = Color3.new(255/255,0/255,255/255 - k/255)
k = k + add
wait()
end
while k <= 255 do
text.BackgroundColor3 = Color3.new(255/255 - k/255,0/255,0/255)
k = k + add
wait()
end
endtask.wait(1)

local Player = game.Players.LocalPlayer

if game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name) then
	script.Parent.Visible = true
else
	script.Parent.Visible = false
end

game.ReplicatedStorage.ChatStuff.ChildAdded:Connect(function()
	if game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name) then
		script.Parent.Visible = true
	end
end)

game.ReplicatedStorage.ChatStuff.ChildRemoved:Connect(function()
	if not game.ReplicatedStorage.ChatStuff:FindFirstChild(Player.Name) then
		script.Parent.Visible = false
	end
end)task.wait()

local heyyoooo = game.ReplicatedStorage:WaitForChild("Header")

local button = script.Parent
local enabled = true
local startingcolor = script.Parent.BackgroundColor3

function yeeeep()
	for i,v in pairs(game.Players:GetPlayers()) do
		if v.Character then
			if v.Character:FindFirstChild("headerrrr") then
				v.Character.headerrrr.Enabled = enabled
			end
		end
	end
end

button.MouseButton1Down:Connect(function()
	if enabled == true then
		enabled = false
		button.Text = "DISABLE OVERHEAD INFO"
		button.BackgroundColor3 = Color3.fromRGB(255,75,75)
	else
		enabled = true
		button.BackgroundColor3 = startingcolor
		button.Text = "ENABLE OVERHEAD INFO"
	end
	yeeeep()
end)

heyyoooo.OnClientEvent:Connect(function(uhhhhhhhhh)
	if uhhhhhhhhh ~= nil then
		uhhhhhhhhh.Enabled = enabled
	end
end)local image = script.Parent
local rotationSpeed = 1

local function rotateImage()
	while true do
		image.Rotation = image.Rotation + rotationSpeed
		if image.Rotation >= 360 then
			image.Rotation = 0 
		end
		wait(0.01)
	end
end

rotateImage()
repeat wait() until script.Parent.Parent:FindFirstChild("Humanoid") ~= nil

local hum = script.Parent.Parent:FindFirstChild("Humanoid")
local humShirt = hum.Parent:FindFirstChild("Shirt")
local humPants = hum.Parent:FindFirstChild("Pants")

while true do
	wait()
	if hum.Parent:FindFirstChild("Pants") ~= nil then
		script.Parent["Cloth"].Transparency = 0.05
		script.Parent["Cloth"].TextureID = hum.Parent:FindFirstChild("Pants").PantsTemplate
	end
endrepeat wait() until script.Parent.Parent:FindFirstChild("Humanoid") ~= nil

local hum = script.Parent.Parent:FindFirstChild("Humanoid")
local humShirt = hum.Parent:FindFirstChild("Shirt")
local humPants = hum.Parent:FindFirstChild("Pants")

while true do
	wait()
	if hum.Parent:FindFirstChild("Pants") ~= nil then
		script.Parent["Cloth"].Transparency = 0.05
		script.Parent["Cloth"].TextureID = hum.Parent:FindFirstChild("Pants").PantsTemplate
	end
end[12:51:30 FTL] Decompilation error
Unluau.DecompilerException: Bytecode version mismatch, expected version 3...6, got 10
   at Unluau.Deserializer.Deserialize()
   at Unluau.Decompiler..ctor(Stream stream, DecompilerOptions options)
   at Unluau.CLI.Program.RunOptions(Options options)
