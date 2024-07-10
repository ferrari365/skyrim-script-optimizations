Scriptname dunLabyrinthianMazeControlScript extends ObjectReference  

Import Game

bool Property bDestructionClear Auto
bool Property bIllusionClear Auto
bool Property bRestorationClear Auto
bool Property bAlterationClear Auto

bool hasSolved

Activator Property SummonTargetFXActivator Auto
ObjectReference Property summonPoint Auto
ObjectReference Property DremoraPoint Auto
ObjectReference Property ReappearPlayerPoint Auto
ObjectReference Property ReappearDremoraPoint Auto

ActorBase Property lvlAtronachAny Auto

ObjectReference Property atronach01SummonPoint Auto
ObjectReference Property atronach02SummonPoint Auto

ActorBase Property LvlDremoraMelee Auto
Armor Property dunLabyrinthianMazeCircletReward Auto

ObjectReference Property myPortal Auto

ImageSpaceModifier Property dunLabyrinthianMazeFadeImod Auto

Function CheckMaze()
	If bDestructionClear == true && bIllusionClear == true && bRestorationClear == true && bAlterationClear == true
; 		debug.trace("Labyrinthian Maze Elements all set!")
		; add an extra check here to avoid double-up If player double-casted at the last tablet
		If !hasSolved
			hasSolved = true
			SolveMaze()
		EndIf
	Else
; 		debug.trace("Labyrinthian Maze not solved yet")
	EndIf
EndFunction

Function SolveMaze()
	; this function is fired from one of the dunLabyrinthianMazeTabletScript objects
	; whenever the four magical tablets have been "solved"
; 	debug.trace("Labyrinthian Maze: Player has used four pre-requisite Elements, now conjure player")
	
	; ferrari365 - cache the player
	Actor PlayerRef = GetForm(0x14) As Actor

	; enable the portal beneath the maze
	myPortal.Enable()
	Utility.Wait(0.1)
	myPortal.PlayAnimation("playAnim02")
	
	; ferrari365 - no point making an object ref and then keep casting it for no reason, redundant as Actor already extends Object Ref
	; objectReference dremoraREF = dremoraPoint.placeatme(LvlDremoraMelee)
	Actor dremoraREF = dremoraPoint.PlaceAtMe(LvlDremoraMelee) As Actor
	; (dremoraREF as actor).addItem(dunLabyrinthianMazeCircletReward,1)
	; (dremoraREF as actor).equipItem(dunLabyrinthianMazeCircletReward,TRUE)
	dremoraREF.AddItem(dunLabyrinthianMazeCircletReward, 1)
	dremoraREF.EquipItem(dunLabyrinthianMazeCircletReward, true)
	
	; While getPlayer().getDistance(summonPoint) > 256
	; ferrari365 - extended distance to prevent trapping the player in the conjuration world if they leave the 256 units before the loop can exit
	While PlayerRef.GetDistance(summonPoint) > 1500.0
		; wait until player has come through the portal
		Utility.Wait(2.0)
	EndWhile
	
	; while (dremoraREF as Actor).GetActorValuePercentage("Health") > 0.75
	; ferrari365 - failsave if the dremora somehow dies without losing health (e.g killmove), otherwise traps player again
	While dremoraREF.GetActorValuePercentage("Health") > 0.75 && !dremoraREF.IsDead() 
		; wait until dremora falls below 75% HP
		Utility.Wait(1.0)
	EndWhile
	
	myPortal.Disable()
	dremoraREF.PlaceAtMe(SummonTargetFXActivator)
	
	Utility.Wait(0.33)
	; (dremoraREF as actor).moveto(reappearDremoraPoint)
	dremoraREF.MoveTo(reappearDremoraPoint)
	; getPlayer().placeatme(SummonTargetFXActivator)
	PlayerRef.PlaceAtMe(SummonTargetFXActivator)
	
	Utility.Wait(0.33)
	; getPlayer().moveto(reappearPlayerPoint)
	PlayerRef.MoveTo(reappearPlayerPoint)
	reappearPlayerPoint.PlaceAtMe(SummonTargetFXActivator)
	reappearDremoraPoint.PlaceAtMe(SummonTargetFXActivator)
	
	; summon in reinforcements
	Utility.Wait(1.75)
	atronach01SummonPoint.PlaceAtMe(SummonTargetFXActivator)
	Utility.Wait(0.33)
	atronach01SummonPoint.PlaceAtMe(lvlAtronachAny)
	atronach02SummonPoint.PlaceAtMe(SummonTargetFXActivator)
	Utility.Wait(0.33)
	atronach02SummonPoint.PlaceAtMe(lvlAtronachAny)
	
	; while (dremoraREF as actor).isDead() == FALSE
	while !dremoraREF.IsDead()
		; wait until dremora has been killed
		Utility.Wait(1.0)
	endWhile
	
	;USSEP 4.2.9 Bug #32943. Added this If/Endif block to make sure the reward is given in the event the Dremora is not teleported properly.
	;[Note: Previously undocumented fix from March of 2016]
	If( dremoraREF.GetDistance(dremoraPoint) <= 1500.0 )
		If( dremoraREF.GetItemCount(dunLabyrinthianMazeCircletReward) > 0 )
			ObjectReference Diadem = reappearDremoraPoint.PlaceAtMe( dunLabyrinthianMazeCircletReward )
			; ferrari365 - compatibility for people on older USSEP versions - slight Z-axis offset, otherwise it falls through the ground - very stupid, I know...
			Diadem.MoveTo(reappearDremoraPoint, afZOffset = 2.0)
		EndIf
	EndIf
EndFunction

	;;this function is fired from one of the dunLabyrinthianMazeTabletScript objects
	;;whenever the four magical tablets have been "solved"
; 	; debug.trace("Labyrinthian Maze: Player has used four pre-requisite Elements, now conjure player")
	;;pause a moment so it's not too jarring
	; utility.wait(0.25)
	; shakeController(0.1,0.5,2.0)
	; getPlayer().placeatme(SummonTargetFXActivator)
	; objectReference dremoraREF = dremoraPoint.placeatme(LvlDremoraMelee)
	; dunLabyrinthianMazeFadeImod.apply()
	; disablePlayerControls(true,false)
	
	; utility.wait(1.66)
	; getPlayer().placeatme(SummonTargetFXActivator)
	; summonPoint.placeatme(SummonTargetFXActivator)
	
	; utility.wait(0.33)
	; getPlayer().moveTo(summonPoint)
	; dunLabyrinthianMazeFadeImod.remove()
	;;enable the player controls and spawn in the enemy
	
	; utility.wait(0.33)
	; (dremoraREF as actor).setAV("aggression",0)
	; (dremoraREF as actor).addItem(dunLabyrinthianMazeCircletReward,1)
	; (dremoraREF as actor).equipItem(dunLabyrinthianMazeCircletReward,TRUE)
	
	;;Need a better way to wait for the Dremora to finish his anim/ritual...
	; utility.wait(10.0)
	; dunLabyrinthianMazeFadeImod.apply()
	
	; utility.wait(1.66)
	; dremoraREF.placeatme(SummonTargetFXActivator)
	; getPlayer().placeatme(SummonTargetFXActivator)
	;;standard wait time for summon FX
	
	; utility.wait(0.33)
	; enablePlayerControls()
	; (dremoraREF as actor).moveto(reappearDremoraPoint)
	; getPlayer().moveto(reappearPlayerPoint)
	; reappearPlayerPoint.placeatme(SummonTargetFXActivator)
	; reappearDremoraPoint.placeatme(SummonTargetFXActivator)
	
	;;give a grace period while the player is disoriented
	; utility.wait(0.33)
	; (dremoraREF as actor).setAV("variable07",1)
	; (dremoraREF as actor).setAV("aggression",2)
	; (dremoraREF as actor).startCombat(getPlayer())
	; (dremoraREF as actor).evaluatePackage()
