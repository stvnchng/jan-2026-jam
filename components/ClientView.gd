extends Panel
class_name ClientView

@onready var profile_lbl = $Margin/VBox/ProfileSummary
@onready var pref_list = $Margin/VBox/PrefList

func setup(data: ProfileData):
	profile_lbl.text = "%s (%s)\n%s | %s" % [
		data.profile_name, data.age, 
		data.get_drinks_f(), data.get_smokes_f()
	]
	
	for child in pref_list.get_children():
		child.queue_free()
	
	_add_pref_line("Age", "%d - %d" % [data.min_age, data.max_age], data.age_negotiable)
	_add_pref_line("Height", "%d - %d cm" % [data.min_height, data.max_height], data.height_negotiable)
	
	if not data.smokers_welcome:
		_add_pref_line("Lifestyle", "NO SMOKERS", false, Color.TOMATO)
	
	if not data.dealbreaker_hobbies.is_empty():
		var hobbies_str = ", ".join(data.dealbreaker_hobbies.map(func(h): return ProfileData.Hobby.keys()[h]))
		_add_pref_line("Hates", hobbies_str, false, Color.TOMATO)

func _add_pref_line(label_text: String, value_text: String, is_neg: bool, color := Color.WHITE):
	var label = Label.new()
	var neg_text = " (Flexible)" if is_neg else " (Strict)"
	label.text = "- %s: %s%s" % [label_text, value_text, neg_text]
	label.add_theme_color_override("font_color", color)
	pref_list.add_child(label)
