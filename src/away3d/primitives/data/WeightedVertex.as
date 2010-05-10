package away3d.primitives.data
{
    import away3d.arcane;
    import away3d.core.base.Vertex;
	
    use namespace arcane;
    
    /**
    * A WeightedVertex that simply extends vertex with a w weight property.
    * Properties x, y, z and w represent a 3d point in space with nurb weighting.
    */
    public class WeightedVertex extends Vertex
    {
		
        public var w:Number;
        public var nurbData:Object = new Object();
       
		/**
		 * Creates a new <code>WeightedVertex</code> object.
		 *
		 * @param	x	[optional]	The local x position of the vertex. Defaults to 0.
		 * @param	y	[optional]	The local y position of the vertex. Defaults to 0.
		 * @param	z	[optional]	The local z position of the vertex. Defaults to 0.
		 * @param	w	[optional]	The local w weight of the vertex. Defaults to 1.
		 */
        public function WeightedVertex(x:Number = 0, y:Number = 0, z:Number = 0, wVal:Number = 1 ) {
						w = wVal;
            super(x, y, z);
        }
    }
}
