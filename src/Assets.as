package
{
	import flash.display.Bitmap;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class Assets
	{
		private static var sTextures:Dictionary = new Dictionary();
		private static var sTextureAtlas:TextureAtlas;
		
		[Embed(source="../media/graphics/spaceBackground.png")]
		public static const Background:Class;
		
		[Embed(source="../media/graphics/spaceForeground.png")]
		public static const Foreground:Class;
		
		[Embed(source="../media/graphics/spaceForeground2.png")]
		public static const Foreground2:Class;
		
		[Embed(source="../media/graphics/atlas.png")]
		public static const AtlasTextureGame:Class;
		
		[Embed(source="../media/graphics/atlas.xml", mimeType="application/octet-stream")]
		public static const AtlasXmlGame:Class;
		
		[Embed(source="../fonts/Eras\ Demi\ ITC.ttf", embedAsCFF="false", mimeType = "application/x-font",fontFamily="Eras Sans", advancedAntiAliasing = "true", unicodeRange = "U+0020-U+007e")]
		public static const Eras:Class;
		
		// SOUNDS
		
		[Embed(source="../media/sounds/shieldGeneratorHit.mp3")] 
		public static const ShieldHitSound:Class; 
		
		[Embed(source="../media/sounds/basiclazer2.mp3")]
		public static const LaserSound:Class;
		
		[Embed(source="../media/sounds/explosion_1_2.mp3")]
		public static const ExplosionSound:Class;
		
		[Embed(source="../media/sounds/blipSound.mp3")]
		public static const TypingSound:Class;
		
		[Embed(source="../media/sounds/play.mp3")]
		public static const PlaySound:Class;
		
		public static function getAtlas():TextureAtlas {
			if (sTextureAtlas == null) {
				var texture:Texture = getTexture("AtlasTextureGame");
				var xml:XML = XML(new AtlasXmlGame());
				sTextureAtlas = new TextureAtlas(texture, xml); 
			}
			return sTextureAtlas;
		}
		
		public static function getTexture(name:String):Texture
		{
			if (sTextures[name] == undefined)
			{	
				var bitmap:Bitmap = new Assets[name]();
				sTextures[name] = Texture.fromBitmap(bitmap);
			}
			
			return sTextures[name];
		}
	}
}
