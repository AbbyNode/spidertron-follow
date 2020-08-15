

script.on_event(defines.events.on_player_changed_position,
	function(event)
		local player = game.get_player(event.player_index)

		if (player.spider_followers ~= nil) {
			game.print("has followers")
		}
	end
)

script.on_event(defines.events.on_player_used_spider_remote,
	function(event)
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
		
		if (selectedPlayer) then
			game.print(selectedPlayer.name)

			if (selectedPlayer.spider_followers == nil) {
				selectedPlayer.spider_followers = {}
			} 

			selectedPlayer.spider_followers

		end

	end
)


