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
	
	# 2. Calcoliamo la X (avanti alla carovana)
	var random_distance = randf_range(0, 50)
	var spawn_x = caravan.position.x + 400 + random_distance
	
	# 3. Calcoliamo la Y (FISSA SUL PAVIMENTO)
	# IMPORTANTE: Cambia '300.0' con l'altezza Y del tuo Pavimento!
	# Guarda nell'Inspector del nodo 'Pavimento' o 'CollisionShape2D' qual è la Position Y.
	var spawn_y = caravan.position.y 
	
	# 4. Assegniamo la posizione finale
	new_goblin.position = Vector2(spawn_x, spawn_y)
	
	# 5. Aggiungiamo il goblin al mondo
	add_child(new_goblin)
	
	print("Nuovo mostro generato a terra!")
