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
end

local function on_player_used_spider_remote(event)
	remove_leader(event.vehicle)

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
	local player_spider_table = global.players[player.unit_number]

	-- If player has spider followers
	if (player_spider_table ~= nil) then
		for _, spider_unit_number in ipairs(player_spider_table) do
			game.print(spider_unit_number)
		end
	end

	--[[
	if (player.spider_followers ~= nil) then
		game.print("has followers")
	end
	]]--
end


script.on_event(defines.events.on_player_used_spider_remote, on_player_used_spider_remote)
script.on_event(defines.events.on_player_changed_position, on_player_changed_position)
