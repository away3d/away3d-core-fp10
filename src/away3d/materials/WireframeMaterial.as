package away3d.materials
{
	import away3d.events.MaterialEvent;
	import away3d.arcane;
    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.utils.*;
	
	use namespace arcane;
	
    /**
    * Wire material for face border outlining only
    */
    public class WireframeMaterial extends Material
    {
		/** @private */
        arcane var _materialDirty:Boolean;
    	/** @private */
        arcane function notifyMaterialUpdate():void
        {
        	_materialDirty = false;
        	
            if (!hasEventListener(MaterialEvent.MATERIAL_UPDATED))
                return;
			
            if (_materialupdated == null)
                _materialupdated = new MaterialEvent(MaterialEvent.MATERIAL_UPDATED, this);
                
            dispatchEvent(_materialupdated);
        }
    	/** @private */
        arcane override function updateMaterial(source:Object3D, view:View3D):void
        {
        	if (_materialDirty)
        		notifyMaterialUpdate();
        }
        /** @private */
        arcane override function renderSegment(seg:DrawSegment):void
        {
            if (wireAlpha <= 0)
                return;
			
			seg.source.session.renderTriangleLine(_thickness, _wireColor, _wireAlpha, seg.screenVertices, seg.screenCommands, seg.screenIndices, seg.startIndex, seg.endIndex);
        }
        /** @private */
        arcane override function renderTriangle(tri:DrawTriangle):void
        {
            if (wireAlpha <= 0)
                return;

            tri.source.session.renderTriangleLine(_thickness, _wireColor, _wireAlpha, tri.screenVertices, tri.screenCommands, tri.screenIndices, tri.startIndex, tri.endIndex);
        }
        
        private var _materialupdated:MaterialEvent;
        
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		protected var ini:Init;
		
        protected var _wireAlpha:Number;
        protected var _wireColor:uint = 0x0;
        protected var _thickness:Number;
		
		protected function getDefaultThickness():Number
		{
			return 1;
		}
		
		/**
		 * 24 bit color value representing the wire color
		 */
        public function get wireColor():uint
        {
        	return _wireColor;
        }
        
        public function set wireColor(val:uint):void
        {
        	if (_wireColor == val)
        		return;
        	
        	_wireColor = val;
        	
        	_materialDirty = true;
        }
		
		/**
		 * Determines the alpha value of the wire
		 */
        public function get wireAlpha():Number
        {
        	return _wireAlpha;
        }
        
        public function set wireAlpha(val:Number):void
        {
        	if (_wireAlpha == val)
        		return;
        	
        	_wireAlpha = val;
        	
        	_materialDirty = true;
        }
		
		/**
		 * Determines the thickness value of the wire
		 */
        public function get thickness():Number
        {
        	return _thickness;
        }
        
        public function set thickness(val:Number):void
        {
        	if (_thickness == val)
        		return;
        	
        	_thickness = val;
        	
        	_materialDirty = true;
        }
    	
		/**
		 * @inheritDoc
		 */
        public override function get visible():Boolean
        {
            return (wireAlpha > 0);
        }
        
		/**
		 * Creates a new <code>WireframeMaterial</code> object.
		 * 
		 * @param	wireColor				A string, hex value or colorname representing the color of the wire.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function WireframeMaterial(wireColor:* = null, init:Object = null)
        {
            if (wireColor == null)
                wireColor = "random";
            
            this.wireColor = Cast.trycolor(wireColor);
			
            ini = Init.parse(init);
            
            wireAlpha = ini.getNumber("wireAlpha", 1, {min:0, max:1});
            thickness = ini.getNumber("thickness", getDefaultThickness(), {min:0});
        }
        
		/**
		 * Duplicates the material properties to another material object.  Usage: existingMaterial = materialToClone.clone( existingMaterial ) as WireframeMaterial;
		 * 
		 * @param	object	[optional]	The new material instance into which all properties are copied. The default is <code>WireframeMaterial</code>.
		 * @return						The new material instance with duplicated properties applied.
		 */
        public override function clone(material:Material = null):Material
        {
        	var mat:WireframeMaterial = (material as WireframeMaterial) || new WireframeMaterial();
        	mat.wireColor = _wireColor;
        	mat.wireAlpha = _wireAlpha;
        	mat.thickness = _thickness;
        	
        	return mat;
        }
    }
}
