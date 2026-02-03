extends CharacterBody2D

# --- RIFERIMENTI ---
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var enemy_detector = $EnemyDetector

# Bersaglio attuale (Ci serve solo per sapere se dobbiamo frenare)
var current_target = null

# (Opzionale) Teniamo il riferimento alla palla di fuoco se un giorno vorrai rimetterla
var fireball_scene = preload("res://Scenes/Fireball.tscn")

func _ready():
	print("Carovana pronta (Modalità: Payload). Vita: ", GameManager.cart_data.current_health)

func _physics_process(delta):
	# 1. GRAVITÀ
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. CONTROLLO STATO
	# Si muove solo in TRAVEL o COMBAT
	if GameManager.current_state != GameManager.GameState.TRAVEL and GameManager.current_state != GameManager.GameState.COMBAT:
		velocity.x = move_toward(velocity.x, 0, 10)
		move_and_slide()
		return

	# 3. LOGICA DI MOVIMENTO INTELLIGENTE
	update_target()
	
	# Se abbiamo un nemico davanti...
	if is_instance_valid(current_target):
		# ...FRENIAMO! La carovana ha paura e aspetta che l'Eroe pulisca la strada.
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
	else:
		# Altrimenti avanziamo alla velocità definita nei Dati
		velocity.x = GameManager.cart_data.speed

	move_and_slide()

# --- RILEVAMENTO NEMICI (Solo per frenare) ---

func update_target():
	if not enemy_detector: return
	
	if is_instance_valid(current_target):
		if enemy_detector.overlaps_body(current_target) and not current_target.is_queued_for_deletion():
			return 

	current_target = null
	var bodies = enemy_detector.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Enemies") and is_instance_valid(body):
			if not body.is_queued_for_deletion():
				current_target = body
				break

# --- DISARMO TOTALE ---

func _on_timer_timeout():
	# La Carovana ora è passiva. Non fa nulla quando scatta il timer.
	pass

func shoot_fireball():
	# Funzione disattivata.
	# Se vuoi riattivarla in futuro per un upgrade "Torretta", togli il 'return'
	return 
	
	# (Vecchio codice morto)
	# if not fireball_scene: return
	# var ball = fireball_scene.instantiate()
	# ball.global_position = global_position + Vector2(60, -10)
	# ball.damage = GameManager.cart_data.damage
	# get_parent().add_child(ball) 

# --- GESTIONE DANNI E ORO ---

func take_damage(amount):
	GameManager.damage_cart(amount)
	
	# Feedback visivo rosso
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func add_gold(amount):
	GameManager.add_money(amount)
