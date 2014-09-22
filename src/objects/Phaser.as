package objects
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import global.VARS;
	
	import objects.AI;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Phaser extends Ship implements PrimaryWeapon, AI, STALKER, ENEMY
	{
		private var art:Image = new Image(Assets.getAtlas().getTexture("phaser"));
		
		public var playerRef:Blackbird;
		
		private var _fireSpeed:Number;
		private var _fireTimer:Timer;
		private var _firePower:int
		private var _canFire:Boolean;
		
		public function Phaser(s:Sprite, p:Blackbird) {
			super(s);
			this._HP = 100;
			speed = 0.4;
			
			playerRef = p;
			
			trace(p);
			
			// PHASER SPECIFIC ATTRIBUTES
			fireSpeedPrimary = 600;
			canFirePrimary = true;
			firePowerPrimary = 25;
			fireTimerPrimary = new Timer(fireSpeedPrimary, 1);
			
			fireTimerPrimary.addEventListener(TimerEvent.TIMER, function(e:TimerEvent) : void { fireTimerPrimary.stop(); canFirePrimary = true; });
		}
		
		override protected function onAddedToStage(e:Event) : void {
			this.createExhaustArt(new Point(-10, -15), -1);
			this.createExhaustArt(new Point(-10, -5), -1);
			this.createExhaustArt(new Point(-10, 5), -1);
			this.createShipArt("phaser");
			
			this.boundingbox = this.bounds;
			this.showBoundingBox();
			direction = 1;
		}
		
		public function init() : void {
			// Init the Phaser!
			addEventListener(Event.ENTER_FRAME, behaviourLoop);
		}
		
		public function behaviourLoop(e:Event) : void {
			// Do stuff;
			if (!playerRef) {
				this.removeEventListener(Event.ENTER_FRAME, behaviourLoop);
				return;
			}
			copyPlayerMoves();
			
			velY *= VARS.airRes; 
			
			
			if(Math.round(velY*5) == 0) velY = 0;
			
			this.y += velY;
		}
		
		public function copyPlayerMoves() : void
		{	
			if(Math.abs(playerRef.y + Math.round(playerRef.getWeaponDistance()) - this.y) > 5) {
				this.velY = (playerRef.y + Math.round(playerRef.getWeaponDistance()) < this.y) ? velY - speed : velY + speed;
			}
			else {
				primary();
			}
		}
		
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
			var m:MuzzleFlash = new MuzzleFlash(stageRef);
			var l:Laser = new Laser(stageRef, this, 1, firePowerPrimary);
			l.x = this.x - 30;
			l.y = this.y - 15;
			
			m.x = this.x + 21;
			m.y = this.y - 7;
			
			stageRef.addChild(m);
			stageRef.addChild(l);
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
		
		// Interface ENEMY
		public function get target() : Blackbird { return playerRef; }
		public function set target(s:Blackbird) : void { playerRef = s }
		
		public function clean() : void {
			removeEventListener(Event.ENTER_FRAME, behaviourLoop);
			playerRef = null;
		}
	}
}