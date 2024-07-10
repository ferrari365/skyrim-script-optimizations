Scriptname Trigger extends ObjectReference  
{
 base class for a trigger that watches for a target to enter and exit

 fireTriggerEvent function is called whenever the target enters or leaves the trigger
 
 Derive from this script, and override fireTriggerEvent function for whatever you need -- you can use IsTargetInTrigger to check if the target has just entered or left
 
}

bool bTargetInTrigger = false conditional

objectReference property targetRef auto
{ if None (default), watching for player
  otherwise, watching for this reference
}

bool busy = False ; ferrari365 - control variable

Event onLoad()
	if GetState() != "Waiting"
		GotoState("Waiting")
	endif
	if targetRef == None
		; targetRef = game.getPlayer()
		targetRef = Game.GetForm(0x00000014) as ObjectReference
	endif
endEvent

; ferrari365 - using states to avoid chance of events running concurrently
Auto State Waiting
	Event OnTriggerEnter(ObjectReference triggerRef)	
		if(!busy && triggerRef == targetRef)
			;target has entered the trigger
			GotoState("InsideTrigger")
; 			debug.trace(self + " target has entered the trigger")
		endif
	EndEvent
EndState

State InsideTrigger
	; ferrari365 - "lock" the script down while running OnBeginState or OnEndState
	Event OnBeginState()
		busy = true
		bTargetInTrigger = true
		fireTriggerEvent()
		busy = false
	EndEvent

	Event OnEndState()
		busy = true
		bTargetInTrigger = false
		fireTriggerEvent()
		busy = false
	EndEvent

	Event OnTriggerLeave(ObjectReference triggerRef)
		while busy
			Utility.Wait(0.2) ; ferrari365 - extra precaution to avoid concurrency with OnBeginState
		endwhile
		if(triggerRef == targetRef)
			;target has left the trigger
			GotoState("Waiting")
; 			debug.trace(self + " target has entered the trigger")
		endif
	EndEvent
EndState

;/ ferrari365 - the vanilla enter/leave events
Event onTriggerEnter(objectReference triggerRef)
	if(triggerRef == targetRef)
		;target has entered the trigger
		SetTargetInTrigger(true)
	 	debug.trace(self + " target has entered the trigger")
	endif
endEvent

Event onTriggerLeave(objectReference triggerRef)
	if (triggerRef == targetRef)
		;target has left the trigger
		SetTargetInTrigger(false)
		debug.trace(self + " target has left the trigger")
	endif
endEvent
/;

bool function IsTargetInTrigger()
	return bTargetInTrigger
endFunction

; PRIVATE function - do not call from outside this script
;/ ferrari365 - redundant, inlined into the InsideTrigger state to cut out function calls
function SetTargetInTrigger(bool isInTrigger)
	bTargetInTrigger = isInTrigger
	fireTriggerEvent()
endFunction
/;

function fireTriggerEvent()
	; do something when target enters/leaves trigger
endFunction
