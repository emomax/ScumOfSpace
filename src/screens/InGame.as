package screens
{
	import flash.utils.getTimer;
	
	import controllers.KeyboardHandler;
	
	import feathers.controls.Button;
	
	import global.VARS;
	
	import debugger.Debug;
	
	import objects.Blackbird;
	import objects.ENEMY;
	import objects.IngameBackground;
	import objects.Laser;
	import objects.Phaser;
	import objects.ShieldHit;
	import objects.Ship;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	public class InGame extends Sprite
	{
		private var startBtn:Button;
		private var player:Blackbird;
		private var bg:IngameBackground;
		private var keyHandler:KeyboardHandler;
		
		public static var boxesShown:Boolean = true;
		
		private var timePrevious:Number;
		private var timeCurrent:Number;
		private var elapsed:Number;
		
		private var _gameState:String;
		
		public static var bullets:Array = new Array();
		public static var ships:Array = new Array();
		
		// TEMP TESTING VARS
		
		private var en:Phaser;
		
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
					startBtn.removeEventListener(Event.TRIGGERED, onMouseDown);
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
			
			drawStart();
		}
		
		private function drawStart() : void {
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
			
			ships.push(player);
			
			en = new Phaser(this, player);
			en.x = 40;
			en.y = stage.stageHeight / 2;
			
			ships.push(en);
			
			addChild(en);
			addChild(player);
		}
		
		private function gameLoop(e:Event) : void {
			switch (_gameState) {
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
						en.init();
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
					
					checkBullets();
					
					break;
				case "over":
					
					break;
				default: 
					break;
			}
		}
		
		public static function showBoxes() : void {
			for (var i:int = 0; i < ships.length; ++i) {
				(ships[i] as Ship).toggleBox(!boxesShown);
			}
			
			boxesShown = !boxesShown;
		}
		
		private function cleanUp() : void {
			Debug.INFO("Cleaning up!");
			for (var i:int = 0; i < ships.length; ++i) {
				(ships[i] as ENEMY).clean();
			}
		}
		
		private function gameOver() : void {
			cleanUp();
			
			this.removeEventListener(Event.ENTER_FRAME, checkElapsed);
			this.removeEventListener(Event.ENTER_FRAME, gameLoop);
			
			showGameOverScreen();
			gameState = "over";
		}
		
		private function set gameState(state:String) : void {
			_gameState = state;
			Debug.INFO("gameState is now: " + state);
		}
		
		private function showGameOverScreen() : void {
			var GO:Image = new Image(Assets.getAtlas().getTexture("gameOver"));
			GO.x = 350 - GO.width / 2;
			GO.y = 120;
			
			startBtn = new Button(); // DEPR APPROACH - STARLING BUTTON: Assets.getAtlas().getTexture("startGameBtn"), "", Assets.getAtlas().getTexture("startGameBtnDown"));
			startBtn.defaultSkin = new Image(Assets.getAtlas().getTexture("startGameBtn"));
			startBtn.downSkin = new Image(Assets.getAtlas().getTexture("startGameBtnDown"));
			startBtn.hoverSkin = new Image(Assets.getAtlas().getTexture("startGameBtnOver"));
			startBtn.label = "This button starts the game!";
			
			addChild(startBtn);
			
			startBtn.validate();
			startBtn.y = stage.stageHeight / 4;
			startBtn.x = stage.stageWidth/2 - startBtn.width / 2;
			
			addChild(GO);
			startBtn.y = 200;
			startBtn.addEventListener(Event.TRIGGERED, onMouseDown);
		}
		
		private function checkBullets() : void {
			for (var i:int = 0; i < bullets.length; ++i) {
				for (var j:int = 0; j < ships.length; ++j) {
					if ((bullets[i] as Laser).gunman == ships[j]) {
						// The one we hit was the one self. Not likely - skip this cycle.
						// This is a bounding box issue and handled by this simple hack.
						continue;
					}
					if ((bullets[i] as Laser).bounds.intersects((ships[j] as Ship).boundingbox)) {
						Debug.INFO("Hit was registered: on object [" + ships[j] + "]");
						
						var isPlayer:Boolean = (ships[j] == player);
						
						if (ships[j].takeDmg((bullets[i] as Laser).power)) {
							// if this is player ship, game is over.
							if (isPlayer) {
								gameOver();
							}
							
							(bullets[i] as Laser).destroy();
							// if the ship is destroyed, don't show shieldHit.
							break;
						}
						
						(bullets[i] as Laser).destroy();
						
						var shieldHit:ShieldHit = new ShieldHit(ships[j]);
						shieldHit.x += ships[j].direction * ships[j].boundingbox.width / 2;
						shieldHit.y -= ships[j].boundingbox.height / 2 + 10;
						
						shieldHit.scaleX = -ships[j].direction * ((ships[j].boundingbox.width + 20) / shieldHit.width);
						shieldHit.scaleY = (ships[j].boundingbox.height + 20) / shieldHit.height;
						
						ships[j].addChild(shieldHit);
						
						break;
					}
				}
			}
		}
	}
}