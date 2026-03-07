extends Node2D

# --- RIFERIMENTI UI (Trascinali dall'Inspector!) ---
# Usiamo @export così è impossibile sbagliare il percorso dei nodi
@export var btn_start: Button
@export var btn_shop: Button
@export var btn_exit: Button
@export var shop_panel: Control # Il nodo ShopPanel (o MetaShop)

func _ready():
	# 1. SBLOCCO PAUSA (Cruciale dopo il Game Over)
	get_tree().paused = false
	if shop_panel:
		if not shop_panel.shop_closed.is_connected(_on_shop_closed):
			shop_panel.shop_closed.connect(_on_shop_closed)
	# 2. FOCUS INIZIALE (Il Segreto per Steam Deck) 🎮
	# Appena il menu appare, diciamo al gioco: "Seleziona il tasto Inizia!"
	# Così puoi premere "A" o "Invio" subito senza mouse.
	if btn_start:
		btn_start.grab_focus()
	
	# 3. UI UPDATE
	print("🏰 Benvenuto nella Gilda! Oro in Banca: ", GameManager.permanent_gold)
	
	# Aggiorna la label della banca (con controllo di sicurezza)
	if has_node("CanvasLayer/BankLabel"):
		$CanvasLayer/BankLabel.text = "Tesoro Gilda: " + str(GameManager.permanent_gold)

func _on_btn_start_mission_pressed():
	print("🚀 Preparazione alla partenza...")
	
	# Reset Run
	GameManager.start_new_run()
	
	# Carica Livello
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_btn_manage_shop_pressed():
	# Gestione apertura Shop
	if shop_panel and shop_panel.has_method("open_shop"):
		shop_panel.open_shop()
		
		# --- 4. SPOSTAMENTO FOCUS ---
		# Quando apri lo shop, il cursore deve entrare lì dentro!
		# Cerchiamo un bottone qualsiasi dentro lo shop per dargli il focus.
		# (Nota: Assicurati che nel tuo ShopPanel ci sia un bottone chiamato 'BtnClose' o simile)
		var focus_target = shop_panel.find_child("BtnClose", true, false) 
		
		# Se non trova 'BtnClose', prova a cercare il primo bottone generico
		if not focus_target:
			var all_buttons = shop_panel.find_children("*", "Button", true, false)
			if all_buttons.size() > 0:
				focus_target = all_buttons[0]
		
		# Applica il focus se trovato
		if focus_target:
			focus_target.grab_focus()
			
	else:
		# FALLBACK: Il tuo vecchio metodo (nel caso non assegni l'export)
		var canvas_layer = get_node_or_null("CanvasLayer")
		if canvas_layer:
			var sp = canvas_layer.get_node_or_null("ShopPanel")
			if sp and sp.has_method("open_shop"):
				sp.open_shop()
			else:
				print("❌ ERRORE: ShopPanel non trovato o metodo mancante!")

func _on_btn_exit_pressed():
	print("👋 Chiusura gioco.")
	get_tree().quit()
func _on_shop_closed():
	if btn_shop:
		btn_shop.grab_focus()
