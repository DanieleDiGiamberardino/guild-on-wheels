extends Node2D

# --- CONFIGURAZIONE ONDATE ---
var current_wave = 1
var enemies_to_spawn = 5 # Quanti ne nascono in totale questa ondata
var enemies_alive = 0    # Quanti sono vivi ora nel mondo

# Riferimenti
@onready var goblin_scene = preload("res://Scenes/Goblin.tscn")
@onready var spawn_timer = $SpawnTimer # Assicurati che il nodo Timer si chiami così
@onready var caravan = $Caravan        # Assicurati che il nodo Caravan si chiami così
@onready var spawn_point = $SpawnPoint # Un Node2D o Marker2D dove iniziano a spawnare

# UI
@onready var wave_label = $CanvasLayer/WaveLabel
@onready var btn_start_wave = $CanvasLayer/BtnStartWave

func _ready():
	# All'avvio, fermiamo tutto. Il giocatore deve cliccare "Inizia".
	spawn_timer.stop()
	btn_start_wave.visible = true
	btn_start_wave.text = "INIZIA ONDATA 1"
	update_ui()

# --- GESTIONE ONDATA ---

func start_next_wave():
	# Nascondi il bottone
	btn_start_wave.visible = false
	
	# Calcola difficoltà (Esempio: 2 goblin in più ogni ondata)
	enemies_to_spawn = 3 + (current_wave * 2)
	enemies_alive = enemies_to_spawn
	
	# Velocizza lo spawn ogni ondata (minimo 0.5 secondi)
	var new_wait_time = 2.0 - (current_wave * 0.1)
	if new_wait_time < 0.5: new_wait_time = 0.5
	spawn_timer.wait_time = new_wait_time
	spawn_timer.start()
	
	update_ui()
	print("Ondata ", current_wave, " iniziata! Nemici: ", enemies_to_spawn)

func _on_spawn_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		update_ui()
	else:
		# Abbiamo finito di generare nemici per questa ondata
		spawn_timer.stop()

func spawn_enemy():
	if not is_instance_valid(caravan): return

	var goblin = goblin_scene.instantiate()
	
	# Spawn 1000px davanti alla carovana
	var spawn_x = caravan.global_position.x + 1000
	# La Y la prendiamo dal punto di spawn originale (o fissa a terra)
	var spawn_y = spawn_point.global_position.y 
	
	goblin.global_position = Vector2(spawn_x, spawn_y)
	
	# --- PUNTO CRUCIALE: COLLEGAMENTO MORTE ---
	# Diciamo al Goblin: "Quando muori (tree_exited), avvisa World!"
	goblin.tree_exited.connect(_on_enemy_died)
	
	add_child(goblin)

func _on_enemy_died():
	# Questa funzione scatta quando un Goblin sparisce (queue_free)
	enemies_alive -= 1
	update_ui()
	
	if enemies_alive <= 0:
		wave_completed()

func wave_completed():
	print("Ondata ", current_wave, " COMPLETATA!")
	current_wave += 1
	
	# Mostra il bottone per la prossima
	btn_start_wave.text = "INIZIA ONDATA " + str(current_wave)
	btn_start_wave.visible = true
	
	# (Opzionale) Dai un bonus di oro alla carovana per aver vinto l'ondata
	if is_instance_valid(caravan):
		caravan.add_gold(50) 
		print("Bonus ondata: +50 Oro")

func update_ui():
	# Aggiorna la scritta in alto
	if wave_label:
		# Se stiamo ancora spawnando, mostriamo il totale, altrimenti quelli rimasti vivi
		wave_label.text = "Ondata " + str(current_wave) + " - Nemici vivi: " + str(enemies_alive)

# --- COLLEGAMENTO BOTTONE START ---
# Ricordati di collegare il segnale pressed del bottone a questa funzione!
func _on_btn_start_wave_pressed():
	start_next_wave()
