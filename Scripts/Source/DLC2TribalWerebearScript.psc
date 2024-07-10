Scriptname DLC2TribalWerebearScript extends Actor  


Spell Property WerebearChange auto
int Property TransformDistance = 500 auto

Actor Player
float property transformDistanceFloat auto hidden

Function Transform()
	; do nothing by default
EndFunction

Auto State human
	Function Transform()
		GoToState("bear")
		StopCombat()
		StopCombatAlarm()
		;UDBP 2.0.2 - Needs 3D check
		if( Is3DLoaded() )
			WerebearChange.Cast(self)
		EndIf
		; SetAv("aggression", 3)
		; SetAv("confidence", 4)
		if( !IsDead() ) ; UDBP 2.0.1 added check for dead actor
			StartCombat(Player)
		EndIf
	EndFunction	


	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		; ferrari365 - filter out non hostile spells, so that we don't transform from invisible cloaks
		Spell spellHit
		If akSource
			spellHit = akSource as Spell ; will always be None, unless akSource is a spell
		EndIf
		If spellHit != None && !spellHit.IsHostile()
			return ; don't do anything if the spell is not hostile
		Else
			; all other sources and hostile spells
			Transform()
		EndIf
	EndEvent

;/ vanilla OnHit
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		Transform()
	EndEvent
/;

	; relegating the update to when the combat state with the player is changed to avoid unnecessary polling
	Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
		If akTarget == Player && Is3DLoaded() ; 3D check because of OnCombatStateChanged quirks to avoid registering again after the player is lost, if they checked out to a different postal code
			; Debug.Trace(self + " is in combat or looking for player, registering for update")
			RegisterForSingleUpdate(1.0)
		EndIf
	EndEvent
EndState

State bear
	Event OnBeginState()
		UnregisterForUpdate() ; being overly cautious
	EndEvent
EndState

;/
ferrari365 - replaced with OnCombatStateChanged above
Event OnLoad()
	RegisterForSingleUpdate(1)
EndEvent

Event OnCellAttach()
	RegisterForSingleUpdate(1)
EndEvent

deprecated, as it's unreliable in worldspaces for this purpose
Event OnCellDetach()
	UnregisterForUpdate()
EndEvent
/;

; ferrari365 - cache the player, as it's used often and convert distance from int to float once, instead of every update
Event OnInit()
	; Debug.Trace("OnInit called on " + self)
	If !Player
		Player = Game.GetForm(0x00000014) as Actor
	EndIf
	If !transformDistanceFloat
		transformDistanceFloat = TransformDistance as float
	EndIf
EndEvent

Event OnUpdate()
	; if (Player.GetDistance(self) <= TransformDistance) ; deprecated TransformDistance as it's an int and comparing it to a float is bit slower, replaced with cached float value
	if (Player.GetDistance(self) <= transformDistanceFloat)
		; Debug.Trace("Distance check passed, transform and stop polling on " + self)
		Transform()
	ElseIf !IsInCombat() || !Is3DLoaded() ; stop polling if the werebear is no longer in combat or loaded at all
		; Debug.Trace("Combat ended/3D is unloaded, stop polling on " + self)
		return
	Else
		; Debug.Trace("Keep polling on " + self)
		RegisterForSingleUpdate(1.0)
	endif
EndEvent
