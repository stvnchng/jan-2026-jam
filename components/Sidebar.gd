extends Panel
class_name Sidebar

@onready var profile_lbl: RichTextLabel = $Margin/VBox/ProfileSummary
@onready var pref_list = $Margin/VBox/PrefList
@onready var round_lbl: RichTextLabel = $Margin2/VBox/RoundLabel
@onready var score_lbl: RichTextLabel = $Margin2/VBox/ScoreLabel

var display_score: float = 0.0:
	set(value):
		display_score = value
		if score_lbl:
			_update_funds_display()

func setup(data: ProfileData):
	profile_lbl.text = "[wave rate=5.0 level=3][font_size=36][b]%s[/b][/font_size][/wave]" % data.get_title_f()
	
	for child in pref_list.get_children():
		child.queue_free()

	if !data.age_negotiable or (data.max_age - data.min_age < 10):
		_add_pref_line("Desired Age Range", "%d-%d" % [data.min_age, data.max_age], data.age_negotiable)

	if data.min_height > 160 or !data.height_negotiable:
		_add_pref_line("Desired Height", "%dcm+" % data.min_height, data.height_negotiable)

	if !data.smokers_welcome:
		_add_pref_line("Lifestyle", "Non-smokers only", false, Color.TOMATO)

	if !data.likes.is_empty():
		_add_pref_line("Interests", _format_hobbies(data.likes), false, Color.SPRING_GREEN)

	if !data.dislikes.is_empty():
		_add_pref_line("Personal Aversions", _format_hobbies(data.dislikes), false, Color.GOLD)

	_add_pref_line(data.get_smokes_f(), "", !data.smokers_welcome, Color.TOMATO if !data.smokers_welcome else Color.WHITE)
	_add_pref_line(data.get_drinks_f(), "", !data.alcoholics_welcome, Color.TOMATO if !data.alcoholics_welcome else Color.WHITE)

func update_stats(current_round: int, max_rounds: int, new_total_score: int):
	round_lbl.text = "[center][color=gray][font_size=16]CURRENT ROUND[/font_size][/color]\n[font_size=22][b]CLIENT %d / %d[/b][/font_size][/center]" % [current_round, max_rounds]
	create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).tween_property(self, "display_score", new_total_score, 1.5)

func _update_funds_display():
	var color = "SPRING_GREEN" if display_score >= 0 else "TOMATO"
	score_lbl.text = "[center][color=gray][font_size=16]TOTAL FUNDS[/font_size][/color]\n[font_size=42][color=%s][pulse freq=2.0 color=#ffffff44]$ %s[/pulse][/color][/font_size][/center]" % [color, str(comma_sep(roundi(display_score)))]

func comma_sep(n: int) -> String:
	var s = str(abs(n))
	var res = ""
	for i in range(s.length()):
		if i > 0 and (s.length() - i) % 3 == 0:
			res += ","
		res += s[i]
	return ("-" if n < 0 else "") + res


func _format_hobbies(list: Array) -> String:
	return ", ".join(list.map(func(h): return ProfileData.Hobby.keys()[h].to_lower().replace("_", " ")))

func _add_pref_line(label_text: String, value_text: String, is_neg: bool, color := Color.WHITE):
	var bg = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color, 0.05)

	style.set_border_width_all(1)
	style.border_width_left = 5 
	style.border_color = Color(color, 0.4)
	style.content_margin_left = 15
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	bg.add_theme_stylebox_override("panel", style)

	var l = RichTextLabel.new()
	l.bbcode_enabled = true
	l.fit_content = true
	l.selection_enabled = false
	
	var display_text = ""
	if value_text == "":
		display_text = "[font_size=22][b]%s[/b][/font_size]" % label_text
	else:
		display_text = "[color=gray][font_size=16]%s[/font_size][/color]\n[font_size=20][b]%s[/b][/font_size]" % [label_text.to_upper(), value_text]

	var neg_tag = " [color=gray][i] Flexible[/i][/color]" if is_neg else ""
	l.text = "[color=%s]%s%s[/color]" % [color.to_html(), display_text, neg_tag]
	
	bg.add_child(l)
	pref_list.add_child(bg)
