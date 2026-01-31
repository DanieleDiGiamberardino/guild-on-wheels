extends CharacterBody2D

# --- VARIABILI ---
@export var speed = 50.0
@export var damage = 50
@export var is_in_mission = false 

var max_hp = 100
var current_hp = 100

# --- GESTIONE ORO ---
var gold = 0
var upgrade_cost = 50 

# --- RIFERIMENTI ---
var fireball_scene = preload("res://Scenes/Fireball.tscn")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variabili UI (inizializzate a null per sicurezza)
var health_bar = null
var gold_label = null

@onready var enemy_detector = $EnemyDetector

# Bersaglio attuale
var current_target = null

func _ready():
	is_in_mission = true
	# Cerca l'interfaccia in modo sicuro (evita crash se siamo nel Menu Home)
	if get_parent().has_node("CanvasLayer/HealthBar"):
		health_bar = get_parent().get_node("CanvasLayer/HealthBar")
		health_bar.max_value = max_hp
		health_bar.value = current_hp
	
	if get_parent().has_node("CanvasLayer/GoldLabel"):
		gold_label = get_parent().get_node("CanvasLayer/GoldLabel")
		gold_label.text = "Oro: " + str(gold)

func _physics_process(delta):
	# 1. GRAVITÀ (Deve funzionare SEMPRE, anche se la missione è ferma)
	if not is_on_floor():
		velocity.y += gravity * delta

	# Se non siamo in missione, applichiamo la gravità ma non ci muoviamo
	if not is_in_mission:
		move_and_slide()
		return
	
	# 2. LOGICA DI GIOCO (Solo se in missione)
	update_target()
	
	# Se abbiamo un bersaglio valido e vivo, freniamo per sparare
	if is_instance_valid(current_target):
		velocity.x = move_toward(velocity.x, 0, speed * delta * 5)
	else:
		# Altrimenti avanziamo
		current_target = null # Pulizia sicura
		velocity.x = speed

	move_and_slide()

# --- LOGICA COMBATTIMENTO ---

func update_target():
	if not enemy_detector: return
	
	# Se abbiamo già un target, controlliamo se è ancora valido
	if is_instance_valid(current_target):
		# Se è ancora nel detector e non sta morendo, teniamocelo
		if enemy_detector.overlaps_body(current_target) and not current_target.is_queued_for_deletion():
			return 

	# Se non abbiamo un target o quello vecchio è andato, cercane uno nuovo
	current_target = null
	var bodies = enemy_detector.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Enemies") and is_instance_valid(body):
			if not body.is_queued_for_deletion():
				current_target = body
				break

func _on_timer_timeout():
	# Timer collegato al nodo Timer nella scena
	if is_in_mission and is_instance_valid(current_target):
		shoot_fireball()

func shoot_fireball():
	if not fireball_scene: return

	var ball = fireball_scene.instantiate()
	# Spawn leggermente avanti e in alto per non colpire il pavimento
	ball.global_position = global_position + Vector2(60, -10)
	ball.damage = damage
	
	# Aggiungi al Mondo
	get_parent().add_child(ball) 

func take_damage(amount):
	current_hp -= amount
	if health_bar:
		health_bar.value = current_hp
	
	if current_hp <= 0:
		game_over()

func game_over():
	print("GAME OVER")
	get_tree().reload_current_scene()

# --- LOGICA UI ---
func add_gold(amount):
	gold += amount
	if GameData:
		GameData.add_savings(amount)
	if gold_label:
		gold_label.text = "Oro: " + str(gold)
