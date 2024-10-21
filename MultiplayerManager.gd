extends Node

var dealerKey
var playerID = 0
var peer : ENetMultiplayerPeer
var thinking = false
var waiting = false
var timeout = 0.0

func _ready():
	var dealerKeyFile = FileAccess.open("res://dealerkey.key", FileAccess.READ)
	if !dealerKeyFile: get_tree().quit()
	else:
		dealerKey = dealerKeyFile.get_buffer(dealerKeyFile.get_length())
		dealerKeyFile.close()
	
	multiplayer.peer_disconnected.connect(checkDisconnect)
	
	connectToMaster()

func _process(delta):
	if waiting:
		timeout += delta
	else:
		timeout = 0.0
	if timeout > 10.0:
		get_tree().quit()

@rpc("any_peer", "reliable")
func linkDealer(id):
	var start = not bool(playerID)
	var mrm = get_node("MultiplayerRoundManager")
	playerID = id
	if start: startDealer.rpc()
	elif mrm.action > 0:
		var option = mrm.action
		mrm.action = 0
		mrm.receiveBruteforce.rpc(option)

func connectToMaster():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client("localhost", 2095)
	if error: get_tree().quit()
	multiplayer.set_multiplayer_peer(peer)
	waiting = true
	await multiplayer.connected_to_server
	waiting = false
	verifyDealer.rpc(dealerKey, playerID)

func checkDisconnect(id):
	if not thinking: get_tree().quit()

@rpc("any_peer", "reliable") func requestNewUser(_username): pass
@rpc("any_peer", "reliable") func verifyUserCreds(_keyFileData, _client_version): pass
@rpc("any_peer", "reliable") func requestPlayerList(): pass
@rpc("any_peer", "reliable") func createInvite(_to): pass
@rpc("any_peer", "reliable") func acceptInvite(_from): pass
@rpc("any_peer", "reliable") func denyInvite(_from): pass
@rpc("any_peer", "reliable") func retractInvite(_to): pass
@rpc("any_peer", "reliable") func retractAllInvites(): pass
@rpc("any_peer", "reliable") func getInvites(_type): pass
@rpc("any_peer", "reliable") func sendChat(_message): pass
@rpc("any_peer", "reliable") func closeSession(_reason): pass
@rpc("any_peer", "reliable") func verifyDealer(_key): pass
@rpc("any_peer", "reliable") func receiveUserCreationStatus(_return_value, _username): pass
@rpc("any_peer", "reliable") func notifySuccessfulLogin(_username): pass
@rpc("any_peer", "reliable") func receivePrivateKey(_keyString): pass 
@rpc("any_peer", "reliable") func receivePlayerList(_dict): pass
@rpc("any_peer", "reliable") func receiveInvite(_from, _id): pass
@rpc("any_peer", "reliable") func receiveInviteStatus(_username, _status): pass
@rpc("any_peer", "reliable") func receiveInviteList(_list): pass
@rpc("any_peer", "reliable") func opponentDisconnect(): pass
@rpc("any_peer", "reliable") func receiveChat(_message): pass
@rpc("any_peer", "reliable") func startDealer(): pass
