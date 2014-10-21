package screens {
	import flash.geom.Point;
	
	import controllers.KeyboardHandler;
	
	import debugger.Debug;
	
	import global.VARS;
	
	import objects.Bumblebee;
	import objects.Drone;
	import objects.IngameBackground;
	import objects.Phaser;
	import objects.Ship;
	import objects.Sparrow;
	import objects.Target;
	
	import starling.display.Image;
	import starling.events.Event;
	
	import utils.TextGenerator;

	public class Level3 extends Level {
		
		// Objects to be handled 
		private var player:Ship;
		private var commander:Bumblebee;
		private var GO:Image;
		private var bg:IngameBackground;
		
		// Objective parameters
		private var currObjective:String = "";
		private var targetCount:uint;
		private var killCount:uint;
		private var comingEnemies:Array = new Array();
		private var comingPositions:Array = new Array();
		private var iterator:int = 0;
		private var nextSpawnFrame:Array = new Array();
		
		// Text box and handling
		private var textHandler:TextGenerator = new TextGenerator(this);
		
		// Key handling
		private var keyHandler:controllers.KeyboardHandler = new KeyboardHandler(this);

		// Dimensions of screen
		private var xMax:int;
		private var yMax:int;

		
		// Constructor for second level
		public function Level3() {
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
		
		private function gameLoop(e:Event) : void {
			switch (_gameState) {
				case "idle":
					break;
				case "player_enters":
					break;
				default:
					throw new Error("Unknown gameState: '" + _gameState + "'");
			}
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
				default:
					throw new Error("Unknown storyProgress: '" + VARS.storyProgress + "'");
			}
		}
		
		// This function is called when a conversation is over
		// to take the story forward
		override protected function storyTeller() : void {
			removeEventListener("conversationOver", next);
			Debug.INFO("storyTeller() - currProgress is: " + VARS.currProgress, this);
			
			switch (VARS.currProgress) {
				case 0:
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
					
					// 3 first
					comingPositions.push(new Point(stage.stageWidth / 2 + 260, -84.75 / 2 + 10));
					comingPositions.push(new Point(stage.stageWidth / 2 + 130, -84.75 / 2 + 10));
					comingPositions.push(new Point(stage.stageWidth / 2, -84.75 / 2 + 10));
					comingPositions.push(new Point(stage.stageWidth / 2 - 130, -84.75 / 2 + 10));
					
					// time
					nextSpawnFrame.push(60);
					nextSpawnFrame.push(80);
					nextSpawnFrame.push(100);
					nextSpawnFrame.push(120);
					
					// 3 second
					comingPositions.push(new Point(stage.stageWidth / 2 - 260, stage.stageHeight + 84.75 / 2));
					comingPositions.push(new Point(stage.stageWidth / 2 - 130, stage.stageHeight + 84.75 / 2));
					comingPositions.push(new Point(stage.stageWidth / 2, stage.stageHeight + 84.75 / 2));
					comingPositions.push(new Point(stage.stageWidth / 2 + 130, stage.stageHeight + 84.75 / 2));
					
					// time
					nextSpawnFrame.push(230);
					nextSpawnFrame.push(250);
					nextSpawnFrame.push(260);
					nextSpawnFrame.push(280);
					
					// 3 third
					comingPositions.push(new Point(stage.stageWidth / 2 + 260, -84.75 / 2 + 10));
					comingPositions.push(new Point(stage.stageWidth / 2 + 130, -84.75 / 2 + 10));
					comingPositions.push(new Point(stage.stageWidth / 2, -84.75 / 2 + 10));
					comingPositions.push(new Point(stage.stageWidth / 2 - 260, -84.75 / 2 + 10));
					
					// time
					nextSpawnFrame.push(390);
					nextSpawnFrame.push(410);
					nextSpawnFrame.push(430);
					nextSpawnFrame.push(450);
					
					// 3 forth
					comingPositions.push(new Point(stage.stageWidth / 2 - 260, stage.stageHeight + 84.75 / 2));
					comingPositions.push(new Point(stage.stageWidth / 2 - 130, stage.stageHeight + 84.75 / 2));
					comingPositions.push(new Point(stage.stageWidth / 2 + 260, stage.stageHeight + 84.75 / 2));
					comingPositions.push(new Point(stage.stageWidth / 2, stage.stageHeight + 84.75 / 2));
					
					// time
					nextSpawnFrame.push(560);
					nextSpawnFrame.push(580);
					nextSpawnFrame.push(600);
					nextSpawnFrame.push(620);
					
					comingEnemies = new Array(
						"Phaser", 	   "Phaser",      "Phaser", 	 "Phaser",
						"Drone_fixed", "Drone_fixed", "Drone_fixed", "Drone_fixed", 
						"Drone_fixed", "Drone_fixed", "Drone_fixed", "Drone_fixed",
						"Drone_fixed", "Drone_fixed", "Drone_fixed", "Drone_fixed",
						"Drone_fixed", "Drone_fixed", "Drone_fixed", "Drone_fixed");
					
					spawnEnemy("Phaser");
					
					iterator = 0;
					killCount = 0;
					targetCount = 21;
					
					gameState = "play_survival";
					break;
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
				
				case "Drone_fixed":
					en = new Drone(this);
					var pos:Point = new Point(); 
					pos.x = (comingPositions[0] as Point).x;
					pos.y = (comingPositions[0] as Point).y;
					comingPositions.splice(0, 1);
					Debug.INFO( "comingPos = ( " + pos.x + ", " + pos.y + ")", this);
					en.x = pos.x;
					en.y = pos.y;
					ships.push(en);
					addChild(en);
					(en as Drone).setDirection(pos.y > stage.stageHeight / 2);
					break;
				default: 
					throw new Error("spawnEnemy() received unknown type request: '" + type + "'");
			}
		}
	}
}