package objects
{
	import flash.utils.Timer;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Phaser extends Ship implements PrimaryWeapon, AI
	{
		private var playerRef:Ship;
		
		private var _fireSpeed:Number;
		private var _fireTimer:Timer;
		private var _firePower:int
		private var _canFire:Boolean;
		
		public function Phaser(s:Sprite) {
			super(s);
			
			// PHASER SPECIFIC ATTRIBUTES
			fireSpeedPrimary = 600;
			canFirePrimary = true;
			firePowerPrimary = 25;
			fireTimerPrimary = new Timer(fireSpeedPrimary, 1);
			
			init();
		}
		
		private function init() : void {
			// Init the Phaser!
			stageRef.addEventListener(Event.ENTER_FRAME, behaviourLoop);
		}
		
		private function behaviourLoop (e:Event) : void {
			// Do stuff;
		}
		
		// Interface PrimaryWeapon GETTERS
		
		public function get fireSpeedPrimary():Number { return _fireSpeed; }
		public function get fireTimerPrimary():Timer { return _fireTimer; }
		public function get canFirePrimary():Boolean { return _canFire; }
		public function get firePowerPrimary():int { return _firePower; }
		
		// Interface PrimaryWeapon SETTERS
		public function set fireSpeedPrimary(n:Number):void { _fireSpeed = n; }
		public function set fireTimerPrimary(t:Timer):void { _fireTimer = t; }
		public function set canFirePrimary(b:Boolean):void { _canFire = b; }
		public function set firePowerPrimary(i:int):void { _firePower = i; }
	}
}