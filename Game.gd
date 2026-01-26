extends CanvasLayer

const COLOR_GOOD = Color.SPRING_GREEN
const COLOR_WARN = Color.GOLD
const COLOR_DANGER = Color.TOMATO

@onready var progress_bar: ProgressBar = $VBox/ProgressBar
@onready var time_label: Label = $VBox/ProgressBar/TimeLabel

@onready var sidebar: Sidebar = $VBox/HBox/Sidebar
@onready var deck: ProfileDeck = $VBox/HBox/DeckArea/ProfileDeck
@onready var submit_button: Button = $SubmitButton
@onready var summary_node = $Summary
@onready var summary_body: RichTextLabel = $Summary/Panel/VBoxContainer/RichTextLabel
@onready var restart_btn: Button = $Summary/Panel/VBoxContainer/RestartButton

@export var num_rounds: int = 10
@export var round_time := 45.0
var time_left : float

var curr_round = 1
var total_score: int
var current_client: ProfileData

var best_match_phrase := ""
var worst_match_phrase := ""
var best_score := -999.0
var worst_score := 999.0


func _ready():
	submit_button.pressed.connect(_on_submit_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	start()

func start():
	progress_bar.max_value = round_time
	progress_bar.value = round_time
	time_left = round_time
	
	progress_bar.modulate = COLOR_GOOD
	sidebar.setup(_load_client_data())
	sidebar.update_stats(curr_round, num_rounds, total_score)
	deck.start()

func _process(delta: float):
	if time_left > 0:
		time_left -= delta
		progress_bar.value = time_left
		if time_left > 10.0:
			time_label.text = "%ds" % ceil(time_left)
		else:
			time_label.text = "%0.1fs" % time_left
		var ratio = time_left / round_time
		if ratio > 0.5:
			progress_bar.modulate = COLOR_WARN.lerp(COLOR_GOOD, (ratio - 0.5) * 2.0)
		else:
			progress_bar.modulate = COLOR_DANGER.lerp(COLOR_WARN, ratio * 2.0)
	else:
		time_label.text = "0.0s"
		_on_timer_out()
	var count = deck.get_selected_cards().size()
	if count > 0:
		if count == 5:
			submit_button.text = "Send %d Candidates (MAX)" % count
		else:
			submit_button.text = "Send %d Candidates" % count
		submit_button.disabled = false
	else:
		submit_button.text = "Select Candidates"
		submit_button.disabled = true

# TODO implement with premade data
func _load_client_data() -> ProfileData:
	var client = ProfileData.new()
	client.profile_name = ["Alex", "Jordan", "Taylor", "Avery", "Riley", "Logan", "River", "Charlie", "Parker", "Rowen", "Harper", "Cameron", "Jamie", "Kelly", "Kris", "Terry", "Shannon"].pick_random()
	client.age = randi_range(22, 40)
	client.height_cm = randi_range(155, 180)
	client.smokes = ProfileData.Habit.values().pick_random()
	client.drinks = ProfileData.Habit.values().pick_random()

	client.min_age = client.age - 5
	client.max_age = client.age + 7
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
	client.dealbreakers = all_hobbies.slice(0, randi_range(1, 2))
	client.likes = all_hobbies.filter(func(h): return h not in client.dealbreakers).slice(0, randi_range(1, 2))
	client.dislikes = all_hobbies.filter(func(h): return h not in client.dealbreakers + (client.likes)).slice(0, randi_range(1, 2))

	current_client = client
	return client

func _on_timer_out():
	set_process(false)
	_on_submit_pressed()

func _on_submit_pressed():
	submit_button.disabled = true
	deck.freeze
	set_process(false)
	var selected = deck.get_selected_cards()
	if not selected.is_empty():
		total_score += calc_score(selected)
		sidebar.update_stats(curr_round, num_rounds, total_score)

	if total_score < 0:
		_show_summary(false)
		return
	if curr_round >= num_rounds:
		_show_summary(true)
	else:
		curr_round += 1
		await get_tree().create_timer(1.5).timeout
		start()
		set_process(true)

func _on_restart_pressed():
	total_score = 0
	curr_round = 1
	best_score = -999
	worst_score = 999
	summary_node.visible = false
	start()
	set_process(true)

func _show_summary(is_success: bool):
	summary_node.visible = true
	var status = "[font_size=64][wave rate=5.0 level=3]%s[/wave][/font_size]" % ["SUCCESS" if is_success else "BANKRUPT"]
	
	summary_body.bbcode_enabled = true
	summary_body.text = """
	[center]
	%s

	[color=gray][font_size=24]You Made[/font_size][/color]
	[font_size=72]$[b]%s[/b][/font_size]

	[font_size=4] [/font_size] 
	[i]Matchmaking Highlights:[/i]
	[font_size=4] [/font_size] 
	[font_size=24]%s[/font_size]
	[font_size=4] [/font_size] 
	[font_size=24]%s[/font_size]
	[/center]
	""" % [status, sidebar.comma_sep(roundi(total_score)), best_match_phrase, worst_match_phrase]

func calc_score(selected_cards: Array[ProfileCard]) -> int:
	var round_total = 0
	for card in selected_cards:
		var data: ProfileData = card.profile_data
		var score = current_client.get_compatibility_score(data)
		round_total += score
		if score >= best_score:
			best_score = score
			best_match_phrase = "[color=SPRING_GREEN]%s[/color] had a blast with [color=SPRING_GREEN]%s[/color]!" % [current_client.profile_name, data.profile_name]
		if score < worst_score:
			if score < best_score or worst_match_phrase == "":
				worst_score = score
				worst_match_phrase = "[color=TOMATO]%s[/color] couldn't vibe with [color=TOMATO]%s[/color]..." % [current_client.profile_name, data.profile_name]
	return round_total
