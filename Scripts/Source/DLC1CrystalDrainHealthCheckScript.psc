Scriptname DLC1CrystalDrainHealthCheckScript extends ActiveMagicEffect  

bool effectApplied = false
bool property healthStop auto
;effect will stop at a set health percentage
bool property bleedoutStop auto
;effect will stop when actor enters bleedout

magicEffect Property HuskEffect auto

Actor UnfortunateSoul

Event OnEffectStart(Actor Target, Actor Caster)
	UnfortunateSoul = Target
	If UnfortunateSoul.IsDead()
		return
	Else
		effectApplied = true
		RegisterForSingleUpdate(0.5)
	EndIf
	
	;/ ferrari365 - old while loop

	while effectApplied == true
		if target.HasMagicEffect(huskEffect)
			dispel()
		endif
		if healthStop == true
			if(target.getActorValuePercentage("health") <= 0.25) 
				dispel()
			endif
		endif
		if bleedoutStop == true
			if target.isBleedingout() == true 	
				dispel()
			endif
		endif
	endwhile
	/;
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	effectApplied = false
EndEvent

Event OnUpdate()
	; check for huskEffect, alive state, health and bleeding out and dispel the effect if any are met
	if UnfortunateSoul.HasMagicEffect(huskEffect) || UnfortunateSoul.IsDead()
		effectApplied = false
		Dispel()
	elseif healthStop
		if(UnfortunateSoul.getActorValuePercentage("health") <= 0.25) 
			effectApplied = false
			Dispel()
		endif
	elseif bleedoutStop
		if UnfortunateSoul.isBleedingout()
			effectApplied = false
			Dispel()
		endif
	endif
	; if the effect is still not dispelled, reregister for another update
	if effectApplied
		RegisterForSingleUpdate(0.5)
	endif
EndEvent