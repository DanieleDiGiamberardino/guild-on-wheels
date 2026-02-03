class_name GuildMemberData extends Resource

@export var member_name: String = "Recluta"
@export var portrait: Texture2D # Qui ci andrà la faccia del personaggio
@export var max_hp: int = 10

var current_hp: int

func initialize():
	current_hp = max_hp
