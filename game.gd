class_name Game
extends Node

@onready var multiplayer_ui := $UI/RoomSelector
@onready var level = $Level

const PLAYER = preload("res://player/player.tscn")

var peer = ENetMultiplayerPeer.new()
var players: Array[Player] = []

func _ready():
	Multiplayer.nodetunnel.room_connected.connect(setup_game)
	$MultiplayerSpawner.spawn_function = add_player

func setup_game():
	if multiplayer.is_server():
		_server_setup()
	
	multiplayer_ui.hide()
	level.show()

func _server_setup():
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			$MultiplayerSpawner.spawn(pid)
	)
	
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())

func add_player(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	player.global_position = $Level.get_child(players.size()).global_position
	players.append(player)
	
	return player

func get_random_spawnpoint():
	return $Level.get_children().pick_random().global_position
