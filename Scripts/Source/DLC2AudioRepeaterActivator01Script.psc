Scriptname DLC2AudioRepeaterActivator01Script extends ObjectReference  
{Repeats a given sound's playback}

Import Utility
; Import Debug

Sound Property SoundDescriptor  Auto  
{Sound Descriptor that this script will play}

float property delayMin = 1.0 Auto
float property delayMax = 5.0 Auto
Bool bRunning = False
	
Event OnCellAttach()
	; ferrari365 - only run updates if the object is enabled
	bRunning = !IsDisabled()
	If bRunning
		RegisterForSingleUpdate(1.0) ; ferrari365 - give the game time to load the 3D
	EndIf
EndEvent

Event OnUpdate()
	; ferrari365 - keep updating only while the object's 3D model is loaded and bRunning is true in case multithreaded shenanigans happen with the OnCellDetach
	If bRunning && Is3DLoaded()
		SoundDescriptor.Play(self)
		RegisterForSingleUpdate(RandomFloat(DelayMin,DelayMax))
	EndIf
EndEvent

Event OnCellDetach()
	; ferrari365 - stop updating when the player leaves the area
	If bRunning
		bRunning = False
		UnregisterForUpdate()
	EndIf
EndEvent