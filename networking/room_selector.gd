extends Control

@onready var names = %RoomNames
@onready var players = %RoomPlayers
@onready var ids = %RoomIds
@onready var btns = %JoinBtns

@onready var password_popup := %PasswordPopup
@onready var join_room_pass := %JoinRoomPass

@onready var name_in := %RoomNameIn
@onready var pass_in := %RoomPassIn

var selected_room_id: String
var rooms_by_id: Dictionary = {} # room_id -> room metadata

func _ready() -> void:
	if !Multiplayer.authorized:
		await Multiplayer.nodetunnel.authenticated

	_update_rooms()

func _update_rooms() -> void:
	_destroy_room_displays()
	rooms_by_id.clear()

	Multiplayer.nodetunnel.get_rooms()
	var rooms = await Multiplayer.nodetunnel.rooms_received

	for r in rooms:
		var meta = JSON.parse_string(r.metadata)
		if meta == null:
			push_error("failed to parse metadata for room: " + str(r.id))
			continue

		rooms_by_id[r.id] = meta

		_build_room_display(
			str(meta.get("name", "Unnamed")),
			int(meta.get("players", 0)),
			str(r.id),
		)

func _join_room() -> void:
	if selected_room_id.is_empty():
		return

	var room_meta = rooms_by_id.get(selected_room_id)
	if room_meta == null:
		push_error("selected room not found: " + selected_room_id)
		return

	var needs_pass := bool(room_meta.get("password_req", false))

	if needs_pass:
		password_popup.popup()
	else:
		Multiplayer.join(selected_room_id)

func _build_room_display(display_name: String, player_count: int, room_id: String) -> void:
	_build_label(display_name, names)
	_build_label(str(player_count) + "/4", players)
	_build_label(room_id, ids)

	var btn = Button.new()
	btn.text = "Join"
	btn.add_to_group("room_display")
	btn.pressed.connect(func():
		selected_room_id = room_id
		_join_room()
	)
	btns.add_child(btn)

func _build_label(text: String, parent: Node) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_to_group("room_display")
	parent.add_child(lbl)

func _destroy_room_displays() -> void:
	for n in get_tree().get_nodes_in_group("room_display"):
		n.queue_free()

func _on_create_pressed() -> void:
	Multiplayer.host(name_in.text, pass_in.text)

func _on_refresh_pressed() -> void:
	_update_rooms()

func _on_submit_pass_pressed() -> void:
	var pwd = join_room_pass.text
	Multiplayer.join(selected_room_id, pwd)
	password_popup.hide()

func _on_cancel_join_pressed() -> void:
	password_popup.hide()
	selected_room_id = ""
