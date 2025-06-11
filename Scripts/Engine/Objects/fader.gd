extends CanvasLayer

func fadeIn():
	$ColorRect.modulate.a = 1
	while ($ColorRect.modulate.a > 0.02):
		$ColorRect.modulate.a += -0.16
		await get_tree().process_frame
	$ColorRect.modulate.a = 0

func fadeOut():
	$ColorRect.modulate.a = 0
	while ($ColorRect.modulate.a < 0.98):
		$ColorRect.modulate.a += 0.16
		await get_tree().process_frame
	$ColorRect.modulate.a = 1
