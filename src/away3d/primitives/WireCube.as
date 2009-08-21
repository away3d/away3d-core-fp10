package away3d.primitives
{
	import away3d.arcane;
	import away3d.core.base.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d wire cube primitive.
    */ 
    public class WireCube extends AbstractPrimitive
    {
    	private var _width:Number;
    	private var _height:Number;
    	private var _depth:Number;
    	private var _v000:Vertex;
        private var _v001:Vertex;
        private var _v010:Vertex;
        private var _v011:Vertex;
        private var _v100:Vertex;
        private var _v101:Vertex;
        private var _v110:Vertex;
        private var _v111:Vertex;
        
		/**
		 * @inheritDoc
		 */
    	protected override function buildPrimitive():void
    	{
    		super.buildPrimitive();
    		
    		_v000 = createVertex(-_width/2, -_height/2, -_depth/2); 
            _v001 = createVertex(-_width/2, -_height/2, +_depth/2); 
            _v010 = createVertex(-_width/2, +_height/2, -_depth/2); 
            _v011 = createVertex(-_width/2, +_height/2, +_depth/2); 
            _v100 = createVertex(+_width/2, -_height/2, -_depth/2); 
            _v101 = createVertex(+_width/2, -_height/2, +_depth/2); 
            _v110 = createVertex(+_width/2, +_height/2, -_depth/2); 
            _v111 = createVertex(+_width/2, +_height/2, +_depth/2); 

            addSegment(createSegment(v000, v001));
            addSegment(createSegment(v011, v001));
            addSegment(createSegment(v011, v010));
            addSegment(createSegment(v000, v010));

            addSegment(createSegment(v100, v000));
            addSegment(createSegment(v101, v001));
            addSegment(createSegment(v111, v011));
            addSegment(createSegment(v110, v010));

            addSegment(createSegment(v100, v101));
            addSegment(createSegment(v111, v101));
            addSegment(createSegment(v111, v110));
            addSegment(createSegment(v100, v110));
    	}
    	
    	/**
    	 * Returns the back bottom left vertex of the cube.
    	 */
        public function get v000():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v000;
    	}
    	
    	/**
    	 * Returns the front bottom left vertex of the cube.
    	 */
        public function get v001():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v001;
    	}
    	
    	/**
    	 * Returns the back top left vertex of the cube.
    	 */
        public function get v010():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v010;
    	}
    	
    	/**
    	 * Returns the front top left vertex of the cube.
    	 */
        public function get v011():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v011;
    	}
    	
    	/**
    	 * Returns the back bottom right vertex of the cube.
    	 */
        public function get v100():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v100;
    	}
    	
    	/**
    	 * Returns the front bottom right vertex of the cube.
    	 */
        public function get v101():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v101;
    	}
    	
    	/**
    	 * Returns the back top right vertex of the cube.
    	 */
        public function get v110():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v110;
    	}
    	
    	/**
    	 * Returns the front top right vertex of the cube.
    	 */
        public function get v111():Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
        	return _v111;
        }
        
    	/**
    	 * Defines the width of the cube. Defaults to 100.
    	 */
    	public function get width():Number
    	{
    		return _width;
    	}
    	
    	public function set width(val:Number):void
    	{
    		if (_width == val)
    			return;
    		
    		_width = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines the height of the cube. Defaults to 100.
    	 */
    	public function get height():Number
    	{
    		return _height;
    	}
    	
    	public function set height(val:Number):void
    	{
    		if (_height == val)
    			return;
    		
    		_height = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines the depth of the cube. Defaults to 100.
    	 */
    	public function get depth():Number
    	{
    		return _depth;
    	}
    	
    	public function set depth(val:Number):void
    	{
    		if (_depth == val)
    			return;
    		
    		_depth = val;
    		_primitiveDirty = true;
    	}
    	
		/**
		 * Creates a new <code>WireCube</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function WireCube(init:Object = null)
        {
            super(init);

            _width  = ini.getNumber("width", 100, {min:0});
            _height = ini.getNumber("height", 100, {min:0});
            _depth  = ini.getNumber("depth", 100, {min:0});
			
			type = "WireCube";
        	url = "primitive";
        }
    }
}