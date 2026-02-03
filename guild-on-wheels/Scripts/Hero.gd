extends Node2D

# --- CONFIGURAZIONE ---
@export var projectile_scene: PackedScene 

# --- NODI ---
@onready var range_area = $Range
@onready var timer = $Timer
@onready var sprite = $Sprite2D

var can_shoot = true
var current_target = null

func _ready():
	# Caricamento di sicurezza
	if not projectile_scene:
		projectile_scene = load("res://Scenes/Fireball.tscn")

func _physics_process(delta):
	if not can_shoot: return
	
	update_target()
	
	if is_instance_valid(current_target):
		attack()

func update_target():
	var bodies = range_area.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Enemies") and is_instance_valid(body):
			current_target = body
			return 
	
	current_target = null

func attack():
	can_shoot = false
	
	# 1. LEGGIAMO LA VELOCITÀ DAL NEGOZIO
	# Invece di usare una variabile locale, chiediamo al Manager quanto siamo veloci
	var fire_rate = GameManager.cart_data.fire_rate
	timer.start(fire_rate)
	
	if projectile_scene:
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position
		
		# 2. LEGGIAMO IL DANNO DAL NEGOZIO
		# Sovrascriviamo il danno base della palla di fuoco con quello potenziato
		proj.damage = GameManager.cart_data.damage 
		
		# 3. MIRA AUTOMATICA
		var direction = (current_target.global_position - global_position).normalized()
		if "direction" in proj:
			proj.direction = direction
			proj.rotation = direction.angle()
		
		get_tree().root.add_child(proj)
		
		# Effetto saltello (Feedback visivo)
		var tween = create_tween()
		tween.tween_property(sprite, "position:y", -30.0, 0.1)
		tween.tween_property(sprite, "position:y", -20.0, 0.1) # Torna alla posizione seduta (-20 circa)

	# Aspetta che il timer finisca
	await timer.timeout
	can_shoot = true
