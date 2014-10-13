package screens 
{
	import starling.display.Sprite;
	import starling.events.Event;
	
	import events.NavigationEvent;
	
	import debugger.Debug;
	
	public class Game extends Sprite {
	
		private var inGame:Sprite = new InGame();
		private var menu:Sprite = new Menu();
		private var lvlSelection:Sprite = new LevelSelection();
		private var lvlCompleted:Sprite = new LevelComplete();
		
		public function Game () : void {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event) : void {
			this.addChild(inGame);
			inGame.visible = false;
			
			this.addChild(lvlSelection);
			lvlSelection.visible = false;

			this.addChild(menu);
			this.addEventListener(NavigationEvent.CHANGE_SCREEN, changeScreen);
		}
		
		private function changeScreen(e:NavigationEvent) : void {
			Debug.INFO("Change to screen: '" + e.target + "'", this);
			
			switch (e.params.id) {
				case "level_1":
					lvlSelection.visible = false;
					inGame.visible = true;
					break;
				case "lvlSelection":
					menu.visible = false;
					inGame.visible = false;
					lvlSelection.visible = true;
					break;
				case "level_completed":
					inGame.visible = false;
					lvlCompleted.visible = true;
					break;
			}
		}
	}
}