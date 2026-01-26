extends Panel
class_name ProfileCard

signal selected(card_ref: ProfileCard)

@onready var name_lbl: Label = $Margin/VBox/Name
@onready var height_lbl: Label = $Margin/VBox/Height
@onready var weight_lbl: Label = $Margin/VBox/Weight
@onready var hobbies: Label = $Margin/VBox/Hobbies
@onready var smokes_lbl: Label = $Margin/VBox/Smokes
@onready var drinks_lbl: Label = $Margin/VBox/Drinks

var base_pos: Vector2
var is_active := false
var original_style: StyleBoxFlat
var profile_data: ProfileData

func _ready():
	original_style = get_theme_stylebox("panel").duplicate()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_info()

func set_info():
	name_lbl.text = profile_data.get_title_f()
	height_lbl.text = profile_data.get_height_f()
	weight_lbl.text = profile_data.get_weight_f()
	hobbies.text = profile_data.get_hobbies_f()
	smokes_lbl.text = profile_data.get_smokes_f()
	drinks_lbl.text = profile_data.get_drinks_f()

func lift_card(up: bool):
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var current_style = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", current_style)
	if up:
		z_index = 100
		tween.tween_property(self, "position:y", -35, 0.2)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
		tween.tween_property(self, "rotation_degrees", 3.0, 0.2)
		tween.tween_property(current_style, "shadow_color", Color(0, 0, 0, 0.12), 0.2)
		tween.tween_property(current_style, "shadow_size", 18, 0.2)
		tween.tween_property(current_style, "shadow_offset", Vector2(0, 12), 0.2)
	else:
		z_index = get_index()
		tween.tween_property(self, "position:y", 0, 0.2)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(self, "rotation_degrees", 0.0, 0.2)
		tween.tween_property(current_style, "shadow_color", Color(0, 0, 0, 0.05), 0.2)
		tween.tween_property(current_style, "shadow_size", 4, 0.2)
		tween.tween_property(current_style, "shadow_offset", Vector2(0, 2), 0.2)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				selected.emit(self)

func update_selection_visuals(active: bool):
	is_active = active
	if is_active:
		var sb = original_style.duplicate()
		if sb is StyleBoxFlat:
			sb.border_color = Color.GOLD
			add_theme_stylebox_override("panel", sb)
	else:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", original_style.duplicate())

func _on_mouse_entered():
	if is_active: return
	lift_card(true)

func _on_mouse_exited():
	if is_active: return
	lift_card(false)
