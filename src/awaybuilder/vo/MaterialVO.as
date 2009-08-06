package awaybuilder.vo
{
	import awaybuilder.interfaces.IValueObject;
	
	
	
	public class MaterialVO implements IValueObject
	{
		public var id : String ;
		public var name : String ;
		public var properties : Array = [ ] ;
	}
}