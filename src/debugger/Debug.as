package debugger
{
	
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.LocaleID;
	
	public class Debug
	{	
		private static function getNow() : String {
			var d:Date = new Date();
			var dtf:DateTimeFormatter = new DateTimeFormatter(LocaleID.DEFAULT);
			dtf.setDateTimePattern("yyyy-MM-dd hh:mm:ss");
			return dtf.format(d);
		}
		
		public static function INFO(s:String) : void {
			trace("[DEBUG.LOG]: "+ getNow() + ": " + s);
		}
		
		public static function WARNING(s:String) : void {
			trace("[DEBUG.WARNING]: "+ getNow() + ": " + s);
		}
	}
}