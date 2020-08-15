

global.players = {}
global.spiders = {}

local function add_leader(spider, player)
	-- Remove previous leader if exists
	if (global.spiders[spider.unit_number] ~= nil) then
		remove_leader(spider)
	end

	-- Create player's table if needed
	if (global.players[player.unit_number] == nil) then
		global.players[player.unit_number] = {}
	end

	-- Insert spider into player's table
	global.players[player.unit_number][spider.unit_number] = true

	-- Assign player reference to spider
	global.spiders[spider.unit_number] = player.unit_number
end

local function remove_leader(spider)
	-- Get player reference
	local player_unit_number = global.spiders[spider.unit_number]

	-- If reference exists
	if (player_unit_number ~= nil) then
		-- If player has table
		if (global.players[player_unit_number] ~= nil) then
			-- Remove reference to spider
			-- Don't need to check if it exists, we're just setting it to nil
			global.players[player_unit_number][spider.unit_number] = nil
		end

		-- Remove reference to player
		global.spiders[spider.unit_number] = nil
	end

	--[[
	-- If spider has leader
	if (spider_leader ~= nil) then
		local leader_table = global.players[spider_leader_unit_number]

		-- If table exists
		if (leader_table ~= nil) then
			-- Loop through and find spider
			for key, spider_unit_number_i in ipairs(leader_table) do
				-- If spider found
				if (spider.unit_number == spider_unit_number_i) then
					-- Remove it from table
					global.players[player_unit_number] = nil
				end
			end
		end

		spider.leader = nil
	end
	]]--
end

local function on_player_used_spider_remote(event)
	remove_leader(event.vehicle)

	--[[
	local player = game.get_player(event.player_index)
	local surface = player.surface
	local pos = {x = event.position.x, y = event.position.y}
	local bounds = {{pos.x-0.5, pos.y}, {pos.x+0.5, pos.y+1}}
	local filter = {area=bounds, type="character"}

	local selectedPlayer
	local clickedCharacters = surface.find_entities_filtered(filter)
	for _, entity in ipairs(clickedCharacters) do
		selectedPlayer = entity
		break
	end
	]]--

	local surface = game.get_player(event.player_index).surface
	local bounds = {{event.position.x-0.5, event.position.y}
					, {event.position.x+0.5, event.position.y+1}}
	local filter = {area=bounds, type="character"}

	local selectedPlayer
	for _, entity in ipairs(surface.find_entities_filtered(filter)) do
		selectedPlayer = entity
		break
	end

	if (selectedPlayer) then
		add_leader(event.vehicle, selectedPlayer)
	end
end


local function on_player_changed_position(event)
	local player = game.get_player(event.player_index)

	--[[
	if (player.spider_followers ~= nil) then
		game.print("has followers")
	end
	]]--
end


script.on_event(defines.events.on_player_used_spider_remote, on_player_used_spider_remote)
script.on_event(defines.events.on_player_changed_position, on_player_changed_position)
