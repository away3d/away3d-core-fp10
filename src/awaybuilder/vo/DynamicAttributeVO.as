package awaybuilder.vo
{
	import awaybuilder.interfaces.IValueObject;
	
	
	
	public class DynamicAttributeVO implements IValueObject
	{
		public static const DELIMITER_KEY_VALUE : String = ":" ;
		public static const DELIMITER_PROPERTY : String = "," ;
		public static const DELIMITER_VALUE_TYPE : String = "?" ;
		public static const INIT_TYPE_BOOLEAN : String = "b" ;
		public static const INIT_TYPE_INT : String = "i" ;
		public static const INIT_TYPE_NUMBER : String = "n" ;
		public static const INIT_TYPE_STRING : String = "s" ;
		public static const INIT_TYPE_UINT : String = "u" ;
		
		public var key : String ;
		public var value : String ;
		
		
		
		public function DynamicAttributeVO ( )
		{
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function convertToInitObject ( ) : Object
		{
			var init : Object = new Object ( ) ;
			var properties : Array ;
			
			if ( this.value.indexOf ( DELIMITER_PROPERTY ) == -1 )
			{
				properties = [ this.value ] ;
			}
			else
			{
				properties = this.value.split ( DELIMITER_PROPERTY ) ;
			}
			
			for each ( var property : String in properties )
			{
				var propertyPair : Array = property.split ( DELIMITER_KEY_VALUE ) ;
				var key : String = propertyPair[ 0 ] ;
				var valuePair : Array = ( propertyPair[ 1 ] as String ).split ( DELIMITER_VALUE_TYPE ) ;
				var value : String = valuePair[ 0 ] ;
				var valueType : String = valuePair[ 1 ] ;
				
				switch ( valueType )
				{
					case INIT_TYPE_BOOLEAN :
					{
						init[ key ] = Boolean ( value ) ;
						break ;
					}
					case INIT_TYPE_INT :
					{
						init[ key ] = int ( value ) ;
						break ;
					}
					case INIT_TYPE_NUMBER :
					{
						init[ key ] = Number ( value ) ;
						break ;
					}
					case INIT_TYPE_STRING :
					{
						init[ key ] = value ;
						break ;
					}
					case INIT_TYPE_UINT :
					{
						init[ key ] = uint ( value ) ;
						break ;
					}
				}
			}
			
			return init ;
		}
	}
}