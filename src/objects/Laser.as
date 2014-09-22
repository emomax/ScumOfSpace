package objects
{
	import screens.InGame;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Laser extends Sprite
	{
		private var art:Image;
		private var stageRef:Sprite;
		private var velocity:int;
		private var speed:int = 15;
		private var scatterY:Number = (Math.random() > 0.5) ? Math.round(Math.random() * 0.8) : -Math.round(Math.random() * 0.8);
		private var dmg:int;
		
		public var gunman:Ship;
		
		private var yDiff:Number;
		
		public function Laser(s:Sprite, _gunman:Ship, dir:int = -1, _dmg:int = 10)
		{
			this.gunman = _gunman;
			this.dmg = _dmg;
			
			super();
			
			InGame.bullets.push(this);
			
			art = new Image(Assets.getAtlas().getTexture("laser_1"));
			stageRef = s;
			
			velocity = speed * dir;
			addChild(art);
			addEventListener(Event.ENTER_FRAME, laserLoop);
		}
		
		private function laserLoop (e:Event) : void {
			this.x += velocity;
			this.y += scatterY;
			
			if (this.x < -this.width || this.x > 700) {
				this.destroy();
			}
		}
		
		public function get power() : int { return dmg; }
		
		public function destroy() : void {
			if (stageRef.contains(InGame.bullets[InGame.bullets.indexOf(this)])) {
				InGame.bullets.splice(InGame.bullets.indexOf(this), 1);
				//trace("This bullet exists in bullets[]! Remove me!");
			}
			
			//trace("Destroyed laser");
			removeEventListener(Event.ENTER_FRAME, laserLoop);
			stageRef.removeChild(this, true);
		}
	}
}