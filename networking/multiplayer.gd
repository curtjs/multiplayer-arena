extends Node

const RELAY_ADDRESS = "5.161.105.106:8080"
const APP_ID = "rqoc2lh7ei72z6h"

@onready var nodetunnel = NodeTunnelPeer.new()

var authorized = false

func _ready():
	nodetunnel.error.connect(
		func(err_msg):
			print(err_msg)
	)
	
	nodetunnel.forced_disconnect.connect(
		func():
			print("Client was forced to disconnect")
	)
	
	print("Connecting to relay...")
	
	nodetunnel.connect_to_relay(RELAY_ADDRESS, APP_ID)
	multiplayer.multiplayer_peer = nodetunnel
	
	await nodetunnel.authenticated
	
	authorized = true
	print("Connected!")

func host(room_name: String, password: String = ""):
	var metadata = {
		"players": 1,
		"name": room_name,
		"password_req": !password.is_empty()
	}
	
	nodetunnel.host_room(true, JSON.stringify(metadata))
	print("Hosting game...")
	await nodetunnel.room_connected
	DisplayServer.clipboard_set(nodetunnel.room_id)
	print("Hosted game @ ", nodetunnel.room_id)
	
	nodetunnel.join_validation = func(join_metadata) -> bool:
		if multiplayer.get_peers().size() >= 3:
			return false
		var jm = JSON.parse_string(join_metadata)
		var j_pwd = str(jm.get("password", ""))
		return j_pwd == password
	
	multiplayer.peer_disconnected.connect(
		func(pid):
			print(pid, " left.")
			metadata.players -= 1
			nodetunnel.update_room(JSON.stringify(metadata))
	)
	
	multiplayer.peer_connected.connect(
		func(pid):
			print(pid, " connected!")
			metadata.players += 1
			nodetunnel.update_room(JSON.stringify(metadata))
	)

func join(room_id: String, password: String = ""):
	var join_metadata = {
		"password": password
	}
	nodetunnel.join_room(room_id, JSON.stringify(join_metadata))
	print("Joining game: ", room_id)
	await nodetunnel.room_connected
	print("Joined!")
