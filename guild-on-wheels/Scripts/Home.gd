extends Node2D

func _ready():
	# 1. IMPORTANTE: Se torniamo dal Game Over, il gioco è ancora in PAUSA.
	# Dobbiamo sbloccarlo, altrimenti i bottoni non funzionano o il gioco parte fermo.
	get_tree().paused = false
	
	print("🏰 Benvenuto nella Gilda! Oro in Banca: ", GameManager.permanent_gold)
	
	# Aggiorna la label della banca (se esiste)
	if has_node("CanvasLayer/BankLabel"):
		$CanvasLayer/BankLabel.text = "Tesoro Gilda: " + str(GameManager.permanent_gold)

func _on_btn_start_mission_pressed():
	print("🚀 Preparazione alla partenza...")
	
	# 2. RESET TOTALE: Diciamo al Manager di pulire le ferite e resettare l'oro della sessione
	GameManager.start_new_run()
	
	# 3. Carica la scena di livello
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_btn_manage_shop_pressed():
	# Gestione del Negozio nel Menu (Per ora usiamo quello che hai)
	var canvas_layer = get_node_or_null("CanvasLayer")
	
	if canvas_layer:
		var shop_panel = canvas_layer.get_node_or_null("ShopPanel")
		if shop_panel and shop_panel.has_method("open_shop"):
			shop_panel.open_shop()
			# Nota: Questo shop mostrerà l'oro della sessione (0) per ora.
			# In futuro faremo un "MetaShop" che usa l'oro della banca.
		else:
			print("❌ ERRORE: ShopPanel non trovato nel CanvasLayer!")
	else:
		print("❌ ERRORE: CanvasLayer non trovato.")

func _on_btn_exit_pressed():
	print("👋 Chiusura gioco.")
	get_tree().quit()
