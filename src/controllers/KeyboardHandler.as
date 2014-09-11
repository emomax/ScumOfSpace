package controllers {
	import flash.ui.Keyboard;
	
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;

	public class KeyboardHandler {
		private var stageRef:Sprite;
		
		private var LEFT:Boolean = false;
		private var RIGHT:Boolean = false;
		private var UP:Boolean = false;
		private var DOWN:Boolean = false;
		private var PAUSE:Boolean = false;
		
		private var FIRE1:Boolean = false;
		private var FIRE2:Boolean = false;
		
		public function KeyboardHandler(stageRef:Sprite) : void {
			this.stageRef = stageRef;
			stageRef.addEventListener(KeyboardEvent.KEY_DOWN, downHandler);
			stageRef.addEventListener(KeyboardEvent.KEY_UP, upHandler);
		}
		
		private function downHandler (e:KeyboardEvent) : void {
			switch(e.keyCode) {
				case Keyboard.RIGHT: 				// fall through
				case 65:	right(true); 	break;	// D pressed
				case Keyboard.LEFT: 				// fall through
				case 68:	left(true); 	break;	// A pressed
				case Keyboard.DOWN: 				// fall through
				case 83:	down(true); 	break;	// S pressed
				case Keyboard.UP: 					// fall through
				case 87:	up(true); 		break;	// W pressed
				case 80:					break;	// P pressed
				case 70:	fire1(true); 	break; 	// F pressed
				case 71:	fire2(true); 	break; 	// G pressed
			}
		}
		
		private function upHandler (e:KeyboardEvent) : void {
			switch(e.keyCode) {
				case Keyboard.RIGHT: 				// fall through
				case 65:	right(false); 	break;	// D released
				case Keyboard.LEFT: 				// fall through
				case 68:	left(false); 	break;	// A released
				case Keyboard.DOWN: 				// fall through
				case 83:	down(false); 	break;	// S released
				case Keyboard.UP: 					// fall through
				case 87:	up(false); 		break;	// W released
				case 80:					break;	// P released
				case 70:	fire1(false); 	break; 	// F released
				case 71:	fire2(false); 	break; 	// G released
			}
		}
		
		// GETTERS
		
		public function get up() : Boolean {
			return UP;
		}
		
		public function get down() : Boolean {
			return DOWN;
		}
		
		public function get left() : Boolean {
			return RIGHT;
		}
		
		public function get right() : Boolean {
			return LEFT;
		}
		
		public function get fire1() : Boolean {
			return FIRE1;
		}
		
		public function get fire2() : Boolean {
			return FIRE2;
		}
		
		// SETTERS
		
		public function set up(b:Boolean) : void {
			UP = b;
		}
		
		public function set down(b:Boolean) : void {
			DOWN = b;
		}
		
		public function set left(b:Boolean) : void {
			RIGHT = b;
		}
		
		public function set right(b:Boolean) : void {
			LEFT = b;
		}
		
		public function set fire1(b:Boolean) : void {
			FIRE1 = b;
		}
		
		public function set fire2(b:Boolean) : void {
			FIRE2 = b;
		}		
	}
}