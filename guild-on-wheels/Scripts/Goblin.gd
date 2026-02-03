extends CharacterBody2D

# --- STATISTICHE ---
@export var hp = 50 
@export var speed = 100.0
@export var damage_to_player = 10
@export var gold_reward = 15
var push_force = 300.0 

# --- CONFIGURAZIONE ATTACCO ---
var attack_range = 150.0 
var attack_cooldown = 1.0
var time_since_last_attack = 1.0 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target_caravan = null

func _ready():
	if not is_in_group("Enemies"):
		add_to_group("Enemies")

	# Cerca la Carovana per sapere DOVE andare
	if get_parent().has_node("Caravan"):
		target_caravan = get_parent().get_node("Caravan")
	else:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			target_caravan = players[0]

func _process(delta):
	time_since_last_attack += delta

func _physics_process(delta):
	# PROTEZIONE: Se morto, non fare nulla
	if hp <= 0 or is_queued_for_deletion():
		return

	# 1. GRAVITÀ
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. IA (Intelligenza Artificiale)
	if is_instance_valid(target_caravan):
		var dx = target_caravan.global_position.x - global_position.x
		var distance = abs(dx)
		var direction = sign(dx) # 1 se destra, -1 se sinistra

		# Se siamo lontani -> INSEGUI
		if distance > attack_range:
			velocity.x = direction * speed
			if has_node("Sprite2D"):
				$Sprite2D.flip_h = direction > 0 
		
		# Se siamo vicini -> FERMATI E ATTACCA
		else:
			velocity.x = move_toward(velocity.x, 0, speed * delta * 5)
			try_attack() 
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()

func try_attack():
	if time_since_last_attack > attack_cooldown:
		if is_instance_valid(target_caravan) and target_caravan.has_method("take_damage"):
			# Qui chiamiamo ancora la carovana per farla lampeggiare di rosso
			target_caravan.take_damage(damage_to_player)
			
			velocity.y = -150 
			time_since_last_attack = 0.0

func take_damage(amount):
	if hp <= 0: return
	
	hp -= amount
	
	# --- FIX KNOCKBACK ---
	var knockback_dir = -1
	if is_instance_valid(target_caravan):
		knockback_dir = -sign(target_caravan.global_position.x - global_position.x)
	
	velocity.x = knockback_dir * push_force
	velocity.y = -200
	
	modulate = Color.RED
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color.WHITE)
	
	if hp <= 0:
		die()

func die():
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# --- MODIFICA IMPORTANTE QUI SOTTO ---
	# Invece di darli alla carovana, li diamo al Manager!
	GameManager.add_money(gold_reward)
	# -------------------------------------
	
	modulate = Color(1, 0, 0, 0.5)
	await get_tree().create_timer(0.2).timeout
	queue_free()
