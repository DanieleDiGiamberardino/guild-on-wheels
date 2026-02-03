class_name CartData extends Resource

@export_group("Stats")
@export var speed: float = 150.0
@export var max_health: int = 100
@export var inventory_capacity: int = 20

# --- NUOVE STATS PER IL COMBATTIMENTO ---
@export var damage: int = 50        # Danno base della palla di fuoco
@export var fire_rate: float = 1.0  # Tempo tra un colpo e l'altro

# Variabili runtime
var current_health: int

func initialize():
	current_health = max_health
