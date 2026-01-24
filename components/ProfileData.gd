extends Resource
class_name ProfileData

@export var profile_name: String = "Jubba Johnson"
@export var age: int = 25
@export var height_cm: int = 172
@export var weight_kg: int = 70
@export var hobbies: Array = [Hobby.CRYPTO, Hobby.GAMBLING, Hobby.MATCHA_LATTE, Hobby.DEBATING]
@export var drinks: Habit = Habit.SOCIALLY
@export var smokes: Habit = Habit.NO

@export_category("Preferences")
@export var min_age: int = 23
@export var max_age: int = 27
@export var age_negotiable: bool = true
@export var min_height: int = 168
@export var max_height: int = 195
@export var height_negotiable: bool = false
@export var min_weight: int = 60
@export var max_weight: int = 90
@export var weight_negotiable: bool = true
@export var alcoholics_welcome: bool = true
@export var smokers_welcome: bool = false
@export var dealbreaker_hobbies: Array = [Hobby.CRYPTO, Hobby.GAMBLING]

func get_title_f():
	return profile_name + ", " + str(age)

func get_height_f():
	return str(height_cm) + "cm"

func get_weight_f():
	return str(weight_kg) + "kg"

func get_hobbies_f():
	var get_hobby_s = func(h: Hobby): return " ".join(Hobby.keys()[h].split("_")).to_lower()
	var hobby_s = ", ".join(hobbies.map(func(h: Hobby):
		return get_hobby_s.call(h)
	))
	return "Hobbies: " + hobby_s

func get_smokes_f():
	return "Smokes: " + Habit.keys()[smokes].to_lower()

func get_drinks_f():
	return "Drinks: " + Habit.keys()[drinks].to_lower()

enum Habit {
	NO,
	SOCIALLY,
	YES
}

# enum starts at 0, so order hobbies by least -> most attractive for scoring
enum Hobby {
	GAMBLING,
	CRYPTO,
	ANIME,
	DRINKING,
	DEBATING,
	TRAVELING,
	LABUBU,
	MATCHA_LATTE,
	COOKING,
	READING
}
