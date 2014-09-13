package screens
{
	import flash.utils.getTimer;
	
	import controllers.KeyboardHandler;
	
	import feathers.controls.Button;
	
	import global.VARS;
	
	import objects.Blackbird;
	import objects.IngameBackground;
	import objects.Ship;
	import objects.Laser;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	public class InGame extends Sprite
	{
		private var startBtn:Button;
		private var player:Ship;
		private var bg:IngameBackground;
		private var keyHandler:KeyboardHandler;
		
		private var timePrevious:Number;
		private var timeCurrent:Number;
		private var elapsed:Number;
		
		private var gameState:String;
		
		public function InGame() {
			super(); 
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage() : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
			drawGame();
			
			startBtn.addEventListener(Event.TRIGGERED, onMouseDown);
		}
		
		private function onMouseDown(e:Event):void {
			switch (e.currentTarget) {
				case startBtn:
					
					gameState = "idle";
					removeChild(startBtn, true);
					
					this.addEventListener(Event.ENTER_FRAME, checkElapsed);
					this.addEventListener(Event.ENTER_FRAME, gameLoop);
					break;
				default:
					throw new Error("Item clicked was unknown.");
			}
				
		}
		
		private function checkElapsed(e:Event) : void {
			timePrevious = timeCurrent;
			timeCurrent = getTimer();
			elapsed = (timeCurrent - timePrevious);
		}
		
		private function init() : void {
			keyHandler = new KeyboardHandler(this);
			startBtn = new Button(); // DEPR APPROACH - STARLING BUTTON: Assets.getAtlas().getTexture("startGameBtn"), "", Assets.getAtlas().getTexture("startGameBtnDown"));
			startBtn.defaultSkin = new Image(Assets.getAtlas().getTexture("startGameBtn"));
			startBtn.downSkin = new Image(Assets.getAtlas().getTexture("startGameBtnDown"));
			startBtn.hoverSkin = new Image(Assets.getAtlas().getTexture("startGameBtnOver"));
			startBtn.label = "This button starts the game!";
			
			bg = new IngameBackground(this);
		}
		
		private function drawGame():void {
			addChild(bg);
			addChild(startBtn);
			// Feather buttons do not have a width until they have been drawn. 
			// Use .validate() to precalculate width for positioning before
			// next draw call.
			startBtn.validate();
			startBtn.y = stage.stageHeight / 4;
			startBtn.x = stage.stageWidth/2 - startBtn.width / 2;
			
			
			player = new Blackbird(this);
			player.x = stage.stageWidth + player.width + 120;
			player.y = stage.stageHeight * 0.5;
			addChild(player);
		}
		
		private function gameLoop(e:Event) : void {
			switch (gameState) {
				case "idle":
					if (player.x > stage.stageWidth - player.width) {
						player.velX -= player.speed;
						
						if(Math.abs(player.velY) > player.maxVel) player.velY = (Math.abs(player.velY) / player.velY) * player.maxVel; 	// |velY| / velY -> 1 or -1
						if(Math.abs(player.velX) > player.maxVel) player.velX = (Math.abs(player.velX) / player.velX) * player.maxVel;	// |velX| / velX -> 1 or -1
						
						player.velX *= global.VARS.airRes;
						player.velY *= global.VARS.airRes;
						
						player.x += player.velX;
						
						if(player.velX < 4) {
							player.rotation = starling.utils.deg2rad(2 * player.velX);
							player.exhaustArt.rotation = starling.utils.deg2rad(2 * -player.velX);
						}
						else {
							player.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(player.velX) / player.velX));
							player.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(player.velX) / player.velX));
						}
					}
					else {
						gameState = "play";
					}
					break;
				
				case "play":
					if(keyHandler.up) player.velY -= player.speed;
					if(keyHandler.down) player.velY += player.speed;
					if(keyHandler.left) player.velX -= player.speed;
					if(keyHandler.right) player.velX += player.speed;
					
					if(Math.abs(player.velY) > player.maxVel) player.velY = (Math.abs(player.velY) / player.velY) * player.maxVel; 	// |velY| / velY -> 1 or -1
					if(Math.abs(player.velX) > player.maxVel) player.velX = (Math.abs(player.velX) / player.velX) * player.maxVel;	// |velX| / velX -> 1 or -1
					
					player.velX *= global.VARS.airRes;
					player.velY *= global.VARS.airRes;
					
					if(Math.round(player.velX*10) == 0) player.velX = 0;
					if(Math.round(player.velY*10) == 0) player.velY = 0;
					
					player.x += player.velX;
					player.y += player.velY;
					
					if(player.velX < 4) {
						player.rotation = starling.utils.deg2rad(2 * player.velX);
						player.exhaustArt.rotation = starling.utils.deg2rad(2 * -player.velX);
					}
					else {
						player.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(player.velX) / player.velX));
						player.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(player.velX) / player.velX));
					}
					
					player.exhaustArt.scaleX = -(player.velX / player.maxVel) + 1;
					
					// Handle weaponry
					if(keyHandler.fire1) player.primary();
					if(keyHandler.fire2) player.secondary();
					
					break;
				default: 
					break;
			}
		}
	}
}