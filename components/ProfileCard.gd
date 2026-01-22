extends Panel
class_name ProfileCard

@onready var name_lbl: Label = $Margin/VBox/Name
@onready var height_lbl: Label = $Margin/VBox/Height
@onready var weight_lbl: Label = $Margin/VBox/Weight
@onready var hobbies: Label = $Margin/VBox/Hobbies

var base_pos: Vector2
var is_active := false

func _ready():
	set_info()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_info():
	# TODO pass in stats when data model is done and set
	name_lbl.text = "Potential Partner #" + str(get_index())

func _on_mouse_entered():
	if is_active: return
	z_index = 1000
	lift_card(true)

func _on_mouse_exited():
	if is_active: return
	lift_card(false)

func lift_card(up: bool):
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if up:
		z_index = 100
		tween.tween_property(self, "position:y", -30, 0.2)
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)
		tween.tween_property(self, "rotation_degrees", 2.0, 0.2)
	else:
		z_index = get_index()
		tween.tween_property(self, "position:y", 0, 0.2)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(self, "rotation_degrees", 0.0, 0.2)


func toggle_select():
	is_active = !is_active
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if is_active:
		z_index = 200
		tween.tween_property(self, "position:y", -200, 0.4)
		var sb = get_theme_stylebox("CardStyleBox").duplicate()
		sb.border_color = Color.GOLD
		add_theme_stylebox_override("CardStyleBox", sb)
	else:
		add_theme_stylebox_override("CardStyleBox", null)
		lift_card(false)
