extends Control
class_name ProfileDeck

const CARD_WIDTH := 450.0
@export var card_scn: PackedScene
@export var overlap_amount := 120.0

var card_count: int = 10
var cards: Array[ProfileCard] = []

func _ready():
#	TODO use CardData data model, use generator func to instantiate data
	instance_cards()
	await get_tree().process_frame
	layout_cards()

func instance_cards():
	for child in get_children():
		child.queue_free()

	for i in card_count:
		var card: ProfileCard = card_scn.instantiate()
#		TODO set data on card when data available
		cards.append(card)
		add_child(card)


func layout_cards():
	var total_width = (cards.size() - 1) * overlap_amount + CARD_WIDTH
	offset_left = -total_width / 2.0
	offset_right = total_width / 2.0

	for i in range(cards.size()):
		var card = cards[i]
		var target_pos = Vector2(i * overlap_amount, 0)

		var tween = create_tween().set_trans(Tween.TRANS_BACK)
		tween.tween_property(card, "position", target_pos, 1)
		card.z_index = i
		card.base_pos = target_pos
