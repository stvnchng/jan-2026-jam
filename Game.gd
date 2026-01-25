extends CanvasLayer

const COLOR_GOOD = Color.SPRING_GREEN
const COLOR_WARN = Color.GOLD
const COLOR_DANGER = Color.TOMATO

@onready var progress_bar: ProgressBar = $VBox/ProgressBar
@onready var time_label: Label = $VBox/ProgressBar/TimeLabel

@onready var client_view: ClientView = $VBox/HBox/ClientPanel
@onready var deck: ProfileDeck = $VBox/HBox/DeckArea/ProfileDeck
@onready var submit_button: Button = $SubmitButton

@export var round_time := 30.0
var time_left : float

var current_client: ProfileData

func _ready():
	progress_bar.max_value = round_time
	progress_bar.value = round_time
	time_left = round_time
	
	progress_bar.modulate = COLOR_GOOD
	submit_button.pressed.connect(_on_submit_pressed)
	
	client_view.setup(_load_client_data())

func _process(delta: float):
	if time_left > 0:
		time_left -= delta
		progress_bar.value = time_left
		time_label.text = "%0.1fs" % time_left
		var ratio = time_left / round_time
		if ratio > 0.5:
			progress_bar.modulate = COLOR_WARN.lerp(COLOR_GOOD, (ratio - 0.5) * 2.0)
		else:
			progress_bar.modulate = COLOR_DANGER.lerp(COLOR_WARN, ratio * 2.0)
	else:
		time_label.text = "0.0s"
		_on_timer_out()

# TODO implement with premade data
func _load_client_data() -> ProfileData:
	var client = ProfileData.new()
	client.profile_name = ["Sarah", "Mike", "Alex", "Jordan", "Taylor"].pick_random()
	client.age = randi_range(22, 45)
	client.height_cm = randi_range(155, 190)
	client.smokes = ProfileData.Habit.values().pick_random()
	client.drinks = ProfileData.Habit.values().pick_random()
	
	client.min_age = client.age - 5
	client.max_age = client.age + 5
	client.age_negotiable = [true, false].pick_random()

	if randf() < 0.4:
		client.min_height = client.height_cm
		client.max_height = 210
		client.height_negotiable = false
	else:
		client.min_height = 150
		client.max_height = 210
		client.height_negotiable = true

	if client.smokes == ProfileData.Habit.NO:
		client.smokers_welcome = false
	else:
		client.smokers_welcome = true

	var all_hobbies = ProfileData.Hobby.values().duplicate()
	all_hobbies.shuffle()
	client.dealbreaker_hobbies = all_hobbies.slice(0, randi_range(1, 2))
	
	return client


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
