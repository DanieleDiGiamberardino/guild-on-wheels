extends Node

# --- STATI E SEGNALI ---
enum GameState { TRAVEL, COMBAT, CAMP, EVENT, GAME_OVER }

signal game_over_triggered
signal state_changed(new_state)
signal cart_updated(current_health, max_health)
signal gold_updated(current_gold)

# --- VARIABILI GLOBALI ---
var current_state: GameState = GameState.TRAVEL
var cart_data: CartData

# --- DATI DA SALVARE (Banca e Livelli Gilda) ---
var permanent_gold: int = 0
var guild_level_damage: int = 0
var guild_level_health: int = 0
var guild_level_speed: int = 0

# --- DATI SESSIONE (Temporanei) ---
var session_gold: int = 0

func _ready():
	_setup_test_data()
	# 1. APPENA IL GIOCO PARTE, CARICHIAMO I DATI!
	load_game()
	print("✅ GameManager Attivo. Banca caricata: ", permanent_gold)

# --- SISTEMA DI SALVATAGGIO (FILE SYSTEM) ---

func save_game():
	var save_data = {
		"gold": permanent_gold,
		"lvl_dmg": guild_level_damage,
		"lvl_hp": guild_level_health,
		"lvl_spd": guild_level_speed
	}
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_var(save_data)
	print("💾 Partita salvata correttamente!")

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Nessun salvataggio esistente
	
	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var data = file.get_var()
	
	# Ripristiniamo i valori salvati
	permanent_gold = data.get("gold", 0)
	guild_level_damage = data.get("lvl_dmg", 0)
	guild_level_health = data.get("lvl_hp", 0)
	guild_level_speed = data.get("lvl_spd", 0)
	print("📂 Dati caricati: ", data)

# --- GESTIONE PARTITA E BILANCIAMENTO ---

func start_new_run():
	session_gold = 0
	current_state = GameState.EVENT
	
	if cart_data:
		cart_data.initialize() # Reset base
		
		# --- BILANCIAMENTO POWER-UP (Qui applichiamo i livelli salvati!) ---
		
		# Danno: +12 per livello (Molto forte per compensare i nemici)
		cart_data.damage += (guild_level_damage * 12)
		
		# Vita: +30 per livello
		cart_data.max_health += (guild_level_health * 30)
		cart_data.current_health = cart_data.max_health
		
		# Velocità: Spara più veloce ogni livello
		var speed_bonus = (guild_level_speed * 0.1)
		cart_data.fire_rate = max(0.15, cart_data.fire_rate - speed_bonus)
		
	print("💪 Nuova run avviata con potenziamenti Gilda!")

func game_over():
	if current_state == GameState.GAME_OVER: return
	print("💀 GAME OVER")
	current_state = GameState.GAME_OVER
	session_gold = 0 # Perdi l'oro della sessione
	# Non salviamo qui perché non è cambiato nulla nella banca
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Home.tscn")

func secure_gold():
	# Chiama questa funzione quando finisci un livello VIVO
	permanent_gold += session_gold
	session_gold = 0
	save_game() # SALVIAMO I SOLDI GUADAGNATI!
	print("🏦 Oro al sicuro.")

# --- UTILITY ---
func _setup_test_data():
	cart_data = CartData.new()
	cart_data.initialize()

func change_state(new_state):
	current_state = new_state
	emit_signal("state_changed", new_state)

func damage_cart(amount):
	if cart_data:
		cart_data.current_health -= amount
		emit_signal("cart_updated", cart_data.current_health, cart_data.max_health)
		if cart_data.current_health <= 0:
			game_over()

func add_money(amount):
	session_gold += amount
	emit_signal("gold_updated", session_gold)
