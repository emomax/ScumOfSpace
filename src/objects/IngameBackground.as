package objects {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	public class IngameBackground extends Sprite{
		
		public var bg:Image = new Image(Assets.getTexture("Background"));
		public var bg2:Image = new Image(Assets.getTexture("Background"));
		
		public var fg:Image = new Image(Assets.getTexture("Foreground"));
		public var fg2:Image = new Image(Assets.getTexture("Foreground"));
		
		public var mg:Image = new Image(Assets.getTexture("Foreground2"));
		public var mg2:Image = new Image(Assets.getTexture("Foreground2"));
		
		private var speed:int = 1;
		private var stageRef:Sprite;
		
		private var bgX:Number = 0;
		
		public function IngameBackground(s:Sprite) {
			stageRef = s;
			
			bg2.x = -700;
			mg2.x = -700;
			fg2.x = -700;
			
			addChild(bg);
			addChild(bg2);
			
			addChild(mg);
			addChild(mg2);
			
			addChild(fg);
			addChild(fg2);
			
			addEventListener(Event.ENTER_FRAME, backgroundLoop);
		}
		
		private function backgroundLoop(e:Event) : void {
			
			
			fg.x += 10 * speed;
			fg2.x += 10 * speed;
			
			mg.x += 4 * speed;
			mg2.x += 4 * speed;
			
			bgX += speed;
			
			bg.x = Math.ceil(bgX);
			bg2.x = Math.ceil(bgX) - 700;
			
			
			if (fg.x > 700) {
				fg.x -= 700;
				fg2.x -= 700;
			}
			
			if (bg.x > 700) {
				bg.x -= 700;
				bg2.x -= 700;
				bgX = 0;
			}
			
			if (mg.x > 700) {
				mg.x -= 700;
				mg2.x -= 700;
			}
		}
	}
}