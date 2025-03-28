extends Node

signal noray_conncted

const NORAY_ADDRESS = "tomfol.io"
const NORAY_PORT = 8890

var exturnalOID = ""
var ishost = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Noray.on_connect_to_host.connect(on_noray_conected)
	Noray.on_connect_nat.connect(handle_nat_connction)
	Noray.on_connect_relay.connect(handle_relay_connction)
	Noray.connect_to_host(NORAY_ADDRESS, NORAY_PORT)
	
func on_noray_conected():
	print("connected to noray server")
	
	Noray.register_host()
	await Noray.on_pid
	await Noray.register_remote()
	noray_conncted.emit()
func host():
	print("hosting")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Noray.local_port)
	multiplayer.multiplayer_peer = peer
	ishost = true

func join(oid):
	Noray.connect_nat(oid)
	exturnalOID = oid
	
func handle_nat_connction(address, port):
	var err = await connect_to_server(address, port)
	if err != OK && !ishost:
		print("nat failed, using relay")
		Noray.connect_relay(exturnalOID)
		err = OK
		
	return err
func handle_relay_connction(address, port):
	return await connect_to_server(address, port)
func connect_to_server(address, port):
	var err = OK
	
	if !ishost:
		var udp = PacketPeerUDP.new()
		udp.bind(Noray.local_port)
		udp.set_dest_address(address, port)
		
		err = await PacketHandshake.over_packet_peer(udp)
		udp.close()
		if err != OK:
			if err != ERR_BUSY:
				print("Handshake failed ", err)
				return err
			print("err busy ", err)
		else:
			print("handshake success")
		
		var peer = ENetMultiplayerPeer.new()
		err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
		
		if err != OK:
			return err
		multiplayer.multiplayer_peer = peer
		return OK
	else:
		err = await PacketHandshake.over_enet(multiplayer.multiplayer_peer.host, address, port)

	return err
	
