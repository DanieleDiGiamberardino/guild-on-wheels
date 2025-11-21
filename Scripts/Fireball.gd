extends Area2D

var speed = 400 # Velocità del proiettile
var damage = 0 # Questo valore glielo passerà la Carovana quando spara

func _physics_process(delta):
	# Vola verso destra all'infinito
	position += Vector2.RIGHT * speed * delta

# Questa funzione scatta quando tocchiamo qualcosa
func _on_body_entered(body):
	# Se abbiamo toccato un nemico
	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Boom! Palla di fuoco a segno.")
		
		# Distruggiamo la palla di fuoco (altrimenti trapassa i nemici)
		queue_free()
