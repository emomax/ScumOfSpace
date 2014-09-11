package screens
{
	import objects.Ship;
	import controllers.KeyboardHandler;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	public class InGame extends Sprite
	{
		private var ship:Ship;
		private var keyHandler:KeyboardHandler;
		
		public function InGame()
		{
			super(); 
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initControls();
			drawGame();
			
			this.addEventListener(Event.ENTER_FRAME, gameLoop);
		}
		
		private function initControls() : void {
			keyHandler = new KeyboardHandler(this);
		}
		
		private function drawGame():void
		{
			ship = new Ship();
			ship.x = 120;
			ship.y = 120;
			this.addChild(ship);
		}
		
		private function gameLoop(e:Event) : void {
			if (keyHandler.up) ship.y -= ship.speed;
		}
	}
}