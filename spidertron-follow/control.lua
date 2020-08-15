script.on_init(function()
	global.characters = {}
	global.spiders = {}

	global.maxOffset = 12
	global.minOffset = 8
end)

--

local function add_leader(spider, character)
	-- Remove previous leader if exists
	if (global.spiders[spider.unit_number] ~= nil) then
		remove_leader(spider)
	end

	-- Create character's table if needed
	if (global.characters[character.unit_number] == nil) then
		global.characters[character.unit_number] = {}
	end

	-- Insert spider into character's table
	global.characters[character.unit_number][spider.unit_number] = spider

	-- Assign character reference to spider
	global.spiders[spider.unit_number] = character.unit_number
end

local function remove_leader(spider)
	-- Get character reference
	local character_unit_number = global.spiders[spider.unit_number]

	-- If reference exists
	if (character_unit_number ~= nil) then
		-- If character has table
		if (global.characters[character_unit_number] ~= nil) then
			-- Remove reference to spider
			-- Don't need to check if it exists, we're just setting it to nil
			global.characters[character_unit_number][spider.unit_number] = nil
		end

		-- Remove reference to character
		global.spiders[spider.unit_number] = nil
	end
end

local function follow_character(spider, character)
	local xDist = spider.position.x - character.position.x
	local yDist = spider.position.y - character.position.y

	local xDistAbs = math.abs(xDist)
	local yDistAbs = math.abs(yDist)

	if (xDistAbs >= global.maxOffset or yDistAbs >= global.maxOffset) then
		local newPos = {
			x=spider.position.x,
			y=spider.position.y
		}
		
		if (xDistAbs >= global.minOffset) then
			if (xDist > 0) then
				newPos.x = character.position.x + global.minOffset
			else
				newPos.x = character.position.x - global.minOffset
			end
		end

		if (yDistAbs >= global.minOffset) then
			if (yDist > 0) then
				newPos.y = character.position.y + global.minOffset
			else
				newPos.y = character.position.y - global.minOffset
			end
		end

		spider.autopilot_destination = newPos
	end
end

--

local function on_player_used_spider_remote(event)
	-- Remove leader if exists
	remove_leader(event.vehicle)

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

	-- If character found, add it as the spider's leader
	if (selectedCharacter) then
		add_leader(event.vehicle, selectedCharacter)

		-- Get player name
		local name
		if (selectedCharacter.player ~= nil) then
			name = selectedCharacter.player.name
		else
			name = selectedCharacter.name
		end

		-- Show message
		player.print({"spider.attached-spider", name})
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
			for spider_unit_number, spider in pairs(character_spider_table) do
				follow_character(spider, player.character)
			end
		end
	end
end

--

script.on_event(defines.events.on_player_used_spider_remote, on_player_used_spider_remote)
script.on_event(defines.events.on_player_changed_position, on_player_changed_position)
