extends CharacterBody2D

@export var speed = 50.0
@export var damage = 10


# --- NUOVO: Gestione Oro ---
var gold = 0
var upgrade_cost = 50 # Quanto costa il primo livello
var fireball_scene = preload("res://Scenes/Fireball.tscn")
# ... sotto le altre variabili ...
var max_hp = 100
var current_hp = 100
@onready var health_bar = get_node("../CanvasLayer/HealthBar")
# Cerchiamo la Label uscendo dalla Carovana (..) ed entrando nel CanvasLayer
@onready var gold_label = get_node("../CanvasLayer/GoldLabel")

@onready var enemy_detector = $EnemyDetector
var current_target = null

func _physics_process(delta):
	update_target()
	
	if current_target != null:
		velocity = Vector2.ZERO
	else:
		velocity = Vector2.RIGHT * speed

	move_and_slide()

func update_target():
	var bodies = enemy_detector.get_overlapping_bodies()
	current_target = null
	
	for body in bodies:
		if body.is_in_group("Enemies"):
			current_target = body
			break

func _on_timer_timeout():
	# Se abbiamo un bersaglio nel mirino...
	if current_target != null:
		shoot_fireball()

func shoot_fireball():
	# 1. Creiamo il proiettile
	var ball = fireball_scene.instantiate()
	
	# 2. Lo posizioniamo dove siamo noi (global_position è importante!)
	ball.global_position = global_position
	
	# 3. Gli passiamo le nostre statistiche
	ball.damage = damage
	
	# 4. Lo aggiungiamo al MONDO, non alla carovana
	# (Se lo mettessimo nella carovana, si muoverebbe con noi. 
	# Mettendolo nel 'padre' (World), vola indipendente).
	get_parent().add_child(ball)
# --- NUOVO: Funzione per intascare i soldi ---
func add_gold(amount):
	gold += amount
	# Aggiorniamo la scritta sullo schermo
	if gold_label:
		gold_label.text = "Oro: " + str(gold)
	else:
		print("ERRORE: Non trovo GoldLabel! Hai creato il CanvasLayer?")
# Funzione chiamata quando clicchi il bottone
func buy_upgrade():
	# 1. Controlliamo se hai abbastanza soldi
	if gold >= upgrade_cost:
		# 2. Paghiamo
		gold -= upgrade_cost
		add_gold(0) # Trucco per aggiornare la scritta dell'oro (toglie 0 ma aggiorna il testo)
		
		# 3. Diventiamo più forti
		damage += 5
		print("Upgrade effettuato! Nuovo danno: ", damage)
		
		# 4. Aumentiamo il prezzo per la prossima volta (Inflazione!)
		upgrade_cost = upgrade_cost * 2 # Raddoppia il prezzo
		
		# 5. Aggiorniamo il testo del bottone
		# Nota: Dobbiamo trovare il bottone nel CanvasLayer
		var btn = get_node("../CanvasLayer/UpgradeButton")
		if btn:
			btn.text = "Potenzia Spada (" + str(upgrade_cost) + " Oro)"
			
	else:
		print("Non hai abbastanza soldi! Te ne servono: ", upgrade_cost)
func _ready():
	# Impostiamo la barra al massimo all'inizio
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp
func take_damage(amount):
	current_hp -= amount
	print("Ahi! La carovana è stata colpita! Vita: ", current_hp)
	
	# Aggiorniamo la barra
	if health_bar:
		health_bar.value = current_hp
	
	if current_hp <= 0:
		game_over()

func game_over():
	print("GAME OVER - La carovana è distrutta!")
	# Per ora ricarichiamo semplicemente la scena (Ricomincia da capo)
	get_tree().reload_current_scene()
