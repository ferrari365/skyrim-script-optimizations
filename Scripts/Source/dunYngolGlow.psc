ScriptName dunYngolGlow extends ObjectReference
{Script for glowy objects that follow player in this space}
; Import Debug
Import Game
Import Utility

; float transX
; float transY
; float transZ

ObjectReference property myTarget auto
Cell property myHomeCell auto
Quest property myQuest auto
Sound Property QSTYngolLightMotesSD auto

bool continueUpdating = false

Event OnActivate(ObjectReference actronaut)
	ApplyHavokImpulse(0.0, 8.0, 64.0, 8.0)			; little character bob when turned on
	Wait(0.2)
	ApplyHavokImpulse(64.0, 0.0, 8.0, 8.0)			; little character bob when turned on
	ObjectReference LinkedRef = GetLinkedRef() ; ferrari365 - cache the linked ref to save a function call
	If LinkedRef
		LinkedRef.Activate(self)
	EndIf
	myTarget = GetForm(0x14) As Actor
	RegisterForSingleUpdate(RandomFloat(1.5, 2.0))
	GotoState("active")
EndEvent

State Active
	; ferrari365 - additional event to resume the update if the player left the dungeon without completing it
	Event OnCellAttach()
		RegisterForSingleUpdate(RandomFloat(1.5, 2.0))
	EndEvent

	Event OnActivate(ObjectReference actronaut)
		; empty for now!
	EndEvent

	Event OnUpdate()
		If myQuest.IsStageDone(50)
			continueUpdating = false
			Delete()
			GotoState("dead")
			Return
		EndIf

		;/
		ferrari365 - stop the updates, If the player is not in the same cell
		for some reason Is3DLoaded alone is not reliable enough for this
		but is still required for the USSEP fix (in case of disabled objects)
		/;
		continueUpdating = Is3DLoaded() && myHomeCell.IsAttached()
		If continueUpdating
			;USKP 2.0.1 - Can't do this if no 3D
			float distanceToTarget = GetDistance(myTarget)
			If distanceToTarget >= 2048.0
				MoveTo(myTarget, 0.0, 0.0, 130.0)
			ElseIf distanceToTarget <= 64.0
				ApplyHavokImpulse(0.0, 0.0, 64.0, 8.0)		; little happy jumps when near the target
				QSTYngolLightMotesSD.Play(self)
			Else
				float transX = (myTarget.GetPositionX()) - (GetPositionX())
				float transY = (myTarget.GetPositionY()) - (GetPositionY())
				float transZ = (myTarget.GetPositionZ()) - (GetPositionZ() + 256.0)
				
				float impulseStrength = (distanceToTarget / 16.0)
				If impulseStrength > 100.0					; clamp value to avoid silly numbers
					impulseStrength = 99.0
				EndIf
				ApplyHavokImpulse(0.0, 0.0, 64.0, 8.0)
				QSTYngolLightMotesSD.Play(self)
				;tee it up, then hit towards target
				Wait(0.4)
				ApplyHavokImpulse(transX, transY, transZ, impulseStrength)
				QSTYngolLightMotesSD.Play(self)
				;trace("kicking orb " + self as objectReference + " with " + impulseStrength + " impulse.")
			EndIf

			RegisterForSingleUpdate(RandomFloat(1.5,2.0))
		EndIf
	EndEvent
EndState		

State dead
	; nothing happens here
	; do a redundant kill to help try and keep these from re-popping in.
	Event OnBeginState()
		continueUpdating = false
		Delete()		
	EndEvent
	Event OnActivate(ObjectReference actronaut)
		; nothing here, either.
	EndEvent
EndState

; ferrari365 - inlined to the OnUpdate to cut a function call, leaving the original functionality in, in case another mod wants to use the function
Function JumpAt(ObjectReference target)
	If GetDistance(target) > 64.0 && GetDistance(target) < 2048.0
		float transX = (target.GetPositionX()) - (GetPositionX())
		float transY = (target.GetPositionY()) - (GetPositionY())
		float transZ = (target.GetPositionZ()) - (GetPositionZ() + 256.0)
		
		float impulseStrength = (GetDistance(target) / 16.0)
		If impulseStrength > 100.0										; clamp value to avoid silly numbers
			impulseStrength = 99.0
		EndIf
		ApplyHavokImpulse(0.0, 0.0, 64.0, 8.0)
		QSTYngolLightMotesSD.Play(self)
		;tee it up, then hit towards target
		Wait(0.4)
		ApplyHavokImpulse(transX, transY, transZ, impulseStrength)
		QSTYngolLightMotesSD.Play(self)
		;trace("kicking orb " + self as objectReference + " with " + impulseStrength + " impulse.")
	ElseIf getDistance (target) <= 64.0
		ApplyHavokImpulse(0.0, 0.0, 64.0, 8.0)		; little happy jumps when near the target
		QSTYngolLightMotesSD.Play(self)
	EndIf
EndFunction