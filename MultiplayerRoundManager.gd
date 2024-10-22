extends Node

const Bruteforce = preload("res://bruteforce.gd")

var action = 0
var manager
var cancelTimer = 0.0

func _ready():
	manager = get_parent()

@rpc("any_peer", "reliable")
func sendBruteforce(roundType, liveCount, blankCount, d, p, s):
	manager.thinking = true
	multiplayer.multiplayer_peer.close()
	var numItems = 0
	for i in range(3,12):
		numItems += d[i] + p[i]
	var option
	if d[4] > 0 and d[2] < d[1]:
		option = Bruteforce.OPTION_CIGARETTES
	elif numItems > 8 and d[10] > 0 and (liveCount - s[4]) + (blankCount - s[5]) > 0:
		option = Bruteforce.OPTION_BURNER
	elif numItems > 8 and d[3] > 0 and s[1] == Bruteforce.MAGNIFYING_NONE:
		option = Bruteforce.OPTION_MAGNIFY
	elif numItems > 8 and d[5] > 0 and s[1] == Bruteforce.MAGNIFYING_BLANK and d[9] == 0:
		option = Bruteforce.OPTION_BEER
	elif numItems > 8 and d[6] > 0 and s[0] == Bruteforce.HANDCUFF_NONE and liveCount > 1:
		option = Bruteforce.OPTION_HANDCUFFS
	else:
		var dealer = Bruteforce.BruteforcePlayer.new(d[0],d[1],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11])
		var player = Bruteforce.BruteforcePlayer.new(p[0],p[1],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],d[11])
		dealer.health = d[2]
		player.health = p[2]
		var states = Bruteforce.TempStates.new()
		states.handcuffState = s[0]
		states.magnifyingGlassResult = s[1]
		states.usedHandsaw = s[2]
		states.adrenaline = s[3]
		states.futureLive = s[4]
		states.futureBlank = s[5]
		GlobalVariables.recursions = 0
		print("bruteforcing")
		option = Bruteforce.GetBestChoiceAndDamage(roundType, liveCount, blankCount, \
			dealer, player, states).option
		if option == Bruteforce.OPTION_NONE:
			if d[10] > 0 and (liveCount - s[4]) + (blankCount - s[5]) > 0: option = Bruteforce.OPTION_BURNER
			elif d[7] > 0 and s[1] == Bruteforce.MAGNIFYING_LIVE and not s[2]: option = Bruteforce.OPTION_HANDSAW
			elif s[1] == Bruteforce.MAGNIFYING_LIVE: option = Bruteforce.OPTION_SHOOT_OTHER
			elif d[9] > 0 and s[1] == Bruteforce.MAGNIFYING_BLANK: option = Bruteforce.OPTION_INVERTER
			elif s[1] == Bruteforce.MAGNIFYING_BLANK: option = Bruteforce.OPTION_SHOOT_SELF
			elif d[3] > 0: option = Bruteforce.OPTION_MAGNIFY
			elif d[5] > 0: option = Bruteforce.OPTION_BEER
			elif d[9] > 0 and blankCount > liveCount: option = Bruteforce.OPTION_INVERTER
			elif d[6] > 0 and s[0] == Bruteforce.HANDCUFF_NONE: option = Bruteforce.OPTION_HANDCUFFS
			elif d[7] > 0 and not s[2]: option = Bruteforce.OPTION_HANDSAW
			else: option = Bruteforce.OPTION_SHOOT_OTHER
		else:
			print("bruteforce successful")
	action = option
	manager.connectToMaster()
	manager.thinking = false

@rpc("any_peer", "reliable") func receivePlayerInfo(): pass
@rpc("any_peer", "reliable") func sendPlayerInfo(_players): pass
@rpc("any_peer", "reliable") func receiveLoadInfo(): pass
@rpc("any_peer", "reliable") func sendLoadInfo(_currentPlayerTurn, _healthPlayers, _totalShells, _liveCount): pass
@rpc("any_peer", "reliable") func receiveItems(): pass
@rpc("any_peer", "reliable") func sendItems(_itemsForPlayers): pass
@rpc("any_peer", "reliable") func receiveItemsOnTable(_itemTableIdxArray): pass
@rpc("any_peer", "reliable") func sendItemsOnTable(_itemsOnTable): pass
@rpc("any_peer", "reliable") func receiveActionValidation(_action): pass
@rpc("any_peer", "reliable") func sendActionValidation(_action, _result): pass
@rpc("any_peer", "reliable") func sendTimeoutAdrenaline(): pass
@rpc("any_peer", "reliable") func receiveActionReady(): pass
@rpc("any_peer", "reliable") func sendActionReady(): pass
@rpc("any_peer", "reliable") func receiveBruteforce(_option): pass
@rpc("any_peer", "reliable") func requestCountdown(): pass
@rpc("any_peer", "reliable") func alertCountdown(_timeout): pass
