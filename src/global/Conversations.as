package global {
	public class Conversations {
		public static function get(progress:String) : Array {
			
			var convo:Array;
			
			switch (progress) {
				case "mike_intro":
					convo = new Array(
						["Mike", "Hey, we're finally here!\nIt's been ages since we last blasted some space targets!"],
						["Mike", "How about a little challenge?\nThe first one to shoot 5 space targets wins!"],
						["Mike", "Do you think you have what it takes to beat ol' Mike?"],
						["UA", "([W, A, S, D] to steer your vessel. \n[SPACE] to fire primary weapon.)"]);
					break;
				case "mike_intro_middle":
					convo = new Array(
						["Mike", "How's it going ol' friend? I have already shot 3!\nKeep it up!"]);
					break;
				case "mike_intro_over":
					convo = new Array(
						["Mike", "A proud count of 4! How are you doing?"],
						["Mike", "5 ALREADY?\nWow, you are good!"],
						["Mike", "Alright, I admit defeat, but next time I prom..."],
						["mike_shake", ""],
						["Mike", "What was that?"],
						["show_screecher", ""],
						["UA", "You have intruded our territory. For this you will die."],
						["Mike", "What is he talking about? He must be kid..."],
						["Mike", "AAARRRGGH!!!"],
						["mike_explode", ""], 
						["UA", "Puny humans.\nYou will suffer the same fate as your friend!"],
						["UA", "Fwuhuhuhu!"]);
					break;
				case "boss_mid_fight":
					convo = new Array(["UA", "Hrmf.. Weak human! \nMy power level is over 9000!"],
									  ["UA", "My shield is still above 70%!\nYou will never defeat me!"]);
					break;
				case "boss_new_weapon":
					convo = new Array(["UA", "Gah! My shield is beneath 50%!\nHow is this possible!?"],
									  ["UA", "Well well.. \nI guess I have to stop playing then."],
									  ["UA", "Now you will see the full power of the Voreenean Empire!"],
									  ["UA", "Taste my lasers, scum!"]);
					break;
				case "commander_intro":
					convo = new Array(["Commander", "... So here we are. How are you feeling?"],
									  ["Commander", "Atleast the funeral was beautiful.\nPoor Mike.."],
									  ["Commander", ".. anyhow. I brought you out here for a reason.\nOutside enemy radars."],
									  ["Commander", "There's something I want you to have. Mike was supposed to have it but with him being gone and all.."],
									  ["commander_hit", ""],
									  ["Commander", "Blast it! Drones!\nWe have been ambushed! Ready yourself! Avoid the enemy ships!"], 
									  ["Commander", "Remember that your laser gun is useless against them!"]);
					break;
				case "commander_middle":
					convo = new Array(["Commander", "You're still alive!\nI saw some Phasers up ahead!"],
									  ["Commander", "Let's hope you're as good with real enemies as with space targets.."],
									  ["Commander", "CHARGE FORTH!\nFOR MIKE!"]);
					break;
				case "commander_regroup":
					convo = new Array(["Commander", "It seems they are re-grouping!"],
						["Commander", "Take cover!"]);
					break;
				case "commander_combo":
					convo = new Array(["Commander", "The drones are gone!"],
									  ["Commander", "Finish the remaining Phasers so we can\n get out of here!"]);
					break;
				case "commander_finished":
					convo = new Array(["Commander", "Well fought!\nThat'll teach them not to mess with the human race!"],
									  ["Commander", "Let's head back to the base before more of these filth arrive."])
					break;
				
				default: 
					throw new Error("Couldn't not extract conversation - unknown progress: " + progress);
			}
			
			return convo;
		}
	}
}