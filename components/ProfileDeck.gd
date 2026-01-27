extends Control
class_name ProfileDeck

const CARD_WIDTH := 320.0
const OVERLAP_AMOUNT := 120.0

const MAX_SELECTED = 5
const SELECTION_Y_OFFSET = -450.0
const SELECTED_SPACING = 340.0
const SELECTION_SCALE := 0.8

@export var card_scn: PackedScene

var card_count: int = 10
var cards: Array[ProfileCard] = []

func start(client: ProfileData):
	cards.clear()
	for child in get_children():
		child.queue_free()

	for i in card_count:
		var card: ProfileCard = card_scn.instantiate()
		card.profile_data = ProfileData.create_random()
		cards.append(card)
		add_child(card)
		card.selected.connect(toggle_card_selection)

	cards.pick_random().profile_data = _gen_ideal_match(client)
	layout_cards()

func freeze():
	for card in cards:
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE

func get_selected_cards() -> Array[ProfileCard]:
	return cards.filter(func(card: ProfileCard): return card.is_active)

func toggle_card_selection(card: ProfileCard):
	var selected_count = get_selected_cards().size()	
	if not card.is_active:
		if selected_count < MAX_SELECTED:
			card.update_selection_visuals(true)
	else:
		card.update_selection_visuals(false)

	layout_cards()

func _gen_ideal_match(client: ProfileData) -> ProfileData:
	var p = ProfileData.create_random()
	p.age = randi_range(client.min_age, client.max_age)
	p.height_cm = randi_range(client.min_height, client.min_height + 15)
	p.smokes = ProfileData.Habit.NO if !client.smokers_welcome else ProfileData.Habit.SOCIALLY
	if !client.likes.is_empty():
		p.hobbies = []
		for i in range(randi_range(1, len(client.likes))):
			var h = client.likes.pick_random()
			if not h in p.hobbies:
				p.hobbies.append(h)
	return p

func layout_cards():
	var active_cards = get_selected_cards()
	var inactive_cards = cards.filter(func(c): return !c.is_active)

	var deck_width = 0.0
	if inactive_cards.size() > 0:
		deck_width = (inactive_cards.size() - 1) * OVERLAP_AMOUNT + CARD_WIDTH

	offset_left = -deck_width / 2.0
	offset_right = deck_width / 2.0

	for i in range(inactive_cards.size()):
		_animate_card_to(inactive_cards[i], Vector2(i * OVERLAP_AMOUNT, 0), i, 1.0)

	var scaled_width = CARD_WIDTH * SELECTION_SCALE
	var scaled_spacing = SELECTED_SPACING * SELECTION_SCALE
	var float_total_width = (active_cards.size() - 1) * scaled_spacing
	var float_start_x = (deck_width / 2.0) - (float_total_width / 2.0) - (scaled_width / 2.0)
	for i in range(active_cards.size()):
		var target_pos = Vector2(float_start_x + (i * scaled_spacing), SELECTION_Y_OFFSET)
		_animate_card_to(active_cards[i], target_pos, 500 + i, SELECTION_SCALE)

func _animate_card_to(card: ProfileCard, pos: Vector2, z: int, s: float):
	card.z_index = z
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "position", pos, 0.4)
	tw.tween_property(card, "rotation_degrees", 0.0, 0.4)
	tw.tween_property(card, "scale", Vector2(s, s), 0.4)
