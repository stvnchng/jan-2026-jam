extends Node2D
class_name GameManager

var candidate : ProfileCard
var deck : ProfileDeck

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck = preload("res://components/ProfileCard.tscn").instantiate()
	candidate = preload("res://components/ProfileCard.tscn").instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_timer_timeout() -> void:
	var selected_cards = deck.get_selected_cards()
	var score = calculate_score(candidate, selected_cards)

func calculate_score(c : ProfileCard, selected : Array[ProfileCard]) -> float:
	return 0.0
