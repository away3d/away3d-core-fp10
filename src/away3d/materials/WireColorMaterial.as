package away3d.materials
{
	import away3d.arcane;
	import away3d.core.render.*;
    import away3d.core.utils.*;
	
	use namespace arcane;
	
    /**
    * Wire material for solid color drawing with optional face border outlining
    */
    public class WireColorMaterial extends WireframeMaterial
    {
		/** @private */
        arcane override function renderTriangle(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void
        {
			renderer._session.renderTriangleLineFill(_thickness, _color, _alpha, _wireColor, _wireAlpha, viewSourceObject.screenVertices, renderer.primitiveCommands[priIndex], viewSourceObject.screenIndices, renderer.primitiveProperties[priIndex*9], renderer.primitiveProperties[priIndex*9+1]);
        }
        
        protected var _alpha:Number;
        protected var _color:uint;
        
		/**
		 * 24 bit color value representing the material color
		 */
        public function get color():uint
        {
        	return _color;
        }
        
        public function set color(val:uint):void
        {
        	if (_color == val)
        		return;
        	
        	_color = val;
        	
        	_materialDirty = true;
        }
        
    	/**
    	 * Determines the alpha value of the material
    	 */
        public function get alpha():Number
        {
        	return _alpha;
        }
        
        public function set alpha(val:Number):void
        {
        	if (_alpha == val)
        		return;
        	
        	_alpha = val;
        	
        	_materialDirty = true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function get visible():Boolean
        {
            return (alpha > 0) || (wireAlpha > 0);
        }
        
		/**
		 * Creates a new <code>WireColorMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function WireColorMaterial(color:* = null, init:Object = null)
        {
        	if (color == null)
                color = "random";
            
            this.color = Cast.trycolor(color);
            
        	ini = Init.parse(init);
        	
            super(ini.getColor("wireColor", wireColor), ini);
            
            alpha = ini.getNumber("alpha", 1, {min:0, max:1});
        }
        
		/**
		 * Duplicates the material properties to another material object.  Usage: existingMaterial = materialToClone.clone( existingMaterial ) as WireColorMaterial;
		 * 
		 * @param	object	[optional]	The new material instance into which all properties are copied. The default is <code>WireColorMaterial</code>.
		 * @return						The new material instance with duplicated properties applied.
		 */
        public override function clone(material:Material = null):Material
        {
        	var mat:WireColorMaterial = (material as WireColorMaterial) || new WireColorMaterial();
        	super.clone(mat);
        	mat.color = _color;
        	mat.alpha = _alpha;
        	
        	return mat;
        }
    }
}
