extends Resource
class_name ProfileData

@export var profile_name: String = "Jubba Johnson"
@export var age: int = 25
@export var height_cm: int = 172
@export var weight_kg: int = 70
@export var hobbies: Array = [Hobby.CRYPTO, Hobby.GAMBLING, Hobby.MATCHA_LATTE, Hobby.DEBATING]

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
