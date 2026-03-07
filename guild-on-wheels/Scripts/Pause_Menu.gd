extends CanvasLayer

# --- RIFERIMENTI UI ---
# Assicurati che il nome del nodo sia corretto nello Scene Tree!
@onready var resume_btn = $CenterContainer/VBoxContainer/BtnResume

func _ready():
	# Il menu deve partire nascosto
	visible = false 
	
	# IMPORTANTE: Questo script deve girare anche quando il gioco è in pausa!
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	# Gestiamo il tasto ESC / Start
	if event.is_action_pressed("ui_cancel"):
		# Se siamo nel menu principale o Game Over, non apriamo la pausa
		if GameManager.current_state != GameManager.GameState.GAME_OVER: 
			toggle_pause()

func toggle_pause():
	visible = not visible
	get_tree().paused = visible # <--- Congela/Scongela tutto il gioco
	
	if visible:
		# --- SUPPORTO CONTROLLER ---
		# Diamo il focus al primo bottone per permettere la navigazione col Pad
		if resume_btn:
			resume_btn.grab_focus()

# --- FUNZIONI DEI BOTTONI ---

func _on_btn_resume_pressed():
	toggle_pause()

func _on_btn_options_pressed():
	# --- INTEGRAZIONE SETTINGS MANAGER ---
	# Per ora testiamo il cambio schermo intero
	var current_mode = DisplayServer.window_get_mode()
	var is_fullscreen = current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	# Chiamiamo il Manager creato prima
	if has_node("/root/SettingsManager"):
		SettingsManager.set_fullscreen(not is_fullscreen)
	else:
		print("⚠️ SettingsManager non trovato negli Autoload!")

func _on_btn_main_menu_pressed():
	toggle_pause() # Sblocca il tempo PRIMA di cambiare scena!
	GameManager.change_state(GameManager.GameState.TRAVEL) # Resetta lo stato del gioco
	get_tree().change_scene_to_file("res://Scenes/Home.tscn")

func _on_btn_quit_pressed():
	get_tree().quit()
