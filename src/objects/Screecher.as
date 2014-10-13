package objects
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import debugger.Debug;
	
	import objects.ENEMY;
	import objects.Laser;
	import objects.MuzzleFlash;
	import objects.PrimaryWeapon;
	import objects.Ship;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	public class Screecher extends Ship implements ENEMY, PrimaryWeapon
	{
		public var _playerRef:Ship;
		private var startY:Number;
		private var iterator:Number;
		private var hoverIterator:int = 0;
		
		private var homingBeamTop:Image = new Image(Assets.getAtlas().getTexture("homingLaser"));
		private var homingBeamBot:Image = new Image(Assets.getAtlas().getTexture("homingLaser"));
		
		private var offsetInRadians:Number = 0;
		
		private var box5:MovieClip;
		
		private var _bossState:String = "";
		private var canDoAction:Boolean = false;
		private var moves:Array = new Array();
		
		private var actionTimer:Timer;
		
		private var _fireSpeed:Number;
		private var _fireTimer:Timer;
		private var _firePower:int
		private var _canFire:Boolean;
		
		public function Screecher(s:Sprite)
		{
			Debug.INFO("I AM ALIVE!", this);
			super(s);
			this._HP = 2000;
			this.moves.push("homeAndKill");
			this.moves.push("tripleBurst");
			
			bossState = "idle";
			
			firePowerPrimary = 20;
			
			actionTimer = new Timer(3000, 1);
			actionTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent) : void {
				canDoAction = true;
				actionTimer.stop();
			});
		}
		
		override protected function onAddedToStage(e:Event) : void {
			// Middle
			this.createExhaustArt(new Point(-70, -15), -1);
			this.createExhaustArt(new Point(-71, -10), -1);
			this.createExhaustArt(new Point(-71, -5), -1);
			
			this.createExhaustArt(new Point(-72, 0), -1);
			this.createExhaustArt(new Point(-70, 5), -1);
			this.createExhaustArt(new Point(-72, 10), -1);
			
			// Upper
			this.createExhaustArt(new Point(-71, -45), -1);
			this.createExhaustArt(new Point(-72, -40), -1);
			this.createExhaustArt(new Point(-70, -35), -1);

			this.createExhaustArt(new Point(-69, -20), -1);
			this.createExhaustArt(new Point(-70, -25), -1);
			this.createExhaustArt(new Point(-71, -30), -1);
			
			// Bottom
			this.createExhaustArt(new Point(-70, 15), -1);
			this.createExhaustArt(new Point(-72, 20), -1);
			this.createExhaustArt(new Point(-69, 25), -1);

			this.createShipArt("screecher");
			
			this.setWidth(this.shipArt.width);
			Debug.INFO("getWidth() returns: " + this.getWidth(), this);
			Debug.INFO("this.width returns: " + this.width, this);
			
			this.boundingbox = this.bounds;
			
			this.addChild(homingBeamTop);
			homingBeamTop.y = -122;
			homingBeamTop.x = 66;
			homingBeamTop.pivotY = homingBeamTop.height / 2;
			
			this.addChild(homingBeamBot);
			homingBeamBot.y = 83;
			homingBeamBot.x = 70;
			homingBeamBot.pivotY = homingBeamTop.height / 2;
			
			homingBeamBot.visible = false;
			homingBeamTop.visible = false;
			
			addChild(box5);
			
			this.showBoundingBox();
			direction = 1;
		}
		
		public function fixatePosition() : void {
			this.startY = this.y;
		}
		
		public function getBeams(theta1:Number, theta2:Number) : Array {
			
			var a:Array = new Array();
			var a1:Array = new Array();
			var a2:Array = new Array();
			
			a1.push(new Point(homingBeamTop.x, homingBeamTop.y));
			a1.push(new Point(homingBeamTop.x + homingBeamTop.width, homingBeamTop.y + homingBeamTop.height * ((Math.sin(theta1) <= 0) ? -1 : 1)));
				
			a2.push(new Point(homingBeamBot.x, homingBeamBot.y));
			a2.push(new Point(homingBeamBot.x + homingBeamBot.width, homingBeamBot.y + homingBeamBot.height * ((Math.sin(theta2) <= 0) ? 1 : -1)));
			
			a.push(a1);
			a.push(a2);
			
			return a;
		}
		
		override public function init() : void {
			// Init the Phaser!
			Debug.INFO("I am initiated!", this);
			addEventListener(Event.ENTER_FRAME, behaviourLoop);
			
			//box5 = new DrawRect(new Rectangle(0, 0, 10, 10));
			box5 = new MovieClip(Assets.getAtlas().getTextures("spark_"), 15);
			box5.alignPivot();
			box5.scaleX = 0.6;
			box5.scaleY = 0.76;
			box5.visible = false;
			starling.core.Starling.juggler.add(box5);
		}
		
		public function homeAndKill(t:Ship) : void {
			Debug.INFO("homeAndKill()", this);
			iterator = 0;
			
			homingBeamTop.visible = true;
			homingBeamBot.visible = true;
			
			this._playerRef = t;
			
			box5.x = t.x - this.x;
			box5.y = t.y - this.y;
			
			iterator = 0;
			
			var u:Point = new Point (-this.x - homingBeamTop.x + _playerRef.x, -this.y - homingBeamTop.y + _playerRef.y);
			var v:Point = new Point (-this.x - homingBeamBot.x + _playerRef.x, -this.y - homingBeamBot.y + _playerRef.y);
			
			var theta1:Number = Math.atan(u.y / u.x);
			var theta2:Number = Math.atan(v.y / v.x);
			
			homingBeamTop.rotation = theta1;
			homingBeamBot.rotation = theta2;
			
			bossState = "homing";
		}
		
		public function behaviourLoop(e:Event) : void {
			// Do stuff;
			
			switch (bossState) {
				case "homing":					
					iterator++;
					
					if (iterator == 1) {
						box5.visible = true;
						
						homingBeamTop.visible = true;
						homingBeamBot.visible = true;
					} else if (iterator == 20){
						homingBeamTop.visible = false;
						homingBeamBot.visible = false;
						box5.visible = false;
					} else if (iterator == 40) {
						
						box5.visible = true;
						homingBeamTop.visible = true;
						homingBeamBot.visible = true;
					} else if (iterator == 60) { 
						homingBeamTop.visible = false;
						homingBeamBot.visible = false;
						box5.visible = false;
					} else if (iterator == 90) {
						fire();
						bossState = "idle";
						stageRef.dispatchEvent(new Event("megaBlast"));
						actionTimer.start();
						Debug.INFO("FIRE", this);
					}
					
					break;
				
				case "engagedInCombat": 
					if (canDoAction) {
						switch (this.moves[0]) {
							case "homeAndKill":
								stageRef.addEventListener("megaBlast", engage);
								homeAndKill(target);
								canDoAction = false;
								
								break;
							default: 
								break;
						}
					}
					
				
				case "idle":
					var hoverRadians:Number = deg2rad(hoverIterator++);
					this.y = startY + 30 * Math.sin(hoverRadians);	
					break;
								
				default:
					// fall through loop
					break;
			}
		}
		
		public function engage(e:Event = null) : void {
			if (e != null ) stageRef.removeEventListener("megaBlast", arguments.callee);
			bossState = "engagedInCombat";
			//canDoAction = true;
		}
		
		private function calcIntersection(theta1:Number, theta2:Number) : Point {
			var beams:Array = getBeams(theta1, theta2);
			return lineIntersectLine(beams[0][0], beams[0][1], beams[1][0], beams[1][1], true);
		}
		
		private function lineIntersectLine(A:Point,B:Point,E:Point,F:Point,as_seg:Boolean=true):Point {
			var ip:Point;
			var a1:Number;
			var a2:Number;
			var b1:Number;
			var b2:Number;
			var c1:Number;
			var c2:Number;
			
			a1= B.y-A.y;
			b1= A.x-B.x;
			c1= B.x*A.y - A.x*B.y;
			a2= F.y-E.y;
			b2= E.x-F.x;
			c2= F.x*E.y - E.x*F.y;
			
			var denom:Number=a1*b2 - a2*b1;
			if (denom == 0) {
				return null;
			}
			ip=new Point();
			ip.x=(b1*c2 - b2*c1)/denom;
			ip.y=(a2*c1 - a1*c2)/denom;
			
			//---------------------------------------------------
			//Do checks to see if intersection to endpoints
			//distance is longer than actual Segments.
			//Return null if it is with any.
			//---------------------------------------------------
			if(as_seg){
				if(Math.pow(ip.x - B.x, 2) + Math.pow(ip.y - B.y, 2) > Math.pow(A.x - B.x, 2) + Math.pow(A.y - B.y, 2))
				{
					return null;
				}
				if(Math.pow(ip.x - A.x, 2) + Math.pow(ip.y - A.y, 2) > Math.pow(A.x - B.x, 2) + Math.pow(A.y - B.y, 2))
				{
					return null;
				}
				
				if(Math.pow(ip.x - F.x, 2) + Math.pow(ip.y - F.y, 2) > Math.pow(E.x - F.x, 2) + Math.pow(E.y - F.y, 2))
				{
					return null;
				}
				if(Math.pow(ip.x - E.x, 2) + Math.pow(ip.y - E.y, 2) > Math.pow(E.x - F.x, 2) + Math.pow(E.y - F.y, 2))
				{
					return null;
				}
			}
			return ip;
		}
		
		private function set bossState(state:String) : void {
			_bossState = state;
			Debug.INFO("bossState is now: " + state, this);
		}
		
		public function clean() : void {}
		
		
		private function get bossState() : String {return _bossState;}
		public function get target() : Ship {return _playerRef;}
		public function set target(s:Ship) : void { _playerRef = s;}
		
		override public function primary() : void {
			if (canFirePrimary) {
				// Weapon can fire! Let's do it. FIRE() !!
				fireTimerPrimary.start();
				canFirePrimary = false;
				fire();
			}
			else {
				// Weapon on cooldown. No firing allowed.
			}
		}
		
		public function fire() : void {
			var dir1:Point = new Point();
			var dir2:Point = new Point();
			
			dir1.x = Math.cos(homingBeamTop.rotation);
			dir1.y = Math.sin(homingBeamTop.rotation);
			
			dir2.x = Math.cos(homingBeamBot.rotation);
			dir2.y = Math.sin(homingBeamBot.rotation);
			
			var m:MuzzleFlash = new MuzzleFlash(stageRef);
			var l:Laser = new Laser(stageRef, this, 1, firePowerPrimary, dir1);
			var m2:MuzzleFlash = new MuzzleFlash(stageRef);
			var l2:Laser = new Laser(stageRef, this, 1, firePowerPrimary, dir2);
			
			l.scaleX = 2;
			l.scaleY = 2;
			l2.scaleX = 2;
			l2.scaleY = 2;
			
			m.scaleX = 3;
			m.scaleY = 3;
			m2.scaleX = 3;
			m2.scaleY = 3;
			
			l.alignPivot("left","center");
			m.alignPivot("left", "center");
			l2.alignPivot("left", "center");
			m2.alignPivot("left", "center");
			
			l.rotation = homingBeamTop.rotation;
			l2.rotation = homingBeamBot.rotation;
			
			l.x = this.x + homingBeamTop.x;
			l.y = this.y + homingBeamTop.y;
			
			m.x = this.x + homingBeamTop.x;
			m.y = this.y + homingBeamTop.y;
			
			l2.x = this.x + homingBeamBot.x;
			l2.y = this.y + homingBeamBot.y;
			
			m2.x = this.x + homingBeamBot.x;
			m2.y = this.y + homingBeamBot.y;
			
			stageRef.addChild(m);
			stageRef.addChild(l);
			stageRef.addChild(m2);
			stageRef.addChild(l2);
		}
		
		// Interface PrimaryWeapon GETTERS
		
		public function get fireSpeedPrimary():Number { return _fireSpeed; }
		public function get fireTimerPrimary():Timer { return _fireTimer; }
		public function get canFirePrimary():Boolean { return _canFire; }
		public function get firePowerPrimary():int { return _firePower; }
		
		// Interface PrimaryWeapon SETTERS
		public function set fireSpeedPrimary(n:Number):void { _fireSpeed = n; }
		public function set fireTimerPrimary(t:Timer):void { _fireTimer = t; }
		public function set canFirePrimary(b:Boolean):void { _canFire = b; }
		public function set firePowerPrimary(i:int):void { _firePower = i; }
	}
}