extends Node2D

# --- CONFIGURAZIONE ---
@export_group("Settings")
@export var wave_config: WaveConfig # <--- Qui trascini la tua risorsa .tres
@export var enemy_scenes: Array[PackedScene]

# --- STATO INTERNO ---
var current_wave: int = 1
var enemies_to_spawn: int = 0
var enemies_alive: int = 0
var caravan = null

# --- RIFERIMENTI NODI ---
@onready var spawn_timer = $SpawnTimer
@onready var spawn_point = $SpawnPoint
@onready var wave_label = $CanvasLayer/WaveLabel
@onready var btn_start_wave = $CanvasLayer/BtnStartWave

func _ready():
	# Trova il giocatore (Caravan)
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		caravan = players[0]
	else:
		printerr("⚠️ WORLD: Nessun nodo nel gruppo 'Player' trovato!")
	
	# Setup Iniziale UI
	spawn_timer.stop()
	btn_start_wave.visible = true
	btn_start_wave.text = "INIZIA ONDATA 1"
	
	# Verifica sicurezza configurazione
	if not wave_config:
		printerr("🔴 ERRORE CRITICO: WaveConfig non assegnato in World! Il gioco non funzionerà correttamente.")
	if enemy_scenes.is_empty():
		printerr("🔴 ERRORE CRITICO: Nessuna scena nemico assegnata in World!")

	GameManager.change_state(GameManager.GameState.EVENT)
	update_ui()

func start_next_wave():
	# Controllo di sicurezza
	if not wave_config: return

	# 1. Cambio Stato
	GameManager.change_state(GameManager.GameState.COMBAT)
	btn_start_wave.visible = false
	
	# 2. CALCOLO NEMICI (Dalla Risorsa WaveConfig)
	enemies_to_spawn = wave_config.get_enemy_count(current_wave)
	enemies_alive = enemies_to_spawn
	
	# 3. CALCOLO VELOCITÀ SPAWN (Dalla Risorsa WaveConfig)
	var new_wait_time = wave_config.get_spawn_wait_time(current_wave)
	spawn_timer.wait_time = new_wait_time
	spawn_timer.start()
	
	update_ui()
	print("⚔️ ONDATA ", current_wave, " | Nemici: ", enemies_to_spawn, " | Rateo: ", snapped(new_wait_time, 0.01), "s")

func _on_spawn_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		# Se abbiamo finito di spawnare, fermiamo il timer
		if enemies_to_spawn <= 0:
			spawn_timer.stop()
	update_ui()

func spawn_enemy():
	if enemy_scenes.is_empty() or not caravan: return

	# 1. Istanziazione
	var random_scene = enemy_scenes.pick_random()
	var enemy = random_scene.instantiate()
	if "target_caravan" in enemy:
		enemy.target_caravan = caravan
	# 2. APPLICAZIONE POTENZIAMENTI (Data Driven)
	if wave_config:
		# Calcoliamo la posizione sulla curva (da 0.0 a 1.0)
		var normalized_wave = float(current_wave) / wave_config.max_wave_cap
		var hp_mult = wave_config.health_multiplier_curve.sample(min(normalized_wave, 1.0))
		
		# Applichiamo HP
		if "hp" in enemy:
			# Moltiplichiamo HP base * moltiplicatore curva (es. 10 * 2.5 = 25)
			# Nota: Aggiungiamo un moltiplicatore base hardcap (es. x5) se la curva va da 0 a 1
			# Oppure assumiamo che la curva restituisca direttamente il moltiplicatore (es. Y=1 a Y=10)
			enemy.hp = int(enemy.hp * hp_mult)
			
			# Visual Feedback: Più sono forti, più sono grossi (opzionale)
			var scale_mod = 1.0 + ((hp_mult - 1.0) * 0.2) # Crescita controllata
			enemy.scale = Vector2(scale_mod, scale_mod)

	# 3. Posizionamento
	# Usiamo global_position per evitare problemi con nodi annidati
	var spawn_x = caravan.global_position.x + 1000 # 1000px a destra del player
	var spawn_y = spawn_point.global_position.y  # Altezza definita dallo spawn point
	
	enemy.global_position = Vector2(spawn_x, spawn_y)
	
	# 4. Connessione segnali
	# Usiamo connect con il flag CONNECT_ONE_SHOT per sicurezza, anche se tree_exited lo è quasi sempre
	enemy.tree_exited.connect(_on_enemy_died)
	
	add_child(enemy)

func _on_enemy_died():
	# Decrementiamo solo se c'erano nemici vivi contati
	if enemies_alive > 0:
		enemies_alive -= 1
		update_ui()
		
		if enemies_alive <= 0:
			call_deferred("wave_completed") # call_deferred evita problemi se l'ultimo nemico muore durante calcoli fisici

func wave_completed():
	print("✅ ONDATA ", current_wave, " COMPLETATA!")
	
	# Ricompensa Soldi
	# TODO: Anche questo potrebbe essere spostato in WaveConfig in futuro!
	var reward = 100 + (current_wave * 25)
	GameManager.add_money(reward)
	
	GameManager.change_state(GameManager.GameState.EVENT)
	
	current_wave += 1
	btn_start_wave.text = "INIZIA ONDATA " + str(current_wave)
	btn_start_wave.visible = true

func update_ui():
	if wave_label:
		wave_label.text = "Ondata: %d | Nemici rimasti: %d" % [current_wave, enemies_alive]

func _on_btn_start_wave_pressed():
	start_next_wave()
