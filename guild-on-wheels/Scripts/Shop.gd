extends Panel

# Costi dei potenziamenti
var cost_damage = 50
var cost_heal = 30
var cost_speed = 100

# Riferimenti
@onready var caravan = null

# Riferimenti ai bottoni nel VBoxContainer
@onready var btn_damage = $VBoxContainer/Btn_Damage
@onready var btn_heal = $VBoxContainer/Btn_Heal
@onready var btn_speed = $VBoxContainer/Btn_Speed
# (Opzionale) Se hai una label per l'oro nel negozio, aggiungila qui:
# @onready var lbl_gold = $GoldLabel 

func _ready():
	visible = false # Chiudi il negozio all'avvio
	
	# Cerchiamo la Carovana in modo sicuro
	await get_tree().process_frame # Aspetta un attimo che tutto carichi
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		caravan = players[0]
	else:
		# Fallback se non è nel gruppo
		if get_tree().root.has_node("World/Caravan"):
			caravan = get_tree().root.get_node("World/Caravan")

func open_shop():
	print("HAI CLICCATO IL NEGOZIO!")
	visible = true
	get_tree().paused = true # PAUSA IL GIOCO
	update_buttons_text()

func _on_btn_close_pressed():
	visible = false
	get_tree().paused = false # RIATTIVA IL GIOCO

func update_buttons_text():
	# Aggiorniamo i testi dei bottoni
	btn_damage.text = "Spada (+5 Danno) - " + str(cost_damage) + " Oro"
	btn_heal.text = "Ripara (+20 HP) - " + str(cost_heal) + " Oro"
	btn_speed.text = "Fuoco Rapido - " + str(cost_speed) + " Oro"
	
	# Se vuoi vedere l'oro aggiornato:
	# if lbl_gold and caravan:
	# 	lbl_gold.text = "Tuo Oro: " + str(caravan.gold)

# --- FUNZIONI DI ACQUISTO ---

func _on_btn_damage_pressed():
	if caravan and caravan.gold >= cost_damage:
		# PAGAMENTO DIRETTO (Senza usare add_gold per non toccare la Banca)
		caravan.gold -= cost_damage 
		
		# Effetto
		caravan.damage += 5
		print("Danno potenziato a: ", caravan.damage)
		
		# Aumenta prezzo e aggiorna UI
		cost_damage += 25
		
		# Aggiorniamo anche la scritta dell'oro nella UI principale
		if caravan.gold_label:
			caravan.gold_label.text = "Oro: " + str(caravan.gold)
			
		update_buttons_text()
	else:
		print("Non hai abbastanza oro!")

func _on_btn_heal_pressed():
	if caravan and caravan.gold >= cost_heal:
		if caravan.current_hp < caravan.max_hp:
			caravan.gold -= cost_heal
			caravan.current_hp += 20
			
			if caravan.current_hp > caravan.max_hp:
				caravan.current_hp = caravan.max_hp
			
			# Aggiorna barra vita
			if caravan.health_bar:
				caravan.health_bar.value = caravan.current_hp
			
			if caravan.gold_label:
				caravan.gold_label.text = "Oro: " + str(caravan.gold)
				
			print("Carovana riparata!")
			update_buttons_text()

func _on_btn_speed_pressed():
	if caravan and caravan.gold >= cost_speed:
		# Controllo Timer (Se esiste e non è troppo veloce)
		if caravan.has_node("Timer"):
			var timer = caravan.get_node("Timer")
			if timer.wait_time > 0.1:
				caravan.gold -= cost_speed
				timer.wait_time -= 0.1
				
				cost_speed += 50
				
				if caravan.gold_label:
					caravan.gold_label.text = "Oro: " + str(caravan.gold)
					
				update_buttons_text()
				print("Velocità aumentata!")
