extends Node

const CATEGORIES = ["cities", "travel", "companions", "persons", "quests"]

var entries := {}
var filter := {}
var sort_by := "name_ascending"


class AlphabeticalSorter:
	static func sort_ascending(a, b):
		if Journal.entries[a].title[0]<Journal.entries[b].title[0]:
			return true
		return false
	static func sort_descending(a, b):
		if Journal.entries[b].title[0]<Journal.entries[a].title[0]:
			return true
		return false

class TimeSorter:
	static func sort_ascending(a, b):
		if Journal.entries[a].time<Journal.entries[b].time:
			return true
		return false
	static func sort_descending(a, b):
		if Journal.entries[b].time<Journal.entries[a].time:
			return true
		return false


func add_entry(ID : String, title : String, tags : Array, text, image : String, time : int, link=[{}]):
	if typeof(link)!=TYPE_ARRAY:
		link = [link]
	if typeof(text)==TYPE_ARRAY:
		entries[ID] = {"title":title, "tags":tags, "text":text, "image":image, "time":time, "link":link}
	else:
		entries[ID] = {"title":title, "tags":tags, "text":[text], "image":image, "time":time, "link":link}

func append_entry(ID : String, text, link=[{}]):
	if !entries.has(ID):
		return
	if typeof(text)==TYPE_ARRAY:
		if typeof(link)!=TYPE_ARRAY:
			link = [link]
		entries[ID].text += text
		entries[ID].link += link
	else:
		if typeof(link)==TYPE_ARRAY:
			link = link[0]
		entries[ID].text.push_back(text)
		entries[ID].link.push_back(link)

func get_entries_sorted() -> Array:
	var keys := entries.keys()
	match sort_by:
		"name_ascending":
			keys.sort_custom(AlphabeticalSorter, "sort_ascending")
		"name_descending":
			keys.sort_custom(AlphabeticalSorter, "sort_descending")
		"date_ascending":
			keys.sort_custom(TimeSorter, "sort_ascending")
		"date_descending":
			keys.sort_custom(TimeSorter, "sort_descending")
	return keys

func has_valid_tag(tags : Array) -> bool:
	for tag in tags:
		if filter.has(tag) && filter[tag]:
			return true
	return false


func _save(file : File) -> int:
	# Add informations to save file.
	file.store_line(JSON.print(entries))
	return OK

func _load(file : File) -> int:
	# Load from given save file.
	var currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	entries = currentline
	return OK

func _ready():
	for c in CATEGORIES:
		filter[c] = true
