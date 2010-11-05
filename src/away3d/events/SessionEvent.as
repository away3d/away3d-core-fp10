package away3d.events
{
	import away3d.core.session.AbstractSession;
	
	import flash.events.Event;
    
    /**
    * Passed as a parameter when a session event occurs
    */
    public class SessionEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a sessionUpdated event object.
    	 */
    	public static const SESSION_UPDATED:String = "sessionUpdated";
    	
    	/**
    	 * Defines the value of the type property of a drawComplete event object.
    	 */
    	public static const DRAW_COMPLETE:String = "drawComplete";
    	
    	/**
    	 * A reference to the session object that is relevant to the event.
    	 */
        public var session:AbstractSession;
		
		/**
		 * Creates a new <code>SessionEvent</code> object.
		 * 
		 * @param	type	The type of the event. Possible values are: <code>SessionEvent.SESSION_UPDATED</code> and <code>SessionEvent.DRAW_COMPLETE</code>.
		 * @param	session	A reference to the session object that is relevant to the event.
		 */
        public function SessionEvent(type:String, session:AbstractSession)
        {
            super(type);
            this.session = session;
        }
		
		/**
		 * Creates a copy of the SessionEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new SessionEvent(type, session);
        }
    }
}
