package awaybuilder.collada
{
	public class ColladaUtil
	{
		public function ColladaUtil ( )
		{
		}
		
		
		
		public static function removeNamespaces ( data : String ) : XML
		{
			var exp : RegExp = /xmlns=".*?" /g ;
			var result : String = data.replace ( exp , "" ) ;
			var xml : XML = new XML ( result ) ;
			
			return xml ;
		}
	}
}