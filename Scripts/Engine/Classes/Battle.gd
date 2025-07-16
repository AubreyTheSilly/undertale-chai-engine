extends Node

enum SOULMODES {RED=0,BLUE=1}

var loadedBattle = {
	"encounterText":"* . . .",
	"enemies":["dust"],
	"state":0,
	"music":"mus_dustsans",
	"bg":false
}

func Encounter(id : String):
	Undermaker.player_can_move = false
	var encounterFile = FileAccess.open(Undermaker.Path+"Data/Encounters/"+id+".txt",FileAccess.READ)
	var encounter = encounterFile.get_line().split(":")
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
	get_tree().get_root().add_child(preload("res://Scenes/Objects/BattleStarter.tscn").instantiate())

func DictionaryToEnemyData(dict : Dictionary) -> EnemyData:
	var enemydata = EnemyData.new()
	enemydata.EnemyName = dict["enemyName"]
	enemydata.name = dict["name"]
	enemydata.EnemySprite = Loader.load_file("Sprites/Battle/Enemies/"+dict["sprite"]+".png")
	enemydata.EnemyHurtSprite = Loader.load_file("Sprites/Battle/Enemies/"+dict["hurtSprite"]+".png")
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
