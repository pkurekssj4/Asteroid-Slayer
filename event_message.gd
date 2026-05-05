extends RichTextLabel
var lasting_time: int
var message: String
var color: String
var fading_off: bool = false
var alpha_channel: float = 1.0
var alpha_channel_decay_per_sec = 0.75
var font_size: int = 0
var icon: String = "none"
var points: int
var waving: bool = false
var waving_phase: float = 100
var waving_phase_per_sec: float = 0.3
var changing_color: bool = false

func _ready() -> void:
	if waving:
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.shader = PreloadedResourcesHolder.get_shader("ending_text_waving")
		self.material = shader_material
	if font_size != 0: add_theme_font_size_override("normal_font_size", font_size)
	$Timer.start(lasting_time)
	text = "[color= " + color + "]" + message + "[/color]"
	if icon == "resource credit":
		if points > 0: text += "[color=spring_green]+" + str(points)+ "[/color]"
		else: text += "[color=red]-" + str(points * -1) + "[/color]"
		var new_icon = preload("res://resource_icons/resource_credit.png")
		add_image(new_icon, 0, 18) # 0 = image ID (dowolna liczba), 16 = wysokość (dopasuj)
	
func _process(delta: float) -> void:
	if fading_off:
		alpha_channel -= alpha_channel_decay_per_sec * delta
		if alpha_channel == 0: queue_free()

	if waving:
		waving_phase += waving_phase_per_sec * delta
		self.material.set("shader_parameter/phase", waving_phase)
		self.material.set("shader_parameter/alpha_channel", alpha_channel)
	else: modulate.a = alpha_channel

func _on_timer_timeout() -> void:
	fading_off = true
