extends Node2D

# Carichiamo lo "stampino" del Goblin che hai appena salvato
var goblin_scene = preload("res://Scenes/Goblin.tscn")

# Riferimento alla carovana per sapere dove si trova
@onready var caravan = $Caravan

func _ready():
	# Creiamo un Timer via codice per generare nemici
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0 # Genera un nemico ogni 3 secondi
	timer.one_shot = false
	timer.connect("timeout", spawn_enemy) # Quando scatta, chiama spawn_enemy
	timer.start()

func spawn_enemy():
	# 1. Creiamo una copia del Goblin
	var new_goblin = goblin_scene.instantiate()
	
	# 2. Decidiamo dove metterlo: 
	# Prendiamo la posizione della carovana e aggiungiamo 400 pixel a destra
	# Più un po' di variazione casuale (tra 0 e 50 pixel extra)
	var random_distance = randf_range(0, 50)
	new_goblin.position = caravan.position + Vector2(400 + random_distance, 0)
	
	# 3. Aggiungiamo il goblin al mondo
	add_child(new_goblin)
	
	print("Nuovo mostro generato!")
