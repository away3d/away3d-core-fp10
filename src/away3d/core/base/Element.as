package away3d.core.base
{
    import away3d.arcane;
    import away3d.materials.*;
    
    import flash.events.*;
    import flash.geom.*;
    
    use namespace arcane;
	
	/**
	 * Basic 3d element object
     * Not intended for direct use - use <code>Segment</code> or <code>Face</code>.
	 */
    public class Element
    {
		protected var _vertices:Vector.<Vertex>;
		protected var _uvs:Vector.<UV>;
		protected var _commands:Vector.<String>;
		protected var _pathCommands:Array = new Array();
		protected var _lastAddedVertex:Vertex = new Vertex();
    	protected var _material:Material;
    	
		/** @private */
        arcane var _normal:Vector3D;
        /** @private */
        arcane var _visible:Boolean = true;
        /** @private */
        arcane var _inds:Vector.<uint>;
    	/**
    	 * An optional untyped object that can contain used-defined properties.
    	 */
        public var extra:Object;
        
    	/**
    	 * Defines the parent 3d object of the segment.
    	 */
		public var parent:Geometry;
		
		/**
		 * Returns an array of vertex objects that make up the 3d element.
		 */
        public function get vertices():Vector.<Vertex>
        {
            return _vertices;
        }
        
		/**
		 * Returns an array of uv objects that are used by the element.
		 */
		public function get uvs():Vector.<UV>
        {
            return _uvs;
        }
        
		/**
		 * Returns an array of drawing command strings that make up the 3d element.
		 */
        public function get commands():Vector.<String>
        {
            return _commands;
        }
                
        /**
		 * Returns an array of drawing command objects that are used by the face.
		 */
        public function get pathCommands():Array
        {
			return _pathCommands;
		}
        
		/**
		 * Determines whether the 3d element is visible in the scene.
		 */
        public function get visible():Boolean
        {
            return _visible;
        }
		
        public function set visible(value:Boolean):void
        {
            if (value == _visible)
                return;

            _visible = value;
			
            if (parent)
            	parent.notifyVisibleChange();
        }
        
		public function get material():Material
        {
            return _material;
        }

        public function set material(value:Material):void
        { 
        }
    }
}
