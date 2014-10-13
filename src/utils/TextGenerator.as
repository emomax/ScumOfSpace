package utils {
	
	import flash.media.Sound;
	import flash.text.Font;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import Assets;
	
	import debugger.Debug;
	
	import global.VARS;
	
	import objects.Portrait;
	
	import screens.InGame;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import starling.utils.deg2rad;
	
	public class TextGenerator extends Sprite{
		
		private const TEXT:int = 1;
		
		private var _currentTextBlockIndex:int=0;
		private var _currentTextBlock:String;
		private var _textBlocks:Array;
		private var _typingSound:Sound = new Assets.TypingSound();
		private var stageRef:Sprite;
		private var art:Image;
		private var convoBubble:Image;
		private var charIcon:Portrait;
		private var txt:TextField;
		
		private var canPress:Boolean = true;
		
		private var bodyFont:Font = new Assets.Eras;
		
		public function TextGenerator(_stageRef:Sprite = null) : void 
		{
			this.stageRef = _stageRef;
			if (stageRef == null) 
				throw new Error("Couldn't reference stage from class TextGenerator: stageRef is null.");

			art = new Image(Assets.getAtlas().getTexture("textbox"));
			this.addChild(art);
			
			
			charIcon = new Portrait();
			
			//Debug.INFO("Trying to use font named: '" + bodyFont.fontName + "'. ", this);
			txt = new TextField(550, 60, "", bodyFont.fontName, 15, 0x000000);
			
			txt.hAlign = "left";
			txt.vAlign = "top";
			txt.x = 114;
			txt.y = 47;
			
			// Add portrait of speaker
			this.addChild(charIcon);
			charIcon.x = 21;
			charIcon.y = 40;
			showIcon("UA");
			
			//put conversation bubble on top
			convoBubble = new Image(Assets.getAtlas().getTexture("convoBubble"));
			this.addChild(convoBubble);
			convoBubble.x = 90;
			convoBubble.y = 43;
			
			// Add text ontop of it all;
			addChild(txt);
		}
		
		private function keyUp(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.SPACE) {
				canPress = true;
			}
		}
		
		public function showIcon(s:String) : void {
			Debug.INFO(s + " should be speaking!", this);
			switch (s) {
				case "UA":
					charIcon.face = "ua";
					break;
				case "Mike":
					charIcon.face = "mike";
					break;
				default: 
					throw new Error("Couldn't process string '" + s + "'. No matching icon.");
			}
		}
		
		public function set textBlocks(txt:Array):void {
			_textBlocks = txt;
		}
		
		public function startText():void {
			var tween:Tween = new Tween(this, 1.0, Transitions.EASE_IN_OUT);
			tween.animate("y", stageRef.stage.stageHeight - this.height);
			tween.fadeTo(1);    // equivalent to 'animate("alpha", 0)'
			starling.core.Starling.juggler.add(tween);
			
			tween.onComplete = startConversation;
		}
		
		private function startConversation() : void {
			
			_currentTextBlock = _textBlocks[_currentTextBlockIndex][TEXT];
			showIcon(_textBlocks[_currentTextBlockIndex][0]);
			Debug.INFO(_textBlocks[_currentTextBlockIndex][0] + " should speak!", this);
			addEventListener(Event.ENTER_FRAME, updateText);
			addEventListener(KeyboardEvent.KEY_DOWN, fillText);
			
			addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		private function updateText(e:Event):void {
			if(txt.text.length < _currentTextBlock.length){
				txt.text = _currentTextBlock.substr(0, txt.text.length+1);
				_typingSound.play(0, 0, global.VARS.soundVolume);
			} else {
				fillText(null, false);
			}
		}
		
		private function fillText(e:KeyboardEvent = null, forcing:Boolean = true) : void {
			
			if (e != null) {
				if (!canPress) {
					return;
				}
				
				if (e.keyCode != Keyboard.SPACE) {
					return;
				} else {
					canPress = false;
				}
			}
			
			Debug.INFO("fillText()", this);
			removeEventListener(Event.ENTER_FRAME, updateText);
			removeEventListener(KeyboardEvent.KEY_DOWN, fillText);
			
			txt.text = _currentTextBlock;
			
			if(_currentTextBlockIndex < _textBlocks.length-1) {
				Debug.INFO("Next textblock!", this);
				addEventListener(KeyboardEvent.KEY_DOWN, touched);
			} else {
				Debug.INFO("End dialogue!", this);
				addEventListener(KeyboardEvent.KEY_DOWN, endDialogue);
			}
		}
		
		private function touched(e:KeyboardEvent) : void {
			if (!canPress) return;
			if (e.keyCode != Keyboard.SPACE) 
				return;
			
			removeEventListener(KeyboardEvent.KEY_DOWN, touched);
			nextTextBlock();
		}
		
		private function nextTextBlock(_canPress:Boolean = false) : void {	
			Debug.INFO("Next textblock()", this);
			
			txt.text = ""; // clear the text
			
			_currentTextBlockIndex++;	
				
			switch(_textBlocks[_currentTextBlockIndex][0]) {
				case "shake":
					showIcon("UA");
					stageRef.addEventListener("shakeDone", effectDone);
					(stageRef as InGame).shakeScreen();
					return;
				case "mike_shake":
					showIcon("UA");
					stageRef.dispatchEvent(new Event("mikeDamage"));
					stageRef.addEventListener("shakeDone", effectDone);
					return;
				case "mike_explode":
					showIcon("UA");
					stageRef.dispatchEvent(new Event("mikeExplodes"));
					stageRef.addEventListener("shakeDone", effectDone);
				case "show_screecher":
					showIcon("UA");
					stageRef.dispatchEvent(new Event("screecherEnters"));
					stageRef.addEventListener("screecherEntered", effectDone);
					return;
				case "misc":
					showIcon("UA");
					break;
				default:
					Debug.INFO("The speaker exists", this);
			}
			_currentTextBlock = _textBlocks[_currentTextBlockIndex][TEXT]; // set the text
			showIcon(_textBlocks[_currentTextBlockIndex][0]); // set the character icon
			addEventListener(Event.ENTER_FRAME, updateText); // start updating the text
			addEventListener(KeyboardEvent.KEY_DOWN, fillText);
			canPress = _canPress;
		}
		
		private function effectDone(e:Event) : void {
			Debug.INFO("Effect done!", this);
			stageRef.removeEventListener("shakeDone", arguments.callee);
			canPress = true;
			nextTextBlock(true);
		}
		
		private function endDialogue(e:KeyboardEvent) : void {
			Debug.INFO("End this");
			if (!canPress) 
				return;
			if (e.keyCode != Keyboard.SPACE) 
				return;
			
			var tween:Tween = new Tween(this, 2.0, Transitions.EASE_IN_OUT);
			tween.animate("y", stageRef.stage.stageHeight);
			tween.fadeTo(0);    // equivalent to 'animate("alpha", 0)'
			starling.core.Starling.juggler.add(tween);
			
			removeEventListener(KeyboardEvent.KEY_DOWN, endDialogue);
			removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			_currentTextBlockIndex = 0;
			txt.text = "";
			showIcon("UA");
			Debug.INFO("endDialogue now!", this);
			stageRef.dispatchEvent(new Event("conversationOver"));
		}
	}
}