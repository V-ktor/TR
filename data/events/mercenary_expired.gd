extends Node

var num_questions := 0
var questions_asked := []
var character : Characters.Character
var ID : String


func init(_location,args):
	ID = args[0]
	character = Characters.characters[ID]
	Main.add_text(tr("MERCENARY_EXPIRED_INIT").format({"name":character.get_name(),"he/she":tr(Characters.HE_SHE[character.gender])}))
	Characters.payout_party()
	character.location = Game.location
	if character.morale>75.0:
		var cost := int(rand_range(7,9)+character.level-2*int("young" in character.personality)-int("old" in character.personality)-int("shy" in character.personality)+2*int("reckless" in character.personality))
		Main.add_text(tr("MERCENARY_EXPIRED_EXTEND_CONTRACT"))
		if cost>character.payment_cost:
			if "shy" in character.personality || "curious" in character.personality || "cheerful" in character.personality:
				Main.add_text(tr("MERCENARY_EXPIRED_EXTEND_PAYMENT_DESERVE").format({"amount":cost,"currency":character.payment_currency}))
			else:
				Main.add_text(tr("MERCENARY_EXPIRED_EXTEND_PAYMENT_INCREASE").format({"amount":cost,"currency":character.payment_currency}))
			character.payment_cost = cost
		character.hired_until += int(rand_range(5.0,7.0)*24*60*60)
		Main.add_action(Game.Action.new(tr("ACTION_KEEP_CHAR").format({"name":character.get_name()}),self,{6:{"method":"keep","grade":1},0:{"method":"fail_keep","grade":0}},"charisma","",3,6))
		Main.add_action(Game.Action.new(tr("ACTION_DITCH_CHAR").format({"name":character.get_name()}),self,{4:{"method":"abandon","grade":1},0:{"method":"fail_abandon","grade":0}},"charisma","",3,4))
	elif character.morale>25.0:
		if "curious" in character.personality:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_CURIOUS"))
		elif "bold" in character.personality || "reckless" in character.personality:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_ADVENTURE"))
		elif "cynical" in character.personality:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_GLAD"))
		elif "cheerful" in character.personality:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_TOO_BAD"))
		else:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_NEUTRAL"))
		Characters.party.erase(ID)
		Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"leave","grade":1}},"","",3))
	else:
		if "cynical" in character.personality:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_INCOMPETENCE"))
		elif "shy" in character.personality:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_GOODBYE"))
		else:
			Main.add_text(tr("MERCENARY_EXPIRED_LEAVE_ANGRY"))
		Characters.party.erase(ID)
		Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"leave","grade":1}},"","",3))

func keep(_actor,_acion,roll):
	var morale := max(roll-10, -2)
	character.morale += morale
	if "cynical" in character.personality:
		Main.add_text(tr("MERCENARY_EXPIRED_EXTENDED_LOST"))
	elif "shy" in character.personality || "cheerful" in character.personality:
		Main.add_text(tr("MERCENARY_EXPIRED_EXTENDED_GREAT"))
	elif "bold" in character.personality || "reckless" in character.personality:
		Main.add_text(tr("MERCENARY_EXPIRED_EXTENDED_ADVENTURE"))
	else:
		Main.add_text(tr("MERCENARY_EXPIRED_EXTENDED_BUSINESS"))
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"leave","grade":1}},"","",3))

func fail_keep(_actor,_acion,_roll):
	var city = Map.get_location(Game.location)
	Main.add_text(tr("MERCENARY_EXPIRED_EXTENDED_FAILED").format({"name":character.get_name(),"he/she":tr(Characters.HE_SHE[character.gender])}))
	Characters.party.erase(ID)
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"leave","grade":1}},"","",3))
	Journal.add_entry("fired_"+ID, tr("FIRED")+" "+character.get_name(), ["companions"], tr("FIRED_AT"), "", Map.time,{"character":{"name":character.get_name(),"target":ID},"city":{"name":city.name,"target":Game.location}})

func abandon(_actor,_acion,_roll):
	var city = Map.get_location(Game.location)
	Main.add_text(tr("MERCENARY_EXPIRED_ABANDON").format({"name":character.get_name(),"he/she":tr(Characters.HE_SHE[character.gender])}))
	if "bold" in character.personality || "reckless" in character.personality:
		Main.add_text(tr("MERCENARY_EXPIRED_ABANDON_TOO_BAD"))
	elif "cynical" in character.personality:
		Main.add_text(tr("MERCENARY_EXPIRED_ABANDON_WHATEVER"))
	else:
		Main.add_text(tr("MERCENARY_EXPIRED_ABANDON_MEET_AGAIN"))
	Characters.party.erase(ID)
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"leave","grade":1}},"","",3))
	Journal.add_entry("fired_"+ID, tr("FIRED")+" "+character.get_name(), ["companions"], tr("FIRED_AT"), "", Map.time,{"character":{"name":character.get_name(),"target":ID},"city":{"name":city.name,"target":Game.location}})

func abandon_keep(_actor,_acion,_roll):
	Main.add_text(tr("MERCENARY_EXPIRED_ABANDON_FAILED").format({"name":character.get_name(),"he/she":tr(Characters.HE_SHE[character.gender])}))
	Main.add_text(tr("MERCENARY_EXPIRED_ABANDON_NEED"))
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"leave","grade":1}},"","",3))

func leave(_actor,_acion,_roll):
	Game.enter_location(Game.location)
