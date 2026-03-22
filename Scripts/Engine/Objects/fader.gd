extends CanvasLayer

var stopfadingIn := false
var stopfadingOut := false

func fadeIn():
	stopfadingIn = false
	stopfadingOut = true
	$ColorRect.modulate.a = 1
	while ($ColorRect.modulate.a > 0.02):
		if stopfadingIn:
			stopfadingIn = false
			return
		$ColorRect.modulate.a += -0.16
		await get_tree().process_frame
	$ColorRect.modulate.a = 0
	stopfadingOut = false

func fadeOut():
	stopfadingIn = true
	stopfadingOut = false
	$ColorRect.modulate.a = 0
	while ($ColorRect.modulate.a < 0.98):
		if stopfadingOut:
			stopfadingOut = false
			return
		$ColorRect.modulate.a += 0.16
		await get_tree().process_frame
	$ColorRect.modulate.a = 1
	stopfadingIn = false
