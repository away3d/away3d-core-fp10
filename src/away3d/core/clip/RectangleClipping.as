package away3d.core.clip
{
	import away3d.core.render.*;

    /**
    * Rectangle clipping
    */
    public class RectangleClipping extends Clipping
    {
        public function RectangleClipping(init:Object = null)
        {
            super(init);
            
            objectCulling = ini.getBoolean("objectCulling", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function checkPrimitive(renderer:Renderer, priIndex:uint):Boolean
        {
        	var primitiveProperties:Array = renderer.primitiveProperties;
        	var index:uint = priIndex*9;
            if (primitiveProperties[index + 3] < minX)
                return false;
            if (primitiveProperties[index + 2] > maxX)
                return false;
            if (primitiveProperties[index + 5] < minY)
                return false;
            if (primitiveProperties[index + 4] > maxY)
                return false;
			
            return true;
        }
        
		public override function clone(object:Clipping = null):Clipping
        {
        	var clipping:RectangleClipping = (object as RectangleClipping) || new RectangleClipping();
        	
        	super.clone(clipping);
        	
        	return clipping;
        }
    }
}