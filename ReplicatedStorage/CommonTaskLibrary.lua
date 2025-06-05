
-- # Common Task Library 3.0
-- # Written by Xiko

local PlayerService = game:GetService("Players")
local moduleRandom = Random.new()

local module = {}

module.safeGetObject = function(searchInstance : Instance?, lookForName : string?)

	-- Does not expect @searchInstance [1] to exist, nor be an instance.
	-- Does not expect @lookForName [2] to exist, nor be a sting.

	if (typeof(searchInstance) == "Instance") and (not module.isBlankString(lookForName)) then
		return searchInstance:FindFirstChild(lookForName)
	end

end

module.flipNumberChance = function(baseNumber : number)
	-- # 50/50 chance a number will flip to its inverse.
	return baseNumber * (moduleRandom:NextInteger(1, 2) == 1 and -1 or 1)
end

module.fireFromList = function(playerList : {[number]:Player}, remoteEvent : RemoteEvent, ...)
	-- # Send the event to every player in the list
	for index, player in playerList do
		remoteEvent:FireClient(player, ...)
	end
end

module.fireAllExcept = function(exceptList : {[number]:Player}, remoteEvent : RemoteEvent, ...)

	-- # Does not expect @exceptList [1]

	for index, player : Player in PlayerService:GetPlayers() do

		local onIgnoreList = (exceptList and table.find(exceptList, player))

		if onIgnoreList then
			continue
		end

		remoteEvent:FireClient(
			player, 
			...
		)

	end

end

module.clearThread = function(thread : thread?)

	-- # Does not expect @thread [1]
	-- # Closes thread if it is still running.

	if thread and (coroutine.status(thread) == "suspended") then
		coroutine.close(thread)
	end

end

module.generateRandomVectorWithinVector3Range =  function(minVector3 : Vector3, maxVector3 : Vector3)

	local x = moduleRandom:NextNumber(minVector3.X, maxVector3.X)
	local y = moduleRandom:NextNumber(minVector3.Y, maxVector3.Y)
	local z = moduleRandom:NextNumber(minVector3.Z, maxVector3.Z)

	return Vector3.new(x, y, z)

end

module.instance2 = function(itemType : string, itemData : {[string] : any?})

	-- # Creates a new instance, sets properties, and returns the instance.

	-- @itemType example (string) "Part"
	-- @itemData example (dictionary) {Transparency = 1, CanCollide = false}

	-- Using the example, it will return a part with your written properties.

	local newInstance = Instance.new(itemType);

	return module.setObjectProperties(
		newInstance, 
		itemData
	);

end

module.setObjectProperties = function(object : Instance, propertyTable : {[string]:any?})

	-- # Does not expect @object [1]

	-- # Takes a dictionary of properties and applies them to the given object.

	if not object then
		return object
	end

	for property, value in propertyTable do
		object[property] = value
	end

	return object;

end

module.getAnimator = function(humanoid : Humanoid)

	-- # Intended for getting a humanoid's animator, if the animator is nil, create one.

	return humanoid:FindFirstChild("Animator") or module.instance2("Animator", {
		Name = "Animator",
		Parent = humanoid
	});

end

module.loadAnimatorAnimation = function(animator : Animator, animation : Animation, animationData : {[string] : any}, playAnimation : boolean?, playData : {[string] : any}?)

	-- @animationData cycles though animation data. IE {Looped = true, Priority = ...}

	local animationTrack = animator:LoadAnimation(animation) :: AnimationTrack

	if animationData then
		for index, value in animationData do
			animationTrack[index] = value;
		end
	end

	if playAnimation then
		animationTrack:Play(
			unpack(playData or {})
		)
	end

	return animationTrack

end

module.isAlive = function(humanoid : Humanoid)

	-- # Does not expect @humanoid [1]

	-- Returns (boolean)
	-- (true) if humanoid exists, and is alive
	-- (false) if humanoid does not exist, or if the humanoid is dead

	return humanoid and (humanoid.Health > 0) and (humanoid:GetState() ~= Enum.HumanoidStateType.Dead);

end

module.getMagnitude = function(firstVector : Vector3 | BasePart, secondVector : Vector3 | BasePart)

	-- @firstVector [1] and @secondVector [2] can be either a Vector3 or a BasePart.
	-- # Returns the magnitude difference between each points.

	if typeof(firstVector) == "Instance" then
		firstVector = firstVector.Position
	end

	if typeof(secondVector) == "Instance" then
		secondVector = secondVector.Position
	end

	return (firstVector - secondVector).Magnitude;

end

module.easyWeld = function(part0 : BasePart, part1 : BasePart, isMotor6D : boolean?)

	-- if @IsMotor6D is true, a Motor6D is created, otherwise a WeldConstraint is created.
	-- # Returns the constraint that was created.

	return module.instance2((isMotor6D and "Motor6D" or "WeldConstraint"), {

		Part0 = part0,
		Part1 = part1,

		Parent = part0

	});

end

module.safeDestroy = function(object : Instance?)

	-- # does not expect @object [1]
	-- # this function lets you "call destroy" without having to check if the object exists or is the correct type

	if object and typeof(object) == "Instance" then
		object:Destroy()
	end

end;

module.getIndexesInDictionary = function(dictionary : {[any] : any})

	-- # Returns the amount of indexes inside of a dictionary.
	-- @dictionary [1] is not required, and will return (number) 0 if the argument is missing or is not a table.

	if typeof(dictionary) ~= "table" then
		return 0
	end

	local indexes = 0

	for index in dictionary do
		indexes += 1
	end

	return indexes

end

module.getRandomEntryFromDictionary = function(dictionary : {[any] : any})

	-- # Returns a random index from a dictionary.
	-- @dictionary [1] is expected, else an error will throw.

	local keys = {}

	for index in dictionary do
		table.insert(keys, index)
	end

	return keys[moduleRandom:NextInteger(1, #keys)]

end

module.shuffleArray = function(array : {any})

	-- # Returns a randomy shuffled version of given @array [1]
	-- @array [1] is expected, else an error will throw.

	for i = #array, 2, -1 do
		local j = moduleRandom:NextInteger(1, i)
		array[i], array[j] = array[j], array[i]
	end

	return array

end

module.shuffleDictionary = function(dictionary : {[any] : any})

	-- # Returns an array of {key, value} pairs in shuffled order.
	-- # Expects a dictionary (table), else throws an error.

	local newArray = {}

	for key, value in dictionary do
		table.insert(newArray, {key, value})
	end

	for i = #newArray, 2, -1 do
		local j = moduleRandom:NextInteger(1, i)
		newArray[i], newArray[j] = newArray[j], newArray[i]
	end

	return newArray;

end

module.removeDuplicatesFromArray = function(array : {any})

	-- # Returns an array without any duplicate entries.
	-- @array is expected, else an error will throw.

	local seen, result = {}, {}

	for index, value in array do
		if not seen[value] then
			table.insert(result, value)
			seen[value] = true
		end
	end

	return result

end

module.reverseArray = function(array : {any})

	-- # Returns an array in reverse order.
	-- Example: {"hi", "bye"} becomes: {"bye", "hi"}

	local reversedArray = {}

	for i = #reversedArray, 1, -1 do
		table.insert(reversedArray, tab[i])
	end;

	return reversedArray

end

module.fitViewportModel = function(model:Model, viewportFrame:ViewportFrame, cameraRotationValue:CFrame?)

	-- This function has not been updated from CTL 2.0 and may be removed in the future.

	local viewportCamera = viewportFrame.CurrentCamera or module.instance2("Camera", {
		Parent = viewportFrame,
	})

	viewportFrame.CurrentCamera = viewportCamera

	if model and viewportCamera then

		local modelSize, rigCenter = model:GetExtentsSize(), model:GetModelCFrame().Position
		local cameraPosition = rigCenter - Vector3.new(0, 0, modelSize.Magnitude)
		local lookAt = rigCenter

		-- Set the camera's position and look-at point
		viewportCamera.CFrame = CFrame.new(cameraPosition, lookAt) * (cameraRotationValue or CFrame.Angles(0, 0, 0))

		-- Adjust the field of view for a better fit
		local distance = module.getMagnitude(cameraPosition, lookAt)
		viewportFrame.CurrentCamera.FieldOfView = math.deg(math.atan(modelSize.Magnitude / (2 * distance))) * 2

	end;

	return viewportCamera

end

module.isBlankString = function(text : string?)

	-- # Returns (boolean)
	-- # If @text [1] is missing or invalid, or is blank text, (true) is returned.

	if typeof(text) ~= "string" then
		return true
	end

	return string.match(text, "^%s*$") ~= nil

end

module.formatTime = function(secondsTime : number)

	-- This function has not been updated from CTL 2.0
	-- Example [1] | if @secondsTime is 60, the function will return

	return string.format("%02i:%02i", math.floor(secondsTime / 60), secondsTime % 60)

end

module.truncateText = function(text : string, maxLength : number, truncateExtention : string?)

	-- # Returns a string that is no longer than @maxlength [2]
	-- # @truncateExtention [3] example, if the text is cut off the @truncateExtention will be added to the end. ex: (hello wor...)

	if #text > maxLength then
		return text:sub(1, maxLength) .. (truncateExtention or "")
	else
		return text
	end

end

module.truncateDecimal = function(number, maxDecimalPlaces)

	-- This function has not been updated from CTL 2.0

	if maxDecimalPlaces <= 0 then
		return tostring(math.floor(number))
	end

	local str = string.format("%.15f", number)
	local parts = {}

	for part in str:gmatch("[^.]+") do
		table.insert(parts, part)
	end

	local whole = parts[1] or "0"
	local decimal = parts[2] or ""

	if #decimal > maxDecimalPlaces then
		decimal = decimal:sub(1, maxDecimalPlaces)
	else
		while #decimal < maxDecimalPlaces do
			decimal = decimal .. "0"
		end
	end

	if decimal == string.rep("0", maxDecimalPlaces) and whole ~= "0" then
		return whole
	else
		return whole .. "." .. decimal
	end

end

module.getWordCount = function(text : string)

	-- # Returns the number of words in @text [1]
	-- # Example: if @text were "Hello World, Hello Computer" returns (number) 4

	local count = 0

	for word in text:gmatch("%S+") do
		count = count + 1
	end

	return count

end

module.subIllegalCharacters = function(text : string)

	-- # Returns a string that has no illegal characters.
	-- # Illegal characters are those that are not in the range of [a-z] or [A-Z] // [0-9]

	-- # Example: if @text were "Hello World! #2" the result would be "Hello World! 2"

	local str = tostring(text)

	local newString = string.gsub(str,"%W","");

	return newString

end

module.playRepetitiveSound = function(soundObject:Sound, soundParent:Instance, playbackSpeedRange:NumberRange?, pitchRange:NumberRange?)

	-- This function has not been updated from CTL 2.0 and may be removed in the future.

	if (soundObject ~= nil and soundObject.Parent ~= nil) and soundObject.IsLoaded then

		local newSoundObject = soundObject:Clone()
		local newPitchObject = pitchRange ~= nil and module.instance2("PitchShiftSoundEffect", {Octave = moduleRandom:NextNumber(pitchRange.Min, pitchRange.Max)})

		if playbackSpeedRange then
			newSoundObject.PlaybackSpeed = moduleRandom:NextNumber(playbackSpeedRange.Min, playbackSpeedRange.Max)
		end

		newSoundObject.Parent = soundParent or game.SoundService
		game.SoundService:PlayLocalSound(newSoundObject)

		game.Debris:AddItem(newSoundObject, newSoundObject.TimeLength or 0)

	end

end

module.unixTimestampToDate = function(unixTimestamp:number, isAmericanized:boolean?)

	-- This function has not been updated from CTL 2.0

	-- Convert Lua time to UTC date and time
	-- Example :: 1699918068 --> 13/11/2023 // 11/13/2023
	local luaTime = os.time(os.date("!*t", unixTimestamp))
	local timeData = os.date("!%m/%d/%Y", luaTime)

	if isAmericanized then
		return timeData -- RAHH 🦅
	else
		local month, day, year = unpack(timeData:split("/"))
		return ("%s/%s/%s"):format(day, month, year)
	end

			--[[
			%Y: Represents the year with 4 digits (e.g., 2023).
			%m: Represents the month with 2 digits (01-12).
			%d: Represents the day of the month with 2 digits (01-31).
			%H: Represents the hour in 24-hour format with 2 digits (00-23).
			%M: Represents the minute with 2 digits (00-59).
			%S: Represents the second with 2 digits (00-59).
			--]]


end

module.align_model_to_part_surface = function(Model:Model, BasePart:BasePart, UsePrimaryPart:boolean?)

	-- This function has not been updated from CTL 2.0 and may be removed in the future.


	-- Positions a model on top of a part.
	-- @ Model :: The model to be positioned on top of @BasePart
	-- @ BasePart :: The part to position the model on top of.
	-- @ UsePrimaryPart :: If true, use the primary part of the model as reference. Otherwise, use Model:MoveTo(Vector3)

	local _, ModelSize = Model:GetBoundingBox()
	local _CFrame = BasePart.CFrame + Vector3.new(0, BasePart.Size.Y/2 + ModelSize.Y/2, 0)

	local ModelPrimaryPart = UsePrimaryPart and Model.PrimaryPart :: BasePart

	if ModelPrimaryPart then
		ModelPrimaryPart.CFrame = _CFrame
	else
		Model:PivotTo(_CFrame)
	end

end

module.get_model_size = function(Model:Model)
	-- This function has not been updated from CTL 2.0 and may be removed in the future.
	local _, Size = Model:GetBoundingBox()
	return Size
end

module.get_model_center = function(Model:Model)
	-- This function has not been updated from CTL 2.0 and may be removed in the future.
	local CFrame, Size = Model:GetBoundingBox()
	return CFrame
end

module.stopAnimationsFromList = function(animations : {})

	-- This function has not been updated from CTL 2.0 and may be removed in the future.

	if not animations then
		return
	end

	for index, animationTrack in animations do

		if (typeof(animationTrack) ~= "Instance") or not (animationTrack:IsA("AnimationTrack")) then
			continue
		end

		animationTrack:Stop()

	end

end

module.clearConnection = function(connection : RBXScriptConnection?)

	-- @connection [1] is not expected.
	-- # Disconnects a connection if it exists

	if typeof(connection) == "RBXScriptConnection" and connection.Connected then
		connection:Disconnect()
	end
end

return module
