ScriptName DLC2dunFrostmoonTriggerScript extends ObjectReference
{Script on the trigger around Frostmoon Crag. Manages Rakel's warnings and the camp's aggression.}

Quest property DLC2dunFrostmoonQST Auto
Scene property DLC2dunFrostmoonQST_RakelWarning1 Auto
Scene property DLC2dunFrostmoonQST_RakelWarning2 Auto
Scene property DLC2dunFrostmoonQST_RakelWarning3 Auto
Spell property WerewolfChange Auto
ReferenceAlias property Alias_Majni Auto
ReferenceAlias property Alias_Akar Auto
ReferenceAlias property Alias_Hjordis Auto
ReferenceAlias property Alias_Rakel Auto
Actor Rakel
Actor PlayerRef
;/ ferrari365 - timestamps no longer necessary, replaced with RegisterForSingleUpdateGameTime
float EntryTimestamp
float ExitTimestamp
/;

; ferrari365 - cache the player, runs immediately on new game as the trigger is a persistent reference
Event OnInit()
	PlayerRef = Game.GetForm(0x00000014) as Actor
EndEvent

Event OnTriggerEnter(ObjectReference triggerRef)
	If !PlayerRef ; ferrari365 - cache again if installed on an existing save where it will be None, otherwise skip
		PlayerRef = Game.GetForm(0x00000014) as Actor
	EndIf

	if (Rakel == None)
		Rakel = Alias_Rakel.GetReference() as Actor
	EndIf
	
	if (triggerRef == PlayerRef && Rakel != None)
		UnregisterForUpdate()
		float actorValue = Rakel.GetActorValue("Variable06") ; ferrari365 - cache the actor value to save on function calls
		if (Rakel.IsDead())
			;Omit the first warning entirely.
			Rakel.SetActorValue("Variable06", 3.0)
			RegisterForSingleUpdateGameTime(0.1)
		ElseIf (actorValue == 0.0)
			;First time.
			Rakel.SetActorValue("Variable06", 2.0)
			RegisterForSingleUpdateGameTime(0.12) ; ferrari365 - slightly longer delay, as it's the first time
		ElseIf (actorValue == 1.0)
			;Subsequent times.
			if (PlayerRef.HasSpell(WerewolfChange))
				Rakel.SetActorValue("Variable06", 2.0)
			Else
				Rakel.SetActorValue("Variable06", 3.0)
				DLC2dunFrostmoonQST_RakelWarning1.Start()
				RegisterForSingleUpdateGameTime(0.1)
			EndIf
			; DLC2dunFrostmoonQST_RakelWarning1.Start() - ferrari365 - moved above to fix a bug where Rakel will still warn the player in some situations, even if they're accepted by everyone
		ElseIf (actorValue >= 3.0)
			; ferrari365 - subsequent times, but the player is annoying and doesn't take the hint
			RegisterForSingleUpdateGameTime(0.1)
		EndIf
		Rakel.EvaluatePackage()
		; EntryTimestamp = Utility.GetCurrentGameTime() - ferrari365 - no longer needed, replaced by OnUpdateGameTime below
	EndIf
EndEvent

Event OnUpdateGameTime()
	if !PlayerRef.HasSpell(WerewolfChange)
		float actorValue = Rakel.GetActorValue("Variable06") ; ferrari365 - cache the AV again, as it's controlled externally too and may change between updates
		if (actorValue == 3.0)
			;Second warning.
			DLC2dunFrostmoonQST_RakelWarning2.Start()
			RegisterForSingleUpdateGameTime(0.1)
		ElseIf (actorValue == 4.0)
			;Third warning.
			DLC2dunFrostmoonQST_RakelWarning3.Start()
			RegisterForSingleUpdateGameTime(0.1)
		ElseIf (actorValue == 5.0)
			;Start combat.
			Rakel.SetActorValue("Variable06", 10.0)
			DLC2dunFrostmoonQST.SetCurrentStageID(20)
		EndIf
	EndIf
EndEvent

;/ ferrari365 - deprecated, gets called repeatedly and from every NPC inside the trigger for no good reason - replaced with OnUpdateGameTime above

Event OnTrigger(ObjectReference triggerRef)
	if (triggerRef == Game.GetPlayer() && !Game.GetPlayer().HasSpell(WerewolfChange) && EntryTimestamp > 0 && !DLC2dunFrostmoonQST.GetStageDone(1))
; 		;Debug.Trace("Passed. Time differential:  " + (Utility.GetCurrentGameTime() - EntryTimeStamp) + ", " + Rakel.GetAV("Variable06"))
		if ((Utility.GetCurrentGameTime() > 0.003 + EntryTimeStamp) && Rakel.GetAV("Variable06") == 3)
			;Second warning.
			DLC2dunFrostmoonQST_RakelWarning2.Start()
		ElseIf ((Utility.GetCurrentGameTime() > 0.006 + EntryTimeStamp) && Rakel.GetAV("Variable06") == 4)
			;Third warning.
			DLC2dunFrostmoonQST_RakelWarning3.Start()
		ElseIf ((Utility.GetCurrentGameTime() > 0.009 + EntryTimeStamp) && Rakel.GetAV("Variable06") == 5)
			;Start combat.
			Rakel.SetAV("Variable06", 10)
			DLC2dunFrostmoonQST.SetStage(20)
		EndIf
	EndIf
EndEvent
/;

Event OnTriggerLeave(ObjectReference triggerRef)
	If triggerRef == PlayerRef ; ferrari365 - check if the player left and not any random NPC
		UnregisterForUpdateGameTime()
		RegisterForSingleUpdate(10.0)
	EndIf
EndEvent

Event OnUpdate()
; 	Debug.Trace("Reset")
	;UDBP 2.0.1 - Added None check here because it's possible to get to this point without the property being filled yet.
	if (Rakel == None)
		Rakel = Alias_Rakel.GetReference() as Actor
	EndIf
	
	;UDBP 2.0.7 - If it's still empty, it's possible Stage 200 has been hit and these aliases are no good now.
	if( Rakel != None )
		Rakel.SetActorValue("Variable06", 1.0)
		Rakel.EvaluatePackage()
	EndIf
	; EntryTimestamp = 0 - ferrari365 - no longer needed
EndEvent
