package objects
{
	import flash.geom.Point;
	import flash.geom.Rectangle
	
		import debugger.Debug;
		
	import screens.InGame;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import geometry.DrawRect;
	
	public class Laser extends Sprite
	{
		private var art:Image;
		private var stageRef:Sprite;
		public var velocity:Point;
		public var dir:int;
		private var scatterY:Number = (Math.random() > 0.5) ? Math.round(Math.random() * 0.8) : -Math.round(Math.random() * 0.8);
		private var speed:int = 15;
		private var dmg:int;
		
		public var hitBox:Rectangle;
		
		public var gunman:Ship;
		
		private var yDiff:Number;
		
		public function Laser(s:Sprite, _gunman:Ship, dir:int = -1, _dmg:int = 10, vel:Point = null) : void
		{
			this.dir = dir;
			this.gunman = _gunman;
			this.dmg = _dmg;
			
			if (vel == null) {
				velocity = new Point();
				velocity.x = speed * dir; 
				velocity.y = 0;
			} else {
				velocity = vel;
				velocity.x *= speed;
				velocity.y *= speed;
				scatterY = 0;
			}
			
			super();
			
			InGame.bullets.push(this);
			
			art = new Image(Assets.getAtlas().getTexture("laser_1"));
			stageRef = s;
			
			addChild(art);
			
			hitBox = this.bounds;
			
			// Uncomment this to see bounding box
			//addChild(new DrawRect(hitBox));
			addEventListener(Event.ENTER_FRAME, laserLoop);
		}
		
		private function laserLoop (e:Event) : void {
			this.x += velocity.x;
			this.y += velocity.y + scatterY;
			
			if (this.x < -this.width || this.x > 700) {
				this.destroy();
			}
		}
		
		public function get power() : int { return dmg; }
		
		public function destroy() : void {
			if (stageRef.contains(InGame.bullets[InGame.bullets.indexOf(this)])) {
				InGame.bullets.splice(InGame.bullets.indexOf(this), 1);
				
				removeEventListener(Event.ENTER_FRAME, laserLoop);
				stageRef.removeChild(this, true);
				//trace("This bullet exists in bullets[]! Remove me!");
			}
			
			//trace("Destroyed laser");
		}
	}
}