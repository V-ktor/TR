extends Node

func enter(_actor,_action,_roll):
	Main.set_title("")

func leave(_actor,_action,_roll):
	print("Leave city")
	Game.leave_location()
