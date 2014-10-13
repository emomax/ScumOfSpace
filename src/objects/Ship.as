package objects
{
	import com.freeactionscript.effects.explosion.AbstractExplosion;
	import com.freeactionscript.effects.explosion.LargeExplosion;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	
	import debugger.Debug;
	
	import geometry.DrawRect;
	
	import global.VARS;
	
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
		protected var _weaponDistance:Point = new Point(0,0);
		
		public var direction:int;
		
		public var velY:Number = 0;
		public var velX:Number = 0;
		public var maxVel:int = 6;
		protected var _boundingbox:Rectangle;
		private var _speed:Number = 0.5;
		
		private var _width:int;
		
		protected var _HP:int;
		
		public var rotatable:Boolean = false;
		
		private var explosionSound:Sound = new Assets.ExplosionSound();
		
		public function Ship(s:Sprite)
		{
			this.stageRef = s;
			super();
			this.setWidth(this.width);
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			this.boundingbox = this.bounds;
			
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function showBoundingBox() : void {
			lines = new DrawRect(new Rectangle(0, 0, this.boundingbox.width, this.boundingbox.height));
			lines.x -= boundingbox.width / 2;
			lines.y -= boundingbox.height / 2;
			addChild(lines);
			
			toggleBox(VARS.showBoundingBoxes);
		}
		
		protected function createShipArt(a:String):void
		{
			// Create ship art
			shipArt = new Image(Assets.getAtlas().getTexture(a));
			shipArt.alignPivot();
			
			// Add it
			this.addChild(shipArt);
			
		}
		
		public function init() : void {
			
		}
		
		public function getWeaponDistance() : Point { return _weaponDistance; }
		
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
		
		public function getWidth() : int {
			return _width;
		}
		
		public function setWidth(i:int) : void {
			_width = i;
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
			
			Debug.INFO(this._HP + " hp left.", this);
			
			if (this._HP <= 0) {
				this.destroy();
				Debug.INFO("Aaargh! I died!", this); 
				return true;
			}
			
			return false;
		}
		
		private function destroy() : void {
			InGame.ships.splice(InGame.ships.indexOf(this), 1);
			
			var expl:AbstractExplosion = new LargeExplosion(stageRef);
			expl.create(this.x - this.width / 2, this.y);
			
			stageRef.removeChild(this, true);
			explosionSound.play();
		}
	}
}