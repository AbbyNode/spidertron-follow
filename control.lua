script.on_event(defines.events.on_player_changed_position,
	function(event)
		local player = game.get_player(event.player_index)
		print(player)
	end
)