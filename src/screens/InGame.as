package screens
{
	import objects.Ship;
	import controllers.KeyboardHandler;
	import global.VARS;
	
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
			addChild(ship);
		}
		
		private function gameLoop(e:Event) : void {
			
			if(keyHandler.up) ship.velY -= ship.speed;
			if(keyHandler.down) ship.velY += ship.speed;
			if(keyHandler.left) ship.velX -= ship.speed;
			if(keyHandler.right) ship.velX += ship.speed;
			
			// UNDER TESTING
			
			/*if(Math.abs(ship.velY) > ship.maxVel) ship.velY = (Math.abs(ship.velY) / ship.velY) * ship.maxVel; 	// |velY| / velY -> 1 or -1
			if(Math.abs(ship.velX) > ship.maxVel) ship.velX = (Math.abs(ship.velX) / ship.velX) * ship.maxVel;	// |velX| / velX -> 1 or -1
			
			ship.velX *= global.VARS.airRes;
			ship.velY *= global.VARS.airRes;
			
			if(Math.round(ship.velX*10) == 0) ship.velX = 0;
			if(Math.round(ship.velY*10) == 0) ship.velY = 0;*/
			
			ship.x += ship.velX;
			ship.y += ship.velY;
			
			/*if(ship.x > ship.xMax || ship.x < ship.realWidth / 4) 
				ship.x = (ship.x > (width / 2)) ? ship.xMax : ship.realWidth / 4;
			
			if(ship.y > ship.yMax || ship.y < ship.height / 2)
				ship.y = (ship.y > (height / 2)) ? ship.yMax : ship.height / 2;
			
			ship.exhaustArt.scaleX = (3 - 5 * (ship.velX / ship.maxVel));
			
			// EXTERNAL THINGS
			if(keyHandler.fire1()) ship.primary();
			if(keyHandler.fire2()) ship.secondary();*/
		}
	}
}