extends Resource
class_name ProfileData

@export var profile_name: String = "Jubba Johnson"
@export var age: int = 25
@export var height_cm: int = 172
@export var weight_kg: int = 70
@export var hobbies: Array = []
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
@export var likes: Array = []
@export var dislikes: Array = []
@export var dealbreakers: Array = []

func get_compatibility_score(candidate: ProfileData) -> int:
	var score = 0
	var multiplier = 1.0
	for hobby in candidate.hobbies:
		if hobby in likes:
			score += 1
		if hobby in dislikes:
			if hobby >= Hobby.CLEANING:
				score += 10
				multiplier += 0.2
			else:
				score -= 10
	
	if candidate.age >= min_age and candidate.age <= max_age:
		score += 20
		var age_gap = abs(candidate.age - age)
		score += max(0, 10 - age_gap)
	else:
		var out_of_range = min(abs(candidate.age - min_age), abs(candidate.age - max_age))
		var penalty = out_of_range * 15
		score -= (penalty * 0.5) if age_negotiable else penalty
	
	var h_diff = candidate.height_cm - height_cm
	if h_diff >= 5 and h_diff <= 20:
		score += 15
	elif h_diff < 0 and !height_negotiable:
		score -= 20
	
	if !smokers_welcome and candidate.smokes == Habit.YES:
		score -= 40
		multiplier *= 0.8
	
	if candidate.drinks == Habit.YES and !alcoholics_welcome:
		score -= 30
	
	return roundi(score * multiplier)

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
	TRAVELING,
	MATCHA_LATTE,
	# cleaning and above can be complementary
	CLEANING,
	FITNESS,
	COOKING,
	READING
}
