extends Node2D

var Character_Json : Dictionary = {
	"walk_down":[],
	"walk_left":[],
	"walk_right":[],
	"walk_up":[],
	"idle_down":"",
	"idle_left":"",
	"idle_right":"",
	"idle_up":""
}
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var anim : String = "walk_down"
var animindex : int = 0

func characterupdate():
	sprite.sprite_frames.clear("idle_down")
	sprite.sprite_frames.clear("idle_up")
	sprite.sprite_frames.clear("idle_left")
	sprite.sprite_frames.clear("idle_right")
	sprite.sprite_frames.clear("walk_down")
	sprite.sprite_frames.clear("walk_left")
	sprite.sprite_frames.clear("walk_up")
	sprite.sprite_frames.clear("walk_right")
	if Character_Json["idle_down"]:
		sprite.sprite_frames.add_frame("idle_down",Loader.load_file("Sprites/Character/"+Character_Json["idle_down"]+".png"),1,-1)
	if Character_Json["idle_left"]:
		sprite.sprite_frames.add_frame("idle_left",Loader.load_file("Sprites/Character/"+Character_Json["idle_left"]+".png"),1,-1)
	if Character_Json["idle_up"]:
		sprite.sprite_frames.add_frame("idle_up",Loader.load_file("Sprites/Character/"+Character_Json["idle_up"]+".png"),1,-1)
	if Character_Json["idle_right"]:
		sprite.sprite_frames.add_frame("idle_right",Loader.load_file("Sprites/Character/"+Character_Json["idle_right"]+".png"),1,-1)
	
	if Character_Json["walk_down"]:
		for i in Character_Json["walk_down"]:
			sprite.sprite_frames.add_frame("walk_down",Loader.load_file("Sprites/Character/"+i+".png"),1,-1)
	if Character_Json["walk_left"]:
		for i in Character_Json["walk_left"]:
			sprite.sprite_frames.add_frame("walk_left",Loader.load_file("Sprites/Character/"+i+".png"),1,-1)
	if Character_Json["walk_up"]:
		for i in Character_Json["walk_up"]:
			sprite.sprite_frames.add_frame("walk_up",Loader.load_file("Sprites/Character/"+i+".png"),1,-1)
	if Character_Json["walk_right"]:
		for i in Character_Json["walk_right"]:
			sprite.sprite_frames.add_frame("walk_right",Loader.load_file("Sprites/Character/"+i+".png"),1,-1)

func _on_animlist_item_selected(index):
	animindex = index
	sprite.animation = $ItemList2.get_item_text(index)
	$ItemList.clear()
	if sprite.animation.begins_with("idle_"):
		$ItemList.add_item(Character_Json[sprite.animation])
	else:
		for i in Character_Json[sprite.animation]:
			$ItemList.add_item(i)
	sprite.play()

func _on_framelist_item_selected(index):
	$ItemList.remove_item(index)
	Character_Json[sprite.animation].remove_at(index)
	characterupdate()

func _on_add_sprite_pressed():
	if sprite.animation.begins_with("idle_"):
		if $ItemList.get_item_count() == 0:
			$ItemList.add_item($LineEdit.text)
		else:
			$ItemList.set_item_text(0,$LineEdit.text)
		Character_Json[sprite.animation] = $LineEdit.text
	else:
		$ItemList.add_item($LineEdit.text)
		Character_Json[sprite.animation].append($LineEdit.text)
	if not sprite.is_playing():
		sprite.play()
	characterupdate()

func _on_save_pressed():
	Undermaker.createJsonFromDictionary("Data/characters/"+$LineEdit2.text+".json",Character_Json)

func _on_load_pressed():
	Character_Json = Undermaker.loadJsonAsDictionary("Data/characters/"+$LineEdit2.text+".json")
	_on_animlist_item_selected(animindex)
	characterupdate()
