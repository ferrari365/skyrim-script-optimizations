Scriptname DLC2dunSeekerInvisScript extends Actor
{when in combat, have Seeker become invisible}

import Utility
import Debug

Spell property mySpell auto
{spell to cast when entering combat}

bool property startIvis = false auto
{default = false}

float property myDistance = 512.0 auto hidden
{how close before variable01 is set to true}

float property mySpeedMult = 3000.0 auto hidden
{how fast while invisible}

float property mySpeedNormal = 100.0 auto hidden
{how fast while not invisible}

bool doOnce = false
bool close = true
Actor PlayerRef

;******************************************************

auto State Waiting

	Event OnCellAttach()
		; ferrari365 - cache the player for later
		If !PlayerRef
			PlayerRef = Game.GetForm(0x00000014) as Actor
		EndIf
		if(startIvis == true) && (!isDead())
			SetAlpha(0.0)
			SetActorValue("SpeedMult", mySpeedMult)
			Disable()
			Enable()
			SetAlpha(0.0)

;/ ferrari365 - optimizations
			SetAlpha(0, false)
			self.setAV("SpeedMult", mySpeedMult)
			disable(0)
			enable(0)
			SetAlpha(0, false)
/;
		endif
	endEvent

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
	  bool abBashAttack, bool abHitBlocked)
		; ferrari365 - filter out non hostile spells, so that we don't call gotoState from invisible cloaks
		Spell spellHit
		If akSource
			spellHit = akSource as Spell ; will always be None, unless akSource is a spell
		EndIf
		If spellHit != None && !spellHit.IsHostile()
			return ; don't do anything if the spell is not hostile
		Else
			; all other sources and hostile spells
			gotoState("ReturnToNormal")
		EndIf
	endEvent

;/ vanilla OnHit
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
		bool abBashAttack, bool abHitBlocked)
		  gotoState("ReturnToNormal")
	  endEvent
/;

	Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
		; if (akTarget == Game.GetPlayer())
		if (akTarget == PlayerRef)
			; if (aeCombatState == 1) ; ferrari365 - redundant, aeCombatState is set to 1 even if the player is hidden or being searched for
			if(!doOnce)
				doOnce = true
				close = false
				mySpell.Cast(self, self)
				SetActorValue("SpeedMult", mySpeedMult)
				Wait(1.0)
				SetAlpha(0.0)
				EvaluatePackage()
				Disable()
				Enable()
				SetAlpha(0.0)
				RegisterForSingleUpdate(0.0)

;/ ferrari365 - optimizations
				self.setAV("SpeedMult", mySpeedMult)
				wait(1)
				SetAlpha(0, false)
				evaluatePackage()
				disable(0)
				enable(0)
				SetAlpha(0, false)
				registerForSingleUpdate(0)
/;
			endif
	    	; endIf
		endIf
	endEvent

	Event OnUpdate()
		;UDBP 1.0.4 - 3D check added to prevent the script from getting permanently stuck in here if the Seeker unloads from memory before becoming visible.
		; if(self.getDistance(game.getPlayer()) < myDistance)
		if (GetDistance(PlayerRef) < myDistance) || ( !Is3DLoaded() )
			close = true
			gotoState("ReturnToNormal")
		EndIf
		
		;/ ferrari365 - moved above
		if(self.getDistance(game.getPlayer()) < myDistance)
			close = true
			gotoState("ReturnToNormal")
		endif
		/;
	
		; ferrari365 - replacing the busy while loop with RegisterForSingleUpdate to prevent FPS drops
		If (!close)
			RegisterForSingleUpdate(0.2)
		EndIf
	
		;/ ferrari365 - deprecated while loop
		while(!close)
			;UDBP 1.0.4 - 3D check added to prevent the script from getting permanently stuck in here if the Seeker unloads from memory before becoming visible.
			if( !Is3DLoaded() )
				close = true
				gotoState("ReturnToNormal")
			EndIf
			
			if(self.getDistance(game.getPlayer()) < myDistance)
				close = true
				gotoState("ReturnToNormal")
			endif
		endWhile
		/;
	endEvent

endState

;******************************************************

State ReturnToNormal
	Event onBeginState()
		close = true
		SetActorValue("Variable01", 1.0)
		SetActorValue("SpeedMult", mySpeedNormal)
		Disable()
		Enable()
		EvaluatePackage()
		SetAlpha(1.0)

;/ ferrari365 - optimizations
		setAV("Variable01", 1)
		self.setAV("SpeedMult", mySpeedNormal)
		disable(0)
		enable(0)
		evaluatePackage()
		SetAlpha(1, false)
/;
	endEvent
endState

;******************************************************