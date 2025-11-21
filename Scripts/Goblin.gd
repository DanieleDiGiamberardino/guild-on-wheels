extends StaticBody2D

# Punti vita del nemico
var hp = 50
var gold_reward = 15 # Il Goblin vale 15 monete

# Funzione per subire danno
func take_damage(amount):
	hp -= amount
	print("Goblin colpito! Vita rimanente: ", hp)
	
	# Feedback visivo: diventa bianco per un attimo
	modulate = Color.RED # Diventa rosso sangue
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE # Torna normale
	
	if hp <= 0:
		die()

func die():
	# Cerchiamo la carovana nel livello per darle i soldi
	var caravan = get_parent().get_node("Caravan")
	
	if caravan:
		caravan.add_gold(gold_reward) # Paga!
	
	queue_free() # Muori
# Aggiungi questa variabile in alto
var damage_to_player = 10 # Quanto male fa il goblin
var attack_cooldown = 1.0 # Attacca ogni secondo
var time_since_last_attack = 0.0

func _process(delta):
	# Questo timer conta il tempo che passa
	time_since_last_attack += delta
	
	# Controlliamo se stiamo toccando qualcosa
	# Nota: Per uno StaticBody è un po' complesso rilevare collisioni attive.
	# TRUCCO VELOCE: Usiamo un controllo di distanza semplice.
	
	# Cerchiamo la carovana
	var caravan = get_parent().get_node("Caravan")
	
	if caravan:
		# Calcoliamo la distanza tra Goblin e Carovana
		var distance = global_position.distance_to(caravan.global_position)
		
		# Se siamo vicinissimi (es. meno di 60 pixel) E il cooldown è pronto
		if distance < 30 and time_since_last_attack > attack_cooldown:
			attack_caravan(caravan)
			time_since_last_attack = 0.0 # Resetta il timer

func attack_caravan(target):
	if target.has_method("take_damage"):
		target.take_damage(damage_to_player)
		# Effetto visivo: il goblin salta un pochino
		position.y -= 5
		await get_tree().create_timer(0.1).timeout
		position.y += 5
