script.on_init(function()
	global.characters = {}
	global.spiders = {}
end)

--

local function add_leader(spider, character)
	-- Create character's table if needed
	if (global.characters[character.unit_number] == nil) then
		global.characters[character.unit_number] = {}
	end

	-- Insert spider into character's table
	global.characters[character.unit_number][spider.unit_number] = spider

	-- Assign character to spider
	global.spiders[spider.unit_number] = character.unit_number

	-- Detect when spider is destroyed
	script.register_on_entity_destroyed(spider)
end

local function remove_leader(spider_unit_number)
	-- Get character reference
	local character_unit_number = global.spiders[spider_unit_number]

	-- If reference exists
	if (character_unit_number ~= nil) then
		-- If character has table
		if (global.characters[character_unit_number] ~= nil) then
			-- Remove reference to spider
			-- Don't need to check if it exists, we're just setting it to nil
			global.characters[character_unit_number][spider_unit_number] = nil
		end

		-- Remove reference to character
		global.spiders[spider_unit_number] = nil
	end
end

local function follow_character(spider, character, minOffset, maxOffset)
	-- Distance between player and spider
	local xDist = spider.position.x - character.position.x
	local yDist = spider.position.y - character.position.y

	local xDistAbs = math.abs(xDist)
	local yDistAbs = math.abs(yDist)

	-- If distance is greater than maxOffset,
	if (xDistAbs > maxOffset or yDistAbs > maxOffset) then
		local newPos = {
			x=spider.position.x,
			y=spider.position.y
		}
		
		-- If distance is greater than minOffset too
		if (xDistAbs > minOffset) then
			if (xDist > 0) then -- Positive dist
				newPos.x = character.position.x + minOffset
			else -- Negative dist
				newPos.x = character.position.x - minOffset
			end
		end

		-- If distance is greater than minOffset too
		if (yDistAbs > minOffset) then
			if (yDist > 0) then -- Positive dist
				newPos.y = character.position.y + minOffset
			else -- Negative dist
				newPos.y = character.position.y - minOffset
			end
		end

		spider.autopilot_destination = newPos
	end
end

--

local function attempt_add_leader(spider, character)
	if (spider.valid and character.valid) then
		-- Get previous leader
		local prevLeader = global.spiders[spider.unit_number]

		-- If previous is different from new,
		if (prevLeader ~= character.unit_number) then
			-- If previous exists
			if (prevLeader ~= nil) then
				-- Remove previous
				remove_leader(spider.unit_number)
			end
	
			-- Add new
			add_leader(spider, character)
		end
	end
end

local function attempt_remove_leader(spider)
	if (spider.valid) then
		remove_leader(spider.unit_number)
	end
end

local function attempt_follow_character(spider, character, minOffset, maxOffset)
	if (spider.valid) then
		follow_character(spider, character, minOffset, maxOffset)
	end
end

local function get_character_name(character)
	local name
	if (character.player ~= nil) then
		name = character.player.name
	else
		name = character.name
	end
	return name
end

--

local function on_player_used_spider_remote(event)
	-- Gather event data
	local player = game.get_player(event.player_index)
	local surface = player.surface
	local bounds = {{event.position.x-0.5, event.position.y}
					, {event.position.x+0.5, event.position.y+1}}
	local filter = {area=bounds, type="character"}

	-- Find character at click position
	local selectedCharacter
	for _, entity in ipairs(surface.find_entities_filtered(filter)) do
		selectedCharacter = entity
		break
	end

	-- If character found
	if (selectedCharacter ~= nil) then
		-- Add it as the spider's leader
		attempt_add_leader(event.vehicle, selectedCharacter)
		
		-- Show message
		player.print({"spider.attached-spider", get_character_name(selectedCharacter)})
	else
		-- Else remove any existing leader
		attempt_remove_leader(event.vehicle)
	end
end

local function on_player_changed_position(event)
	-- Gather event data
	local player = game.get_player(event.player_index)

	-- If player has a character
	if (player.character ~= nil) then
		-- Get spider followers table
		local character_spider_table = global.characters[player.character.unit_number]

		-- If character has spider followers
		if (character_spider_table ~= nil) then
			-- Load player settings
			local playerSettings = settings.get_player_settings(event.player_index)
			local minOffset = playerSettings["min-offset"].value
			local maxOffset = playerSettings["max-offset"].value
			if (maxOffset < minOffset) then
				maxOffset = minOffset
			end

			-- Loop through spider followers and get them to follow player character
			for spider_unit_number, spider in pairs(character_spider_table) do
				attempt_follow_character(spider, player.character, minOffset, maxOffset)
			end
		end
	end
end

local function on_entity_destroyed(event)
	for spider_unit_number, spider in pairs(global.spiders) do
		if (spider_unit_number == event.unit_number) then
			remove_leader(spider_unit_number)
		end
	end
end

--

script.on_event(defines.events.on_player_used_spider_remote, on_player_used_spider_remote)
script.on_event(defines.events.on_player_changed_position, on_player_changed_position)
script.on_event(defines.events.on_entity_destroyed, on_entity_destroyed)
