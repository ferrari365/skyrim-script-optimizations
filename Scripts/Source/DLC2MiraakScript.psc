Scriptname DLC2MiraakScript extends Actor  
{Actor on base DLC2Miraak actors. Attach this if you need your Miraak to appear/disappear and call these functions.}

;Notes: This assumes you only want him to AppearOnLoad once per Appear()/Disappear() function calls

;PLEASE TALK TO jduvall BEFORE EDITING THIS SCRIPT. Thanks :)

bool property AppearOnLoad auto
{Optional: default = false
If true will call the Appear() function without moving him to AppearAtRef, assuming you've already placed him where he needs to be}

ObjectReference Property AppearAtRef auto
{Optional
 When Miraak appears, where he is moved to.
 For example, Player}

ObjectReference Property DisappearToRef auto
{Optional (USE IF AppearOnLoad is true - other wise next time you are in the area he will appear)
When Miraak disappears, where he is moved to. 
For example:
DLC2SoulStealMiraakSpawnMarker in DLC2aaaMarkers cell - an xmarker in a holding cell}

Explosion Property DLC2MiraakTeleportExp auto
Explosion Property DLC2MiraakTeleportReturnExp auto



EffectShader property DLC2MiraakTeleportStartFXS auto
EffectShader property DLC2MiraakTeleportReturnFXS auto



ImageSpaceModifier Property DLC2MiraakTeleportIMODStatic auto

bool Appeared

Event OnUpdate()
	;assumes this is only ever called for the IMOD effect

	bool IMOD = false

	float distance = 1500.0

	; ferrari365 - cache the player
	Actor PlayerRef = Game.GetForm(0x00000014) as Actor

	; ferrari365 - exit the loop after 120 seconds (same amount of time as in DLC2SoulStealScript), just in case it's still stuck
	int failsafe = 240

	While Appeared && failsafe > 0
		Utility.Wait(0.5) ; small wait to stop the loop from spinning as quickly as possible and wrecking the scripting engine
		if GetDistance(PlayerRef) <= distance
			if !IMOD
				IMOD = true
				DLC2MiraakTeleportIMODStatic.ApplyCrossFade(3.0)
			EndIf
		ElseIf IMOD
			IMOD = false
			ImageSpaceModifier.RemoveCrossFade(3.0)
		endif
		failsafe -= 1
	endWhile

;/ ferrari365 - original while loop
	While Appeared
		if GetDistance(Game.GetPlayer()) <= distance && IMOD == false
			IMOD = true
			DLC2MiraakTeleportIMODStatic.ApplyCrossFade(3)
		endif
		
		if GetDistance(Game.GetPlayer()) > distance && IMOD == true
			IMOD = false
			ImageSpaceModifier.RemoveCrossFade(3)
		endif
	endWhile
/;

EndEvent


Function OnLoad()
	if AppearOnLoad && Appeared == false
		Appeared = true
		Appear(MoveToAppearAtRef = false)
	endif

EndFunction

Function Appear(bool MoveToAppearAtRef = true, bool UseIMOD = true)

; debug.trace(self + "Appear()")

	Appeared = true

	if MoveToAppearAtRef && AppearAtRef != None
		MoveTo(AppearAtRef, 200.0)
	endif

	if IsDisabled()
		Enable(true)
	endif

; 	debug.trace(self + "setAlpha(0)")
	SetAlpha(0.0)


; 	debug.trace(self + "Placing Explosion.")	
	PlaceAtMe(DLC2MiraakTeleportExp)

	if UseIMOD
		RegisterForSingleUpdate(0.001)
	endif

; 	debug.trace(self + "Waiting...")	
	Utility.Wait(2.0)
	
	SetAlpha(1.0, true)

	DLC2MiraakTeleportStartFXS.Play(self)

; 	debug.trace(self + "setAlpha(1, true)")
	


EndFunction

Function Disappear()

	Appeared = false

	PlaceAtMe(DLC2MiraakTeleportReturnExp)

	DLC2MiraakTeleportReturnFXS.Play(self)
	
	Utility.Wait(0.5)

	ImageSpaceModifier.RemoveCrossFade(3.0)

	SetAlpha(0.0, true)
	
	Disable(true)

	if DisappearToRef
		MoveTo(DisappearToRef)
	endif

EndFunction
