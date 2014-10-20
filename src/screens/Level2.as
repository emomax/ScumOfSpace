package screens {
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.Timer;
	
	import controllers.KeyboardHandler;
	
	import debugger.Debug;
	
	import global.Conversations;
	import global.VARS;
	
	import objects.Bumblebee;
	import objects.Drone;
	import objects.IngameBackground;
	import objects.Laser;
	import objects.Phaser;
	import objects.ShieldHit;
	import objects.Ship;
	import objects.Sparrow;
	import objects.Target;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	import utils.TextGenerator;
	
	public class Level2 extends Level {
		
		// State of the gameLoop
		private var _gameState:String = "over";
		
		// Objective parameters
		private var currObjective:String = "";
		private var targetCount:uint;
		private var killCount:uint;
		private var comingEnemies:Array = new Array();
		
		// Items for allowing an easier game
		private var spawnTimer:Timer;
		
		// Track keeping of items on stage;
		public static var bullets:Array = new Array();
		public static var ships:Array = new Array();
		
		// Text box and handling
		private var textHandler:TextGenerator = new TextGenerator(this);
		
		// Key handling
		private var keyHandler:controllers.KeyboardHandler = new KeyboardHandler(this);
		
		// Dimensions of screen
		private var xMax:int;
		private var yMax:int;
		
		// Necessary iterators
		private var shakeIterator:uint = 0;
		private var fireIterator:uint = 0;
		
		// Objects to be handled 
		private var player:Ship;
		private var commander:Bumblebee;
		private var bg:IngameBackground;
		
		// SOUNDS 
		private var shieldHitSound:Sound = new Assets.ShieldHitSound();
		private var startGameSound:Sound = new Assets.PlaySound();
		
		private var stageRef:Sprite = this;
		
		// Constructor for second level
		public function Level2() {
			super();
			
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		// This happens when screen is added to stage
		private function onAddedToStage(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			xMax = this.stage.stageWidth - 100;
			yMax = this.stage.stageHeight - 100;
			init();
		}
		
		// Init this screen!
		private function init() : void {
			drawScreen();	
			
			gameState = "player_enters";
			
			VARS.currProgress = -1;
			VARS.storyProgress = 0;
			
			stage.addEventListener(Event.ENTER_FRAME, gameLoop);
		}
		
		// Compose the graphical objects
		private function drawScreen() : void {
			bg = new IngameBackground(this, 2);
			player = new Sparrow(this);
			commander = new Bumblebee(this);
			chatter = commander;
			
			player.x = stage.stageWidth + player.width + 120;
			player.y = stage.stageHeight * 0.2;
			
			commander.x = 760;
			commander.y = stage.stageHeight * 0.6;
			
			textHandler.y = stage.stageHeight;
			
			// Add them all
			addChild(bg);
			addChild(player);
			addChild(commander);
			addChild(textHandler);
		}
		
		// Initiate a new conversation
		private function startConvo() : void {
			
			var text:Array;
			switch (VARS.storyProgress++) {
				case 0:
					text = global.Conversations.get("commander_intro");
					textHandler.textBlocks = text;
					textHandler.startText();
					this.addEventListener("conversationOver", next);
					break;
				case 1: 
					text = global.Conversations.get("commander_middle");
					textHandler.textBlocks = text;
					textHandler.startText();
					this.addEventListener("conversationOver", next);
					break;
				case 2:
					text = global.Conversations.get("commander_boss");
					textHandler.textBlocks = text;
					textHandler.startText();
					this.addEventListener("conversationOver", next);
					break;
				case 3:
					text = global.Conversations.get("commander_boss");
					textHandler.textBlocks = text;
					textHandler.startText();
					this.addEventListener("conversationOver", next);
					break;
				default:
					throw new Error("VARS.storyProgress = "+ VARS.storyProgress + " out of story range!");
			}
		}
		
		// This function is called when a conversation is over
		// to take the story forward
		override protected function storyTeller() : void {
			removeEventListener("conversationOver", next);
			Debug.INFO("storyTeller() - currProgress is: " + VARS.currProgress, this);
			
			switch (VARS.currProgress) {
				case 0:
					startConvo();
					gameState = "over";
					
					var hitCommander:Function;
					addEventListener("commanderHit", hitCommander = function(e:Event) : void {
						Debug.INFO("Spawn a new Drone!", this);
						removeEventListener("commanderHit", hitCommander);
						
						var en:Ship = new Drone(stageRef);
						en.x = commander.x - 20;
						en.y = -en.height + 10;
						
						ships.push(en);
						addChild(en);						
						(en as Drone).setDirection(false);
						
						var droneLoop:Function;
						
						addEventListener(Event.ENTER_FRAME, droneLoop = function(e:Event) : void {
							if ((en as Ship).boundingbox.intersects((commander as Ship).boundingbox)) {
								removeEventListener(Event.ENTER_FRAME, droneLoop);
								
								commander.takeDmg(1);
								commander.y += 20;
								(en as Drone).explode();
								
								var shieldHit:ShieldHit = new ShieldHit(commander);
								shieldHit.x += commander.direction * commander.boundingbox.width / 2;
								shieldHit.y -= commander.boundingbox.height / 2 + 10;
								
								shieldHit.scaleX = -commander.direction * ((commander.boundingbox.width + 20) / shieldHit.width);
								shieldHit.scaleY = (commander.boundingbox.height + 20) / shieldHit.height;
								
								commander.addChild(shieldHit);
								
								shakeScreen();
								
								Level.soundHandler = (new Assets.Level2Music).play();
							}
							
						});
					});
					break;
				case 1: 
					gameState = "commander_leaving";
					fireIterator = 0;
					commander.velX = 0;
					
					break;
					
				case 2: 
					currObjective = "killCount";
					
					addEventListener("objectiveComplete", function(e:Event) : void {
						removeEventListener("objectiveComplete", arguments.callee);
						next();
					});
					
					addEventListener("enemyDown", function(e:Event) : void {
						removeEventListener("enemyDown", arguments.callee);
						spawnTimer = new Timer(Math.round(Math.random() * 300) + 900);
						spawnTimer.addEventListener(TimerEvent.TIMER, onSpawnTimer);
						spawnTimer.start();

					});
					
					addEventListener("enemyDown", function(e:Event) : void {
						if (++killCount == targetCount)
							removeEventListener("enemyDown", arguments.callee);
					});
					
					comingEnemies = new Array("Drone", "Drone", "Drone", "Drone", "Drone", "Drone", "Drone");
					spawnEnemy("Drone");
					
					killCount = 0;
					targetCount = 8;
					
					gameState = "survival";
					break;
				
				case 3:
					commander.x = 760;
					commander.y = stage.stageHeight * 0.6;
					gameState = "commander_enters";
				break;
				
				case 4:
					gameState = "over";
					startConvo();
					break;
				
				case 5: 
					gameState = "commander_leaving";
					commander.velX = 0;
					break;
				case 6: 
					currObjective = "killCount";
					
					addEventListener("objectiveComplete", function(e:Event) : void {
						removeEventListener("objectiveComplete", arguments.callee);
						next();
					});
					
					this.addEventListener("enemyDown", function(e:Event) : void {
						trace("I am called!");
						if (++killCount == targetCount) {
							removeEventListener("enemyDown", arguments.callee);
						}
						Debug.INFO(killCount + "/" + targetCount + " enemies defeated.", this);
					});
					
					comingEnemies = new Array("Phaser", "Phaser");
					spawnEnemy("Phaser");
					
					killCount = 0;
					targetCount = 3;
					
					ships.push(player);
					gameState = "play";
					break;
				case 7: 
					gameState = "over";
					startConvo();
					break;
				case 8: 
					break;
				default:
					throw new Error("VARS.currProgress = "+ VARS.currProgress + " is out of story range!");
			}
		}
		
		private function gameLoop(e:Event) : void {
			switch (_gameState) {
				case "idle":
					break;
				case "player_enters":
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
						//player.exhaustArt.rotation = starling.utils.deg2rad(2 * -player.velX);
					}
					else {
						player.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(player.velX) / player.velX));
						//player.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(player.velX) / player.velX));
					}
				}
				else {
					gameState = "commander_enters";
				}
					break;
				case "commander_enters":
					var allInPlace:Boolean = true;
					addChild(commander);
					
					if (commander.x > stage.stageWidth - 200) {
						allInPlace = false;
						commander.velX -= commander.speed;
						
						if(Math.abs(commander.velX) > commander.maxVel/3) commander.velX = (Math.abs(commander.velX) / commander.velX) * commander.maxVel/3;
						
						commander.velX *= global.VARS.airRes;
						commander.x += commander.velX * 2;	
					}
					
					if (Math.round(player.y) > stage.stageHeight * 0.2 || Math.round(player.x) < stage.stageWidth - player.width) {
						allInPlace = false;
						
						if (Math.round(player.x) < stage.stageWidth - player.width) {
							
							player.velX += player.speed;
							
							if(Math.abs(player.velX) > player.maxVel/3) 
								player.velX = (Math.abs(player.velX) / player.velX) * player.maxVel/3;	// |velX| / velX -> 1 or -1
							
							player.velX *= global.VARS.airRes;
							player.x += player.velX;
							
						}
						if (Math.round(player.y) > stage.stageHeight * 0.2) {
							player.velY -= player.speed;
							
							if(Math.abs(player.velY) > player.maxVel/3)
								player.velY = (Math.abs(player.velY) / player.velY) * player.maxVel/3; 	// |velY| / velY -> 1 or -1
							
							player.velY *= global.VARS.airRes;
							player.y += player.velY;
						}
						
						if (!player.rotatable) break;
						
						if(player.velX < 4) {
							player.rotation = starling.utils.deg2rad(2 * player.velX);
							//player.exhaustArt.rotation = starling.utils.deg2rad(2 * -player.velX);
						}
						else {
							player.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(player.velX) / player.velX));
							//player.exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(player.velX) / player.velX));
						}
					}
					
					if (allInPlace) {
						next();
					}
					
					break;
				case "over":
					break;
				
				case "commander_leaving": 
					commander.velX -= commander.speed * 0.3;
					commander.x += commander.velX;	
					
					if (++fireIterator % 10 == 0  && fireIterator % 30 != 0) {
						commander.fire();
					}
					
					if (commander.x < -commander.width) {
						fireIterator = 0;
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
							(player as Sparrow).exhaustArt.rotation = starling.utils.deg2rad(2 * -player.velX);
						}
						else {
							player.rotation = starling.utils.deg2rad(2 * 4 * (Math.abs(player.velX) / player.velX));
							(player as Sparrow).exhaustArt.rotation = starling.utils.deg2rad(2 * 4 * -(Math.abs(player.velX) / player.velX));
						}
					}
					
					(player as Sparrow).exhaustArt.scaleX = -(player.velX / player.maxVel) + 1;
					
					// Handle weaponry
					if(keyHandler.fire1) player.primary();
					if(keyHandler.fire2) player.secondary();
					
					checkBullets();
					
					break;
					
					break;
				
				case "survival": 
					
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
					
					(player as Sparrow).exhaustArt.scaleX = -(player.velX / player.maxVel) + 1;
					
					// Handle weaponry
					if(keyHandler.fire1) player.primary();
					if(keyHandler.fire2) player.secondary();
					
					checkShipCollisions();
					
					break;
				
				default: 
					throw new Error("Unknown gameState! gameState = '"+_gameState+"'");
			}
		}
		
		private function onSpawnTimer(e:TimerEvent) : void {
			spawnTimer.removeEventListener(TimerEvent.TIMER, onSpawnTimer);
			spawnTimer.stop(); 
			
			if (comingEnemies.length != 0) {
				spawnEnemy(comingEnemies.splice(0, 1));
				
				addEventListener("enemyDown", function(e:Event) : void {
					removeEventListener("enemyDown", arguments.callee);
					spawnTimer = new Timer(Math.round(Math.random() * 500) + 1500);
					spawnTimer.addEventListener(TimerEvent.TIMER, onSpawnTimer);
					spawnTimer.start();
				});
			}
		}
		
		// Spawn enemy of type 'type'
		private function spawnEnemy(type:String) : void {
			var en:Ship;
			
			switch(type) {
				case "Phaser": 
					en = new Phaser(this, player);
					en.x = -en.width;
					en.y = Math.random()* (stage.stageHeight - 100) + 50;
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
				case "Drone":
					var upper:Boolean = (Math.round(Math.random()) == 1);//(player.y < stage.stageHeight / 2);
					
					en = new Drone(this);
					en.x = player.x;
					en.y = upper ? (stage.stageHeight + en.height / 2) : -en.height + 10 ;
					ships.push(en);
					addChild(en);
					(en as Drone).setDirection(upper);
					break;
				default: 
					throw new Error("spawnEnemy() received unknown type request!");
			}
		}
		
		// See if objective is fulfilled
		private function checkObjective() : Boolean {
			switch (currObjective) {
				case "killCount":
					if (killCount == targetCount) {
						return true;
					}
					break;
				case "survivalMode":
					if (killCount++ == targetCount) {
						return true;
					}
					break;
				case "ua":
					return false;
				default:
					throw new Error("Unknown objective type: '" + currObjective + "'");
			}
			
			return false;
		}
		
		// Function called when player dies
		private function gameOver() : void {
			
		}
		
		// Shake screen. Explosion? Earth quake? One does not know
		public function shakeScreen() : void {
			Debug.INFO("Shaking screen!", this);
			addEventListener(Event.ENTER_FRAME, shakeLoop);
		}
		
		// Handle the shaking. Will it end? (yes, after 1.5 seconds)
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
		
		// Let's the game loop know where in the story we are.
		private function set gameState(state:String) : void {
			_gameState = state;
			Debug.INFO("gameState is now: " + state, this);
		}
		
		// Check for collisions!
		private function checkShipCollisions() : void { 
			for (var i:uint = 0; i < ships.length; ++i) {
				if (ships[i] == player) 
					continue;
				
				if ((ships[i] as Ship).boundingbox.intersects(player.boundingbox)) { 
					player.velY += (ships[i] as Drone).speed * 15; 
					player.takeDmg(30);
					(ships[i] as Drone).explode();
					
					var shieldHit:ShieldHit = new ShieldHit(player);
					shieldHit.x += player.direction * player.boundingbox.width / 2;
					shieldHit.y -= player.boundingbox.height / 2 + 10;
					
					shieldHit.scaleX = -player.direction * ((player.boundingbox.width + 20) / shieldHit.width);
					shieldHit.scaleY = (player.boundingbox.height + 20) / shieldHit.height;
					
					player.addChild(shieldHit);
				}
			}
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
						
						// This returns true if current ship dies from the hit
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
								}
								else {
									
								}
							}
							
							(bullets[i] as Laser).destroy();
							// if the ship is destroyed, don't show shieldHit.
							break;
						}
						
						if (isPlayer && (bullets[i] as Laser).bigBlast)
							shakeScreen();
						
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