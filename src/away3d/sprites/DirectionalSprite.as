package away3d.sprites
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.materials.*;
	
	use namespace arcane;
	
	/**
	 * Spherical billboard (always facing the camera) sprite object that uses an array of bitmapData objects defined with viewing direction vectors.
	 * Draws 2d directional image dependent on viewing angle inline with z-sorted triangles in a scene.
	 */
    public class DirectionalSprite extends Sprite3D
    {
    	private var _materials:Vector.<Material>;
        
		/**
		 * Returns an array of directional materials.
		 */
        public function get materials():Vector.<Material>
        {
            return _materials;
        }
        
		/**
		 * Creates a new <code>DirectionalSprite</code> object.
		 * 
		 */
        public function DirectionalSprite(material:Material = null, width:Number = 10, height:Number = 10, rotation:Number = 0, align:String = "center", scaling:Number = 1, distanceScaling:Boolean = true)
        {
            super(material, width, height, rotation, align, scaling, distanceScaling);

			_materials = spriteVO.materials;
        }
		
		/**
		 * Adds a new material definition to the array of directional materials.
		 * 
		 * @param		vertex		The orienting vertex to be used by the directional material.
		 * @param		bitmap		The bitmapData object to be used as the directional material.
		 */
        public function addDirectionalMaterial(vertex:Vertex, material:Material):void
		{
			_materials.push(material);
			
			_vertices.push(vertex);
			
			vertex.parents.push(this);
  			
  			if (parent)
  				parent.notifyGeometryChanged();
		}
    }
}
