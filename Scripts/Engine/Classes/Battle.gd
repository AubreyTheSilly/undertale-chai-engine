extends Node

enum SOULMODES {RED=0,BLUE=1}

signal battleEnd(bad : bool)

var loadedBattle = {
	"encounterText":"* deAR GOD THE DUMMIES ARE[newline]  MULTIPLYING",
	"enemies":["dummy","dummy","dummy"]
}

func _startBattle(id : String):
	pass

func DictionaryToEnemyData(dict : Dictionary) -> EnemyData:
	var enemydata = EnemyData.new()
	enemydata.EnemyName = dict["enemyName"]
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
	return enemydata
