package away3d.events
{
	import away3d.sprites.*;
    
    import flash.events.Event;
    
    /**
    * Passed as a parameter when a segment event occurs
    */
    public class SpriteEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a materialChanged event object.
    	 */
    	public static const MATERIAL_CHANGED:String = "materialChanged";
    	
    	/**
    	 * A reference to the Billboard object that is relevant to the event.
    	 */
        public var sprite:Sprite3D;
		
		/**
		 * Creates a new <code>BillboardEvent</code> object.
		 * 
		 * @param	type		The type of the event. Possible values are: <code>BillboardEvent.MATERIAL_CHANGED</code>.
		 * @param	Billboard	A reference to the Billboard object that is relevant to the event.
		 */
        public function SpriteEvent(type:String, sprite:Sprite3D)
        {
            super(type);
            this.sprite = sprite;
        }
		
		/**
		 * Creates a copy of the BillboardEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new SpriteEvent(type, sprite);
        }
    }
}
