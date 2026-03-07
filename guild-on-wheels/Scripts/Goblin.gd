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

	# --- DIAGNOSTICA SPAWN ---
	# Appena nasco, urlo le mie statistiche!
	print("🟢 SPAWN: ", name, " | HP Iniziali: ", hp, " | Speed: ", speed)
	# -------------------------

	# 1. Injection da World
	if target_caravan != null:
		print("✅ TARGET RICEVUTO DAL MONDO: ", target_caravan.name)
		return

	# 2. Fallback
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target_caravan = players[0]
		print("⚠️ TARGET TROVATO DA SOLO (Gruppo): ", target_caravan.name)
	elif get_parent().has_node("Caravan"):
		target_caravan = get_parent().get_node("Caravan")
		print("⚠️ TARGET TROVATO DA SOLO (Parent): ", target_caravan.name)
	else:
		print("❌ ERRORE CRITICO: Nessun target trovato!")

func _process(delta):
	time_since_last_attack += delta

func _physics_process(delta):
	if hp <= 0: return

	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimento e Logica
	if is_instance_valid(target_caravan):
		var dx = target_caravan.global_position.x - global_position.x
		var distance = abs(dx)
		var direction = sign(dx)

		if distance > attack_range:
			velocity.x = direction * speed
			if has_node("Sprite2D"):
				$Sprite2D.flip_h = direction > 0 
		else:
			# Frenata e attacco
			velocity.x = move_toward(velocity.x, 0, speed * delta * 5)
			try_attack() 
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()

func try_attack():
	if time_since_last_attack > attack_cooldown:
		if is_instance_valid(target_caravan) and target_caravan.has_method("take_damage"):
			target_caravan.take_damage(damage_to_player)
			velocity.y = -150 
			time_since_last_attack = 0.0

func take_damage(amount):
	if hp <= 0: return
	
	hp -= amount
	
	# --- DIAGNOSTICA DANNO ---
	# Questo ti dirà la verità!
	print("🩸 ", name, " COLPITO! | Danno: ", amount, " | HP Rimanenti: ", hp)
	# -------------------------
	
	# Knockback
	var knockback_dir = -1
	if is_instance_valid(target_caravan):
		knockback_dir = -sign(target_caravan.global_position.x - global_position.x)
	
	velocity.x = knockback_dir * push_force
	velocity.y = -200
	
	modulate = Color.RED
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color.WHITE)
	
	if hp <= 0:
		print("💀 ", name, " È MORTO!")
		die()

func die():
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	GameManager.add_money(gold_reward)
	modulate = Color(1, 0, 0, 0.5)
	await get_tree().create_timer(0.2).timeout
	queue_free()
