extends Control
var message: String
var text_message: String = ""
var part = 1
var last_part = 1
var event_manager = null #set by game.tscn
var upgrade_console = null #set by upgrade_console.tscn
var game = null #set by game.tscn
var character_actual_unveil_ticks = 0
var character_target_unveil_ticks = 1
var fade_duration = 0.3
var sender: String
var place: String
var current_waving_phase: float = 0.0
var shader_phase_thresholds: Array[int] = [195, 213]
var waving_phase_per_sec: float = 2.0
var waving_multiplier: float = 1.0

func _ready() -> void:
	# aktualny brak preload dla shadera tylko z gory ustawiony w inspektorze gdyz tylko game ma resource loadera
	# var shader_material: ShaderMaterial = ShaderMaterial.new()
	# shader_material.shader = get_node("/root/Game/ResourceLoader").get_shader("message_box_border_animation")
	# $Borders.material = shader_material
	if !GlobalScript.current_data.game.muted: $MessageSound.play()
	if message == "intro": last_part = 3
	elif message == "first visit": last_part = 4
	elif message == "first god encounter": last_part = 2
	elif message == "asteroids tree unlocked": last_part = 3
	elif message == "ufo_warning": last_part = 7
	set_message_text()
	global_position = get_viewport_rect().size / 2
	#if game == null: global_position = get_viewport_rect().size / 2
	#else: global_position = Vector2(game.get_node("Camera2D").position.x, 540)
	global_position -= $Borders.size / 2
	if GlobalScript.skip_all_messages:
		if event_manager != null: event_manager.advance_game_state()
		else: upgrade_console.activated = true
		queue_free()
	set_process(false)
	reset_box()
	current_waving_phase = shader_phase_thresholds[0]
	$Borders.material.set("shader_parameter/phase", current_waving_phase)
	modulate.a = 0
	fade_scene(1)
	await get_tree().create_timer(fade_duration).timeout
	set_process(true)
	$Message.visible_ratio = 0
	
func _process(delta: float) -> void:
	if current_waving_phase >= shader_phase_thresholds[1]: waving_multiplier = -1.0
	elif current_waving_phase <= shader_phase_thresholds[0]: waving_multiplier = 1.0
	current_waving_phase += (waving_phase_per_sec * delta) * waving_multiplier
	$Borders.material.set("shader_parameter/phase", current_waving_phase)
	if $Message.visible_ratio < 1:
		character_actual_unveil_ticks += 1
		if character_actual_unveil_ticks != character_target_unveil_ticks:
			return
		character_actual_unveil_ticks = 0
		if Input.is_action_pressed("fire"):
			$Message.visible_characters += 15
			$MessageUnveiling.pitch_scale = 5.5
		else:
			$Message.visible_characters += 3
			$MessageUnveiling.pitch_scale = 4
		if !GlobalScript.current_data.game.muted: $MessageUnveiling.play()
		if $Message.visible_ratio >= 1:
			$ContinueButton.show()
			
func set_message_text() -> void:
	# GAME
	sender = "Xanetti Corporation"
	place = "Oasis: Power Plant"
	if message == "intro":
		if part == 1: text_message = "Welcome to the Oasis – the last remaining stronghold on Earth, sheltering around a thousand survivors of our species. Once a symbol of hope, it is no longer safe. Scientists have calculated with grim certainty: for the next 100 days, relentless waves of asteroids will rain down upon the planet, threatening to annihilate what little is left of humanity."
		elif part == 2: text_message = "As our appointed commander, you carry the weight of survival on your shoulders. You will take charge of our defensive cannon, plan strategies, and make critical decisions to protect the Oasis from destruction. While you fight off the cosmic onslaught, a team of engineers and scientists will work tirelessly to prepare a rocket—a vessel that holds the fragile hope of escaping Earth and starting anew on Mars."
		elif part == 3: text_message = "Time is not on our side. The fate of humanity rests in your hands. Can you hold the line long enough to ensure our future among the stars? The countdown begins now."
	elif message == "ending of day 1": text_message = "Well done Commander, thanks to you we've survived the first day of asteroids threats.\nBe advised: Along with our scientists and astereologists, we predict that each new day, a new type of asteroid will appear on the sky. We estimate there will be ten in total. We strongly advise you caution and proper preparation."
	elif message == "day_3": text_message = "Commander – great work! You've made it to Day 3. Your aim and decisions are impressive. But stay sharp – the asteroid threat is growing. Scientists predict that each day, they’ll come slightly faster and bigger."
	elif message == "day_5": text_message = "Commander, this day is extraordinary. A wave of massive asteroids is on a collision course with the base. Their size make them especially dangerous. This will be a true test of your defenses and precision. Prepare your weapon systems and hold the line — the humanity survival depends on you."
	elif message == "day_15": text_message = "It's another day when we expect unusual wave of asteroids. This time they are only explosive, what makes them easier to destroy but in the same time it's huge threat to the infrastructure. Good luck Commander!"
	elif message == "hyper_velocity_alert": text_message = "Commander, be advised as danger raises. Our radars have detected a huge number of incoming hypervelocity asteroid waves. According to the data, their frequencies and numbers will increase over time. We estimate that waves will appear on the sky everyday. Stay cautious."
	elif message == "first god encounter": 
		if part == 1: text_message = "Wait! What is this?? Commander, do you see this? This world is extraordinary. We are regularly encountering asteroids, UFOs and they are serious threat to the humanity, but we see these eyes for the first time and we have no idea what is going to happen!"
		elif part == 2: text_message = "This encounter is improbable and unpredictable. It looks like real entity of God is looking directly on us."
	elif message == "after god encounter": text_message = "This is insane! We have detected a surge of power within the defensive infrastructure. We don't know how to explain it, but apparently God sees your efforts and decided to support you!\nBy the way – you managed to deal with those massive asteroids that posed a huge threat to our base and future. Glory to you, Commander. We are very grateful for your commitment."
	elif message == "day_6": text_message = "Commander be advised, we have a new observation. Before asteroids appear in the sky, they occasionally collide with one another. These impacts cause them to shed dust, which then condenses into a protective shield forming at the asteroid’s core. Apparently, this will make destroying them more challenging."
	if text_message != "":
		assign_message_data() 
		return
	
	# UPGRADE CONSOLE
	sender = "Livrenn Group"
	place = "Oasis: Upgrade Console"
	if message == "first visit": 
		if part == 1: text_message = "Commander, welcome to the Upgrade Console. This is a special place where all your upgrades will take shape. Plan your choices carefully — some decisions are difficult, or even impossible, to reverse. Take your time and choose wisely."
		elif part == 2: text_message = "Please note that upgrade trees and specialization network function through highly advanced computational structures, loosely inspired by the architecture of the human brain. These networks require immense energy input and a precise balance of various calculating components to operate. Because of this complexity, altering the configuration is no trivial task—it demands a substantial amount of Resource Credits, Nano Cores and Asteroid Shards to initiate and stabilize any changes."
		elif part == 3: text_message = "When it comes to resources, this is a short overview of them:\n\nResource Credits – a reward for destryoing asteroids provided by the Xanetti Corporation, which hired you. Used to improve the cannon and base infrastructure."
		elif part == 4: text_message = "Asteroid Shards - There’s a small chance they’ll drop from destroyed asteroids. Used to manipulate the properties and behavior of asteroids. \n\nNano Cores - Our scientists work tirelessly in laboratories to produce them. Since the process is slow and complex, you'll receive only one Nano Core at the end of each day. Used to implement and enhance cannon abilities."
	elif message == "specialisation": text_message = "Commander, you’re no longer a newcomer — you’ve become a seasoned practitioner. You’ve proven your worth and successfully defended the base from destruction. This is a moment to celebrate. From now on, you have the opportunity to choose a specialisation and become even more effective. Take your time — each specialisation is unique and has its own benefits. Click the glowing circle in the upgrade menu to explore the available options."
	elif message == "blessings introduction to the console": text_message = "Dear Commander, Xanetti Corporation just informed us that power raised in base and it looks like this is a kind of permanent upgrade to your infrastructure. We have upgraded the Console and added a new tab. Thanks to this you will be able to have an eye on so called God's blessings."
	elif message == "asteroids tree unlocked": 
		if part == 1: text_message = "We have collected all available data regarding asteroids. We have closely examined behavior of their types and deployed powerful sonds across vast universe distances that detected incoming new tiers from other galaxies."
		elif part == 2: text_message = "We expect these intergalactic asteroids to have far greater durability than common ones: they will be harder to destroy but their shards will be much more potent."
		elif part == 3: text_message = "Using the collected data, we designed an effective Asteroid Tree to manipulate both the appearance of asteroids in the sky and also their behavior. We believe that this will help you to plan new strategies and bring your commandement skills to higher level."
	elif message == "ufo_warning":
		if part == 1: text_message = "Commander we have very worrying report. Our HTII (High Tech Information Interceptors) just intercepted very weird and intrusive information. It is very hard to understand what it tells about, but we suppose that it says that someone wants to annihilate... you."
		if part == 2: text_message = "It is not our language but we did our best to decrypt the message. When you proceed forward, you will see encrypted message."
		if part == 3: text_message = "--- Start of the intercepted message ---\nDear Emperor Xinkuluh, according to your orders, we have closely examined the Oasis planet. It definitely has very potent resources underneath it's surface."
		if part == 4: text_message = "Oasis's civilisation is in big worries, thousands of asteroids are heading directly on the planet. Our original plan was to just wait and arrive on the planet after asteroids annihilated the civilisation, but something is wrong."
		if part == 5: text_message = "Our vision nearby Oasis showed us that the planet is very effectively defended by Plasma Cannon, Laser Turrets, and Pulse Barriers. According to our data it wouldn't be possible without clever decisions and strategies. Apparently one of the humans is behind the great defensive."
		if part == 6: text_message = "Dear Emperor Xinkuluh, we will do everything what is possible to gather all possible information about this important human. Additionally we are taking first offensive steps to stop Oasis from defending.\n --- The end of the intercepted message ---"
		if part == 7: text_message = "We don't really know what to say further... The truth is harsh, but definitely we will heavily support you."
	if text_message != "":
		assign_message_data()
		return
	
func assign_message_data() -> void:
	$Place.text = place
	$Sender.text = "Incoming message from: " + sender
	$Message.text = text_message
	
func reset_box() -> void:
	$ContinueButton.hide()
	text_message = ""
	$Message.visible_characters = 0

func _on_continue_button_pressed() -> void:
	if part != last_part:
		part += 1
		reset_box()
		set_message_text()
	else:
		$ContinueButton.hide()
		if event_manager != null: event_manager.advance_game_state()
		else: upgrade_console.activated = true
		fade_scene(0)
		await get_tree().create_timer(fade_duration).timeout
		queue_free()

func fade_scene(alpha_channel) -> void:
	var scene_tween = get_tree().create_tween()
	var borders_tween = get_tree().create_tween()
	scene_tween.tween_property(self, "modulate", Color(1, 1, 1, alpha_channel), fade_duration)
	borders_tween.tween_property($Borders.material, "shader_parameter/alpha_channel", alpha_channel, fade_duration)
