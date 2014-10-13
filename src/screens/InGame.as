package screens
{
	import com.freeactionscript.effects.explosion.AbstractExplosion;
	import com.freeactionscript.effects.explosion.LargeExplosion;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	
	import events.NavigationEvent;
	
	import controllers.KeyboardHandler;
	
	import debugger.Debug;
	
	import feathers.controls.Button;
	
	import global.Conversations;
	import global.VARS;
	
	import objects.Blackbird;
	import objects.ENEMY;
	import objects.IngameBackground;
	import objects.Laser;
	import objects.Phaser;
	import objects.ShieldHit;
	import objects.Ship;
	import objects.Sparrow;
	import objects.Screecher;
	import objects.Target;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	import utils.TextGenerator;
	
	
	
	public class InGame extends Sprite
	{
		private var startBtn:Button;
		private var player:Sparrow;
		private var mike:Blackbird;
		private var bg:IngameBackground;
		private var keyHandler:KeyboardHandler;
		
		private var bgVolume:SoundTransform = new SoundTransform();		
		private var soundChannel:SoundChannel = new SoundChannel();
		
		private var currObjective:String = "";
		
		// STAGE THINGS
		
		private var xMax:int;
		private var yMax:int;
		
		private var GO:Image;
		
		private static var _explosion:AbstractExplosion;
		
		public static var boxesShown:Boolean = true;
		
		private var timePrevious:Number;
		private var timeCurrent:Number;
		private var elapsed:Number;
		
		private var _gameState:String = "";
		
		private var targetCount:int;
		private var killCount:int;
		
		private var comingEnemies:Array = new Array();
		
		public static var bullets:Array = new Array();
		public static var ships:Array = new Array();
		
		private var textHandler:TextGenerator = new TextGenerator(this);
		
		private var shakeIterator:int = 0;
		
		private var boss:Ship = new Screecher(this);
		
		// TEMP TESTING VARS
		private var en:Phaser;
		
		// SOUNDS 
		private var shieldHitSound:Sound = new Assets.ShieldHitSound();
		private var startGameSound:Sound = new Assets.PlaySound();
			
		public function InGame() {
			super(); 
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage() : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
			drawGame();
			startBtn.addEventListener(Event.TRIGGERED, onMouseDown);
			
			xMax = stage.stageWidth - 100;
			yMax = stage.stageHeight - 100;
			
		}
		
		// Handle clicks
		private function onMouseDown(e:Event):void {
			switch (e.currentTarget) {
				case startBtn:
					if (_gameState == "over" && this.contains(GO)) {
						removeChild(GO);
						//drawStart(true);
						retargetEnemies();
					}
					
					for (var i:int = 0; i < ships.length; ++i) {
						if (stage.contains(ships[i])) 
							removeChild(ships[i], true);
						
						ships.splice(i, 1);
					}
					
					ships.push(player);
					addChild(player);
					gameState = "idle";
					startBtn.removeEventListener(Event.TRIGGERED, onMouseDown);
					removeChild(startBtn, true);
					
					startGameSound.play(0, 0, VARS.soundVolume);
					
					this.addEventListener(Event.ENTER_FRAME, checkElapsed);
					this.addEventListener(Event.ENTER_FRAME, gameLoop);
					break;
				default:
					throw new Error("Item clicked was unknown.");
			}	
		}
		
		// Initiate a new conversation
		private function startConvo() : void {
			
			var text:Array;
			switch (VARS.storyProgress++) {
				case 0:
					text = global.Conversations.get("mike_intro");
					textHandler.textBlocks = text;
					textHandler.startText();
					this.addEventListener("conversationOver", next);
					break;
				case 1: 
					text = global.Conversations.get("mike_intro_middle");
					textHandler.textBlocks = text;
					textHandler.startText();
					this.addEventListener("conversationOver", next);
					break;
				case 2: 
					text = global.Conversations.get("mike_intro_over");
					textHandler.textBlocks = text;
					textHandler.startText();
					this.addEventListener("conversationOver", next);
					break;
				default: break;
			}
		}
		
		// This function is called when a conversation is over
		// to take the story forward
		private function storyTeller() : void {
			removeEventListener("conversationOver", next);
			Debug.INFO("storyTeller() - currProgress is: " + VARS.currProgress, this);
			
			switch (VARS.currProgress) {
				case 0:
					startConvo();
					gameState = "over";
					break;
				case 1: 
					gameState = "mike_leaving";
					break;
				case 2: 
					
					currObjective = "killCount";
					this.addEventListener("enemyDown", function(e:Event) : void {
						if (++killCount == targetCount) {
							removeEventListener("enemyDown", arguments.callee);
						}
						Debug.INFO(killCount + "/" + targetCount + " enemies defeated.", this);
					});
					
					addEventListener("objectiveComplete", function(e:Event) : void {
						removeEventListener("objectiveComplete", arguments.callee);
						next();
					});
					
					comingEnemies = new Array("Target");
					spawnEnemy("Target");
					
					killCount = 0;
					targetCount = 2;
					
					gameState = "play";
					break;
				case 3:
					mike.x = 760;
					mike.y = stage.stageHeight * 0.2;
					mike.rotation = 0;
					mike.velX = 0;
					mike.velY = 0;
					gameState = "mike_enters";
					break;
				case 4: 
					startConvo();
					gameState = "over";
					break;
				case 5:	
					gameState = "mike_leaving";
					break;
				case 6:
					
					currObjective = "killCount";
					this.addEventListener("enemyDown", function(e:Event) : void {
						if (++killCount == targetCount) {
							removeEventListener("enemyDown", arguments.callee);
						}
						Debug.INFO(killCount + "/" + targetCount + " enemies defeated.", this);
					});
					
					addEventListener("objectiveComplete", function(e:Event) : void {
						removeEventListener("objectiveComplete", arguments.callee);
						next();
					});
					
					comingEnemies = new Array("Target", "Target");
					spawnEnemy("Target");
					
					killCount = 0;
					targetCount = 3;
					
					gameState = "play";
					break;
				
				case 7:
					mike.x = 760;
					mike.y = stage.stageHeight * 0.2;
					mike.rotation = 0;
					mike.velX = 0;
					mike.velY = 0;
					gameState = "mike_enters";
					break;
				case 8: 
					gameState = "over";
					startConvo();
					
					var callBack:Function;
					
					addEventListener("mikeDamage", callBack = function(e:Event) : void {
						removeEventListener("mikeDamage", callBack);
						
						var l:Laser = new Laser((this as Sprite), boss, 1, 1); 
						l.y = stage.stageHeight * 0.2;
						l.x = -30;
						l.scaleX = 2;
						l.scaleY = 2;
						
						(new Assets.LaserSound() as Sound).play(0, 0, global.VARS.soundVolume);
						
						addChild(l);
						
						addEventListener(Event.ENTER_FRAME, function(e:Event) : void {
							if (l.bounds.intersects(mike.boundingbox)) {
								mike.takeDmg(l.power);
								l.destroy();
								
								var shieldHit:ShieldHit = new ShieldHit(mike);
								shieldHit.x += mike.direction * mike.boundingbox.width / 2;
								shieldHit.y -= mike.boundingbox.height / 2 + 10;
								
								shieldHit.scaleX = -mike.direction * ((mike.boundingbox.width + 20) / shieldHit.width);
								shieldHit.scaleY = (mike.boundingbox.height + 20) / shieldHit.height;
								
								mike.addChild(shieldHit);
								
								shakeScreen();
								
								(new Assets.ExplosionSound() as Sound).play(0, 0, global.VARS.soundVolume);
								
								removeEventListener(Event.ENTER_FRAME, arguments.callee);
							}
						});
						
					});
					
					var screech:Function;
					
					addEventListener("screecherEnters", screech = function(e:Event) : void {
						removeEventListener("screecherEnters", screech);
						boss.x = -100;
						boss.y = 190;
						(boss as Screecher).fixatePosition();
						boss.init();
						
						addChild(boss);
						gameState = "screecher_enter";
					});
					
					var expl:Function;
					
					addEventListener("mikeExplodes", expl = function(e:Event) : void { 
						removeEventListener("mikeExplodes", expl);
						
						(boss as Screecher).homeAndKill(mike);
						
						var mikeFire:Function;
						
						addEventListener("megaBlast", mikeFire = function() : void {
							
							removeEventListener("megaBlast", mikeFire);
							var l:Laser = new Laser((this as Sprite), boss, 1, 9001); 
							l.y = stage.stageHeight * 0.2;
							l.x = 150;
							l.scaleX = 2;
							l.scaleY = 2;
							addChild(l);
							(new Assets.LaserSound() as Sound).play(0, 0, global.VARS.soundVolume);
							
							addEventListener(Event.ENTER_FRAME, function(e:Event) : void {
								if (l.bounds.intersects(mike.boundingbox)) {
									ships.push(mike);
									mike.takeDmg(l.power);
									l.destroy();
									
									shakeScreen();
									removeEventListener(Event.ENTER_FRAME, arguments.callee);
									addEventListener("conversationOver", next);
									
									(new Assets.ExplosionSound() as Sound).play(0, 0, global.VARS.soundVolume);
								}
							});
						});
					});
					break;
				case 9:
					ships.push(boss);
					(boss as Screecher).target = player;
					(boss as Screecher).engage();
					currObjective = "ua";
					gameState = "play";
					Debug.INFO(Debug.formatArray(ships), this);
					Debug.INFO(Debug.formatArray(bullets), this);
					
					var gameWon:Function;
					this.addEventListener("enemyDown", gameWon = function (e:Event) : void {
						gameState = "bossExplode";
						this.removeEventListener("enemyDown", gameWon);
						this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "level_completed"}, true));
					});
					break;
				default: break;
			}
			
		}
		
		// Temporary function? 
		private function retargetEnemies(init:Boolean = false) : void {
			for (var i:int = 0; i < ships.length; ++i) {
				if (ships[i] == player) continue;
				
				if (ships[i] is ENEMY) (ships[i] as ENEMY).target = player;
				
				if (init) (ships[i] as Ship).init();
			}
		}
		
		// For animation handling. Not used as-is.
		private function checkElapsed(e:Event) : void {
			timePrevious = timeCurrent;
			timeCurrent = getTimer();
			elapsed = (timeCurrent - timePrevious);
		}
		
		// Start it all?
		private function init() : void {
			keyHandler = new KeyboardHandler(this);
			startBtn = new Button(); // DEPR APPROACH - STARLING BUTTON: Assets.getAtlas().getTexture("startGameBtn"), "", Assets.getAtlas().getTexture("startGameBtnDown"));
			startBtn.defaultSkin = new Image(Assets.getAtlas().getTexture("startGameBtn"));
			startBtn.downSkin = new Image(Assets.getAtlas().getTexture("startGameBtnDown"));
			startBtn.hoverSkin = new Image(Assets.getAtlas().getTexture("startGameBtnOver"));
			startBtn.label = "This button starts the game!";
			
			VARS.currProgress = -1;
			VARS.storyProgress = 0;
			
			_explosion = new LargeExplosion(this);
			
			mike = new Blackbird(this);
			mike.x = 760;
			mike.y = stage.stageHeight * 0.2;
			
			bg = new IngameBackground(this);
		}
		
		// Paint the screen like one of your french girls.
		private function drawGame():void {
			
			addChild(bg);
			
			addChild(textHandler);
			textHandler.y = stage.stageHeight;
			
			drawStart();
		}
		
		// Hit the start button? Redraw game
		private function drawStart(restart:Boolean = false) : void {
			addChild(startBtn);
			// Feather buttons do not have a width until they have been drawn. 
			// Use .validate() to precalculate width for positioning before
			// next draw call.
			startBtn.validate();
			startBtn.y = stage.stageHeight / 4;
			startBtn.x = stage.stageWidth/2 - startBtn.width / 2;
			
			player = new Sparrow(this);
			player.x = stage.stageWidth + player.width + 120;
			player.y = stage.stageHeight * 0.6;
			
			ships.push(player);
			addChild(player);
			
			if (!restart) {
				//spawnEnemy(Math.round(Math.random()) == 1 ? "Phaser" : "Target");
			}
		}
		
		// Spawns a new enemy of parsed string (type) s
		private function spawnEnemy(type:String) : void {
			var en:Ship;
			
			switch(type) {
				case "Phaser": 
					en = new Phaser(this, player);
					en.x = 40;
					en.y = stage.stageHeight / 2;
					en.init();
					ships.push(en);
					addChild(en);
					break;
				case "Target":
					var t:Target = new Target(this);
					t.x = 40;
					t.y = Math.random() * (stage.stageHeight - (textHandler.height + 60)) + 60;
					t.fixatePosition();
					t.init();
					ships.push(t);
					addChild(t);
					break;
				default: 
					throw new Error("spawnEnemy() received unknown type request!"); 
					break;
			}
		}
		
		// Handle game
		private function gameLoop(e:Event) : void {
			switch (_gameState) {
				case "idle":
					if (player.x > stage.stageWidth - player.width) {
						player.velX -= player.speed;
						
						if(Math.abs(player.velY) > player.maxVel/3) player.velY = (Math.abs(player.velY) / player.velY) * player.maxVel/3; 	// |velY| / velY -> 1 or -1
						if(Math.abs(player.velX) > player.maxVel/3) player.velX = (Math.abs(player.velX) / player.velX) * player.maxVel/3;	// |velX| / velX -> 1 or -1
						
						player.velX *= global.VARS.airRes;
						player.velY *= global.VARS.airRes;
						
						player.x += player.velX;
						
						if (!player.rotatable) break;
						
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
						//gameState = "play";
						//en.init();
						gameState = "mike_enters";
					}
					break;
				
				case "mike_enters":
					var allInPlace:Boolean = true;
					addChild(mike);
					
					if (mike.x > stage.stageWidth - 100) {
						allInPlace = false;
						mike.velX -= mike.speed;
						
						if(Math.abs(mike.velX) > mike.maxVel/3) mike.velX = (Math.abs(mike.velX) / mike.velX) * mike.maxVel/3;
						
						mike.velX *= global.VARS.airRes;
						mike.x += mike.velX;	
					}
					
					if (Math.round(player.y) < stage.stageHeight * 0.5 || Math.round(player.x) < stage.stageWidth - player.width) {
						allInPlace = false;
						
						if (Math.round(player.x) < stage.stageWidth - player.width) {
							
							player.velX += player.speed;
							
							if(Math.abs(player.velX) > player.maxVel/3) 
								player.velX = (Math.abs(player.velX) / player.velX) * player.maxVel/3;	// |velX| / velX -> 1 or -1
						
							player.velX *= global.VARS.airRes;
							player.x += player.velX;
						
						}
						if (Math.round(player.y) < stage.stageHeight * 0.5) {
							player.velY += player.speed;
							
							if(Math.abs(player.velY) > player.maxVel/3)
								player.velY = (Math.abs(player.velY) / player.velY) * player.maxVel/3; 	// |velY| / velY -> 1 or -1
							
							player.velY *= global.VARS.airRes;
							player.y += player.velY;
						}
						
						if (!player.rotatable) break;
						
						if(player.velX < 4) {
							player.rotation = starling.utils.deg2rad(2 * player.velX);
							player.exhaustArt.rotation = starling.utils.deg2rad(2 * -player.velX);
						}
						else {
							player.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(player.velX) / player.velX));
							player.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(player.velX) / player.velX));
						}
					}
					
					if (allInPlace) {
						next();
					}
					
					break;
				
				case "mike_leaving": 
					if (!mike) {
						throw new Error("Mike doesn't exist - why? Can't remove him");
					}
					
					mike.velX -= mike.speed * 0.1;
					mike.velY -= mike.speed * 0.05;
					mike.rotation -= mike.velY * 0.002;
					//mike.velX *= global.VARS.airRes;
					mike.x += mike.velX;
					mike.y += mike.velY;
					
					if (mike.x < -130) {
						removeChild(mike);
						next();
					}
					
					break;
				
				case "play":
					if (checkObjective()) {
						Debug.INFO("Objective completed!", this);
						this.dispatchEvent(new Event("objectiveComplete"));
						break;
					}
										
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
					
					if(player.x > this.xMax || player.x < player.width / 4) 
						player.x = (player.x > (stage.stageWidth / 2)) ? this.xMax : player.width / 4;
					
					if(player.y > this.yMax || player.y < player.height / 2)
						player.y = (player.y > (stage.stageHeight / 2)) ? this.yMax : player.height / 2;
					
					if (player.rotatable) {
						if(player.velX < 4) {
							player.rotation = starling.utils.deg2rad(2 * player.velX);
							player.exhaustArt.rotation = starling.utils.deg2rad(2 * -player.velX);
						}
						else {
							player.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(player.velX) / player.velX));
							player.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(player.velX) / player.velX));
						}
					}
					
					player.exhaustArt.scaleX = -(player.velX / player.maxVel) + 1;
					
					// Handle weaponry
					if(keyHandler.fire1) player.primary();
					if(keyHandler.fire2) player.secondary();
					
					checkBullets();
					
					break;
				
				case "screecher_enter":
					if (boss.x >= 120) {
						dispatchEvent(new Event("screecherEntered"));
						
						gameState = "over";
					}
					
					boss.x += 1;
				case "bossExplode":
					// fall through
				case "over":
					
					break;
				default: 
					throw new Error("Unhandled result in gameLoop: '"+ _gameState + "' was unknown.");
			}
		}
		
		private function checkObjective() : Boolean {
			switch (currObjective) {
				case "killCount":
					if (killCount == targetCount) {
						return true;
					}
					break;
				case "ua":
					return false;
				default:
					break;
			}
			
			return false;
		}
		
		// Show bounding boxes of all ships
		public static function showBoxes() : void {
			for (var i:int = 0; i < ships.length; ++i) {
				(ships[i] as Ship).toggleBox(!VARS.showBoundingBoxes);
			}
			
			VARS.showBoundingBoxes = !VARS.showBoundingBoxes;	
		}
		
		// Shake screen. Explosion? Earth quake? One does not know
		public function shakeScreen() : void {
			Debug.INFO("Shaking screen!", this);
			addEventListener(Event.ENTER_FRAME, shakeLoop);
		}
		
		// Handle the shaking. Will it end? (yes, after 2 second)
		private function shakeLoop(e:Event) : void {
			if (shakeIterator >= 90){
				shakeIterator = 0;
				removeEventListener(Event.ENTER_FRAME, shakeLoop);
				this.x = 0.0;
				this.y = 0.0;
				this.scaleX = 1.0;
				this.scaleY = 1.0;
				this.dispatchEvent(new Event("shakeDone"));
				return;
			}
			
			this.x = Math.random()*6 - 3;
			this.y = Math.random()*6 - 3;
			this.scaleX = 1 + Math.random() * 0.01;
			this.scaleY = 1 + Math.random() * 0.01;
			shakeIterator++;
		}
		
		// Clean up. This place is a mess.
		private function cleanUp() : void {
			Debug.INFO("Cleaning up!");
			for (var i:int = 0; i < ships.length; ++i) {
				(ships[i] as ENEMY).clean();
			}
		}
		
		// Player died - game over!
		private function gameOver() : void {
			//cleanUp();
			
			this.removeEventListener(Event.ENTER_FRAME, checkElapsed);
			this.removeEventListener(Event.ENTER_FRAME, gameLoop);
			
			showGameOverScreen();
			gameState = "over";
		}
		
		// Take me to the next stage of this epic adventure!
		public function next() : void {
			Debug.INFO("next() incremented current progress!", this);
			Debug.INFO("ships[] is: " + Debug.formatArray(ships), this);
			++VARS.currProgress;
			storyTeller();
		}
		
		// Let's the game loop know where in the story we are.
		private function set gameState(state:String) : void {
			_gameState = state;
			Debug.INFO("gameState is now: " + state, this);
		}
		
		// Let the player know that the game actually is over.
		private function showGameOverScreen() : void {
			GO = new Image(Assets.getAtlas().getTexture("gameOver"));
			GO.x = 350 - GO.width / 2;
			GO.y = 120;
		
			init();
			
			drawGame();
			startBtn.addEventListener(Event.TRIGGERED, onMouseDown);
		}
		
		// Check for hits!
		private function checkBullets() : void {
			for (var i:int = 0; i < bullets.length; ++i) {
				for (var j:int = 0; j < ships.length; ++j) {
					if ((bullets[i] as Laser).gunman == ships[j]) {
						// The one we hit was the one self. Not likely - skip this cycle.
						// This is a bounding box issue and handled by this simple hack.
						continue;
					}
					
					if (new Rectangle(bullets[i].x, bullets[i].y, (bullets[i] as Laser).hitBox.width, (bullets[i] as Laser).hitBox.width).intersects((ships[j] as Ship).boundingbox)) {
						//Debug.INFO("Hit was registered: on object [" + Formatting.getName(ships[j]) + "]", this);
						
						var isPlayer:Boolean = (ships[j] == player);
						
						if (ships[j].takeDmg((bullets[i] as Laser).power)) {
							// if this is player ship, game is over.
							if (isPlayer) {
								gameOver();
							}
							else {
								//spawnEnemy(Math.round(Math.random()) == 1 ? "Phaser" : "Target");
								this.dispatchEvent(new Event("enemyDown"));
								if (comingEnemies.length != 0) {
									spawnEnemy(comingEnemies.splice(0, 1));
								//retargetEnemies(true);
								}
								else {
									
								}
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
						
						shieldHitSound.play();
						
						break;
					}
				}
			}
		}
	}
}