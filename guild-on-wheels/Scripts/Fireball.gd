extends Area2D

var speed = 600
var direction = Vector2.RIGHT
var damage = 10

func _ready():
	z_index = 100
	
	# --- DIAGNOSTICA INIZIALE ---
	print("🔥 FIREBALL GENERATA!")
	print("   > Posizione: ", global_position)
	print("   > Collision Mask (Cosa guardo): ", collision_mask)
	print("   > Monitoring attivo?: ", monitoring)
	# ----------------------------

	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)

func _physics_process(delta):
	position += direction * speed * delta

# Questa funzione deve essere collegata dall'Editor (segnalino verde accanto)
func _on_body_entered(body):
	# --- DIAGNOSTICA IMPATTO ---
	print("💥 LA PALLA HA TOCCATO QUALCOSA!")
	print("   > Nome oggetto: ", body.name)
	print("   > Collision Layer dell'oggetto: ", body.collision_layer)
	# ---------------------------

	if body.has_method("take_damage"):
		print("   > C'è il metodo take_damage! Infliggo danni.")
		body.take_damage(damage)
		queue_free()
	elif body.name != "Caravan":
		print("   > Non è un nemico, ma mi distruggo lo stesso.")
		queue_free()
