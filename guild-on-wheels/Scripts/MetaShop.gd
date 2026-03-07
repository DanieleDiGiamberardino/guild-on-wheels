extends Panel

# --- SEGNALE PER LA HOME ---
signal shop_closed # <--- Avvisa quando lo shop si chiude per ridare il focus

# Riferimenti ai bottoni (devono chiamarsi così nella scena Home!)
@onready var btn_damage = $VBoxContainer/Btn_Damage
@onready var btn_health = $VBoxContainer/Btn_Heal # Riusiamo il bottone "Heal" per "Max HP"
@onready var btn_speed = $VBoxContainer/Btn_Speed
@onready var lbl_gold = $VBoxContainer/GoldInfo

# Prezzi Base
var base_cost = 100

func _ready():
	visible = false # Chiuso all'inizio

# --- GESTIONE INPUT (Tasto B / ESC) ---
func _unhandled_input(event):
	# Se lo shop è chiuso, ignoriamo l'input
	if not visible:
		return
		
	# Se premo ESC o B (Xbox) o Cerchio (PlayStation)
	if event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled() # Blocchiamo l'input qui

func open_shop():
	visible = true
	update_ui()
	
	# --- FOCUS AUTOMATICO ---
	# Appena apre, diamo il focus al primo bottone (Danno)
	# Così il giocatore può muoversi subito con le frecce/pad
	if btn_damage:
		btn_damage.grab_focus()

func close_shop():
	visible = false
	# Avvisiamo la Home che abbiamo finito
	shop_closed.emit() 

func _on_btn_close_pressed():
	close_shop()

func update_ui():
	# Calcoliamo i costi in base al livello attuale
	var cost_dmg = (GameManager.guild_level_damage + 1) * base_cost
	var cost_hp = (GameManager.guild_level_health + 1) * base_cost
	var cost_spd = (GameManager.guild_level_speed + 1) * base_cost
	
	# Aggiorniamo i testi
	if btn_damage:
		btn_damage.text = "Potenzia Spade (Lv " + str(GameManager.guild_level_damage) + ") - " + str(cost_dmg) + " Oro"
	if btn_health:
		btn_health.text = "Rinforza Carro (Lv " + str(GameManager.guild_level_health) + ") - " + str(cost_hp) + " Oro"
	if btn_speed:
		btn_speed.text = "Addestra Arcieri (Lv " + str(GameManager.guild_level_speed) + ") - " + str(cost_spd) + " Oro"
	
	if lbl_gold:
		lbl_gold.text = "Tesoro Gilda: " + str(GameManager.permanent_gold)

# --- ACQUISTI ---

func _on_btn_damage_pressed():
	var price = (GameManager.guild_level_damage + 1) * base_cost
	if GameManager.permanent_gold >= price:
		GameManager.permanent_gold -= price
		GameManager.guild_level_damage += 1
		update_ui()
		# Aggiorniamo la UI della Home (banca)
		if get_parent().has_node("CanvasLayer/BankLabel"):
			get_parent().get_node("CanvasLayer/BankLabel").text = "Tesoro Gilda: " + str(GameManager.permanent_gold)
	GameManager.save_game()

func _on_btn_heal_pressed():
	# Nota: Questo aumenta la VITA MASSIMA, non cura!
	var price = (GameManager.guild_level_health + 1) * base_cost
	if GameManager.permanent_gold >= price:
		GameManager.permanent_gold -= price
		GameManager.guild_level_health += 1
		update_ui()
	GameManager.save_game()

func _on_btn_speed_pressed():
	var price = (GameManager.guild_level_speed + 1) * base_cost
	if GameManager.permanent_gold >= price:
		GameManager.permanent_gold -= price
		GameManager.guild_level_speed += 1
		update_ui()
	GameManager.save_game()
