extends Node

# Nome del file di salvataggio (user:// è la cartella sicura di Godot)
const SETTINGS_FILE = "user://settings.cfg"

# Variabili di default
var config = ConfigFile.new()
var master_volume: float = 1.0
var fullscreen: bool = false

func _ready():
	load_settings()

func save_settings():
	# Scriviamo i dati nel file
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Video", "fullscreen", fullscreen)
	
	config.save(SETTINGS_FILE)
	print("⚙️ Impostazioni salvate!")

func load_settings():
	var err = config.load(SETTINGS_FILE)
	if err != OK:
		print("⚠️ Nessun file impostazioni trovato. Uso default.")
		return

	# Leggiamo i dati (con valori di default se mancano)
	master_volume = config.get_value("Audio", "master_volume", 1.0)
	fullscreen = config.get_value("Video", "fullscreen", false)
	
	apply_settings()

func apply_settings():
	# 1. Applica Schermo Intero
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# 2. Applica Volume (AudioServer di Godot)
	# Nota: Il bus "Master" è solitamente l'indice 0
	var bus_index = AudioServer.get_bus_index("Master")
	# Convertiamo da lineare (0-1) a Decibel
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))

# Funzioni Helper da chiamare dai menu
func set_fullscreen(value: bool):
	fullscreen = value
	apply_settings()
	save_settings()

func set_volume(value: float):
	master_volume = value
	apply_settings()
	save_settings()
