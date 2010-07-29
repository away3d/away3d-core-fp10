package away3d.materials
{
    import away3d.arcane;
	import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;
    
	use namespace arcane;
	
    /**
    * Basic bitmap material
    */
    public class LayerMaterial extends ColorMaterial
    {
    	/** @private */
        arcane function renderLayer(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer, layer:Sprite, level:int):int
        {
        	throw new Error("Not implemented");
        }
    	/** @private */
        arcane function renderBitmapLayer(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO
		{
			throw new Error("Not implemented");
    	}
    	
		/**
		 * Creates a new <code>LayerMaterial</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function LayerMaterial(init:Object = null)
        {
        	ini = Init.parse(init);
        	
            super(ini.getColor("color", 0xFFFFFF), ini);
        }
	}
}
