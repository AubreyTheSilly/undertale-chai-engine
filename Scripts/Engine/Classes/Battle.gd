extends Node

enum SOULMODES {RED=0,BLUE=1}

var loadedBattle = {
	"encounterText":"* ...",
	"enemies":["idutshane"],
	"state":0,
	"music":"mus_dusttale2",
	"bg":false,
	"serious":true
}

func Encounter(id : String,transition : bool = true):
	PlayerData.player_can_move = false
	var encounterFile = FileAccess.open(Undermaker.Path+"Data/Encounters/"+id+".txt",FileAccess.READ)
	var encounterText := encounterFile.get_as_text()
	var encounter : Array = encounterText.split("\n")
	if encounter.size() <= 2:
		encounter = encounterText.split(":")
	encounterFile.close()
	loadedBattle["encounterText"] = encounter[0]
	loadedBattle["enemies"] = []
	for i in range(3):
		if encounter[i+1] != "none":
			loadedBattle["enemies"].append(encounter[i+1])
	loadedBattle["state"] = int(encounter[4])
	loadedBattle["music"] = encounter[5]
	if encounter[6] == "yes":
		loadedBattle["bg"] = true
	else:
		loadedBattle["bg"] = false
	if encounter.size() >= 8:
		if encounter[7] == "yes":
			loadedBattle["serious"] = true
		else:
			loadedBattle["serious"] = false
	await get_tree().process_frame
	if transition:
		get_tree().get_root().add_child(preload("res://Scenes/Objects/BattleStarter.tscn").instantiate())
	else:
		get_tree().change_scene_to_packed(preload("res://Scenes/Battle.tscn"))

func DictionaryToEnemyData(dict : Dictionary) -> EnemyData:
	var enemydata = EnemyData.new()
	enemydata.EnemyName = dict["enemyName"]
	enemydata.name = dict["name"]
	if dict["sprite"] == "none":
		enemydata.EnemySprite = preload('res://Sprites/empty.png')
	else:
		enemydata.EnemySprite = Loader.load_file("Sprites/Battle/Enemies/"+dict["sprite"]+".png")
	if dict["hurtSprite"] == "none":
		enemydata.EnemyHurtSprite = preload('res://Sprites/empty.png')
	else:
		enemydata.EnemyHurtSprite = Loader.load_file("Sprites/Battle/Enemies/"+dict["hurtSprite"]+".png")
	if dict["spareSprite"] == "none":
		enemydata.EnemySpareSprite = preload('res://Sprites/empty.png')
	else:
		enemydata.EnemySpareSprite = Loader.load_file("Sprites/Battle/Enemies/"+dict["spareSprite"]+".png")
	enemydata.HP = dict["hp"]
	enemydata.ATK = dict["atk"]
	enemydata.DEF = dict["def"]
	enemydata.acts = dict["acts"]
	enemydata.RandomDialogs = dict["randomdialogs"]
	enemydata.Check = dict["check"]
	enemydata.InstantSpare = dict["spareable"]
	enemydata.BubbleType = dict["bubble_type"]
	enemydata.EXP = dict["exp"]
	enemydata.GOLD = dict["gold"]
	enemydata.autodialog = dict["autodialog"]
	enemydata.FlavorText = dict["flavortext"]
	enemydata.offset = Vector2(dict["offsetx"],dict["offsety"])
	enemydata.BubbleOffset = Vector2(dict["bubbleoffsetx"],dict["bubbleoffsety"])
	enemydata.Attacks = dict["attacks"]
	return enemydata

func EnemyDataToDictionary(enemydata : EnemyData) -> Dictionary:
	var dict : Dictionary
	dict["enemyName"] = enemydata.EnemyName
	dict["name"] = enemydata.name
	if enemydata.EnemySprite == null:
		dict["sprite"] = "none"
	else:
		dict["sprite"] = enemydata.EnemySprite.resource_path.get_file().get_basename()
		print(enemydata.EnemySprite.resource_path)
	if enemydata.EnemyHurtSprite == null:
		dict["hurtSprite"] = "none"
	else:
		dict["hurtSprite"] = enemydata.EnemyHurtSprite.resource_path.get_file().get_basename()
	if enemydata.EnemySpareSprite == null:
		dict["spareSprite"] = "none"
	else:
		dict["spareSprite"] = enemydata.EnemySpareSprite.resource_path.get_file().get_basename()
	dict["hp"] = enemydata.HP
	dict["atk"] = enemydata.ATK
	dict["def"] = enemydata.DEF
	dict["acts"] = enemydata.acts
	dict["randomdialogs"] = enemydata.RandomDialogs
	dict["check"] = enemydata.Check
	dict["spareable"] = enemydata.InstantSpare
	dict["bubble_type"] = enemydata.BubbleType
	dict["exp"] = enemydata.EXP
	dict["gold"] = enemydata.GOLD
	dict["autodialog"] = enemydata.autodialog
	dict["flavortext"] = enemydata.FlavorText
	dict["offsetx"] = enemydata.offset.x
	dict["offsety"] = enemydata.offset.y
	dict["bubbleoffsetx"] = enemydata.BubbleOffset.x
	dict["bubbleoffsety"] = enemydata.BubbleOffset.y
	dict["attacks"] = enemydata.Attacks
	return dict
