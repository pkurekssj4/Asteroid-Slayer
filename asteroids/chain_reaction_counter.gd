extends Node
var chain_length: int = 1
var reaction_started: bool = false
var source = null
var player: bool = false
var chain_reaction_reward: int = 0
var resource_credits: int = 0
var objects: Array = []
var last_object_position = Vector2()
@onready var game: Node2D = get_node("/root/Game")

func _process(_delta):
	objects = objects.filter(func(e): return is_instance_valid(e))
	
	if objects.is_empty() and reaction_started:
		grant_reward()
		queue_free()
		
func grant_reward() -> void:
	var reward: int = 0
	if chain_length >= 2:
		reward += chain_reaction_reward
		if player:
			game.statistics_data.chain_reactions.count += 1
			game.statistics_data.chain_reactions.cumulated_rewards += chain_reaction_reward
			game.display_event_message("Chain reaction (" + str(chain_length) + " explosions)! ", 2, "none", 0 , "lawn_green", "normal", "resource credit", chain_reaction_reward)
		if chain_length > game.statistics_data.chain_reactions.highscore: game.new_highscore("chain reaction", chain_length)
	reward += resource_credits 
	if reward > 0: game.update_resource_credits(reward, source, last_object_position)
	
func add_object(object) -> void:
	if objects.is_empty(): reaction_started = true
	objects.append(object)
