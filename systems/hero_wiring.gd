## Connects the hero manager, its panel and the input router. Holds no rules: purchases are
## reported through `spent` so Main (which owns gold) deducts the cost.
class_name HeroWiring
extends Node

signal spent(amount: int)

var gold_of: Callable   # () -> int, current gold


func setup(hero_mgr: HeroManager, panel: HeroPanel, router: InputRouter, gold_getter: Callable) -> void:
	gold_of = gold_getter
	hero_mgr.changed.connect(func() -> void: panel.set_info(hero_mgr.info()))
	panel.buy_pressed.connect(func(k: String) -> void: spent.emit(hero_mgr.try_buy(k, gold_of.call())))
	panel.evolve_pressed.connect(func(id: String) -> void: spent.emit(hero_mgr.try_evolve(id, gold_of.call())))
	panel.move_pressed.connect(hero_mgr.toggle_select)
	router.intercept = hero_mgr.intercept
