package away3d.materials
{
    import away3d.arcane;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	
	use namespace arcane;
	
    /**
    * Material for solid color drawing
    */
    public class ColorMaterial extends WireColorMaterial
    {
		/** @private */
        arcane override function renderTriangle(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void
        {
        	if (debug)
				renderer._session.renderTriangleLineFill(_thickness, _color, _alpha, _wireColor, _wireAlpha, viewSourceObject.screenVertices, renderer.primitiveCommands[priIndex], viewSourceObject.screenIndices, renderer.primitiveProperties[priIndex*9], renderer.primitiveProperties[priIndex*9+1]);
        	else
        		renderer._session.renderTriangleColor(_color, _alpha, viewSourceObject.screenVertices, renderer.primitiveCommands[priIndex], viewSourceObject.screenIndices, renderer.primitiveProperties[priIndex*9], renderer.primitiveProperties[priIndex*9+1]);
        }
        
		/** @private */
        arcane override function renderSprite(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void
        {
            renderer._session.renderSpriteColor(_color, _alpha, priIndex, viewSourceObject, renderer);
        }
        
		/** @private */
        arcane function renderFog(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void
        {
            renderer._session.renderFogColor(_color, _alpha, renderer.primitiveProperties[priIndex*9 + 2], renderer.primitiveProperties[priIndex*9 + 3], renderer.primitiveProperties[priIndex*9 + 4], renderer.primitiveProperties[priIndex*9 + 5]);
        }
        
        protected var _debug:Boolean;
        
    	/**
        * Toggles debug mode: textured triangles are drawn with white outlines, precision correction triangles are drawn with blue outlines.
        */
        public function get debug():Boolean
        {
        	return _debug;
        }
        
        public function set debug(val:Boolean):void
        {
        	if (_debug == val)
        		return;
        	
        	_debug = val;
        	
        	_materialDirty = true;
        }
    	
		/**
		 * Creates a new <code>ColorMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function ColorMaterial(color:* = null, init:Object = null)
        {
        	super(color, init);
        	
        	debug = ini.getBoolean("debug", false);
        }
        
        
		/**
		 * Duplicates the material properties to another material object.  Usage: existingMaterial = materialToClone.clone( existingMaterial ) as ColorMaterial;
		 * 
		 * @param	object	[optional]	The new material instance into which all properties are copied. The default is <code>ColorMaterial</code>.
		 * @return						The new material instance with duplicated properties applied.
		 */
        public override function clone(material:Material = null):Material
        {
        	var mat:ColorMaterial = (material as ColorMaterial) || new ColorMaterial();
        	super.clone(mat);
        	mat.debug = _debug;
        	
        	return mat;
        }
    }
}
