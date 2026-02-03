extends Node2D

# --- CONFIGURAZIONE ONDATE ---
var current_wave = 1
var enemies_to_spawn = 5
var enemies_alive = 0

# Riferimenti
@export var enemy_scenes: Array[PackedScene]
@onready var spawn_timer = $SpawnTimer
@onready var spawn_point = $SpawnPoint

# Cerchiamo la carovana in modo dinamico (più sicuro)
var caravan = null

# UI
@onready var wave_label = $CanvasLayer/WaveLabel
@onready var btn_start_wave = $CanvasLayer/BtnStartWave

func _ready():
	# Troviamo la carovana nel gruppo Player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		caravan = players[0]
	
	spawn_timer.stop()
	btn_start_wave.visible = true
	btn_start_wave.text = "INIZIA ONDATA 1"
	
	# Assicuriamoci che il gioco parta in stato di "Attesa"
	GameManager.change_state(GameManager.GameState.EVENT)
	update_ui()

# --- GESTIONE ONDATA ---

func start_next_wave():
	# 1. NUOVO: Diciamo al Manager che inizia la guerra!
	GameManager.change_state(GameManager.GameState.COMBAT)
	
	btn_start_wave.visible = false
	
	# Calcola difficoltà
	enemies_to_spawn = 3 + (current_wave * 2)
	enemies_alive = enemies_to_spawn
	
	# Velocizza lo spawn
	var new_wait_time = 2.0 - (current_wave * 0.1)
	if new_wait_time < 0.5: new_wait_time = 0.5
	spawn_timer.wait_time = new_wait_time
	spawn_timer.start()
	
	update_ui()
	print("⚔️ ONDATA ", current_wave, " INIZIATA!")

func _on_spawn_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		update_ui()
	else:
		spawn_timer.stop()

func spawn_enemy():
# CONTROLLO SICUREZZA
	if enemy_scenes.size() == 0:
		print("❌ ERRORE: Nessun nemico nell'array 'enemy_scenes'!")
		return

	# 1. PESCA UN NEMICO A CASO
	var random_scene = enemy_scenes.pick_random()
	var enemy = random_scene.instantiate()
	
	# 2. POSIZIONAMENTO (Uguale a prima)
	var spawn_x = caravan.global_position.x + 1000
	var spawn_y = spawn_point.global_position.y
	
	enemy.global_position = Vector2(spawn_x, spawn_y)
	
	# Importante: collegare la morte per contare l'ondata
	enemy.tree_exited.connect(_on_enemy_died)
	
	add_child(enemy)

func _on_enemy_died():
	# Importante: controlliamo se il gioco è ancora attivo
	if enemies_alive > 0:
		enemies_alive -= 1
		update_ui()
		
		if enemies_alive <= 0:
			wave_completed()

func wave_completed():
	print("✅ ONDATA ", current_wave, " COMPLETATA!")
	
	# 2. NUOVO: Bonus Oro direttamente nella Banca
	GameManager.add_money(50 + (current_wave * 10))
	print("💰 Bonus Ondata incassato!")
	
	# 3. NUOVO: L'ondata è finita, apriamo il Negozio o torniamo a viaggiare?
	# Per ora torniamo in stato EVENT (fermi) aspettando il click
	GameManager.change_state(GameManager.GameState.EVENT) # O TRAVEL se vuoi che riparta
	
	current_wave += 1
	btn_start_wave.text = "INIZIA ONDATA " + str(current_wave)
	btn_start_wave.visible = true

func update_ui():
	if wave_label:
		wave_label.text = "Ondata " + str(current_wave) + " - Nemici: " + str(enemies_alive)

func _on_btn_start_wave_pressed():
	start_next_wave()
