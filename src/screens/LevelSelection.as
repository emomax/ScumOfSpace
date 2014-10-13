package screens {
	
	import flash.text.Font;
	
	import events.NavigationEvent;
	
	import debugger.Debug;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class LevelSelection extends Sprite {
		private var level1:Button;
		private var level2:Button;
		private var level3:Button;
		
		private var label1:TextField;
		private var label2:TextField;
		private var label3:TextField;
		
		private var header:TextField;
		
		private var bodyFont:Font = new Assets.Eras;
		
		public function LevelSelection() : void {
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			createGraphics();
		}
		
		private function createGraphics() : void {
			// instantiate buttons
			level1 = new Button(Assets.getAtlas().getTexture("startGameBtn"));
			level2 = new Button(Assets.getAtlas().getTexture("startGameBtn"));
			level3 = new Button(Assets.getAtlas().getTexture("startGameBtn"));
			
			// Set level labels
			label1 = new TextField(150, 40, "", bodyFont.fontName, 20, 0xffffff);
			label1.text = "Level 1";
			label2 = new TextField(150, 40, "", bodyFont.fontName, 20, 0xffffff);
			label2.text = "Level 2";
			label3 = new TextField(150, 40, "", bodyFont.fontName, 20, 0xffffff);
			label3.text = "Level 3";
			
			level1.x = 50;
			level1.y = 50;
			label1.x = level1.x;
			label1.y = level1.y + level1.height;
			
			level2.x = 50;
			level2.y = 150;
			label2.x = level2.x;
			label2.y = level2.y + level2.height;
			
			level3.x = 50;
			level3.y = 250;
			label3.x = level3.x;
			label3.y = level3.y + level3.height;
			
			addChild(level1);
			addChild(label1);
			addChild(level2);
			addChild(label2);
			addChild(level3);
			addChild(label3);
			
			level1.addEventListener(Event.TRIGGERED, onClick);
			level2.addEventListener(Event.TRIGGERED, onClick);
			level3.addEventListener(Event.TRIGGERED, onClick);
		}
		
		private function onClick(e:Event) : void {
			switch (e.target) {
				case level1:
					this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "level_1"}, true));
					break;
				case level2:
					this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "level_2"}, true));
					break;
				case level3:
					this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "level_3"}, true));
					break;
			}
		}
	}
}