ScriptName DA11GlooredhelScript extends ReferenceAlias

Location Property pReachcliffCaveLocation Auto
Location Property pMarkarthHalloftheDead Auto
ObjectReference Property pReachcliffCaveInsideEntranceMarker Auto
Scene Property pGlooredhelForcegreetReachcliff Auto
ObjectReference Property pReachcliffState1Marker Auto
ObjectReference Property pReachcliffState2Marker Auto

Quest DA11
Actor GlooredhelREF

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	If !DA11
		DA11 = GetOwningQuest()
	EndIf
	if (akTarget == Game.GetPlayer())
		if (aeCombatState == 1) && (!DA11.IsStageDone(225)) && (DA11.IsStageDone(40))
			DA11.SetCurrentStageID(225)
		endIf
	endIf
endEvent

Event OnDeath(Actor akKiller)

	If !DA11
		DA11 = GetOwningQuest()
	EndIf
	;if Glooredhel dies, fail the Quest
	DA11.SetCurrentStageID(250)

EndEvent

Event OnCellDetach()

	If !DA11
		DA11 = GetOwningQuest()
	EndIf
	If !GlooredhelREF
		GlooredhelREF = Self.GetReference() as Actor
	EndIf
	;if the player encountered Glooredhel in the Hall of the Dead, move her to Reachcliff Cave
	If (DA11.GetCurrentStageID() == 10) && (pReachcliffCaveLocation != GlooredhelREF.GetCurrentLocation())
		GlooredhelREF.MoveTo(pReachcliffCaveInsideEntranceMarker)
	EndIf

	;If (GetOwningQuest().GetStageDone(17) == 1) && (pMarkarthHalloftheDead == Self.GetActorRef().GetCurrentLocation())
	;	Self.GetActorRef().MoveTo(pGlooredhelTravelMarker)
	;	GetOwningQuest().SetStage(20)
	;EndIf

	;State change for Reachcliff Cave when the player has taken over the cave
	If (DA11.IsStageDone(30)) && (pReachcliffState2Marker.IsDisabled())
; 		debug.Trace("Switching states in Reachcliff Cave")
; 		debug.Trace("Disabling Reachcliff Normal Marker")
		pReachcliffState1Marker.Disable()
; 		debug.Trace("Enabling Reachcliff DA11 Marker")
		pReachcliffState2Marker.Enable()
	EndIf

	;/ quest shutdown - relegated to DA11ShrineRoomTriggerScript

	;Move all the cultists back to Markarth
	If (GetOwningQuest().GetStageDone(100) == 1) && (GetOwningQuest().GetStageDone(600) == 0)
		GetOwningQuest().SetStage(600)
	EndIf
	/;
EndEvent

ObjectReference Property pGlooredhelTravelMarker  Auto  
