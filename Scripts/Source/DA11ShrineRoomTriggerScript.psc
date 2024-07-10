ScriptName DA11ShrineRoomTriggerScript extends ReferenceAlias

ReferenceAlias Property pVerulus Auto
; DA11QuestScript var
DA11QuestScript Property pDA11QuestScript auto
bool shutdown = false

Event OnTriggerEnter(ObjectReference akActionRef)

	If (akActionRef == pVerulus.GetReference())
; 		Debug.Trace("Set iVerulusAtShrine to 1")
; 		Debug.Trace("pDA11QuestScript = " + pDA11QuestScript)
		pDA11QuestScript.iVerulusAtShrine = 1
		Quest DA11 = GetOwningQuest()
		If !DA11.IsStageDone(45)
			DA11.SetCurrentStageID(45)
		EndIf
	EndIf
	
EndEvent

Event OnTriggerLeave(ObjectReference akActionRef)

	If (akActionRef == pVerulus.GetReference())
; 		Debug.Trace("Set iVerulusAtShrine to 0")
		pDA11QuestScript.iVerulusAtShrine = 0
	EndIf	
	
EndEvent	

Event OnCellDetach()
	If GetOwningQuest().GetCurrentStageID() == 100 && !shutdown
		RegisterForSingleUpdateGameTime(12.0)
		shutdown = true
	EndIf
EndEvent

Event OnUpdateGameTime()
	Cell namiraShrine = GetReference().GetParentCell()
	If !namiraShrine.IsAttached()
		GetOwningQuest().SetCurrentStageID(600)
	Else
		RegisterForSingleUpdateGameTime(12.0)
	EndIf
EndEvent