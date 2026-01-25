extends CanvasLayer

@onready var progress_bar: ProgressBar = $VBox/ProgressBar
@onready var deck: ProfileDeck = $VBox/HBox/DeckArea/ProfileDeck
@onready var submit_button: Button = $SubmitButton

@export var round_time := 30.0
var time_left : float

var color_good = Color.SPRING_GREEN
var color_warn = Color.GOLD
var color_danger = Color.TOMATO

func _ready():
	progress_bar.max_value = round_time
	progress_bar.value = round_time
	time_left = round_time
	
	progress_bar.modulate = color_good
	submit_button.pressed.connect(_on_submit_pressed)

func _process(delta: float):
	if time_left > 0:
		time_left -= delta
		progress_bar.value = time_left
		var ratio = time_left / round_time
		if ratio > 0.5:
			progress_bar.modulate = color_warn.lerp(color_good, (ratio - 0.5) * 2.0)
		else:
			progress_bar.modulate = color_danger.lerp(color_warn, ratio * 2.0)
	else:
		_on_timer_out()

func _on_timer_out():
	set_process(false)
	_on_submit_pressed()

func _on_submit_pressed():
	set_process(false)
	var selected = deck.get_selected_cards()
	if not selected.is_empty():
		print("submitted ", selected.size(), " profiles:")
		_show_mock_summary(selected)

func _show_mock_summary(selected_cards: Array[ProfileCard]):
	for card in selected_cards:
		print(card.profile_data.get_title_f())
