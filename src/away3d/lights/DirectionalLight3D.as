package away3d.lights
{
	import away3d.arcane;
	import away3d.containers.*;
    import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.events.*;
    import away3d.materials.*;
    import away3d.primitives.*;
    
	import flash.display.*;
	import flash.geom.*;
	import flash.filters.*;
	import flash.utils.*;
	
	use namespace arcane;
	
    /**
    * Lightsource that colors all shaded materials proportional to the dot product of the offset vector with the normal vector.
    * The scalar value of distance does not affect the resulting light intensity, it is calulated as if the
    * source is an infinite distance away with an infinite brightness.
    */
    public class DirectionalLight3D extends AbstractLight
    {
    	        
        /**
         * @private
         * Transform dictionary for the diffuse lightmap used by shading materials.
         */
        arcane var diffuseTransform:Dictionary = new Dictionary(true);
        
        /**
         * @private
         * Transform dictionary for the specular lightmap used by shading materials.
         */
        arcane var specularTransform:Dictionary = new Dictionary(true);
        
        /**
         * @private
         * Colormatrix transform used in DOT3 materials for resolving normal values in the normal map.
         */
        arcane var normalMatrixDiffuseTransform:Dictionary = new Dictionary(true);
        
        /**
         * @private
         * Colormatrix transform used in DOT3 materials for resolving normal values in the normal map.
         */
        arcane var normalMatrixSpecularTransform:Dictionary = new Dictionary(true);
        
        /**
         * @private
         * Updates the transform matrix for the diffuse lightmap.
         * 
         * @see diffuseTransform
         */
        arcane function setDiffuseTransform(source:Object3D):void
        {
			
        	if (!diffuseTransform[source])
        		diffuseTransform[source] = new MatrixAway3D();
        	
			diffuseTransform[source].multiply3x3(_sceneTransform, source.sceneTransform);
        	diffuseTransform[source].normalize(diffuseTransform[source]);
        }
        
        /**
         * @private
         * Updates the transform matrix for the specular lightmap.
         * 
         * @see specularTransform
         */
        arcane function setSpecularTransform(source:Object3D, view:View3D):void
        {
			//find halfway matrix between camera and direction matricies
			_cameraTransform = view.camera.transform;
			_cameraDirection.x = -_cameraTransform.sxz;
			_cameraDirection.y = -_cameraTransform.syz;
			_cameraDirection.z = -_cameraTransform.szz;
			_halfVector.add(_cameraDirection, sceneDirection);
			_halfVector.normalize();
			_nx = _halfVector.x;
        	_ny = _halfVector.y;
        	_mod = Math.sqrt(_nx*_nx + _ny*_ny);
        	_halfTransform.rotationMatrix(-_ny/_mod, _nx/_mod, 0, Math.acos(-_halfVector.z));
        	
			if (!specularTransform[source])
        		specularTransform[source] = new Dictionary(true);
        	
			if (!specularTransform[source][view])
				specularTransform[source][view] = new MatrixAway3D();
			
        	specularTransform[source][view].multiply3x3(_halfTransform, source.sceneTransform);
        	specularTransform[source][view].normalize(specularTransform[source][view]);
        }
        
        /**
         * @private
         * Updates the normal transform matrix.
         * 
         * @see normalMatrixTransform
         */
        arcane function setNormalMatrixDiffuseTransform(source:Object3D):void
        {
        	_r = _red*2*_diffuse*_brightness;
			_g = _green*2*_diffuse*_brightness;
			_b = _blue*2*_diffuse*_brightness;
			
        	_szx = diffuseTransform[source].szx;
			_szy = -diffuseTransform[source].szy;
			_szz = diffuseTransform[source].szz;
			
        	//multipication of [_szx, 0, 0, 0, 127 - _szx*127, 0, -_szy, 0, 0, 127 + _szy*127, 0, 0, _szz, 0, 127 - _szz*127, 0, 0, 0, 1, 0]*[_red, _red, _red, 0, -381*_red, _green, _green, _green, 0, -381*_green, _blue, _blue, _blue, 0, -381*_blue, 0, 0, 0, 1, 0]
        	_normalMatrix.matrix = [_r*_szx, _r*_szy, _r*_szz, 0, -_r *127*(_szx + _szy + _szz),
        						    _g*_szx, _g*_szy, _g*_szz, 0, -_g *127*(_szx + _szy + _szz),
        						    _b*_szx, _b*_szy, _b*_szz, 0, -_b *127*(_szx + _szy + _szz),
        						   0, 0, 0, 1, 0];
        	normalMatrixDiffuseTransform[source] = _normalMatrix.clone();
        }
        
        /**
         * @private
         * Updates the normal transform matrix.
         * 
         * @see colorMatrixTransform
         */
        arcane function setNormalMatrixSpecularTransform(source:Object3D, view:View3D, specular:uint, shininess:Number):void
        {
        	if (!normalMatrixSpecularTransform[source])
				normalMatrixSpecularTransform[source] = new Dictionary(true);
			
			_sr = _specular*_brightness*((specular & 0xFF0000) >> 16)/255;
            _sg = _specular*_brightness*((specular & 0xFF00) >> 8)/255;
            _sb  = _specular*_brightness*(specular & 0xFF)/255;
            
        	_r = (_red*2 + shininess)*_sr;
			_g = (_green*2 + shininess)*_sg;
			_b = (_blue*2 + shininess)*_sb;
			
        	_szx = specularTransform[source][view].szx;
			_szy = -specularTransform[source][view].szy;
			_szz = specularTransform[source][view].szz;
			
        	//multipication of [_szx, 0, 0, 0, 127 - _szx*127, 0, -_szy, 0, 0, 127 + _szy*127, 0, 0, _szz, 0, 127 - _szz*127, 0, 0, 0, 1, 0]*[_red, _red, _red, 0, -127*shininess-381*_red, _green, _green, _green, 0, -127*shininess-381*_green, _blue, _blue, _blue, 0, -127*shininess-381*_blue, 0, 0, 0, 1, 0];
        	_normalMatrix.matrix = [_r*_szx, _r*_szy, _r*_szz, 0, -_r *127*(_szx + _szy + _szz) -127*shininess*_sr,
        						    _g*_szx, _g*_szy, _g*_szz, 0, -_g *127*(_szx + _szy + _szz) -127*shininess*_sg,
        						    _b*_szx, _b*_szy, _b*_szz, 0, -_b *127*(_szx + _szy + _szz) -127*shininess*_sb,
        						   0, 0, 0, 1, 0];
        	
        	normalMatrixSpecularTransform[source][view] = _normalMatrix.clone();
        }
        
    	private var _direction:Number3D = new Number3D();
        private var _ambient:Number;
        private var _diffuse:Number;
        private var _specular:Number;
        private var _brightness:Number;
    	private var _sceneDirection:Number3D = new Number3D();
		
		private var _normalMatrix:ColorMatrixFilter = new ColorMatrixFilter();
    	private var _matrix:Matrix = new Matrix();
    	private var _shape:Shape = new Shape();
    	private var _sceneTransform:MatrixAway3D = new MatrixAway3D();
    	private var _nx:Number;
    	private var _ny:Number;
    	private var _mod:Number;
        private var _cameraTransform:MatrixAway3D;
        private var _cameraDirection:Number3D = new Number3D();
        private var _halfVector:Number3D = new Number3D();
        private var _halfTransform:MatrixAway3D = new MatrixAway3D();
        private var _r:Number;
		private var _g:Number;
		private var _b:Number;
		private var _sr:Number;
		private var _sg:Number;
		private var _sb:Number;
        private var _szx:Number;
        private var _szy:Number;
        private var _szz:Number;
		
		protected override function onSceneTransformChange(event:Object3DEvent = null):void
        {
        	_sceneDirection.rotate(_direction, _parent.sceneTransform);
        	
        	//update direction vector
        	_sceneDirection.normalize(-1);
        	
        	_nx = _sceneDirection.x;
        	_ny = _sceneDirection.y;
        	_mod = Math.sqrt(_nx*_nx + _ny*_ny);
        	_sceneTransform.rotationMatrix(_ny/_mod, -_nx/_mod, 0, -Math.acos(-_sceneDirection.z));
        	
        	diffuseTransform = new Dictionary(true);
        	specularTransform = new Dictionary(true);
        	normalMatrixDiffuseTransform = new Dictionary(true);
        	normalMatrixSpecularTransform = new Dictionary(true);
        }
        
        /**
         * @private
         * Updates the bitmapData object used as the lightmap for ambient light shading.
         * 
         * @param	ambient		The coefficient for ambient light intensity.
         */
		protected override function updateAmbient():void
        {
        	_ambientBitmap = new BitmapData(256, 256, false, int(_ambient*_red*0xFF << 16) | int(_ambient*_green*0xFF << 8) | int(_ambient*_blue*0xFF));
        	_ambientBitmap.lock();
        	
        	//update colortransform
        	_ambientColorTransform = new ColorTransform(1, 1, 1, 1, _ambient*_red*0xFF, _ambient*_green*0xFF, _ambient*_blue*0xFF, 0);

			_ambientDirty = false;
        }
        
        /**
         * @private 
         * Updates the bitmapData object used as the lightmap for diffuse light shading.
         * 
         * @param	diffuse		The coefficient for diffuse light intensity.
         */
        protected override function updateDiffuse():void
        {
    		_diffuseBitmap = new BitmapData(256, 256, false, 0x000000);
    		_diffuseBitmap.lock();
    		_matrix.createGradientBox(256, 256, 0, 0, 0);
    		var colArray:Array = [];
    		var alphaArray:Array = [];
    		var pointArray:Array = [];
    		var i:int = 15;
    		var diffbright:Number = _diffuse*_brightness;
    		while (i--) {
    			var r:Number = (i*diffbright/14);
    			if (r > 1) r = 1;
    			var g:Number = (i*diffbright/14);
    			if (g > 1) g = 1;
    			var b:Number = (i*diffbright/14);
    			if (b > 1) b = 1;
    			colArray.push((r*_red*0xFF << 16) | (g*_green*0xFF << 8) | b*_blue*0xFF);
    			alphaArray.push(1);
    			pointArray.push(int(30+225*2*Math.acos(i/14)/Math.PI));
    		}
    		_shape.graphics.clear();
    		_shape.graphics.beginGradientFill(GradientType.LINEAR, colArray, alphaArray, pointArray, _matrix);
    		_shape.graphics.drawRect(0, 0, 256, 256);
    		_diffuseBitmap.draw(_shape);
        	
        	//update colortransform
        	_diffuseColorTransform = new ColorTransform(diffbright*_red, diffbright*_green, diffbright*_blue, 1, 0, 0, 0, 0);

			_diffuseDirty = false;
        }
        
        /**
         * Updates the bitmapData object used as the lightmap for the combined ambient and diffue light shading.
         * 
         * @param	ambient		The coefficient for ambient light intensity.
         * @param	diffuse		The coefficient for diffuse light intensity.
         */
        protected override function updateAmbientDiffuse():void
        {
    		_ambientDiffuseBitmap = new BitmapData(256, 256, false, 0x000000);
    		_ambientDiffuseBitmap.lock();
    		_matrix.createGradientBox(256, 256, 0, 0, 0);
    		var colArray:Array = [];
    		var alphaArray:Array = [];
    		var pointArray:Array = [];
			var i : int = 15;
    		var diffbright:Number = _diffuse*_brightness/14;
    		while (i--) {
    			var r:Number = (i*diffbright + _ambient);
    			if (r > 1) r = 1;
    			var g:Number = (i*diffbright + _ambient);
    			if (g > 1) g = 1;
    			var b:Number = (i*diffbright + _ambient);
    			if (b > 1) b = 1;
    			colArray.push((r*_red*0xFF << 16) | (g*_green*0xFF << 8) | b*_blue*0xFF);
    			alphaArray.push(1);
    			pointArray.push(int(30+225*2*Math.acos(i/14)/Math.PI));
    		}
    		_shape.graphics.clear();
    		_shape.graphics.beginGradientFill(GradientType.LINEAR, colArray, alphaArray, pointArray, _matrix);
    		_shape.graphics.drawRect(0, 0, 256, 256);
    		_ambientDiffuseBitmap.draw(_shape);

			_ambientDiffuseDirty = false;
        }
        
        /**
         * @private 
         * Updates the bitmapData object used as the lightmap for specular light shading.
         * 
         * @param	specular		The coefficient for specular light intensity.
         */
        protected override function updateSpecular():void
        {
    		_specularBitmap = new BitmapData(512, 512, false, 0x000000);
    		_specularBitmap.lock();
    		_matrix.createGradientBox(512, 512, 0, 0, 0);
    		var colArray:Array = [];
    		var alphaArray:Array = [];
    		var pointArray:Array = [];
    		var i:int = 15;
    		var specbright:Number = _specular*_brightness*0xFF/14;
    		while (i--) {
    			colArray.push((i*specbright*_red << 16) + (i*specbright*_green << 8) + i*specbright*_blue);
    			alphaArray.push(1);
    			pointArray.push(int(30+225*2*Math.acos(Math.pow(i/14,1/20))/Math.PI));
    		}
    		_shape.graphics.clear();
    		_shape.graphics.beginGradientFill(GradientType.RADIAL, colArray, alphaArray, pointArray, _matrix);
    		_shape.graphics.drawCircle(255, 255, 255);
    		_specularBitmap.draw(_shape);

			_specularDirty = false;
        }

		        
    	/**
    	 * Defines the direction of the light relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get direction():Number3D
        {
            return _direction;
        }
		
        public function set direction(value:Number3D):void
        {
            _direction.x = value.x;
            _direction.y = value.y;
            _direction.z = value.z;
            
            if (_parent)
				onSceneTransformChange();
        }
        
		/**
		 * Defines a coefficient for the ambient light intensity.
		 */
		public function get ambient():Number
		{
			return _ambient;
		}
		public function set ambient(val:Number):void
		{
			if (val < 0)
				val  = 0;
			
			_ambient = val;
			
            _ambientDirty = true;
            _ambientDiffuseDirty = true;
		}
		
		/**
		 * Defines a coefficient for the diffuse light intensity.
		 */
		public function get diffuse():Number
		{
			return _diffuse;
		}
		
		public function set diffuse(val:Number):void
		{
			if (val < 0)
				val  = 0;
			
			_diffuse = val;
			
            _diffuseDirty = true;
            _ambientDiffuseDirty = true;
		}
		
		/**
		 * Defines a coefficient for the specular light intensity.
		 */
		public function get specular():Number
		{
			return _specular;
		}
		
		public function set specular(val:Number):void
		{
			if (val < 0)
				val  = 0;
			
			_specular = val;
			
            _specularDirty = true;
		}
		
		/**
		 * Defines a coefficient for the overall light intensity.
		 */
		public function get brightness():Number
		{
			return _brightness;
		}
		
		public function set brightness(val:Number):void
		{
			_brightness = val;
            
            _ambientDirty = true;
            _diffuseDirty = true;
            _ambientDiffuseDirty = true;
            _specularDirty = true;
		}
		
		public function get sceneDirection():Number3D
		{
			return _sceneDirection;
		}
		
		/**
		 * Creates a new <code>DirectionalLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function DirectionalLight3D(init:Object = null)
        {
            super(init);
            direction = ini.getNumber3D("direction") || new Number3D();
            ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
            diffuse = ini.getNumber("diffuse", 0.5, {min:0, max:10});
            specular = ini.getNumber("specular", 1, {min:0, max:1});
            brightness = ini.getNumber("brightness", 1);
            debug = ini.getBoolean("debug", false);
        }
		
		/**
		 * Duplicates the light object's properties to another <code>DirectionalLight3D</code> object
		 * 
		 * @param	light	[optional]	The new light instance into which all properties are copied
		 * @return						The new light instance with duplicated properties applied
		 */
        public override function clone(light:AbstractLight = null):AbstractLight
        {
            var directionalLight3D:DirectionalLight3D = (light as DirectionalLight3D) || new DirectionalLight3D();
            super.clone(directionalLight3D);
            directionalLight3D.brightness = brightness;
            directionalLight3D.ambient = ambient;
            directionalLight3D.diffuse = diffuse;
            directionalLight3D.specular = specular;
            return directionalLight3D;
        }

    }
}
