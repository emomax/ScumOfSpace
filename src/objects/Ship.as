package objects
{
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Ship extends Sprite implements Aircraft
	{
		private var exhaustArt:MovieClip;
		private var shipArt:Image;
		
		private var _velX:Number = 0;
		private var _velY:Number = 0;
		private var _maxVel:int = 6;
		private var _speed:Number = 0.5;
		
		public function Ship()
		{
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			createShipArt();
		}
		
		private function createShipArt():void
		{
			// Create ship art
			shipArt = new Image(Assets.getAtlas().getTexture("blackbird"));
			shipArt.x = Math.ceil(-shipArt.width / 2);
			shipArt.y = Math.ceil(-shipArt.height / 2);

			// Create exhaust animation
			exhaustArt = new MovieClip(Assets.getAtlas().getTextures("sprite"), 60);
			exhaustArt.x = shipArt.width / 3;
			exhaustArt.y = - shipArt.height / 5;
			starling.core.Starling.juggler.add(exhaustArt);
			
			// Add them all
			this.addChild(exhaustArt);
			this.addChild(shipArt);
		}
		
		public function get speed() : int {
			return _speed;	
		}
		
		public function set speed(s:int) : void {
			_speed = s;
		}
	}
}