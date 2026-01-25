extends Control
class_name ProfileDeck

const CARD_WIDTH := 320.0
const OVERLAP_AMOUNT := 150.0

@export var card_scn: PackedScene

var card_count: int = 8
var cards: Array[ProfileCard] = []

func _ready():
	instance_cards()
	await get_tree().process_frame
	layout_cards()

func instance_cards():
	for child in get_children():
		child.queue_free()

	for i in card_count:
		var card: ProfileCard = card_scn.instantiate()
		cards.append(card)
		add_child(card)

func get_selected_cards() -> Array[ProfileCard]:
	return cards.filter(func(card: ProfileCard): return card.is_active)

func layout_cards():
	var total_width = (cards.size() - 1) * OVERLAP_AMOUNT + CARD_WIDTH
	offset_left = -total_width / 2.0
	offset_right = total_width / 2.0

	for i in range(cards.size()):
		var card = cards[i]
		var target_pos = Vector2(i * OVERLAP_AMOUNT, 0)

		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "position", target_pos, 1)
		card.z_index = i
		card.base_pos = target_pos
