package away3d.primitives
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.materials.ColorMaterial;
	
	import flash.geom.Rectangle;
	
	import wumedia.vector.VectorText;
	
	use namespace arcane;
	
	public class TextField3D extends AbstractPrimitive
	{
		private var _font:String;
		private var _size:Number;
		private var _leading:Number;
		private var _letterSpacing:Number;
		private var _text:String;
		private var _width:Number;
		private var _align:String;
		private var _face:Face;
		
		/**
		 * @inheritDoc
		 */
    	protected override function buildPrimitive():void
    	{
    		super.buildPrimitive();
    		
			geometry.graphics.clear();
			VectorText.write(geometry.graphics, _font, _size, _leading, _letterSpacing, _text, 0, 0, _width, _align, false);
			
			//clear the materials on the shapes
			for each (_face in geometry.faces)
				_face.material = null;
    	}
    	
		/**
    	 * Defines the size of the text in pixels. Defaults to 20.
    	 */
		public function get size():Number
		{
			return _size;
		}
		
		public function set size(val:Number):void
		{
			if (_size == val)
    			return;
    		
			_size = val;
			_primitiveDirty = true;
		}
		
		/**
    	 * Defines the amount of vertical space between lines. Defaults to 20.
    	 */
		public function get leading():Number
		{
			return _leading;
		}
		
		public function set leading(val:Number):void
		{
			if (_leading == val)
    			return;
    		
			_leading = val;
			_primitiveDirty = true;
		}
		
		/**
    	 * Defines the amount of horizontal padding between characters. Defaults to 0.
    	 */
		public function get letterSpacing():Number
		{
			return _letterSpacing;
		}
		
		public function set letterSpacing(val:Number):void
		{
			if (_letterSpacing == val)
    			return;
    		
			_letterSpacing = val;
			_primitiveDirty = true;
		}
				
		/**
    	 * Defines the current text in the textfield.
    	 */
		public function get text():String
		{
			return _text;
		}
		
		public function set text(val:String):void
		{
			if (_text == val)
    			return;
    		
			_text = val;
			_primitiveDirty = true;
		}
				
		/**
    	 * Defines the fixed width of the textfield.
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
    	 * Defines the paragraph alignment of the textfield. Defaults to TL (Top Left).
    	 */
		public function get align():String
		{
			return _align;
		}
		
		public function set align(val:String):void
		{
			if (_align == val)
    			return;
    		
			_align = val;
			_primitiveDirty = true;
		}
    	
    	/**
    	 * Adds a hit box wrapping the text that captures mouse events near the text.
    	 * @param paddingWidth Number Adds specified amount of pixels on the hitbox to the left and right of the text. 
    	 * @param paddingHeight Number Adds specified amount of pixels on the hitbox to the top and bottom of the text. 
    	 * @param debug Boolean If using the default color material, makes the hit box visible for debugging.
    	 * @param colorMaterial ColorMaterial Allows to use a custom material for the hit box. The main idea is to avoid having multiple materials if a lot
    	 * of TextField3D instances are used.
    	 * @return Face A reference to the face representing the hit box.
    	 */    	
    	public function addHitBox(paddingWidth:Number = 0, paddingHeight:Number = 0, debug:Boolean = false, colorMaterial:ColorMaterial = null):Face
		{
			var bounds:Rectangle = new Rectangle(minX, minY, maxX - minX, maxY - minY);
			bounds.inflate(paddingWidth, paddingHeight);
			
			var hit:Face = new Face();
			hit.moveTo(bounds.left, bounds.top, 0);
			hit.lineTo(bounds.right, bounds.top, 0); 
			hit.lineTo(bounds.right, bounds.bottom, 0); 
			hit.lineTo(bounds.left, bounds.bottom, 0); 
			hit.lineTo(bounds.left, bounds.top, 0); 
			hit.material = colorMaterial ? colorMaterial : new ColorMaterial(0x3399CC, {alpha: debug ? .2 : .001}); 
			addFace(hit);
			
			return hit;
		}
    	
		/**
		 * Creates a new <code>TextField3D</code> object.
		 *
		 * @param	font				The name of the font to be used in the textfield.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function TextField3D(font:String, init:Object = null)
		{
			super(init);
			
			_font = font;
			
			_size = ini.getNumber("size", 20);
			_leading = ini.getNumber("leading", 20);
			_letterSpacing = ini.getNumber("letterSpacing", 0);
			_text = ini.getString("text", "");
			_width = ini.getNumber("width", 500);
			_align = ini.getString("align", "TL");
			
			_primitiveDirty = true;
			
			this.bothsides = true;
			
			type = "TextField3D";
        	url = "primitive";
		}
	}
}