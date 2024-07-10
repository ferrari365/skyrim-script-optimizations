scriptName MQ105QuestScript extends Quest Conditional

Location property HighHrothgarLocation auto
ReferenceAlias property Alias_Arngeir auto
ReferenceAlias property Alias_Borri auto

Quest property MQ106 auto
Scene property EinarthTeachScene auto
Scene property PushTrialScene auto
Scene property SprintTrialScene auto


int property MQ105Test auto

int Property targetsHit  Auto  Conditional

int Property sceneCount  Auto  Conditional
{how long did it take player to finish push trial?}


int Property iSprintWordToUnlock = 1 Auto Conditional ; set to which word to unlock (set in quest stage): 1-3

bool bPushTrialWaiting Conditional
bool bPushTrialWeakHit Conditional
bool bPushTrialGoodHit Conditional

bool Property pushTrialWaiting
{set to true when phantom form is summoned, set to false when it goes away}
	bool function get()
   		return bPushTrialWaiting
	endFunction
	function set(bool value)
		bPushTrialWaiting = value
	endFunction
endProperty

bool Property pushTrialWeakHit 
{set to true when player hits form with only the first word of the push, so Arngeir can comment}
	bool function get()
   		return bPushTrialWeakHit 
	endFunction
	function set(bool value)
		bPushTrialWeakHit = value
	endFunction
endProperty

bool Property pushTrialGoodHit
{set to true when player hits form with Fus-Ro, so Arngeir can comment}
	bool function get()
   		return bPushTrialGoodHit
	endFunction
	function set(bool value)
		bPushTrialGoodHit = value
	endFunction
endProperty


bool Property sprintTrialPlayerReady auto Conditional
bool busy = false ; ferrari365 - control variable to prevent trigger spam during sprint trial
Actor PlayerRef

import Game
import utility

Event OnInit()
	; ferrari365 - cache the player for future use, gets cached in other places as well if installed on an existing save where it will be None to not mess up other parts of the quest
	PlayerRef = Game.GetForm(0x00000014) as Actor
EndEvent

Event OnGainLOS(Actor akViewer, ObjectReference akTarget)
	; watch for player to have LOS on note and not be in combat
	; ferrari365 - optimizations
	; if getStageDone(180) == true && getStageDone(190) == false && TombTrigger.bAllTargetsInTrigger
	if IsStageDone(180) == true && IsStageDone(190) == false && TombTrigger.bAllTargetsInTrigger
		; if Game.GetPlayer().IsInCombat() == 0
		If !PlayerRef
			PlayerRef = Game.GetForm(0x00000014) as Actor
		EndIf
		if !PlayerRef.IsInCombat()
			; setstage(190)
			SetCurrentStageID(190)
		endif
	endif
endEvent

GlobalVariable Property MQ105TargetsHit  Auto  
{how many targets have been hit?}

GlobalVariable Property MQ105TargetsTotal Auto  
{how many targets are there total}

function SetWaiting(bool newVal)
	pushTrialWaiting= newVal
endFunction



function IncrementPushTargetCount(Actor target)
; 	debug.trace(self + "IncrementPushTargetCount " + MQ105TargetsHit.value)
; ferrari365 - optimizations
	float totalTargets = MQ105TargetsTotal.GetValue()
	; if MQ105TargetsHit.value < MQ105TargetsTotal.value
	if MQ105TargetsHit.GetValue() < totalTargets
		; if ModObjectiveGlobal(1.0, MQ105TargetsHit, 40, MQ105TargetsTotal.value)
		if ModObjectiveGlobal(1.0, MQ105TargetsHit, 40, totalTargets)
			; SetStage(90)
			SetCurrentStageID(90)
		endif
	endif
endFunction

; call this function before the next target is summoned
function StartNewTarget()
; 	debug.trace(self + " START NEW TARGET")
	; set waiting variable
	PushTrialWaiting = true
	; clear hit variables
	PushTrialGoodHit = false
	PushTrialWeakHit = false
	; reset shout timer
	; Game.GetPlayer().SetVoiceRecoveryTime( 0 )
	If !PlayerRef
		PlayerRef = Game.GetForm(0x00000014) as Actor
	EndIf
	PlayerRef.SetVoiceRecoveryTime(0.0)
endFunction

; call this function when the player exits the sprint start trigger
function SprintStartTriggerChangeState(bool bOnEnter)
; 	debug.trace(self + " SprintStartTriggerChangeState bOnEnter=" + bOnEnter)
	if busy
		return ; ferrari365 - exit early if we're already doing processing from a different thread to avoid scripts getting stuck
	endif
	if bOnEnter
		busy = true
; 		debug.trace(self + " SprintStartTriggerChangeState - setting sprintTrialPlayerReady to TRUE")
		sprintTrialPlayerReady = true
		; if scene already running, do nothing, otherwise start scene
		; ferrari365 - optimizations here and in the else block
		; if GetStageDone(140) == 0 && SprintTrialScene.IsPlaying() == false
		if IsStageDone(140) == 0 && SprintTrialScene.IsPlaying() == false
			SprintTrialScene.Start()
		endif
		busy = false
	else
		busy = true
; 		debug.trace(self + " SprintStartTriggerChangeState - setting sprintTrialPlayerReady to FALSE")
		; if exiting, check state of trial gate
		; immediately close the gate and restart the scene if the gate isn't open yet
		; if SprintTrialSuccessTrigger.IsEnabled() == 0 
		if SprintTrialSuccessTrigger.IsDisabled()
			OpenSprintTrialGate(false)
			if sprintTrialPlayerReady
; 				debug.trace(self + " ExitSprintStartTrigger before gate is open - STOP TRYING TO CHEAT!")
				sprintTrialPlayerReady = false
; 				debug.trace(self + " SprintStartTriggerChangeState - setting sprintTrialPlayerReady to FALSE - DONE 1")

				; SprintTrialScene.Stop() - ferrari365 - moved into the loop, because that's just silly
				while SprintTrialScene.IsPlaying()
					SprintTrialScene.Stop()
					utility.wait(1.0)
				endWhile
				SprintTrialScene.Start()
			endif
		endif
		sprintTrialPlayerReady = false
		busy = false
; 		debug.trace(self + " SprintStartTriggerChangeState - setting sprintTrialPlayerReady to FALSE - DONE 2")
	endif

endFunction

function OpenSprintTrialGate(bool bDoOpen = true)
	if bDoOpen
		; open gate & enable success trigger
		SprintTrialGate.SetOpen(true)
		SprintTrialSuccessTrigger.Enable()
	else
		; close gate & disable success trigger
		SprintTrialGate.SetOpen(false)
		SprintTrialSuccessTrigger.Disable()
	endif
endFunction

function GreybeardSpeakingEffect(float fTotalTime = 2.0)
	If !PlayerRef
		PlayerRef = Game.GetForm(0x00000014) as Actor
	EndIf
	; AMBRumbleShakeGreybeards.Play(Game.GetPlayer())
	AMBRumbleShakeGreybeards.Play(PlayerRef)
	GreybeardOutroIMOD.Apply()
	; OutroDust1.Activate(Game.GetPlayer())
	OutroDust1.Activate(PlayerRef)
	OutroTrigger.knockAreaEffect(0.25,250.0)
;	Game.GetPlayer().PlayIdle(BracedPainIdle)
	game.shakeController(0.5, 0.5, fTotalTime)
	game.shakeCamera(NONE, 0.1 * fTotalTime)
	utility.wait(0.4 * fTotalTime)
	; OutroDust2.Activate(Game.GetPlayer())
	OutroDust2.Activate(PlayerRef)
	utility.wait(0.2 * fTotalTime)
	; OutroDust3.Activate(Game.GetPlayer())
	OutroDust3.Activate(PlayerRef)
	utility.wait(0.1 * fTotalTime)
	OutroTrigger.knockAreaEffect(0.2,250.0)
	; OutroDust4.Activate(Game.GetPlayer())
	OutroDust4.Activate(PlayerRef)
	utility.wait(0.3 * fTotalTime)
	OutroTrigger.knockAreaEffect(0.2,250.0)
;	Game.GetPlayer().PlayIdle(BracedPainIdle)
	game.shakeCamera(NONE, 0.01 * fTotalTime)
;	game.shakeController(0.1, 0.1, 1.0)
	; OutroDust1.Activate(Game.GetPlayer())
	OutroDust1.Activate(PlayerRef)
endFunction
ObjectReference Property OutroTrigger  Auto  
{used to for Greybeard speaking effects}

ImageSpaceModifier Property GreybeardOutroIMOD  Auto  
{imagespace modifier for Greybeard speaking outro}

Quest Property MQ00  Auto  

ObjectReference Property OutroDust1  Auto  
ObjectReference Property OutroDust2  Auto  
ObjectReference Property OutroDust3  Auto  
ObjectReference Property OutroDust4  Auto  

Idle Property StaggerIdle  Auto  

WordOfPower Property SprintWord  Auto  
{the word that Borri teaches player (set by quest stage)
}

DefaultOnEnter Property TombTrigger  Auto  
{trigger to tell when player is close to tomb}

ObjectReference Property Tomb  Auto  
{tomb, for LOS check}

Idle Property BracedPainIdle  Auto  

ObjectReference Property SprintTrialGate  Auto  

ObjectReference Property SprintTrialSuccessTrigger  Auto  

Sound Property AMBRumbleShakeGreybeards  Auto  
