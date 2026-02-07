extends Node2D

# --- CONFIGURAZIONE ONDATE ---
var current_wave = 1
var enemies_to_spawn = 5
var enemies_alive = 0

# Riferimenti
@export var enemy_scenes: Array[PackedScene]
@onready var spawn_timer = $SpawnTimer
@onready var spawn_point = $SpawnPoint

# Cerchiamo la carovana in modo dinamico
var caravan = null

# UI
@onready var wave_label = $CanvasLayer/WaveLabel
@onready var btn_start_wave = $CanvasLayer/BtnStartWave

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		caravan = players[0]
	
	spawn_timer.stop()
	btn_start_wave.visible = true
	btn_start_wave.text = "INIZIA ONDATA 1"
	
	GameManager.change_state(GameManager.GameState.EVENT)
	update_ui()

# --- GESTIONE ONDATA HARDCORE ---

func start_next_wave():
	# 1. Stato COMBAT
	GameManager.change_state(GameManager.GameState.COMBAT)
	
	btn_start_wave.visible = false
	
	# --- MODIFICA DIFFICOLTÀ: IL MACELLO ---
	# Prima: 3 + (Ondata * 2). Esempio Ondata 5 = 13 nemici
	# ORA: 10 + (Ondata * 5). Esempio Ondata 5 = 35 nemici! 
	enemies_to_spawn = 10 + (current_wave * 5)
	enemies_alive = enemies_to_spawn
	
	# --- MODIFICA VELOCITÀ: MITRAGLIATRICE ---
	# Riduciamo il tempo drasticamente ogni ondata
	# Ondata 1: 1.5s
	# Ondata 5: 0.7s (Spawnano come pazzi)
	var new_wait_time = 1.7 - (current_wave * 0.2)
	
	# Cap minimo molto basso (0.25s è velocissimo)
	if new_wait_time < 0.25: new_wait_time = 0.25
	
	spawn_timer.wait_time = new_wait_time
	spawn_timer.start()
	
	update_ui()
	print("⚔️ ONDATA ESTREMA ", current_wave, " INIZIATA! Nemici: ", enemies_to_spawn, " Rateo: ", new_wait_time)

func _on_spawn_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		update_ui()
	else:
		spawn_timer.stop()

func spawn_enemy():
	if enemy_scenes.size() == 0: return

	# 1. Crea il nemico base
	var random_scene = enemy_scenes.pick_random()
	var enemy = random_scene.instantiate()
	
	# --- NUOVO: POTENZIAMENTO DINAMICO ---
	# Calcoliamo un moltiplicatore: 
	# Ondata 1 = 1.0 (Normale)
	# Ondata 5 = 2.0 (Doppia Vita)
	# Ondata 10 = 3.25 (Tripla Vita!)
	var multiplier = 1.0 + (current_wave * 0.25)
	
	# Controlliamo se il nemico ha la variabile "hp" per evitare errori
	if "hp" in enemy:
		enemy.hp = int(enemy.hp * multiplier)
		# (Opzionale) Possiamo ingrandirli leggermente per far vedere che sono grossi
		enemy.scale = Vector2(1, 1) * (1.0 + (current_wave * 0.05))
		
	# -------------------------------------
	
	# 2. Posizionamento (uguale a prima)
	var spawn_x = caravan.global_position.x + 1000
	var spawn_y = spawn_point.global_position.y
	
	enemy.global_position = Vector2(spawn_x, spawn_y)
	enemy.tree_exited.connect(_on_enemy_died)
	
	add_child(enemy)

func _on_enemy_died():
	if enemies_alive > 0:
		enemies_alive -= 1
		update_ui()
		
		if enemies_alive <= 0:
			wave_completed()

func wave_completed():
	print("✅ ONDATA ", current_wave, " SOPRAVVISSUTA!")
	
	# Aumentiamo anche la ricompensa, altrimenti è impossibile potenziarsi abbastanza!
	# Prima: 50 + (wave * 10)
	# Ora: 100 + (wave * 25) -> Più soldi per comprare danni nel negozio
	var reward = 100 + (current_wave * 25)
	GameManager.add_money(reward)
	print("💰 Ricompensa massiccia incassata: ", reward)
	
	GameManager.change_state(GameManager.GameState.EVENT) 
	
	current_wave += 1
	btn_start_wave.text = "INIZIA ONDATA " + str(current_wave)
	btn_start_wave.visible = true

func update_ui():
	if wave_label:
		wave_label.text = "Ondata " + str(current_wave) + " - Nemici: " + str(enemies_alive)

func _on_btn_start_wave_pressed():
	start_next_wave()
