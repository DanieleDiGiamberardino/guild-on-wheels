extends Button

func _pressed():
	print("Click bottone rilevato!")
	# Cerca il pannello "cugino" (figlio dello stesso padre CanvasLayer)
	# Assicurati che il nodo del pannello si chiami ESATTAMENTE "ShopPanel"
	var shop = get_parent().get_node("ShopPanel")
	
	if shop:
		shop.open_shop()
	else:
		print("ERRORE: Non trovo ShopPanel! Controlla il nome.")
