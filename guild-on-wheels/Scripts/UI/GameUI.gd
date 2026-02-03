extends CanvasLayer

# --- ASSEGNAZIONE NODI ---
# Usiamo @export così puoi trascinare i nodi direttamente dall'Editor
# ed evitare errori tipo "Node not found" se cambi nome.
@export var health_bar: ProgressBar
@export var gold_label: Label

func _ready():
	# 1. SETUP INIZIALE
	# Appena parte il gioco, chiediamo al Manager: "Quanta vita e soldi abbiamo?"
	update_initial_view()
	
	# 2. CONNESSIONE SEGNALI (Il "Wireless")
	# Diciamo: "Quando il GameManager lancia il segnale 'cart_updated', esegui la mia funzione '_on_health_changed'"
	GameManager.cart_updated.connect(_on_health_changed)
	GameManager.gold_updated.connect(_on_gold_changed)

func update_initial_view():
	# Aggiorna la barra della vita con i dati attuali
	if GameManager.cart_data:
		health_bar.max_value = GameManager.cart_data.max_health
		health_bar.value = GameManager.cart_data.current_health
	
	# Aggiorna l'oro
	gold_label.text = "Oro: " + str(GameManager.session_gold)

# --- REAZIONI AI SEGNALI ---

func _on_health_changed(current_hp, max_hp):
	# Questa funzione parte in automatico quando la carovana prende danno
	health_bar.value = current_hp
	
	# Esempio tocco di classe: Cambia colore se la vita è bassa
	if current_hp < max_hp * 0.3:
		health_bar.modulate = Color(1, 0, 0) # Rosso
	else:
		health_bar.modulate = Color(1, 1, 1) # Normale

func _on_gold_changed(new_amount):
	# Questa parte quando raccogli una moneta
	gold_label.text = "Oro: " + str(new_amount)
