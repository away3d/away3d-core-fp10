package away3d.primitives
{
	import away3d.arcane;
	import away3d.core.base.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d sphere primitive.
    */ 
    public class Sphere extends AbstractPrimitive
    {
        private var vertexGrid:Vector.<Vector.<Vertex>>;
        private var uvGrid:Vector.<Vector.<UV>>;
        private var _radius:Number;
        private var _segmentsW:uint;
        private var _segmentsH:uint;
        private var _yUp:Boolean;
        
		/**
		 * @inheritDoc
		 */
    	protected override function buildPrimitive():void
    	{
    		super.buildPrimitive();
    		
            var i:int;
            var j:int;

            vertexGrid = new Vector.<Vector.<Vertex>>(_segmentsH + 1, true);
            uvGrid = new Vector.<Vector.<UV>>(_segmentsH + 1, true);

            var bottom:Vertex = _yUp? createVertex(0, -_radius, 0) : createVertex(0, 0, -_radius);
            vertexGrid[0] = new Vector.<Vertex>(_segmentsW, true);
            uvGrid[0] = new Vector.<UV>(_segmentsW + 1, true);
            
            for (i = 0; i <= _segmentsW; ++i) {
            	if (i < _segmentsW)
                	vertexGrid[0][i] = bottom;
                
                uvGrid[0][i] = createUV(i/_segmentsW, 0);
            }

            for (j = 1; j < _segmentsH; ++j) { 
                var horangle:Number = j / _segmentsH * Math.PI;
                var z:Number = -_radius * Math.cos(horangle);
                var ringradius:Number = _radius * Math.sin(horangle);

                vertexGrid[j] = new Vector.<Vertex>(_segmentsW, true);
                uvGrid[j] = new Vector.<UV>(_segmentsW + 1, true);
                
                for (i = 0; i <= _segmentsW; ++i) {
                	if (i < _segmentsW) {
	                    var verangle:Number = 2 * i/_segmentsW * Math.PI;
	                    var x:Number = ringradius * Math.sin(verangle);
	                    var y:Number = ringradius * Math.cos(verangle);
	                    
	                    if (_yUp)
	                    	vertexGrid[j][i] = createVertex(y, z, x);
	                    else
	                    	vertexGrid[j][i] = createVertex(y, -x, z);
                	}
                	
					uvGrid[j][i] = createUV(i/_segmentsW, j/_segmentsH);
                }
            }

            var top:Vertex = _yUp? createVertex(0, _radius, 0) : createVertex(0, 0, _radius);
            vertexGrid[_segmentsH] = new Vector.<Vertex>(_segmentsW, true);
            uvGrid[_segmentsH] = new Vector.<UV>(_segmentsW + 1, true);
            
			for (i = 0; i <= _segmentsW; ++i) {
            	if (i < _segmentsW)
                	vertexGrid[_segmentsH][i] = top;
                
                uvGrid[_segmentsH][i] = createUV(i/_segmentsW, 1);
            }
            
            for (j = 1; j <= _segmentsH; ++j) {
                for (i = 0; i < _segmentsW; ++i) {
                    var v0:Vertex = vertexGrid[j][i];
                    var v1:Vertex = vertexGrid[j][(i-1+_segmentsW) % _segmentsW];
                    var v2:Vertex = vertexGrid[j-1][(i-1+_segmentsW) % _segmentsW];
                    var v3:Vertex = vertexGrid[j-1][i];
					
					var i2:int = i || _segmentsW;
					
					var uv0:UV = uvGrid[j][i2];
                    var uv1:UV = uvGrid[j][i2-1];
                    var uv2:UV = uvGrid[j-1][i2-1];
                    var uv3:UV = uvGrid[j-1][i2];
                    
                    var vab:Number = j / _segmentsH;
                    var vcd:Number = (j-1) / _segmentsH;
                    var uad:Number = i2 / _segmentsW;
                    var ubc:Number = (i2-1) / _segmentsW;
                    var uva:UV = createUV(uad,vab);
                    var uvb:UV = createUV(ubc,vab);
                    var uvc:UV = createUV(ubc,vcd);
                    var uvd:UV = createUV(uad,vcd);

                    if (j < _segmentsH)  
                        addFace(createFace(v0,v1,v2, null, uv0,uv1,uv2));
                    if (j > 1)                
                        addFace(createFace(v0,v2,v3, null, uv0,uv2,uv3));
                }
            }
    	}
    	
    	/**
    	 * Defines the radius of the sphere. Defaults to 100.
    	 */
    	public function get radius():Number
    	{
    		return _radius;
    	}
    	
    	public function set radius(val:Number):void
    	{
    		if (_radius == val)
    			return;
    		
    		_radius = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines the number of horizontal segments that make up the sphere. Defaults to 8.
    	 */
    	public function get segmentsW():uint
    	{
    		return _segmentsW;
    	}
    	
    	public function set segmentsW(val:uint):void
    	{
    		if (_segmentsW == val)
    			return;
    		
    		_segmentsW = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines the number of vertical segments that make up the sphere. Defaults to 1.
    	 */
    	public function get segmentsH():uint
    	{
    		return _segmentsH;
    	}
    	
    	public function set segmentsH(val:uint):void
    	{
    		if (_segmentsH == val)
    			return;
    		
    		_segmentsH = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines whether the coordinates of the sphere points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
    	 */
    	public function get yUp():Boolean
    	{
    		return _yUp;
    	}
    	
    	public function set yUp(val:Boolean):void
    	{
    		if (_yUp == val)
    			return;
    		
    		_yUp = val;
    		_primitiveDirty = true;
    	}
		
		/**
		 * Creates a new <code>Sphere</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function Sphere(init:Object = null)
        {
            super(init);
            
            _radius = ini.getNumber("radius", 100, {min:0});
            _segmentsW = ini.getInt("segmentsW", 8, {min:3});
            _segmentsH = ini.getInt("segmentsH", 6, {min:2});
			_yUp = ini.getBoolean("yUp", true);
			
			type = "Sphere";
        	url = "primitive";
        }
        
		/**
		 * Returns the vertex object specified by the vertexGrid position of the mesh.
		 * 
		 * @param	w	The horizontal position on the primitive mesh.
		 * @param	h	The vertical position on the primitive mesh.
		 */
        public function vertex(w:int, h:int):Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
            return vertexGrid[h][w];
        }
    }
}