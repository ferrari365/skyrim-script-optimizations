Scriptname dunRavenscarQST extends Quest  

import game
import debug
import utility

ReferenceAlias Property Alias_Boss01  Auto  
ReferenceAlias Property Alias_Boss02  Auto  
ReferenceAlias Property Alias_Boss03 Auto  
ReferenceAlias Property Alias_Boss04  Auto  
ReferenceAlias Property Alias_TrappedBandit Auto  
ReferenceAlias Property Alias_CageDoor  Auto  

Faction Property dunRavenscarFaction  Auto  
Faction Property PlayerFaction Auto

ObjectReference Property dunRavenscarSetStageTrigREF Auto

Actor Boss2
Actor Boss3
Actor Boss4

; caching the 3 bosses
Event OnInit()
	Boss2 = Alias_Boss02.GetReference() as Actor
	Boss3 = Alias_Boss03.GetReference() as Actor
	Boss4 = Alias_Boss04.GetReference() as Actor
	;RegisterForUpdate(1)
	;Register moved to stage 10 - unregister put in a shut-down stage
endEvent

Event OnUpdate()
	; bool ContinueUpdate = TRUE
	;if (Alias_CageDoor.GetReference().GetOpenState() == 1) || (Alias_CageDoor.GetReference().GetOpenState() == 2)		;Player has unlocked cage door
	;	if (GetStage() == 0)
	;		;MessageBox("Door Unlock.  Dude should be following now!")
	;		SetStage(10)
	;		dunRavenscarSetStageTrigREF.Enable()
	;		Alias_TrappedBandit.GetActorRef().RemoveFromFaction(dunRavenscarFaction)		;Remove the "friends with hagravens" faction
	;	endif
	;endif
	
	; ferrari365 - cache the bosses again in case this is installed on an existing save and OnInit has already been called
	if !Boss2 ; if one of them is None, then most likely all of them are None
		OnInit()
	endif

	; ferrari365 - stage 10 check no longer needed as we register on it in the fragment script
	if GetCurrentStageID() != 10 ; exit the loop if the current stage is not 10 to shut down already running updates on existing saves
		return
	elseif Boss2.IsDead() && Boss3.IsDead() && Boss4.IsDead()
		SetCurrentStageID(20)
	else
		RegisterForSingleUpdate(1.0)
	endif

	;/ ferrari365 - no need to register at the beginning of the quest and keep updating unless we're on stage 10
	if (GetStage() == 10)
		if (Alias_Boss02.GetActorRef().IsDead() == 1) && (Alias_Boss03.GetActorRef().IsDead() == 1) && (Alias_Boss04.GetActorRef().IsDead() == 1)
			SetStage(20)
			ContinueUpdate = FALSE
			;MessageBox("All birdies are dead!")
		endif
	endif
	
	;if (GetStage() == 30)
	;	SetStage(40)
	;	Alias_TrappedBandit.GetActorRef().RemoveFromFaction(PlayerFaction)
	;	Alias_TrappedBandit.GetActorRef().SetAV("Aggression", 2)
	;	;MessageBox("Dude is done with you, now you die!")
	;endif
	if ContinueUpdate
		RegisterForSingleUpdate(1)
	endif
	/;
endEvent
int Property DeadCurrent  Auto  

int Property DeadMax  Auto  
