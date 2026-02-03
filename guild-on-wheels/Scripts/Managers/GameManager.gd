extends Node

# --- STATI DEL GIOCO ---
enum GameState { TRAVEL, COMBAT, CAMP, EVENT, GAME_OVER }

# --- SEGNALI (Notifiche per la UI) ---
signal game_over_triggered
signal state_changed(new_state)
signal cart_updated(current_health, max_health)
signal gold_updated(current_gold) # Nuovo segnale per aggiornare le etichette dell'oro

# --- VARIABILI GLOBALI ---
var current_state: GameState = GameState.TRAVEL
var cart_data: CartData

# --- LA TUA BANCA (Integrata qui) ---
# permanent_gold: I soldi al sicuro in banca (per gli upgrade permanenti)
var permanent_gold: int = 0
# session_gold: I soldi raccolti DURANTE la missione attuale (che perdi se muori)
var session_gold: int = 0

func _ready():
	_setup_test_data()
	print("✅ GameManager Attivo. Banca caricata: ", permanent_gold)

# --- FUNZIONI DI GESTIONE STATI ---
func change_state(new_state: GameState):
	if current_state == new_state: return
	current_state = new_state
	emit_signal("state_changed", new_state)

func damage_cart(amount: int):
	if cart_data:
		cart_data.current_health -= amount
		emit_signal("cart_updated", cart_data.current_health, cart_data.max_health)
		if cart_data.current_health <= 0:
			game_over()

# --- LE TUE FUNZIONI PER L'ORO (Migliorate) ---
func add_money(amount: int):
	# Aggiungiamo ai soldi della sessione corrente
	session_gold += amount
	print("💰 Raccolto oro! Totale sessione: ", session_gold)
	emit_signal("gold_updated", session_gold)

func secure_gold():
	# Chiama questa funzione quando finisci una missione vivo
	permanent_gold += session_gold
	session_gold = 0
	print("🏦 Oro messo in banca! Totale salvato: ", permanent_gold)
	# Qui in futuro chiameremo save_game()

func game_over():
	if current_state == GameState.GAME_OVER: return
	
	print("💀 CAROVANA DISTRUTTA! La missione è fallita.")
	current_state = GameState.GAME_OVER
	
	# (Opzionale) Qui potresti decidere se l'oro raccolto viene perso o salvato.
	# Per ora lo perdiamo (roguelike cattivo):
	session_gold = 0
	
	# Creiamo un piccolo ritardo di 2 secondi così il giocatore vede che è morto
	# IMPORTANTE: Usiamo create_timer invece di mettere in pausa il gioco
	await get_tree().create_timer(2.0).timeout
	
	# Ora torniamo alla base (Home)
	print("🏠 Ritorno alla Gilda...")
	get_tree().change_scene_to_file("res://Scenes/Home.tscn")

# --- SETUP DI PROVA ---
func _setup_test_data():
	cart_data = CartData.new()
	cart_data.initialize()
# --- FUNZIONI PER IL NEGOZIO ---

# Restituisce true se l'acquisto va a buon fine, false se non hai soldi
func spend_gold(amount: int) -> bool:
	if session_gold >= amount:
		session_gold -= amount
		emit_signal("gold_updated", session_gold)
		return true
	return false

func heal_cart(amount: int):
	if cart_data:
		cart_data.current_health += amount
		# Non superiamo mai la vita massima
		if cart_data.current_health > cart_data.max_health:
			cart_data.current_health = cart_data.max_health
		
		# Avvisiamo la UI che la vita è cambiata
		emit_signal("cart_updated", cart_data.current_health, cart_data.max_health)
# Incolla questo in fondo a GameManager.gd se non c'è già
func start_new_run():
	session_gold = 0
	current_state = GameState.EVENT # Parte ferma in attesa dell'ondata
	
	if cart_data:
		cart_data.initialize() # HP al massimo
	
	print("🔄 Nuova run inizializzata!")
