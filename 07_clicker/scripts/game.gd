extends Node2D

func _ready():
	var effects = [
		"[rainbow][pulse freq=5.0]COMBO x5[/pulse][/rainbow]",
		"[color=red][tornado radius=3.0 freq=5.0]COMBO x4[/tornado][/color]",
		"[color=orange][shake]COMBO x3[/shake][/color]",
		"[color=yellow][wave]COMBO x2[/wave][/color]"
	]
	
	for i in range(effects.size()):
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true
		label.scroll_active = false
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		
		label.position = Vector2(200, 100 + i * 60) # stack vertically
		label.text = effects[i]
		
		add_child(label)
