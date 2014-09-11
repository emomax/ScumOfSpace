package
{
	import flash.display.Sprite;
	import starling.core.Starling;
	import screens.InGame;
	
	[SWF(framerate="60", width="700", height="550", backgroundColor="0x000000")]
	public class ScumOfSpace extends Sprite
	{
		private var starling:Starling;
		
		public function ScumOfSpace()
		{
			starling = new Starling(screens.InGame, stage);
			trace("Hello, world!");
			starling.start();
		}
	}
}