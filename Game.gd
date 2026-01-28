extends CanvasLayer

const COLOR_GOOD = Color.SPRING_GREEN
const COLOR_WARN = Color.GOLD
const COLOR_DANGER = Color.TOMATO

@onready var progress_bar: ProgressBar = $VBox/ProgressBar
@onready var time_label: Label = $VBox/ProgressBar/TimeLabel

@onready var sidebar: Sidebar = $VBox/HBox/Sidebar
@onready var deck: ProfileDeck = $VBox/HBox/DeckArea/ProfileDeck
@onready var submit_button: Button = $SubmitButton
@onready var start_node = $Start
@onready var instructions : RichTextLabel = $Start/Panel/VBoxContainer/RichTextLabel
@onready var start_btn : Button = $Start/Panel/VBoxContainer/StartButton
@onready var summary_node = $Summary
@onready var summary_body: RichTextLabel = $Summary/Panel/VBoxContainer/RichTextLabel
@onready var restart_btn: Button = $Summary/Panel/VBoxContainer/RestartButton

@export var num_rounds: int = 10
@export var round_time := 30.0
var time_left : float

var curr_round = 1
var total_score: int
var current_client: ProfileData

var best_match_phrase := ""
var worst_match_phrase := ""
var best_score := -999.0
var worst_score := 999.0


func _ready():
	show_start()
	submit_button.pressed.connect(_on_submit_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	set_process(false)

func _on_start_pressed():
	start_node.visible = false
	start()

func show_start():
	start_node.visible = true
	instructions.text = """
	[center]
	[color=green][font_size=60]Rules[/font_size][/color]
	[/center]
	[left]
	[color=white][font_size=28]%s[/font_size][/color]
	[/left]
	""" % instructions.text

func reset():
	total_score = 0
	curr_round = 1
	best_score = -999
	worst_score = 999
	best_match_phrase = ""
	worst_match_phrase = ""
	summary_node.visible = false

func start():
	progress_bar.max_value = round_time
	progress_bar.value = round_time
	time_left = round_time
	
	progress_bar.modulate = COLOR_GOOD
	
	current_client = gen_client_data()
	sidebar.setup(current_client)
	sidebar.update_stats(curr_round, num_rounds, total_score)
	deck.start(current_client)
	set_process(true)

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
			submit_button.text = "Send %d Candidate(s)" % count
		submit_button.disabled = false
	else:
		submit_button.text = "Select Candidates"
		submit_button.disabled = true

# TODO implement with premade data
func gen_client_data() -> ProfileData:
	var client = ProfileData.create_random()

	client.min_age = max(18, client.age - 8)
	client.max_age = min(50, client.age + 4)
	if randf() < 0.3:
		client.min_age = 18
		client.max_age = 24
	elif randf() < 0.1:
		client.min_age = 38
		client.max_age = 50

	client.min_height = 160
	client.max_height = 190
	if randf() < 0.2:
		client.min_height = 185
		client.max_height = 210
	elif randf() < 0.2:
		client.min_height = 150
		client.max_height = 170

	if client.smokes == ProfileData.Habit.NO and randf() < 0.7:
		client.smokers_welcome = false
	else:
		client.smokers_welcome = true
	
	if client.drinks == ProfileData.Habit.NO and randf() < 0.3:
		client.alcoholics_welcome = false
	else:
		client.alcoholics_welcome = true

	client.likes = ProfileData.pick_likes(randi_range(2, 4))
	client.dislikes = ProfileData.pick_aversions(randi_range(2, 4), client.likes)

	return client

func _on_timer_out():
	set_process(false)
	_on_submit_pressed()

@export var no_selection_penalty = 50
func _on_submit_pressed():
	submit_button.disabled = true
	deck.freeze()
	set_process(false)
	var selected = deck.get_selected_cards()
	if not selected.is_empty():
		total_score += calc_score(selected)
		sidebar.update_stats(curr_round, num_rounds, total_score)
	else:
		total_score -= no_selection_penalty
		worst_match_phrase = "[color=TOMATO]%s left a scathing review about your prowess as a matchmaker.[/color]" % [current_client.profile_name]
		sidebar.display_score = total_score

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
	reset()
	start()
	set_process(true)

func _show_summary(is_success: bool):
	summary_node.visible = true
	var status = "[font_size=64][wave rate=5.0 level=3]%s[/wave][/font_size]" % ["SUCCESS" if is_success else "BANKRUPT"]
	var highlight_text = best_match_phrase if is_success else worst_match_phrase
	summary_body.text = """
	[center]
	%s

	[color=gray][font_size=24]Final Earnings[/font_size][/color]
	[font_size=72]$%s[/font_size]
	[font_size=24][/font_size] 
	[font_size=24]%s[/font_size] 
	[/center]
	""" % [status, sidebar.comma_sep(roundi(total_score)), highlight_text]

func calc_score(selected_cards: Array[ProfileCard]) -> int:
	var round_total = 0
	for card in selected_cards:
		var data: ProfileData = card.profile_data
		var score = get_compatibility_score(current_client, data)
		round_total += score
		if score >= best_score:
			best_score = score
			best_match_phrase = "[color=SPRING_GREEN]%s[/color] had a blast with [color=SPRING_GREEN]%s[/color]!" % [current_client.profile_name, data.profile_name]
		if score < worst_score:
			if score < best_score or worst_match_phrase == "":
				worst_score = score
				if data.age < 18:
					worst_match_phrase = "[color=TOMATO]%s[/color] is underaged..." % data.profile_name
				else:
					worst_match_phrase = "[color=TOMATO]%s[/color] couldn't vibe with [color=TOMATO]%s[/color]..." % [current_client.profile_name, data.profile_name]
	return round_total

@export var reward = 10;
@export var additional_reward = 5;
@export var penalty = -30;
func get_compatibility_score(client: ProfileData, candidate: ProfileData) -> int:
	var score = reward
	for hobby in candidate.hobbies:
		if hobby in client.likes:
			score += additional_reward
		if hobby in client.dislikes:
			return penalty
	
	if candidate.age < 18:
		return -10000 # instant death
	if candidate.age < client.min_age or candidate.age > client.max_age:
		return penalty
	
	if candidate.height_cm < client.min_height or candidate.height_cm > client.max_height:
		return penalty
	
	if !client.smokers_welcome and candidate.smokes != ProfileData.Habit.NO:
		return penalty
	
	if !client.alcoholics_welcome and candidate.drinks != ProfileData.Habit.NO:
		return penalty

	if client.drinks == candidate.drinks && client.smokes == candidate.smokes:
		score += additional_reward * 2
	
	return score 
