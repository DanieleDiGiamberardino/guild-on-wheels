extends CharacterBody2D

# --- STATISTICHE ---
var hp = 50
var speed = 100.0
var damage_to_player = 10
var gold_reward = 15
var push_force = 300.0 

# --- CONFIGURAZIONE ATTACCO ---
var attack_range = 150.0  # Prima era 100.0, troppo poco!
var attack_cooldown = 1.0
# TRUCCO: Mettiamo il timer GIÀ pieno all'inizio, così attacca subito appena arriva!
var time_since_last_attack = 1.0 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target_caravan = null

func _ready():
	# DEBUG: Cerchiamo la carovana e stampiamo se la troviamo
	target_caravan = get_parent().get_node_or_null("Caravan")
	
	if target_caravan:
		print("Goblin: Ho trovato la Carovana! Pronto a combattere.")
	else:
		print("ERRORE GOBLIN: Non trovo il nodo 'Caravan'! Controlla il nome nella scena World.")

func _process(delta):
	# Il timer avanza
	time_since_last_attack += delta

func _physics_process(delta):
	# 1. Gravità
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Logica
	if target_caravan:
		var distance = abs(target_caravan.global_position.x - global_position.x)
		var direction_vector = (target_caravan.global_position - global_position).normalized()
		var direction = direction_vector.x

		# Se siamo lontani -> Cammina
		if distance > attack_range:
			velocity.x = direction * speed
			if has_node("Sprite2D"):
				$Sprite2D.flip_h = direction > 0 
		
		# Se siamo vicini -> Fermati e Attacca
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			try_attack() # Prova ad attaccare
	
	move_and_slide()

func try_attack():
	# Controlliamo il timer
	if time_since_last_attack > attack_cooldown:
		
		# Controlliamo se possiamo fare danno
		if target_caravan and target_caravan.has_method("take_damage"):
			print("BAM! Attacco eseguito!") # Se vedi questo, funziona
			
			target_caravan.take_damage(damage_to_player)
			
			# Effetto saltello
			velocity.y = -200 
			time_since_last_attack = 0.0
		else:
			print("ERRORE ATTACCO: Sono vicino, ma non riesco a chiamare take_damage sulla Carovana!")

# --- DANNI E MORTE ---
func take_damage(amount):
	hp -= amount
	velocity.x = -sign(velocity.x) * push_force
	velocity.y = -200
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	if hp <= 0:
		die()

func die():
	if target_caravan:
		target_caravan.add_gold(gold_reward)
	queue_free()
