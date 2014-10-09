package utils
{
	import flash.utils.getQualifiedClassName;
	
	public class Formatting
	{
		public static function getName(o:Object) : String {
			return getQualifiedClassName(o).replace(/.+::/, ""); // returns the class of the caller in text.
		}
	}
}