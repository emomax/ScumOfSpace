package
{
	import flash.display.Sprite;
	
	import screens.InGame;
	
	import starling.core.Starling;
	
	[SWF(frameRate="60", width="700", height="550", backgroundColor="0x000000")]
	public class ScumOfSpace extends Sprite
	{
		private var starling:Starling;
		
		public function ScumOfSpace()
		{
			starling = new Starling(screens.InGame, stage);
			starling.core.Starling.current.showStats = true;
			starling.start();
		}
	}
}