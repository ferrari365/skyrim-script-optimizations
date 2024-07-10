scriptName dunFolgunthurBossBattle extends dunProgressiveCombatScriptRefAlias
{ Boss Battle script for Mikrul Gaulderson in Folgunthur. }

Faction property MikrulFaction Auto
Faction property ThrallFaction Auto
Faction property PlayerFaction Auto

ReferenceAlias property Ally1Alias Auto
ReferenceAlias property Ally2Alias Auto
ReferenceAlias property Ally3Alias Auto
ReferenceAlias property Mikrul Auto

; float property timeForSpellcasting auto hidden - ferrari365 - unused

bool initBattle = False

Event OnActivate(ObjectReference obj)
	if (!initBattle)
		initBattle = True
		isActive = True
		totalEnemies = BattleManager.countLinkedRefChain()
		UpdateLoop()
	EndIf
EndEvent

;/
ferrari365 - Not actually working as intended. Replaced with the more reliable OnCellDetach below.
Event OnUnload()
	breakLoop = True
EndEvent
/;

; ferrari365 - Exits the loop if the player leaves the cell, as was originally intended.
Event OnCellDetach()
	breakLoop = True
EndEvent

;/
ferrari365 - Calls the loop funtion when the player enters the cell. Does nothing if the battle is over or not started yet.
Used to restart the thrall activation in case the player ran away from the fight.
/;
Event OnCellAttach()
	UpdateLoop()
EndEvent

Function UpdateLoop()
	While (isActive && !breakLoop)
		RunUpdate()
		Utility.Wait(1.0)
	EndWhile
	breakLoop = False
EndFunction

Function RunUpdate()
	;Basically, do everything dunProgressiveCombatScript wants to do.
	Parent.RunUpdate()
	
	;Then, if we're still active, run through and update the aliases.
	if (isActive)
		; FindLivingAliases() - ferrari365 - moved the function in here to cut down a function call
		ObjectReference localManager = BattleManager
		int currentAlias = 0
	
		While (localManager != None && currentAlias < 3)
			Actor localLinkedRef = localManager.GetLinkedRef(EnemyLinkKeyword) as Actor
			if (localLinkedRef != None && !localLinkedRef.IsDead())
				currentAlias += 1
				If (currentAlias == 1)
					Ally1Alias.ForceRefTo(localLinkedRef)
				ElseIf (currentAlias == 2)
					Ally2Alias.ForceRefTo(localLinkedRef)
				Else
					Ally3Alias.ForceRefTo(localLinkedRef)
				EndIf
			EndIf
			localManager = localManager.GetLinkedRef()
		EndWhile
; 		;Debug.Trace("Alias: " + Ally1Alias.GetReference() + " " + Ally1Alias.GetActorRef().IsDead())
; 		;Debug.Trace("Alias: " + Ally2Alias.GetReference() + " " + Ally2Alias.GetActorRef().IsDead())
; 		;Debug.Trace("Alias: " + Ally3Alias.GetReference() + " " + Ally3Alias.GetActorRef().IsDead())
	EndIf
EndFunction

; ferrari365 - this function has been optimized and integrated into RunUpdate, leaving it in for posterity
Function FindLivingAliases()
	ObjectReference localManager = BattleManager
	int currentAlias = 0
	
	While (localManager != None && currentAlias < 3)
		; ferrari365 - caching the linked reference to the battle manager to cut down on function calls
		Actor localLinkedRef = localManager.GetLinkedRef(EnemyLinkKeyword) as Actor
		; if ((localManager.GetLinkedRef(EnemyLinkKeyword) As Actor) != None && !(localManager.GetLinkedRef(EnemyLinkKeyword) As Actor).IsDead())
		if (localLinkedRef != None && !localLinkedRef.IsDead())
			; currentAlias = currentAlias + 1
			currentAlias += 1
			If (currentAlias == 1)
				; Ally1Alias.ForceRefTo(localManager.GetLinkedRef(EnemyLinkKeyword))
				Ally1Alias.ForceRefTo(localLinkedRef)
			ElseIf (currentAlias == 2)
				; Ally2Alias.ForceRefTo(localManager.GetLinkedRef(EnemyLinkKeyword))
				Ally2Alias.ForceRefTo(localLinkedRef)
			ElseIf (currentAlias == 3)
				; Ally3Alias.ForceRefTo(localManager.GetLinkedRef(EnemyLinkKeyword))
				Ally3Alias.ForceRefTo(localLinkedRef)
			EndIf
		EndIf
		localManager = localManager.GetLinkedRef()
	EndWhile
EndFunction

; ferrari365 - this function appears to be cut content, as it isn't used anywhere, but I'm leaving it in just in case
Function UpdateQuestAliases()
	; ferrari365 - moved these 4 into the unused function to save on overall memory, as they're otherwise unused as well
	ObjectReference Ally1Slot
	ObjectReference Ally2Slot
	ObjectReference Ally3Slot
	ObjectReference Temp

	Ally1Alias.ForceRefTo(Ally1Slot)
	Ally2Alias.ForceRefTo(Ally2Slot)
	Ally3Alias.ForceRefTo(Ally3Slot)
	if (Ally2Alias.GetReference().GetDistance(Mikrul.GetReference()) > Ally3Alias.GetReference().GetDistance(Mikrul.GetReference()) && Ally3Alias.GetReference() != None)
		Temp = Ally3Alias.GetReference()
		Ally3Alias.ForceRefTo(Ally2Alias.GetReference())
		Ally2Alias.ForceRefTo(Temp)
	EndIf
	if (Ally1Alias.GetReference().GetDistance(Mikrul.GetReference()) > Ally2Alias.GetReference().GetDistance(Mikrul.GetReference()) && Ally2Alias.GetReference() != None)
		Temp = Ally2Alias.GetReference()
		Ally2Alias.ForceRefTo(Ally1Alias.GetReference())
		Ally1Alias.ForceRefTo(Temp)
	EndIf
	if (Ally2Alias.GetReference().GetDistance(Mikrul.GetReference()) > Ally3Alias.GetReference().GetDistance(Mikrul.GetReference()) && Ally3Alias.GetReference() != None)
		Temp = Ally3Alias.GetReference()
		Ally3Alias.ForceRefTo(Ally2Alias.GetReference())
		Ally2Alias.ForceRefTo(Temp)
	EndIf
EndFunction

; ferrari365 - When Mikrul dies, shut down the script and kill the remaining thralls.
Event OnDeath(Actor killer)
; 	;Debug.Trace("Mikrul Wrapping Up")
	;Wrap up the battle.
	isActive = False
	Self.UnregisterForUpdate()
	
	;Kill all of the remaining Thralls.
	(Ally1Alias.GetReference() as Actor).Kill()
	(Ally2Alias.GetReference() as Actor).Kill()
	(Ally3Alias.GetReference() as Actor).Kill()
	
	;/
	While(BattleManager != None)
		(BattleManager.GetLinkedRef(EnemyLinkKeyword) as Actor).Activate(Self.GetReference())
		Utility.Wait(0.5)
		(BattleManager.GetLinkedRef(EnemyLinkKeyword) as Actor).Kill()
		BattleManager = BattleManager.GetLinkedRef()
	EndWhile
	
	USSEP 4.1.5 Bug #14020: Modified this:
	Apparently, the quest may shut down in the background while this code is still running and suddenly BattleManager
	will be 'none' and an error is thrown.
	/;
	While(BattleManager != None)
		actor BMTemp = BattleManager.GetLinkedRef(EnemyLinkKeyword) as Actor
		if BMTemp
			; improper use of self, points to the Mikrul alias which is None at this stage and causes errors in the logs, replaced with BMTemp that USSEP implements
			; BMTemp.Activate(Self.GetReference())
			BMTemp.Activate(BMTemp)
			Utility.Wait(0.5)
			BMTemp.Kill()
		endif
		if BattleManager
			BattleManager = BattleManager.GetLinkedRef()
		endif
	EndWhile
EndEvent