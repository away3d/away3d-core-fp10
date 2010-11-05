package away3d.events
{
	import away3d.containers.*;
	
	import flash.events.Event;
    
    /**
    * Passed as a parameter when a view3d event occurs
    */
    public class ViewEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a viewUpdated event object.
    	 */
    	public static const VIEW_UPDATED:String = "viewUpdated";
    	
    	/**
    	 * Defines the value of the type property of a renderComplete event object.
    	 */
    	public static const RENDER_COMPLETE:String = "renderComplete";
    	
    	/**
    	 * Defines the value of the type property of a renderBegin event object.
    	 */
    	public static const RENDER_BEGIN:String = "renderBegin";
    	
    	/**
    	 * Defines the value of the type property of a renderStart event object.
    	 */
    	public static const RENDER_START:String = "renderStart";
    	
    	/**
    	 * A reference to the view object that is relevant to the event.
    	 */
        public var view:View3D;
		
		/**
		 * Creates a new <code>ViewEvent</code> object.
		 * 
		 * @param	type	The type of the event. Possible values are: <code>ViewEvent.UPDATE_SCENE</code>, <code>ViewEvent.RENDER_COMPLETE</code> and <code>ViewEvent.RENDER_BEGIN</code>.
		 * @param	view	A reference to the view object that is relevant to the event.
		 */
        public function ViewEvent(type:String, view:View3D)
        {
            super(type);
            this.view = view;
        }
		
		/**
		 * Creates a copy of the ViewEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new ViewEvent(type, view);
        }
    }
}
