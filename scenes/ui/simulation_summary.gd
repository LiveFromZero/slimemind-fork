extends Control
class_name SimulationSummary

@onready var Dauer_label = $HFlowContainer/Dauer
@onready var FutterGegessen_label = $HFlowContainer/FutterGegessen
@onready var FuttermengeGegessen_label = $HFlowContainer/FuttermengeGegessen
@onready var LängsterArm_label = $"HFlowContainer/LängsterArm"
@onready var countDeadSegmentsLabel = $HFlowContainer/AnzahlToterSegmente

func _on_world_statistik_send_data_to_summary(_time: String, _foodEaten: int, _foodAmountEaten: float, _longestArm: int, _countDeadSegments:int) -> void:
	Dauer_label.text = "Dauer der Simulation: " + _time
	FutterGegessen_label.text = "Anzahl an Futterquellen, die vollständig gefressen wurden: " + str(_foodEaten)
	FuttermengeGegessen_label = "Futtermenge gegessen: " +  str(_foodAmountEaten)
	LängsterArm_label.text = "längster Arm: " + str(_longestArm) # potenziell redundant
	countDeadSegmentsLabel.text = "Anzahl toter Arme: " + str(_countDeadSegments)
