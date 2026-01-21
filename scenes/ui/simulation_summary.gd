extends Control
class_name SimulationSummary

@onready var Dauer_label = $HFlowContainer/Dauer
@onready var FutterGegessen_label = $HFlowContainer/FutterGegessen
@onready var FuttermengeGegessen_label = $HFlowContainer/FuttermengeGegessen
@onready var LängsterArm_label = $"HFlowContainer/LängsterArm"

func _on_world_statistik_send_data_to_summary(_time: float, _foodEaten: int, _foodAmountEaten: float, _longestArm: int) -> void:
	Dauer_label.text = str(_time)
	FutterGegessen_label.text = str(_foodEaten)
	FuttermengeGegessen_label = str(_foodAmountEaten)
	LängsterArm_label.text = str(_longestArm)
