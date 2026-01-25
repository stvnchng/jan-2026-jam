extends Panel
class_name ClientView

@onready var profile_lbl: RichTextLabel = $Margin/VBox/ProfileSummary
@onready var pref_list = $Margin/VBox/PrefList

func setup(data: ProfileData):
	profile_lbl.text = "[center][font_size=24][b]%s[/b][/font_size]\n[color=gray]%s | %s[/color][/center]" % [
		data.get_title_f(),
		data.get_drinks_f(), 
		data.get_smokes_f()
	]
	
	for child in pref_list.get_children():
		child.queue_free()

	if !data.age_negotiable or (data.max_age - data.min_age < 10):
		_add_pref_line("Age Range", "%d-%d" % [data.min_age, data.max_age], data.age_negotiable)

	if data.min_height > 160 or !data.height_negotiable:
		_add_pref_line("Preferred Height", "%dcm+" % data.min_height, data.height_negotiable)

	if !data.smokers_welcome:
		_add_pref_line("Lifestyle", "Non-smokers only", false, Color.TOMATO)

	if !data.likes.is_empty():
		_add_pref_line("Interests", _format_hobbies(data.likes), false, Color.SPRING_GREEN)

	if !data.dislikes.is_empty():
		_add_pref_line("Personal Aversions", _format_hobbies(data.dislikes), false, Color.GOLD)

func _format_hobbies(list: Array) -> String:
	return ", ".join(list.map(func(h): return ProfileData.Hobby.keys()[h].to_lower().replace("_", " ")))


func _add_pref_line(label_text: String, value_text: String, is_neg: bool, color := Color.WHITE):
	var lbl = RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.fit_content = true
	var neg_tag = " [color=gray][i](Flexible)[/i][/color]" if is_neg else ""
	lbl.text = "[font_size=20][color=%s]• %s:[/color] %s%s[/font_size]" % [color.to_html(), label_text, value_text, neg_tag]
	pref_list.add_child(lbl)
	
	lbl.modulate.a = 0
	var tw = create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.4).set_delay(pref_list.get_child_count() * 0.1)
