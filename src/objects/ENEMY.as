package objects
{
	public interface ENEMY
	{
		function get target() : Blackbird;
		function set target(s:Blackbird) : void;
		
		function clean() : void;
	}
}