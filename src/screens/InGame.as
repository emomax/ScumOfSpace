package screens
{
	import flash.utils.getTimer;
	
	import controllers.KeyboardHandler;
	
	import global.VARS;
	
	import objects.Ship;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.utils.deg2rad;
	
	public class InGame extends Sprite
	{
		private var ship:Ship;
		private var keyHandler:KeyboardHandler;
		
		private var timePrevious:Number;
		private var timeCurrent:Number;
		private var elapsed:Number;
		
		private var gameState:String;
		
		public function InGame()
		{
			super(); 
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
			drawGame();
			
			this.addEventListener(Event.ENTER_FRAME, checkElapsed);
			this.addEventListener(Event.ENTER_FRAME, gameLoop);
		}
		
		private function checkElapsed(e:Event):void
		{
			timePrevious = timeCurrent;
			timeCurrent = getTimer();
			elapsed = (timeCurrent - timePrevious);
			trace (elapsed);
		}
		
		private function init() : void {
			keyHandler = new KeyboardHandler(this);
		}
		
		private function drawGame():void
		{
			ship = new Ship();
			ship.x = stage.stageWidth + ship.width + 120;
			ship.y = stage.stageHeight * 0.5;
			gameState = "idle";
			addChild(ship);
		}
		
		private function gameLoop(e:Event) : void {
			switch (gameState) {
				case "idle":
					if (ship.x > stage.stageWidth - ship.width) {
						ship.velX -= ship.speed;
						
						if(Math.abs(ship.velY) > ship.maxVel) ship.velY = (Math.abs(ship.velY) / ship.velY) * ship.maxVel; 	// |velY| / velY -> 1 or -1
						if(Math.abs(ship.velX) > ship.maxVel) ship.velX = (Math.abs(ship.velX) / ship.velX) * ship.maxVel;	// |velX| / velX -> 1 or -1
						
						ship.velX *= global.VARS.airRes;
						ship.velY *= global.VARS.airRes;
						
						ship.x += ship.velX;
						
						if(ship.velX < 4) {
							ship.rotation = starling.utils.deg2rad(2 * ship.velX);
							ship.exhaustArt.rotation = starling.utils.deg2rad(2 * -ship.velX);
						}
						else {
							ship.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(ship.velX) / ship.velX));
							ship.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(ship.velX) / ship.velX));
						}
					}
					else {
						gameState = "play";
					}
					break;
				
				case "play":
					if(keyHandler.up) ship.velY -= ship.speed;
					if(keyHandler.down) ship.velY += ship.speed;
					if(keyHandler.left) ship.velX -= ship.speed;
					if(keyHandler.right) ship.velX += ship.speed;
					
					if(Math.abs(ship.velY) > ship.maxVel) ship.velY = (Math.abs(ship.velY) / ship.velY) * ship.maxVel; 	// |velY| / velY -> 1 or -1
					if(Math.abs(ship.velX) > ship.maxVel) ship.velX = (Math.abs(ship.velX) / ship.velX) * ship.maxVel;	// |velX| / velX -> 1 or -1
					
					ship.velX *= global.VARS.airRes;
					ship.velY *= global.VARS.airRes;
					
					if(Math.round(ship.velX*10) == 0) ship.velX = 0;
					if(Math.round(ship.velY*10) == 0) ship.velY = 0;
					
					ship.x += ship.velX;
					ship.y += ship.velY;
					
					if(ship.velX < 4) {
						ship.rotation = starling.utils.deg2rad(2 * ship.velX);
						ship.exhaustArt.rotation = starling.utils.deg2rad(2 * -ship.velX);
					}
					else {
						ship.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(ship.velX) / ship.velX));
						ship.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(ship.velX) / ship.velX));
					}
					
					ship.exhaustArt.scaleX = -(ship.velX / ship.maxVel) + 1;
					
					// Handle weaponry
					if(keyHandler.fire1) ship.primary();
					if(keyHandler.fire2) ship.secondary();
					
					break;
				default: 
					break;
			}
		}
	}
}