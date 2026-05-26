class_name BattleInfoDrawer
extends Node2D

func _draw() -> void:
	var maxhp = PlayerData.MaxHP
	var hp = PlayerData.HP
	
	draw_set_transform(Vector2.ZERO,0.0,Vector2(0.5,0.5))
	if hp < 0:
		hp = 0
	
	var hpwrite = str(hp)
	if hp < 10:
		hpwrite = "0"+str(hp)
	
	var font = preload("res://Fonts/undertale-mars-needs-cunnilingus.otf") # so that it's more readable to get the ascent. crazy font name btw LMAO
	draw_string(font,Vector2(30,400+font.get_ascent()),str(PlayerData.Name)+"   LV "+str(PlayerData.LV),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Undermaker.accents["primary"])
	
	if Battle.kr_enabled:
		draw_rect(Rect2(255,400,maxhp*1.2,20),Undermaker.accents["emptyhp"])
		draw_rect(Rect2(255,400,hp*1.2,20),Undermaker.accents["hp"])
		
		if PlayerData.KR > 40:
			PlayerData.KR = 40
		elif PlayerData.KR >= PlayerData.HP:
			PlayerData.KR = PlayerData.HP-1
		var kr = PlayerData.KR
		if kr < 0:
			kr = 0
		draw_rect(Rect2(255+(hp*1.2),400,-(kr*1.2),20),Undermaker.accents["kr"])
		
		if kr > 0:
			draw_string(font,Vector2(305+(maxhp*1.2),400+font.get_ascent()),hpwrite+" / "+str(maxhp),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Undermaker.accents["kr"])
		else:
			draw_string(font,Vector2(305+(maxhp*1.2),400+font.get_ascent()),hpwrite+" / "+str(maxhp),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Undermaker.accents["primary"])
		draw_texture(preload("res://Sprites/Battle/spr_krmeter_0.png"),Vector2(265+(maxhp*1.2),405)+Vector2(0,0),Undermaker.accents["primary"]) # account for the sprite offset in og undertale
		draw_texture(preload("res://Sprites/Battle/spr_hpname_0.png"),Vector2(220,400)+Vector2(4,5),Undermaker.accents["primary"]) # account for the sprite offset in og undertale
	else:
		draw_rect(Rect2(275,400,maxhp*1.2,20),Undermaker.accents["emptyhp"])
		draw_rect(Rect2(275,400,hp*1.2,20),Undermaker.accents["hp"])
		draw_string(font,Vector2(290+(maxhp*1.2),400+font.get_ascent()),hpwrite+" / "+str(maxhp),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Undermaker.accents["primary"])
		draw_texture(preload("res://Sprites/Battle/spr_hpname_0.png"),Vector2(240,400)+Vector2(4,5),Undermaker.accents["primary"]) # account for the sprite offset in og undertale

func _process(_delta) -> void:
	queue_redraw()
