extends Node

const VOVELS = ["a","e","o","u","i"]
const CONS = ["b","c","d","f","g","h","j","k","l","m","n","p","r","s","t","v","w","x","y","z"]
const CITY_PHRASE = [
	"city","town","settlement","colony","polis","camp","township","outpost"
]



class Name:
	var first := ""
	var last := ""
	var title := ""
	
	func get_full() -> String:
		if title!="":
			return tr(title)+" "+first+" "+last
		return first+" "+last
	
	func get_name() -> String:
		return first+" "+last
	
	func _init(f : String,l : String, t:=""):
		first = f
		last = l
		title = t
	
	func to_dict() -> Dictionary:
		var dict = {"first":first,"last":last,"title":title}
		return dict



func get_random_name(gender,race=null) -> Name:
	var name
	var vovels = VOVELS
	if race==null:
		race = Menu.races.keys()[randi()%Menu.races.size()]
	if Menu.races[race].has("vovels"):
		vovels += Menu.races[race].vovels
	if gender==1 || (gender==1 && randf()<0.5):
		name = Name.new(random_name_tags(Menu.races[race].first_name_female,Menu.races[race].phrase_female,vovels),randomize_name(Menu.races[race].last_name[randi()%Menu.races[race].last_name.size()],Menu.races[race].phrase_male+Menu.races[race].phrase_female))
	else:
		name = Name.new(random_name_tags(Menu.races[race].first_name_male,Menu.races[race].phrase_male,vovels),randomize_name(Menu.races[race].last_name[randi()%Menu.races[race].last_name.size()],Menu.races[race].phrase_male+Menu.races[race].phrase_female))
	return name

func get_random_city_name(race=null) -> String:
	var name
	if race==null:
		race = Menu.races.keys()[randi()%Menu.races.size()]
	name = conc(Menu.races[race].last_name[randi()%Menu.races[race].last_name.size()],CITY_PHRASE[randi()%CITY_PHRASE.size()])
	name = replace_syllable(name,Menu.races[race].phrase_male+Menu.races[race].phrase_female)
	name = name[0].to_upper()+name.substr(1,name.length()-1)
	return name

func randomize_name(name,phrases) -> String:
	name = random_syllable(name)
	for _i in range(randi()%int(1+0.25*name.length())+1):
		name = replace_syllable(name,phrases)
	name = name[0].to_upper()+name.substr(1,name.length()-1)
	return name

func random_name_tags(list,phrases,vovels=VOVELS) -> String:
	if list.size()<1:
		return ""
	var name = random_name_conc(list[randi()%list.size()],list[randi()%list.size()],phrases,vovels)
	name = name[0].to_upper()+name.substr(1,name.length()-1)
	return name

func random_name_conc(str1,str2,phrases,vovels=VOVELS) -> String:
	var name = conc(str1,str2)
	for _i in range(randi()%int(1+0.25*name.length())+1):
		name = replace_syllable(name,phrases,vovels)
	return name

func conc(str1,str2,vovels=VOVELS) -> String:
	# Append sub strings of str1 and str2 and make sure a vovel and a consonant are at the crossing.
	var c1 = clamp(round(str1.length()*rand_range(0.5,0.7)+rand_range(-1.5,2.5)),1,str1.length()-1)
	var c2 = clamp(round(str2.length()*rand_range(0.5,0.7)+rand_range(-1.5,2.5)),0,str2.length()-2)
	var name = str1.substr(0,c1)
	if !(str1[max(c1-1,0)] in vovels) && !(str2[c2] in vovels) && (!(str1[max(c1-2,0)] in vovels) || !(str2[min(c2+1,str2.length()-1)] in vovels)):
		name += vovels[randi()%(vovels.size())]
	name += str2.substr(c2,str2.length()-c2)
	return name

func replace_syllable(name,phrases,vovels=VOVELS) -> String:
	# Replace a syllable of name by a random one from phrases.
	var pos := 0
	var phrase = phrases[randi()%phrases.size()]
	var length = phrase.length()
	var v := false
	var c := 0
	var start := 0
	# Chose a random syllable to replace.
	for i in range(name.length()):
		pos = i
		if name[i] in vovels:
			if v:
				v = false
				c = 0
				if randf()<0.5:
					break
				else:
					start = i
			else:
				v = true
		else:
			c += 1
			if c>2:
				v = false
				c = 0
				if randf()<0.5:
					break
				else:
					start = i
	length = abs(start-pos)+randi()%2
	pos = start
	if name.length()>4+randi()%4:
		length += 1
	if pos+length>name.length()-1:
		pos -= pos+length-name.length()+1
	name = name.substr(0,pos)+phrase+name.substr(pos+length,name.length()-pos-length)
	# Replace a vovel by a constant if there are too many in a row or vice versa.
	for i in range(max(pos-1,0),min(pos+length+1,name.length()-1)):
		if !(name[clamp(i,0,name.length()-1)] in vovels) && !(name[clamp(i-1,0,name.length()-1)] in vovels) && !(name[clamp(i+1,0,name.length()-1)] in vovels):
			name[i] = vovels[randi()%vovels.size()]
		elif (name[clamp(i,0,name.length()-1)] in vovels) && (name[clamp(i-1,0,name.length()-1)] in vovels) && (name[clamp(i+1,0,name.length()-1)] in vovels):
			name[i] = CONS[randi()%CONS.size()]
	if name.length()>2 && (name[name.length()-1] in CONS and name[name.length()-2] in CONS):
		name[name.length()-1] = vovels[randi()%vovels.size()]
	return name

func random_syllable(name,vovels=VOVELS) -> String:
	var pos
	var dir
	var length
	for _i in range(20):
		pos = randi()%(name.length())
		if (name[pos] in vovels):
			break
	if pos==0:
		dir = 1
	elif pos==name.length()-1:
		dir = -1
	else:
		dir = 2*(randi()%2)-1
	length = randi()%3
	if pos+dir*length<0:
		length += pos+dir*length
	elif pos+dir*length>name.length()-1:
		length -= pos+dir*length-name.length()+1
	for i in range(pos,pos+dir*length,dir):
		name = name.substr(0,i)+CONS[randi()%CONS.size()]+name.substr(i+1,name.length()-1-i)
	for i in range(name.length()):
		if !(name[clamp(i,0,name.length()-1)] in vovels) && !(name[clamp(i-1,0,name.length()-1)] in vovels) && !(name[clamp(i+1,0,name.length()-1)] in vovels):
			name[i] = vovels[randi()%vovels.size()]
	return name
