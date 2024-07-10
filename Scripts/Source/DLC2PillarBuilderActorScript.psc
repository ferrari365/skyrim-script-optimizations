Scriptname DLC2PillarBuilderActorScript extends Actor  
{Script attached to anyone who is or might become a pillar builder. Handles removing them from faction if the pillar is destroyed.}

;NOTE: see also DLC2PillarBuilderScript which is on aliases in DLC2Pillar quest that handle adding someone to the builder faction after the game starts

DLC2PillarScript Property DLC2Pillar auto
{AUTOFILL THIS PROPERTY}

;/ ferrari365 - this script has been pretty much rewritten from scratch with states for better scenario handling, improved 
	performance and reduced amount of external calls. It should now manage the factions a lot better and not run updates
	even after the DLC's main quest has been completed. The 2 vanilla events have been commented out below for comparison.

event OnLoad()
; 	Debug.Trace(self + "OnLoad() will call CheckMyPillarToggle()")
	DLC2Pillar.CheckMyPillarToggle(self)

endEvent

Event OnPackageStart(Package akNewPackage)
; 	Debug.Trace(self + "OnPackageStart()")
	if akNewPackage.GetTemplate() == DLC2Pillar.DLC2SleepBuild
		DLC2Pillar.SetBuilderFactionFriendliness(self, IsSleepBuildTemplate = true)
	else
		DLC2Pillar.SetBuilderFactionFriendliness(self, IsSleepBuildTemplate = false)
	endif

endEvent
/;

; caching the linked pillar, the sleepbuilding package and the 2 factions that will be managed
ObjectReference myPillarToggleLink
Faction DLC2PillarBuilderFaction
Faction dunPrisonerFaction
Package DLC2SleepBuild

; empty state for when we shouldn't be doing anything anymore
State BuildNoMore
	; empty state
EndState

; default state - decides if we should start checking for package updates, or go to BuildNoMore state if nothing else should be done
Auto State WaitingForBuilding
	; decide which state to go to when the player enters the NPC's cell
	Event OnCellAttach()
		; initialize the pillar and the pillar faction if they're not already
		If !DLC2PillarBuilderFaction
			DLC2PillarBuilderFaction = DLC2Pillar.DLC2PillarBuilderFaction
		EndIf

		If !myPillarToggleLink
			myPillarToggleLink = GetLinkedRef(DLC2Pillar.DLC2LinkPillarToggle)
		EndIf

		; if the linked pillar is None, don't proceed
		If !myPillarToggleLink
			GoToState("BuildNoMore")
		; if the link is valid, but disabled, don't proceed
		ElseIf myPillarToggleLink.IsDisabled()
			GoToState("BuildNoMore")
			; remove the actor from the pillar faction, if it's still in it (in case the player destoyed the pillar while the NPC was not loaded in)
			If IsInFaction(DLC2PillarBuilderFaction)
				RemoveFromFaction(DLC2PillarBuilderFaction)
			EndIf
		Else
			; actor is valid to start being checked for package updates
			GoToState("ShouldBeBuilding")
		Endif
	EndEvent

	; same as OnCellAttach, but handles NPCs that enter the cell the player is currently in
	Event OnAttachedToCell()
		If !DLC2PillarBuilderFaction
			DLC2PillarBuilderFaction = DLC2Pillar.DLC2PillarBuilderFaction
		EndIf

		If !myPillarToggleLink
			myPillarToggleLink = GetLinkedRef(DLC2Pillar.DLC2LinkPillarToggle)
		EndIf

		If !myPillarToggleLink
			GoToState("BuildNoMore")
		ElseIf myPillarToggleLink.IsDisabled()
			GoToState("BuildNoMore")
			If IsInFaction(DLC2PillarBuilderFaction)
				RemoveFromFaction(DLC2PillarBuilderFaction)
			EndIf
		Else
			GoToState("ShouldBeBuilding")
		Endif
	EndEvent
EndState

; manages adding and removing the Prisoner faction from the NPC - used for encapsulation of the updates only when there's a reason for them
State ShouldBeBuilding
	; runs a single package check initially, in case we need to currently add/remove the prisoner faction
	Event OnBeginState()
		; initialize the prisoner faction and the package, if they're not already
		If !dunPrisonerFaction
			dunPrisonerFaction = DLC2Pillar.dunPrisonerFaction
		EndIf

		If !DLC2SleepBuild
			DLC2SleepBuild = DLC2Pillar.DLC2SleepBuild
		EndIf

		; check current package for validity and don't do anything if it's not valid (can rarely be None, e.g. if the NPC is disabled)
		Package currentPackage = GetCurrentPackage()
		If !currentPackage
			GoToState("BuildNoMore")
		; if the NPC is currently sleepwalk-building and doesn't have the faction, add it in (if the player arrives at the NPC's location at their sleepwalking times)
		ElseIf currentPackage.GetTemplate() == DLC2SleepBuild
			If !IsInFaction(dunPrisonerFaction)
				AddToFaction(dunPrisonerFaction)
			EndIf
		; if the NPC is not sleepwalking, but still has the faction for some reason, remove it
		elseIf IsInFaction(dunPrisonerFaction)
			RemoveFromFaction(dunPrisonerFaction)
		EndIf
	EndEvent

	; the package update check - will add the prisoner faction if the NPC is sleepwalking and remove it if not
	Event OnPackageStart(Package akNewPackage)
		; do the check only if the linked pillar is not destroyed - in case the player destroyed it while the NPC was not loaded in
		If !myPillarToggleLink.IsDisabled()
			; if the NPC is currently sleepwalk-building and doesn't have the faction, add it in
			If akNewPackage.GetTemplate() == DLC2SleepBuild
				If !IsInFaction(dunPrisonerFaction)
					AddToFaction(dunPrisonerFaction)
				EndIf
			; if the NPC is not sleepwalking, but still has the faction for some reason, remove it
			ElseIf IsInFaction(dunPrisonerFaction)
				RemoveFromFaction(dunPrisonerFaction)
			Endif
		Else
			; if the pillar is destroyed and the NPC was no loaded in - the pillar faction won't be removed - remove it in this case
			GoToState("BuildNoMore")
			If IsInFaction(DLC2PillarBuilderFaction)
				RemoveFromFaction(DLC2PillarBuilderFaction)
			EndIf
		EndIf
	endEvent

	; the events below are used to manage exiting the state if the NPC was not around for 12 hours to avoid the infinite updates of the vanilla script
	; Detach and Detached for registration to exit, Attach and Attached for unregistration
	Event OnCellAttach()
		UnregisterForUpdateGameTime()
	EndEvent

	Event OnAttachedToCell()
		UnregisterForUpdateGameTime()
	EndEvent
	
	Event OnCellDetach()
		RegisterForSingleUpdateGameTime(12.0)
	EndEvent

	Event OnDetachedFromCell()
		RegisterForSingleUpdateGameTime(12.0)
	EndEvent
	
	Event OnUpdateGameTime()
		GoToState("WaitingForBuilding")
	EndEvent
EndState
