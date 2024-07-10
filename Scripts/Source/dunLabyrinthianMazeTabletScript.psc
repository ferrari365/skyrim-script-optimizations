Scriptname dunLabyrinthianMazeTabletScript extends ObjectReference  
{Script for the magic target tablets in Labyrinthian's Maze}

bool Property isDestruction Auto
bool Property isAlteration Auto
bool Property isRestoration Auto
bool Property isIllusion Auto

Sound Property WrongSpellSFX  Auto  
Sound Property CorrectSpellSFX  Auto  

dunLabyrinthianMazeControlScript Property MazeControl Auto

bool Property done Auto
bool Property FXon Auto hidden

ObjectReference Property linkToActivate Auto
bool continueUpdating = false

; ferrari365 - for caching the player later
Actor PlayerRef

; ferrari365 - check for completion on repeat visits
Event OnCellAttach()
	If !done
		If !PlayerRef
			PlayerRef = Game.GetForm(0x14) As Actor
		EndIf
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent

; ferrari365 - run updates only if the tablet is not "solved" yet and the player is in the same cell
Event OnUpdate()
	If done
		continueUpdating = !done
		Return
	EndIf

	continueUpdating = Is3DLoaded()
	If continueUpdating
		float distanceToPlayer = PlayerRef.GetDistance(self)
		If !FXon && distanceToPlayer < 512.0
			; if the player is nearby, turn on the FX anim
			PlayAnimation("playanim02")
			FXon = true
		ElseIf FXon && distanceToPlayer > 768.0
			; and if the player walks away without solving, turn them off
			PlayAnimation("playanim01")
			FXon = false
		EndIf

		RegisterForSingleUpdate(1.0)
	EndIf

;/ ferrari365 - original logic
	if !FXon
		if game.getPlayer().getDistance(self) < 512 && done == FALSE
			; if the player is nearby, turn on the FX anim
			playAnimation("playanim02")
			FXon = TRUE
		endif
	else
		if game.getPlayer().getDistance(self) > 768 && done == FALSE
			; and if the player walks away without solving, turn them off
			playAnimation("playanim01")
			FXon = FALSE
		endif
	endif

	if continueUpdating
		registerForSingleUpdate(1.0)
	endif
/;
EndEvent

Event OnActivate(ObjectReference actronaut)
	; Not meant to be activated directly.  Play negative feedbackSFX
	WrongSpellSFX.Play(self)
EndEvent

Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
; 	debug.trace("hit by "+akCaster+" with "+akEffect)
	; for now we can't test school so react to any magic effect
	If !done
		; ferrari365 - cache the magic effect school
		string schoolOfMagic = akEffect.GetAssociatedSkill()

		; if (akEffect.getAssociatedSkill() == "Destruction") && isDestruction
		If (schoolOfMagic == "Destruction") && isDestruction
			SolveMe(akCaster)

		; elseif (akEffect.getAssociatedSkill() == "Alteration") && isAlteration
		ElseIf (schoolOfMagic == "Alteration") && isAlteration
			SolveMe(akCaster)
			
		; elseif (akEffect.getAssociatedSkill() == "Restoration") && isRestoration
		ElseIf (schoolOfMagic == "Restoration") && isRestoration
			SolveMe(akCaster)

		; elseif (akEffect.getAssociatedSkill() == "Illusion") && isIllusion
		ElseIf (schoolOfMagic == "Illusion") && isIllusion
			SolveMe(akCaster)
		Else
			; Must have been hit with an incorrect spell type.  Play negative feedback SFX
			WrongSpellSFX.play(self)
		EndIf
	EndIf
EndEvent

Function SolveMe(ObjectReference whoSolved)
	If isDestruction
		MazeControl.bDestructionClear = true
	ElseIf isAlteration
		MazeControl.bAlterationClear = true
	ElseIf isRestoration
		MazeControl.bRestorationClear = true
	ElseIf isIllusion
		MazeControl.bIllusionClear = true
	EndIf
	done = true
	;unregisterForUpdate()
	continueUpdating = !done
	PlayAnimation("playanim01")
	CorrectSpellSFX.Play(self)
	linkToActivate.Activate(whoSolved)
	linkToActivate.SetOpen()
	MazeControl.CheckMaze()
EndFunction