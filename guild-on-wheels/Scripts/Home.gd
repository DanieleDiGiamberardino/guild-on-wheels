extends Node2D
func _ready():
	# Stampa di debug per vedere se funziona
	print("Benvenuto nella Gilda! Oro in Banca: ", GameData.permanent_gold)
	
	# SE HAI UNA LABEL NELLA SCENA HOME (es. BankLabel), SCOMMENTA QUESTO:
	# var bank_label = get_node_or_null("CanvasLayer/BankLabel")
	# if bank_label:
	# 	bank_label.text = "Tesoro Gilda: " + str(GameData.permanent_gold)
func _on_btn_start_mission_pressed():
	# Carica la scena di livello (il tuo vecchio World.tscn)
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_btn_manage_shop_pressed():
	# Tentativo di aprire il pannello del negozio.
	# Assumiamo che il pannello (ShopPanel) si trovi all'interno del CanvasLayer
	var canvas_layer = get_node_or_null("CanvasLayer")
	
	if canvas_layer:
		# Cerchiamo il nodo del negozio (che deve essere stato istanziato qui!)
		var shop_panel = canvas_layer.get_node_or_null("ShopPanel")
		
		if shop_panel and shop_panel.has_method("open_shop"):
			shop_panel.open_shop()
		else:
			print("ERRORE: Il nodo ShopPanel non è stato trovato o non ha la funzione open_shop().")
	else:
		print("ERRORE: Non trovo il CanvasLayer nella scena Home.")

func _on_btn_exit_pressed():
	# Chiude il gioco
	get_tree().quit()
