package away3d.core.utils
{
    
    import away3d.core.base.*;
    
    import flash.events.*;
    
    public class ValueObject extends EventDispatcher
    {
        public var parents:Vector.<Element> = new Vector.<Element>();
        
        public var geometry:Geometry;
    }
}