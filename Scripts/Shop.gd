extends Panel

# Costi dei potenziamenti
var cost_damage = 50
var cost_heal = 30
var cost_speed = 100

# Riferimento alla Carovana (Lo cerchiamo nel mondo)
@onready var caravan = get_tree().get_first_node_in_group("Player")

# Riferimenti ai bottoni (per aggiornare i testi)
@onready var btn_damage = $VBoxContainer/Btn_Damage
@onready var btn_heal = $VBoxContainer/Btn_Heal
@onready var btn_speed = $VBoxContainer/Btn_Speed

func _ready():
	# Assicuriamoci che il negozio sia chiuso all'avvio
	visible = false
	
	# Se non hai messo la Carovana nel gruppo "Player", fallo ora!
	# Altrimenti cercala col percorso classico:
	if caravan == null:
		caravan = get_node("/root/World/Caravan")

func update_buttons_text():
	# Aggiorna i testi con i prezzi attuali (inflazione!)
	btn_damage.text = "Spada (+5 Danno) - " + str(cost_damage) + " Oro"
	btn_heal.text = "Ripara (+20 HP) - " + str(cost_heal) + " Oro"
	btn_speed.text = "Fuoco Rapido - " + str(cost_speed) + " Oro"

# --- FUNZIONI DI ACQUISTO ---

func _on_btn_damage_pressed():
	if caravan.gold >= cost_damage:
		caravan.add_gold(-cost_damage) # Paghiamo (numero negativo)
		caravan.damage += 5
		print("Danno potenziato!")
		
		# Aumenta il prezzo per la prossima volta
		cost_damage += 25
		update_buttons_text()

func _on_btn_heal_pressed():
	if caravan.gold >= cost_heal:
		# Non curiamo se è già al massimo
		if caravan.current_hp < caravan.max_hp:
			caravan.add_gold(-cost_heal)
			caravan.current_hp += 20
			# Limitiamo la vita al massimo (clamp)
			if caravan.current_hp > caravan.max_hp:
				caravan.current_hp = caravan.max_hp
			
			# Aggiorniamo la barra della vita della carovana
			caravan.health_bar.value = caravan.current_hp
			print("Carovana riparata!")

func _on_btn_speed_pressed():
	# Esempio: riduciamo il tempo del timer della carovana
	if caravan.gold >= cost_speed:
		caravan.add_gold(-cost_speed)
		
		# Accediamo al Timer della carovana e riduciamo il wait_time
		var timer = caravan.get_node("Timer")
		if timer.wait_time > 0.1: # Limite massimo di velocità
			timer.wait_time -= 0.1
			print("Velocità di fuoco aumentata!")
			
			cost_speed += 50
			update_buttons_text()

# --- APRI E CHIUDI ---

func _on_btn_close_pressed():
	visible = false
	get_tree().paused = false # Riprendi il gioco

func open_shop():
	print("HAI CLICCATO IL NEGOZIO!") # <--- Aggiungi questo!
	visible = true
	update_buttons_text() # Aggiorna i prezzi prima di mostrare
	get_tree().paused = true # Mette in PAUSA il gioco mentre compri!


func _on_btn_open_shop_pressed() -> void:
	pass # Replace with function body.
