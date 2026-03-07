extends Resource
class_name WaveConfig

@export_category("Progressione Nemici")
@export var enemy_count_curve: Curve # Asse X: Ondata (0-1), Asse Y: Moltiplicatore quantità
@export var spawn_rate_curve: Curve  # Asse X: Ondata (0-1), Asse Y: Velocità (0=Lento, 1=Veloce)
@export var health_multiplier_curve: Curve # Asse X: Ondata (0-1), Asse Y: Moltiplicatore HP

@export var max_wave_cap: float = 50.0 # Il numero di ondata dove le curve raggiungono l'1.0 (il massimo)

# Funzione helper per leggere quanti nemici spawnare
func get_enemy_count(wave: int) -> int:
	# Normalizziamo l'ondata tra 0.0 e 1.0 (es. Ondata 25 su 50 = 0.5)
	var sample_pos = min(float(wave) / max_wave_cap, 1.0)
	
	# Campioniamo la curva. Assumiamo che la curva vada da 0 a 1.
	# Moltiplichiamo per un valore base, es. max 50 nemici a schermo.
	var count = int(enemy_count_curve.sample(sample_pos) * 50) 
	
	# Assicuriamoci che ne spawni almeno 1
	return max(1, count)

# Funzione helper per leggere la velocità di spawn
func get_spawn_wait_time(wave: int) -> float:
	var sample_pos = min(float(wave) / max_wave_cap, 1.0)
	var curve_val = spawn_rate_curve.sample(sample_pos)
	
	# Interpoliamo (Lerp): 
	# Se curva è 0 (inizio) -> 2.0 secondi
	# Se curva è 1 (fine) -> 0.2 secondi
	return lerp(2.0, 0.2, curve_val)
