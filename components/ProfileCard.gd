extends Panel
class_name ProfileCard

@onready var name_lbl: Label = $Margin/VBox/Name
@onready var height_lbl: Label = $Margin/VBox/Height
@onready var weight_lbl: Label = $Margin/VBox/Weight
@onready var hobbies: Label = $Margin/VBox/Hobbies

var base_pos: Vector2
var is_active := false
var original_style: StyleBoxFlat
var profile_data: ProfileData

func _ready():
	original_style = get_theme_stylebox("panel").duplicate()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	profile_data = _gen_rand_profile()
	set_info()

func set_info():
	name_lbl.text = profile_data.get_title_f()
	height_lbl.text = profile_data.get_height_f()
	weight_lbl.text = profile_data.get_weight_f()
	hobbies.text = profile_data.get_hobbies_f()

func lift_card(up: bool):
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if up:
		z_index = 100
		tween.tween_property(self, "position:y", -35, 0.2)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
		tween.tween_property(self, "rotation_degrees", 3.0, 0.2)
	else:
		z_index = get_index()
		tween.tween_property(self, "position:y", 0, 0.2)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(self, "rotation_degrees", 0.0, 0.2)

func _gen_rand_profile() -> ProfileData:
	var p_data = ProfileData.new()
	p_data.age += randi_range(-3, 8)
	p_data.height_cm += randi_range(-10, 25)
	p_data.weight_kg += randi_range(-10, 20)
	var rand_hobbies = ProfileData.Hobby.values().duplicate()
	rand_hobbies.shuffle()
	p_data.hobbies = rand_hobbies.slice(0, 4)
	return p_data

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				toggle_select()

func toggle_select():
	is_active = !is_active
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if is_active:
		z_index = 200
		tween.tween_property(self, "position:y", -500, 0.4)
		tween.tween_property(self, "rotation_degrees", 0.0, 0.2)
		var sb = original_style.duplicate()
		if sb is StyleBoxFlat:
			sb.border_color = Color.GOLD
			add_theme_stylebox_override("panel", sb)
	else:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", original_style.duplicate())
		lift_card(false)

func _on_mouse_entered():
	if is_active: return
	z_index = 1000
	lift_card(true)

func _on_mouse_exited():
	if is_active: return
	lift_card(false)
