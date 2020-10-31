extends Node

var settings := {
	"display":{
		"width":int(OS.window_size.x),"height":int(OS.window_size.y),
		"fullscreen":OS.window_fullscreen,"maximized":OS.window_maximized},
	"audio":{
		"sound_volume":1.0,"music_volume":1.0}}


func apply():
	OS.window_size = Vector2(settings.display.width, settings.display.height)
	OS.window_maximized = settings.display.maximized
	OS.window_fullscreen = settings.display.fullscreen
	AudioServer.set_bus_volume_db(1, linear2db(settings.audio.music_volume))
	AudioServer.set_bus_volume_db(2, linear2db(settings.audio.sound_volume))

func load_settings():
	var config := ConfigFile.new()
	var err := config.load("user://settings.cfg")
	printt("Loading settings.")
	if err==OK:
		for c in settings.keys():
			for k in settings[c].keys():
				settings[c][k] = config.get_value(c, k, settings[c][k])
		settings.display.width = int(settings.display.width)
		settings.display.height = int(settings.display.height)
		apply()
	else:
		save_settings()

func save_settings():
	var config := ConfigFile.new()
	printt("Saving settings.")
	for c in settings.keys():
		for k in settings[c].keys():
			config.set_value(c, k, settings[c][k])
	settings.display.width = int(settings.display.width)
	settings.display.height = int(settings.display.height)
	config.save("user://settings.cfg")

func _ready():
	load_settings()
