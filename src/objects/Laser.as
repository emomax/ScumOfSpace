package objects
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Laser extends Sprite
	{
		private var art:Image;
		private var stageRef:Sprite;
		
		private var yDiff:Number;
		
		public function Laser(s:Sprite)
		{
			super();
			art = new Image(Assets.getAtlas().getTexture("laser_1"));
			stageRef = s;
			
			
			addChild(art);
			addEventListener(Event.ENTER_FRAME, laserLoop);
		}
		
		private function laserLoop (e:Event) : void {
			this.x -= 15;
			
			if (this.x < -this.width) this.destroy();
		}
		
		private function destroy() : void {
			trace("Destroyed laser");
			removeEventListener(Event.ENTER_FRAME, laserLoop);
			stageRef.removeChild(this, true);
		}
	}
}