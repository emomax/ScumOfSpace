package global {
	public class Conversations {
		public static function get(progress:String) : Array {
			
			var convo:Array;
			
			switch (progress) {
				case "mike_intro":
					convo = new Array(
						["Mike", "Hey, we're finally here!\nIt's been ages since we last blasted some space targets."],
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
				default: 
					throw new Error("Couldn't not extract conversation - unknown progress.");
			}
			
			return convo;
		}
	}
}