package away3d.core.base
{
    import away3d.arcane;
    import away3d.core.utils.*;
    
    import flash.geom.*;
    
    use namespace arcane;
    
	/**
	 * Texture coordinates value object.
	 * Properties u and v represent the horizontal and vertical texture axes.
	 */
    public class UV extends ValueObject
    {
		/** @private */
        arcane var _u:Number;
		/** @private */
        arcane var _v:Number;
        /** @private */
        arcane var _mappingDirty:Boolean;
        /** @private */
        arcane var _texIndices:Vector.<uint> = new Vector.<uint>();
		/** @private */
        arcane static function median(a:UV, b:UV):UV
        {
            if (a == null)
                return null;
            if (b == null)
                return null;
            return new UV((a._u + b._u)/2, (a._v + b._v)/2);
        }
		/** @private */
        arcane static function weighted(a:UV, b:UV, aw:Number, bw:Number):UV
        {                
            if (a == null)
                return null;
            if (b == null)
                return null;
            var d:Number = aw + bw;
            var ak:Number = aw / d;
            var bk:Number = bw / d;
            return new UV(a._u*ak+b._u*bk, a._v*ak + b._v*bk);
        }
        
        private function updateMapping():void
        {
        	_mappingDirty = false;
        	
        	_mapping.x = _u;
        	_mapping.y = 1 - _v;
        }
        
        private var _mapping:Point = new Point();
        
    	/**
    	 * An optional untyped object that can contain used-defined properties.
    	 */
        public var extra:Object;
		
		/**
		 * Defines the vertical corrdinate of the texture value.
		 */
        public function get v():Number {
        	
			if (_mappingDirty)
        		updateMapping();
        	
            return _v;
        }

        public function set v(value:Number):void
        {
            if (value == _v)
                return;

            _v = value;
			
            _mappingDirty = true;
            
            if (geometry)
            	geometry.notifyMappingUpdate();
        }
		
		/**
		 * Defines the horizontal corrdinate of the texture value.
		 */
        public function get u():Number
        {
			if (_mappingDirty)
        		updateMapping();
        	
            return _u;
        }

        public function set u(value:Number):void
        {
            if (value == _u)
                return;

            _u = value;
            
            _mappingDirty = true;
            
            if (geometry)
            	geometry.notifyMappingUpdate();
        }
    	
    	public function get mapping():Point
        {
        	if (_mappingDirty)
        		updateMapping();
        	
            return _mapping;
        }
        
		/**
		 * Creates a new <code>UV</code> object.
		 *
		 * @param	u		[optional]	The horizontal corrdinate of the texture value. Defaults to 0.
		 * @param	v		[optional]	The vertical corrdinate of the texture value. Defaults to 0.
		 */
        public function UV(u:Number = 0, v:Number = 0)
        {
            _u = u;
            _v = v;
            
            _mappingDirty = true;
        }
		
		/**
		 * Duplicates the vertex properties to another <code>Vertex</code> object
		 * 
		 * @return	The new vertex instance with duplicated properties applied
		 */
        public function clone():UV
        {
            return new UV(_u, _v);
        }
		
		/**
		 * Used to trace the values of a uv object.
		 * 
		 * @return A string representation of the uv object.
		 */
        public override function toString():String
        {
            return "new UV("+_u+", "+_v+")";
        }


    }
}