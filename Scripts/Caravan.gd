extends CharacterBody2D

# --- VARIABILI ---
@export var speed = 50.0
@export var damage = 10
var max_hp = 100
var current_hp = 100

# --- GESTIONE ORO ---
var gold = 0
var upgrade_cost = 50 

# --- RIFERIMENTI ---
var fireball_scene = preload("res://Scenes/Fireball.tscn")
# Ottieni la gravità dalle impostazioni
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var health_bar = get_node("../CanvasLayer/HealthBar")
@onready var gold_label = get_node("../CanvasLayer/GoldLabel")
@onready var enemy_detector = $EnemyDetector

var current_target = null

func _ready():
	# Impostiamo la barra al massimo all'inizio
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp

func _physics_process(delta):
	# 1. APPLICA GRAVITÀ (Il pezzo nuovo che hai aggiunto)
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. CERCA BERSAGLI
	update_target()
	
	# 3. MOVIMENTO
	# Se abbiamo un nemico nel mirino, ci fermiamo per sparare
	if current_target != null:
		velocity.x = 0
	else:
		# Altrimenti andiamo avanti
		velocity.x = speed

	# 4. MUOVI EFFETTIVAMENTE
	move_and_slide()

# --- LOGICA COMBATTIMENTO ---

func update_target():
	var bodies = enemy_detector.get_overlapping_bodies()
	current_target = null
	
	for body in bodies:
		# IMPORTANTE: Assicurati che il Goblin sia nel gruppo "Enemies"
		if body.is_in_group("Enemies"):
			current_target = body
			break

func _on_timer_timeout():
	# Il Timer scatta ogni tot secondi: se c'è un target, spara
	if current_target != null:
		shoot_fireball()

func shoot_fireball():
	var ball = fireball_scene.instantiate()
	ball.global_position = global_position
	ball.damage = damage
	# Aggiunge la palla al World, così non segue la carovana
	get_parent().add_child(ball) 

func take_damage(amount):
	current_hp -= amount
	print("Ahi! Carovana colpita! Vita: ", current_hp)
	
	if health_bar:
		health_bar.value = current_hp
	
	if current_hp <= 0:
		game_over()

func game_over():
	print("GAME OVER")
	get_tree().reload_current_scene()

# --- LOGICA UI E ORO ---

func add_gold(amount):
	gold += amount
	if gold_label:
		gold_label.text = "Oro: " + str(gold)

func buy_upgrade():
	if gold >= upgrade_cost:
		gold -= upgrade_cost
		add_gold(0) 
		damage += 5
		upgrade_cost = upgrade_cost * 2 
		
		var btn = get_node("../CanvasLayer/UpgradeButton")
		if btn:
			btn.text = "Potenzia Spada (" + str(upgrade_cost) + " Oro)"
	else:
		print("Non hai abbastanza soldi!")
