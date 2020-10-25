extends Node

const CATEGORIES = ["city", "travel", "quests"]

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
		if Journal.entries[a].date<Journal.entries[b].date:
			return true
		return false
	static func sort_descending(a, b):
		if Journal.entries[b].date<Journal.entries[a].date:
			return true
		return false


func add_entry(ID : String, title : String, category : String, text, image : String, date : int):
	if typeof(text)==TYPE_ARRAY:
		entries[ID] = {"title":title, "category":category, "text":text, "image":image, "date":date}
	else:
		entries[ID] = {"title":title, "category":category, "text":[text], "image":image, "date":date}

func append_entry(ID : String, text):
	if !entries.has(ID):
		return
	if typeof(text)==TYPE_ARRAY:
		entries[ID].text += text
	else:
		entries[ID].text.push_back(text)

func get_entries_sorted() -> Array:
	var keys := entries.keys()
	if sort_by=="name_ascending":
		keys.sort_custom(AlphabeticalSorter, "sort_ascending")
	elif sort_by=="name_descending":
		keys.sort_custom(AlphabeticalSorter, "sort_descending")
	if sort_by=="date_ascending":
		keys.sort_custom(TimeSorter, "sort_ascending")
	elif sort_by=="date_descending":
		keys.sort_custom(TimeSorter, "sort_descending")
	return keys


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
