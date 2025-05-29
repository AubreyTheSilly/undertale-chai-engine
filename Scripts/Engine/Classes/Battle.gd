extends Node

enum SOULMODES {RED=0,BLUE=1}

var loadedBattle = {
	"encounterText":"* WOAH A DOGGY!!![wait 2] ...and[newline]  a dummy too i guess",
	"enemies":["dummy","dog"],
	"state":0,
	"music":"mus_dogsong"
}

func Encounter(id : String):
	pass

func DictionaryToEnemyData(dict : Dictionary) -> EnemyData:
	var enemydata = EnemyData.new()
	enemydata.EnemyName = dict["enemyName"]
	enemydata.name = dict["name"]
	enemydata.EnemySprite = load("res://Sprites/Battle/Enemies/"+dict["sprite"]+".png")
	enemydata.EnemyHurtSprite = load("res://Sprites/Battle/Enemies/"+dict["hurtSprite"]+".png")
	enemydata.EnemySpareSprite = load("res://Sprites/Battle/Enemies/"+dict["spareSprite"]+".png")
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
	return enemydata
