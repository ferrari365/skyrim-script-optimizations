Scriptname DLC1FalmerValleyIceDragonSCRIPT extends Actor
{script for breaking ice during the ice dragon fight in Falmer Valley}


Explosion Property myExplosionEnter Auto
Explosion Property myExplosionExit Auto

Quest Property myQuest Auto
int Property myStage Auto
int Property mySetStage Auto
ObjectReference Property myIceCapStart01 Auto
ObjectReference Property myIceCapStart02 Auto
ObjectReference Property myIceCapEnd01 Auto
ObjectReference Property myIceCapEnd02 Auto
ObjectReference Property myIceTrimStart01 Auto
ObjectReference Property myIceTrimStart02 Auto
ObjectReference Property myIceTrimEnd01 Auto
ObjectReference Property myIceTrimEnd02 Auto

int diveCounter = 0
bool doOnce = false

;**********************************************

;/
ferrari365 - moved to the waiting state to work around a still unexplained script spam

Event onLoad()
	if(myQuest.getStage() == myStage && !doOnce)
		doOnce = true
		myQuest.setStage(mySetStage)
	endif
	registerForAnimationEvent(self, "DiveSplashStart")
	registerForAnimationEvent(self, "DiveSplashEnd")
endEvent
/;

;**********************************************

Auto State waiting

	Event OnLoad()
		If(myQuest.GetCurrentStageID() == myStage && !doOnce)
			doOnce = true
			myQuest.SetCurrentStageID(mySetStage)
		EndIf
		RegisterForAnimationEvent(self, "DiveSplashStart")
		RegisterForAnimationEvent(self, "DiveSplashEnd")
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		If (asEventName == "DiveSplashStart")
			If(diveCounter == 0)
				myIceCapStart01.Disable()
				myIceTrimStart01.PlaceAtMe(myExplosionEnter)
				RegisterForAnimationEvent(self, "DiveSplashStart")
			ElseIf(diveCounter == 1)
				myIceCapStart02.Disable()
				myIceTrimStart02.PlaceAtMe(myExplosionEnter)
			EndIf
		EndIf

		If (asEventName == "DiveSplashEnd")
			If(diveCounter == 0)
				diveCounter = 1
				myIceCapEnd01.Disable()
				myIceTrimEnd01.PlaceAtMe(myExplosionExit)
				RegisterForAnimationEvent(self, "DiveSplashEnd")
			ElseIf(diveCounter == 1)
				diveCounter = 2
				myIceCapEnd02.Disable()
				myIceTrimEnd02.PlaceAtMe(myExplosionExit)
			EndIf
		EndIf

	EndEvent

	Event OnDeath(Actor killer)
		gotoState("done")
		; ferrari365 - unregistering from the events, extra precaution
		UnregisterForAnimationEvent(self, "DiveSplashStart")
		UnregisterForAnimationEvent(self, "DiveSplashEnd")
	EndEvent
EndState

;**********************************************

State done
	;do nothing
endState

;**********************************************