package objects
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import geometry.DrawRect;
	
	import screens.InGame;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Ship extends Sprite 
	{
		protected var shipArt:Image;
		protected var stageRef:Sprite;
		public var lines:DrawRect;
		
		public var direction:int;
		
		public var velY:Number = 0;
		public var velX:Number = 0;
		public var maxVel:int = 6;
		protected var _boundingbox:Rectangle;
		private var _speed:Number = 0.5;
		
		protected var _HP:int;
		
		public function Ship(s:Sprite)
		{
			this.stageRef = s;
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			this.boundingbox = this.bounds;
			
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function showBoundingBox() : void {
			lines = new DrawRect(this.boundingbox);
			lines.x = -boundingbox.width / 2;
			lines.y = -boundingbox.height / 2;
			addChild(lines);
		}
		
		protected function createShipArt(a:String):void
		{
			// Create ship art
			shipArt = new Image(Assets.getAtlas().getTexture(a));
			shipArt.x = Math.ceil(-shipArt.width / 2);
			shipArt.y = Math.ceil(-shipArt.height / 2);
			
			// Add it
			this.addChild(shipArt);
		}
		
		protected function createExhaustArt(offset:Point, dir:int = 1) : MovieClip {
			var exhaustArt:MovieClip;
			
			// Create exhaust animation
			exhaustArt = new MovieClip(Assets.getAtlas().getTextures("sprite"), 60);
			exhaustArt.scaleX = dir;
			exhaustArt.x = offset.x;//shipArt.width / 3;
			exhaustArt.y = offset.y; //- shipArt.height / 5;
			starling.core.Starling.juggler.add(exhaustArt);
			
			addChild(exhaustArt);
			return exhaustArt;
		}
		
		public function toggleBox(b:Boolean) : void {
			this.lines.visible = b;
		}
		
		// Getters
		
		public function get speed() : Number {
			return _speed;	
		}
		
		public function set speed(s:Number) : void {
			_speed = s;
		}
		
		public function get boundingbox() : Rectangle {
			var box:Rectangle = new Rectangle(this.x - _boundingbox.width / 2, this.y - this._boundingbox.height / 2, _boundingbox.width, _boundingbox.height);
			return box;			
		}
		
		public function set boundingbox(r:Rectangle) : void {
			this._boundingbox = r;
		}
		
		public function primary() : void {}
		public function secondary() : void {}
		
		public function takeDmg(dmg:int) : Boolean {
			this._HP -= dmg;
			
			trace(this._HP + " hp left.");
			
			if (this._HP <= 0) {
				this.destroy();
				return true;
			}
			
			return false;
		}
		
		private function destroy() : void {
			InGame.ships.splice(InGame.ships.indexOf(this), 1);
			stageRef.removeChild(this, true);
		}
	}
}