## Data table for economy/defence buildings (like Tower.TYPES). Add a building = add an entry.
## income: gold per `interval` seconds. pop_use: population it needs. pop_cap: population it adds.
class_name Buildings
extends RefCounted

const TYPES := {
	"farm": {"name": "Farm", "cost": 40, "hp": 60.0, "income": 5, "interval": 5.0, "pop_use": 1, "pop_cap": 0, "color": Color(0.85, 0.75, 0.25)},
	"lumber": {"name": "Lumber", "cost": 60, "hp": 70.0, "income": 8, "interval": 5.0, "pop_use": 1, "pop_cap": 0, "color": Color(0.5, 0.33, 0.15)},
	"house": {"name": "House", "cost": 50, "hp": 80.0, "income": 0, "interval": 5.0, "pop_use": 0, "pop_cap": 4, "color": Color(0.75, 0.4, 0.3)},
	"wall": {"name": "Wall", "cost": 10, "hp": 250.0, "income": 0, "interval": 5.0, "pop_use": 0, "pop_cap": 0, "color": Color(0.55, 0.55, 0.58)},
}
