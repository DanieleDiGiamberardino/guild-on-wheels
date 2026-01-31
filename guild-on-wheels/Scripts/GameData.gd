extends Node

# BANCA GLOBALE
var permanent_gold = 0

# Funzione per aggiungere oro alla banca
func add_savings(amount):
	permanent_gold += amount
	print("Banca: Ora hai ", permanent_gold, " oro totale.")

# Qui in futuro metteremo save_game() e load_game()
