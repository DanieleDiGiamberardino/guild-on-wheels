extends Panel

# --- COSTI E VARIABILI ---
var cost_damage = 50
var cost_heal = 30
var cost_speed = 100

# --- RIFERIMENTI UI ---
# (Assicurati che i nomi nel VBoxContainer siano giusti!)
@onready var btn_damage = $VBoxContainer/Btn_Damage
@onready var btn_heal = $VBoxContainer/Btn_Heal
@onready var btn_speed = $VBoxContainer/Btn_Speed
@onready var lbl_gold = $VBoxContainer/GoldInfo 

func _ready():
	visible = false # Nascondi all'avvio
	
	# 🎮 FONDAMENTALE PER LA PAUSA:
	# Impostiamo questo nodo su "Always" via codice.
	# Così, quando facciamo get_tree().paused = true, questo script CONTINUA a funzionare
	# e possiamo cliccare i bottoni o premere ESC per uscire.
	process_mode = Node.PROCESS_MODE_ALWAYS

# 🎮 GESTIONE INPUT (Tasto B / ESC)
func _unhandled_input(event):
	# Se lo shop è aperto e premiamo "Indietro"
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled() # Blocca l'input qui

func open_shop():
	print("🏪 BENVENUTO NEL NEGOZIO!")
	visible = true
	get_tree().paused = true # ⏸️ Blocca il mondo di gioco
	
	update_ui()
	
	# 🎮 FOCUS AUTOMATICO
	# Appena apre, diamo il focus al primo bottone (Danno)
	# Così puoi navigare subito col D-Pad o le frecce
	if btn_damage:
		btn_damage.grab_focus()

func close_shop():
	visible = false
	get_tree().paused = false # ▶️ Riprendi il gioco
	
	# 🎮 RILASCIO FOCUS
	# Importante: Quando chiudi lo shop mentre giochi, dobbiamo togliere il focus.
	# Altrimenti, se premi SPAZIO per saltare/sparare, potresti ri-attivare l'ultimo bottone premuto!
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()

func _on_btn_close_pressed():
	close_shop()

func update_ui():
	# Aggiornamento testi bottoni
	if btn_damage:
		btn_damage.text = "Spada (+10 Danno) - " + str(cost_damage) + " Oro"
	if btn_heal:
		btn_heal.text = "Ripara (+30 HP) - " + str(cost_heal) + " Oro"
	if btn_speed:
		btn_speed.text = "Fuoco Rapido (-0.1s) - " + str(cost_speed) + " Oro"
	
	# Aggiornamento label oro
	if lbl_gold:
		lbl_gold.text = "Tuo Oro: " + str(GameManager.session_gold)

# --- LOGICA ACQUISTI (La tua originale) ---

func _on_btn_damage_pressed():
	if GameManager.spend_gold(cost_damage):
		GameManager.cart_data.damage += 10
		cost_damage += 25 
		update_ui()
		print("⚔️ Danno potenziato a: ", GameManager.cart_data.damage)
	else:
		# Feedback sonoro opzionale qui
		print("❌ Non hai abbastanza oro!")

func _on_btn_heal_pressed():
	if GameManager.cart_data.current_health >= GameManager.cart_data.max_health:
		print("La carovana è già nuova di zecca!")
		return

	if GameManager.spend_gold(cost_heal):
		# NOTA: Assicurati che GameManager abbia la funzione heal_cart!
		# Se non ce l'ha, vedi sotto.
		if GameManager.has_method("heal_cart"):
			GameManager.heal_cart(30)
		else:
			# Fallback sicuro se manca la funzione
			var d = GameManager.cart_data
			d.current_health = min(d.current_health + 30, d.max_health)
			GameManager.emit_signal("cart_updated", d.current_health, d.max_health)
			
		update_ui()
		print("💖 Carovana riparata!")

func _on_btn_speed_pressed():
	var data = GameManager.cart_data
	if data.fire_rate <= 0.2:
		print("Sei già alla velocità massima!")
		return

	if GameManager.spend_gold(cost_speed):
		data.fire_rate -= 0.1 
		cost_speed += 50
		update_ui()
		print("⚡ Velocità di fuoco aumentata a: ", data.fire_rate)
