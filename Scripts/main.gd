extends Control


# NODE REFERENCES
# These locate scene nodes after the scene is ready

@onready var money_label: Label = $MarginContainer/PanelContainer/MarginContainer/MainLayout/MoneyBar/MoneyLabel
@onready var eggs_label: Label = $MarginContainer/PanelContainer/MarginContainer/MainLayout/ContentRow/CookingSpace/MarginContainer/VBoxContainer/EggsLabel
@onready var cooking_progress_bar: ProgressBar = $MarginContainer/PanelContainer/MarginContainer/MainLayout/ContentRow/CookingSpace/MarginContainer/VBoxContainer/CookingProgressBar
@onready var cooking_animation_player: AnimationPlayer = $CookingAnimationPlayer
@onready var cooking_timer: Timer = $CookingTimer
@onready var cooking_speed_upgrade_button: Button = $MarginContainer/PanelContainer/MarginContainer/MainLayout/ContentRow/Upgrades/MarginContainer/VBoxContainer/CookingSpeedUpgradeButton
@onready var coffee_station_button: Button = $MarginContainer/PanelContainer/MarginContainer/MainLayout/ContentRow/Upgrades/MarginContainer/VBoxContainer/CoffeeStationButton
@onready var buy_egg_button: Button = $MarginContainer/PanelContainer/MarginContainer/MainLayout/ContentRow/CookingSpace/MarginContainer/VBoxContainer/EggActionRow/BuyEggButton
@onready var serve_egg_button: Button = $MarginContainer/PanelContainer/MarginContainer/MainLayout/ContentRow/CookingSpace/MarginContainer/VBoxContainer/EggActionRow/ServeEggButton



# RESOURCES
# These values persist for as long as this scene exists

var money: float = 10.0
var eggs: int = 6
var cooked_eggs: int = 0
var coffee: int = 0
var coffee_beans: int = 0

# EGG ECONOMY

var egg_purchase_quantity: int = 6
var egg_purchase_price: float = 3.00
var cooked_egg_sale_price: float = 2.00

# COOKING
# Setting and state specifically related to cooking

var cooking_speed: int = 1
var eggs_per_cook: int = 1
var base_cook_time: float = 5.0
var is_cooking: bool = false

# OUTPUT

var eggs_output: int = 1

# UPGRADE AND UNLOCK COSTS

var cooking_speed_cost: int = 2
var coffee_station_cost: float = 25.0
var coffee_station_unlocked: bool = false
var coffee_beans_cost: float = 5.0



# LIFECYCLE FUNCTIONS

func _ready() -> void:
	cooking_progress_bar.value = 0
	update_text()
	
func _process(_delta: float) -> void:
	if not cooking_timer.is_stopped():
		cooking_progress_bar.value = (
			1 - cooking_timer.time_left / cooking_timer.wait_time
	) * 100.0



# COOKING FLOW FUNCTIONS

func _on_cook_button_pressed() -> void:
	_cook_eggs()
	
func _cook_eggs() -> void:
	if is_cooking or eggs < eggs_per_cook:
		return
	
	is_cooking = true
	eggs -= eggs_per_cook
	cooking_progress_bar.value = 0.0
	cooking_animation_player.play("egg_crack")
	update_text()

func _on_cooking_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "egg_crack":
		var duration: float = base_cook_time / cooking_speed
		
		cooking_animation_player.play("cook")
		cooking_timer.start(duration)

func _on_cooking_timer_timeout() -> void:
	cooking_progress_bar.value = 0.0
	cooking_animation_player.stop()
	
	cooked_eggs += eggs_output
	is_cooking = false
	
	update_text()
	
# EGG ECONOMY FUNCTIONS

func _on_buy_egg_button_pressed() -> void:
	if money >= egg_purchase_price:
		money -= egg_purchase_price
		eggs += egg_purchase_quantity
		update_text()
	
func _on_serve_egg_button_pressed() -> void:
	if cooked_eggs >= 1:
		cooked_eggs -= 1
		money += cooked_egg_sale_price
		update_text()

# UPGRADE FUNCTIONS

func _on_speed_upgrade_button_pressed() -> void:
	if money >= cooking_speed_cost: # If i can afford the upgrade
		money -= cooking_speed_cost # Subtract speed_cost
		cooking_speed += 1 # Reward increase the speed
		cooking_animation_player.speed_scale = cooking_speed
		cooking_speed_cost += 1
		update_text()

# UPDATE TEXT FUNCTIONS

func update_text():
	money_label.text = "Money: $%.2f" % money
	eggs_label.text = "Eggs: " + str(eggs) + "  Cooked Eggs:" + str(cooked_eggs)
	cooking_speed_upgrade_button.text = "Cooking Speed \nPrice: $" + str(cooking_speed_cost) + "\nCurrent Speed: " + str(cooking_speed)
	buy_egg_button.text = "BUY 6 EGGS\n$%.2f" % egg_purchase_price
