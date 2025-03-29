extends Node3D

@onready var main_menu: PanelContainer = $CanvasLayer/mainMenu

@onready var addres_entry: LineEdit = $CanvasLayer/mainMenu/MarginContainer/VBoxContainer/addresEntry
@onready var oid_label: Label = $CanvasLayer/mainMenu/MarginContainer/VBoxContainer/oidLabel

const player = preload("res://character_body_3d.tscn")

const port = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	await norayHoster.noray_conncted
	oid_label.text = Noray.oid

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_host_button_pressed() -> void:
	main_menu.hide()
	#enet_peer.create_server(port)
	#multiplayer.multiplayer_peer = enet_peer
	norayHoster.host()
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_connected.disconnect(remove_player)
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()
func _on_join_button_pressed() -> void:
	main_menu.hide()
	#enet_peer.create_client("localhost", port)
	#multiplayer.multiplayer_peer = enet_peer
	norayHoster.join(addres_entry.text)

func add_player(peer_id):
	var playr = player.instantiate()
	playr.name = str(peer_id)
	add_child(playr)
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
func upnp_setup():
	pass
	"""
	var upnp = UPNP.new()
	
	var discover_reesult = upnp.discover()
	assert(discover_reesult == UPNP.UPNP_RESULT_SUCCESS, "upnp discover failed %s" % discover_reesult)
	assert(upnp.get_gateway() and  upnp.get_gateway().is_valid_gateway() , "unpn invalid gateway")
	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "upnp mapping failed %s" % map_result)
	print("success %s"%upnp.query_external_address())
	"""
	


func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Noray.oid)
