extends Panel

# Costi dei potenziamenti (puoi bilanciarli qui)
var cost_damage = 50
var cost_heal = 30
var cost_speed = 100

# Riferimenti ai bottoni (Assicurati che i nomi nel VBoxContainer siano giusti!)
@onready var btn_damage = $VBoxContainer/Btn_Damage
@onready var btn_heal = $VBoxContainer/Btn_Heal
@onready var btn_speed = $VBoxContainer/Btn_Speed
@onready var lbl_gold = $VBoxContainer/GoldInfo # Se hai una label nel negozio, altrimenti rimuovi

func _ready():
	visible = false # Nascondi all'avvio

func open_shop():
	print("🏪 BENVENUTO NEL NEGOZIO!")
	visible = true
	get_tree().paused = true # Blocca il gioco
	
	# Aggiorna i testi con i prezzi attuali
	update_ui()

func close_shop():
	visible = false
	get_tree().paused = false # Riprendi il gioco

func _on_btn_close_pressed():
	close_shop()

func update_ui():
	# Leggiamo i dati dal Manager
	var data = GameManager.cart_data
	
	btn_damage.text = "Spada (+10 Danno) - " + str(cost_damage) + " Oro"
	btn_heal.text = "Ripara (+30 HP) - " + str(cost_heal) + " Oro"
	btn_speed.text = "Fuoco Rapido (-0.1s) - " + str(cost_speed) + " Oro"
	
	if lbl_gold:
		lbl_gold.text = "Tuo Oro: " + str(GameManager.session_gold)

# --- LOGICA ACQUISTI ---

func _on_btn_damage_pressed():
	# Chiediamo al Manager: "Posso spendere questi soldi?"
	if GameManager.spend_gold(cost_damage):
		# Se sì, potenziamo i dati
		GameManager.cart_data.damage += 10
		cost_damage += 25 # Inflazione! Il prossimo costa di più
		update_ui()
		print("⚔️ Danno potenziato a: ", GameManager.cart_data.damage)
	else:
		print("❌ Non hai abbastanza oro!")

func _on_btn_heal_pressed():
	# Controllo se serve curare
	if GameManager.cart_data.current_health >= GameManager.cart_data.max_health:
		print("La carovana è già nuova di zecca!")
		return

	if GameManager.spend_gold(cost_heal):
		GameManager.heal_cart(30) # Cura 30 HP
		update_ui()
		print("💖 Carovana riparata!")

func _on_btn_speed_pressed():
	var data = GameManager.cart_data
	
	# Limite massimo di velocità (per non rompere il gioco)
	if data.fire_rate <= 0.2:
		print("Sei già alla velocità massima!")
		return

	if GameManager.spend_gold(cost_speed):
		data.fire_rate -= 0.1 # Spara più veloce
		cost_speed += 50
		update_ui()
		print("⚡ Velocità di fuoco aumentata a: ", data.fire_rate)
