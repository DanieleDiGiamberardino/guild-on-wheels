extends CharacterBody2D

# --- STATISTICHE ---
var hp = 50 
var speed = 100.0
var damage_to_player = 10
var gold_reward = 15
var push_force = 300.0 

# --- CONFIGURAZIONE ATTACCO ---
var attack_range = 150.0 
var attack_cooldown = 1.0
var time_since_last_attack = 1.0 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target_caravan = null

func _ready():
		# --- DIAGNOSTICA GOBLIN ---
	print("👹 GOBLIN GENERATO!")
	print("   > Collision Layer (Chi sono io): ", collision_layer)
	if not is_in_group("Enemies"):
		add_to_group("Enemies")

	# Cerca la Carovana (Gestisce il caso in cui non esiste, es. test o menu)
	if get_parent().has_node("Caravan"):
		target_caravan = get_parent().get_node("Caravan")
	else:
		# Fallback: cerca nel gruppo Player
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
			# Frenata dolce
			velocity.x = move_toward(velocity.x, 0, speed * delta * 5)
			try_attack() 
	else:
		# Nessun bersaglio -> frena
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()

func try_attack():
	if time_since_last_attack > attack_cooldown:
		if is_instance_valid(target_caravan) and target_caravan.has_method("take_damage"):
			target_caravan.take_damage(damage_to_player)
			
			# Saltello quando attacca
			velocity.y = -150 
			time_since_last_attack = 0.0

func take_damage(amount):
	if hp <= 0: return
	
	hp -= amount
	
	# --- FIX KNOCKBACK ---
	# Se il Goblin è fermo (velocity.x = 0), il sign() dava 0.
	# Ora calcoliamo la direzione basandoci sulla posizione della carovana (se esiste)
	var knockback_dir = -1 # Default verso sinistra
	if is_instance_valid(target_caravan):
		# Spinta nella direzione opposta alla carovana
		knockback_dir = -sign(target_caravan.global_position.x - global_position.x)
	
	velocity.x = knockback_dir * push_force
	velocity.y = -200
	# ---------------------
	
	modulate = Color.RED
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color.WHITE)
	
	if hp <= 0:
		die()

func die():
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	if is_instance_valid(target_caravan) and target_caravan.has_method("add_gold"):
		target_caravan.add_gold(gold_reward)
	
	modulate = Color(1, 0, 0, 0.5)
	await get_tree().create_timer(0.2).timeout
	queue_free()
