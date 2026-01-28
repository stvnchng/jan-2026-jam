extends Resource
class_name ProfileData

@export var profile_name: String 
@export var age: int = 25
@export var height_cm: int = 172
@export var weight_kg: int = 70
@export var hobbies: Array = []
@export var drinks: Habit = Habit.SOCIALLY
@export var smokes: Habit = Habit.NO

@export_category("Preferences")
@export var min_age: int = 23
@export var max_age: int = 27
@export var min_height: int = 168
@export var max_height: int = 195
@export var alcoholics_welcome: bool = true
@export var smokers_welcome: bool = false
@export var likes: Array = []
@export var dislikes: Array = []

func get_title_f():
	return profile_name + ", " + str(age)

func get_height_f():
	return str(height_cm) + "cm"

func get_weight_f():
	return str(weight_kg) + "kg"

func get_hobbies_f():
	var get_hobby_s = func(h: String): return " ".join(h.split("_")).to_lower()
	var hobby_s = ", ".join(hobbies.map(func(h: String):
		return get_hobby_s.call(h)
	))
	return "Hobbies: " + hobby_s

func get_smokes_f():
	return "Smokes: " + Habit.keys()[smokes].to_lower()

func get_drinks_f():
	return "Drinks: " + Habit.keys()[drinks].to_lower()

const MIN_HEIGHT = 150
const MAX_HEIGHT = 210
static func create_random(age_bomb : bool = false) -> ProfileData:
	var p = ProfileData.new()
	p.profile_name = ["Alex", "Jordan", "Taylor", "Avery", "Riley", "Logan", "River", "Charlie", "Parker", "Rowen", "Harper", "Cameron", "Jamie", "Kelly", "Kris", "Terry", "Shannon"].pick_random()
	p.age = randi_range(20, 50)
	if age_bomb and randi_range(0, 10) < 1:
		p.age = 16
	p.height_cm = randi_range(MIN_HEIGHT, MAX_HEIGHT)
	p.weight_kg = randi_range(50, 110)
	p.hobbies = pick_hobbies(randi_range(2, 4))
	p.smokes = pick_smoke_habit()
	p.drinks = pick_drink_habit()
	return p

enum Habit {
	NO,
	SOCIALLY,
	YES
}

static func pick_habit_with_probability(yes, socially, no : float) -> Habit:
	var rng = RandomNumberGenerator.new()
	var num = rng.randf_range(0, yes+socially+no)
	if num < yes:
		return Habit.YES
	if num >= yes and num < yes+socially:
		return Habit.SOCIALLY
	return Habit.NO 

# pick smoking habits base on custom defined probabilities
static func pick_smoke_habit() -> Habit:
	return pick_habit_with_probability(10, 20, 70)
	
static func pick_drink_habit() -> Habit:
	return pick_habit_with_probability(30, 50, 20)

# Format: Hobby_name -> [chances of being hobbies, chances of being disliked]
static var Hobbies = {
	"CRYPTO": [3, 17],
	"ANIME": [10, 15],
	"TRAVELING": [20, 3],
	"GYM": [15, 6],
	"COOKING": [13, 8],
	"READING": [12, 6],
	"CLIMBING": [8, 9],
	"GAMBLING": [1, 20],
	"MOVIES": [10, 3],
}

static func pick_hobbies(num_hobbies : int = 100, pick_aversion: bool = false, skips : Array = []) -> Array:
	var result = []
	var hobby_picks = []
	# on what this index is -> see the description above Hobbies
	var hobby_index = 0
	if pick_aversion:
		hobby_index = 1
	for h in Hobbies:
		if h in skips:
			continue
		var v = Hobbies[h][hobby_index]
		for i in range(v):
			hobby_picks.append(h)
	num_hobbies = min(num_hobbies, len(Hobbies))
	for i in range(num_hobbies):
		var hobby = hobby_picks.pick_random()
		if not hobby in result:
			result.append(hobby)
	return result

static func pick_likes(num_hobbies : int = 100, skips : Array = []) -> Array:
	return pick_hobbies(num_hobbies, false, skips)

static func pick_aversions(num_hobbies : int = 100, skips : Array = []) -> Array:
	return pick_hobbies(num_hobbies, true, skips)
