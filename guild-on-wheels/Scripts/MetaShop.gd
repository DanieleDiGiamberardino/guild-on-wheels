extends Panel

# Riferimenti ai bottoni (devono chiamarsi così nella scena Home!)
@onready var btn_damage = $VBoxContainer/Btn_Damage
@onready var btn_health = $VBoxContainer/Btn_Heal # Riusiamo il bottone "Heal" per "Max HP"
@onready var btn_speed = $VBoxContainer/Btn_Speed
@onready var lbl_gold = $VBoxContainer/GoldInfo

# Prezzi Base
var base_cost = 100

func _ready():
	visible = false # Chiuso all'inizio

func open_shop():
	visible = true
	update_ui()
	# Nella Home non serve mettere in pausa il gioco, è già fermo!

func close_shop():
	visible = false

func _on_btn_close_pressed():
	close_shop()

func update_ui():
	# Calcoliamo i costi in base al livello attuale (es. Livello 2 costa 200)
	var cost_dmg = (GameManager.guild_level_damage + 1) * base_cost
	var cost_hp = (GameManager.guild_level_health + 1) * base_cost
	var cost_spd = (GameManager.guild_level_speed + 1) * base_cost
	
	# Aggiorniamo i testi
	btn_damage.text = "Potenzia Spade (Lv " + str(GameManager.guild_level_damage) + ") - " + str(cost_dmg) + " Oro"
	btn_health.text = "Rinforza Carro (Lv " + str(GameManager.guild_level_health) + ") - " + str(cost_hp) + " Oro"
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
		# Aggiorniamo anche la label della banca nella Home
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
