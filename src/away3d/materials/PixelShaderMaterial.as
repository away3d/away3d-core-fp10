package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.UV;
	import away3d.core.math.MatrixAway3D;
	import away3d.core.math.Number3D;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	use namespace arcane;
	
	/**
	 * The base class for Pixel Bender pixel shader (or rather Texel shader) materials
	 */
	internal class PixelShaderMaterial extends TransformBitmapMaterial
	{	
		/** @private */
        arcane override function updateMaterial(source:Object3D, view:View3D):void
		{
			updatePixelShader(source, view);
			_bitmapDirty = true;
			super.updateMaterial(source, view);
		}
		
		protected var _mesh : Mesh;
		protected var _positionMap : BitmapData;
		protected var _normalMap : BitmapData;
		
		protected var _useWorldCoords : Boolean = false;
		
		protected var _pointLightShader : Shader;
		
		[Embed(source="../pbks/PositionInterpolator.pbj", mimeType="application/octet-stream")]
		private var PositionInterpolator : Class;
		
		private var _posMtx : MatrixAway3D = new MatrixAway3D();		
		
		private var _positionMapMatrix : MatrixAway3D;
		private var _normalMapMatrix : MatrixAway3D;
		
		/**
		 * Creates a new PixelShaderMaterial object.
		 * 
		 * Requirements for the pixel shader kernel:
		 * 	- diffuse input image
		 *	- normalMap input image
		 *  - positionMap input image
		 *  - float4x4 positionTransformation
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param pixelShader The shader to be used to update the renderBitmapData
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 * 
		 */
		public function PixelShaderMaterial(bitmap:BitmapData, normalMap : BitmapData, pixelShader : Shader, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, init);
			_mesh = targetModel;
			_pointLightShader = pixelShader;
			_normalMap = normalMap;
			createPositionMap();
			
			_pointLightShader.data.normalMap.input = _normalMap;
			_pointLightShader.data.positionMap.input = _positionMap;
		}
		
		/**
		 * A map generated specifically for the target model which keeps the object-space coordinates for every texel 
		 */
		public function get positionMap() : BitmapData
		{
			return _positionMap;
		}
		
		/**
		 * An object-space normal map
		 */
		public function get normalMap() : BitmapData
		{
			return _normalMap;
		}
		
		public function set normalMap(value : BitmapData) : void
		{
			_normalMap = value;
			_pointLightShader.data.normalMap.input = _normalMap;
		}
		
		private function createPositionMap() : void
		{
			var faces : Array = _mesh.geometry.faces;
			var face : Face;
			var i : int = faces.length;
			var min : Number3D = new Number3D(_mesh.minX, _mesh.minY, _mesh.minZ);
			var max : Number3D = new Number3D(_mesh.maxX, _mesh.maxY, _mesh.maxZ);
			var diffExtr : Number3D = new Number3D();
			var v0 : Number3D = new Number3D();
			var v1 : Number3D = new Number3D();
			var v2 : Number3D = new Number3D();
			var uv0 : UV = new UV();
			var uv1 : UV = new UV();
			var uv2 : UV = new UV();
			var u01 : Number, v01 : Number; 
			var u02 : Number, v02 : Number;
			var w : Number = bitmap.width;
			var h : Number = bitmap.height;
			var shader : Shader = new Shader(new PositionInterpolator());
			var container : Sprite = new Sprite();
			diffExtr.sub(max, min);
			
			_positionMapMatrix = new MatrixAway3D();
			_positionMapMatrix.sxx = diffExtr.x;
			_positionMapMatrix.syy = diffExtr.y;
			_positionMapMatrix.szz = diffExtr.z;
			_positionMapMatrix.tx = min.x;
			_positionMapMatrix.ty = min.y;
			_positionMapMatrix.tz = min.z;
			_pointLightShader.data.positionTransformation.value = [ _positionMapMatrix.sxx, 0, 0, 0,
															 		0, _positionMapMatrix.syy, 0, 0,
														 			0, 0, _positionMapMatrix.szz, 0,
														 			_positionMapMatrix.tx, _positionMapMatrix.ty, _positionMapMatrix.tz, 1
																	];
			diffExtr.x = 1/diffExtr.x;
			diffExtr.y = 1/diffExtr.y;
			diffExtr.z = 1/diffExtr.z;
			container = new Sprite();
			_positionMap = new BitmapData(w, h, false, 0);
			
			
			while (face = Face(faces[--i])) {
				uv0.u = face.uv0.u*w;
				uv0.v = (1-face.uv0.v)*h;
				uv1.u = face.uv1.u*w;
				uv1.v = (1-face.uv1.v)*h;
				uv2.u = face.uv2.u*w;
				uv2.v = (1-face.uv2.v)*h;
				u01 = uv1.u-uv0.u;
				v01 = uv1.v-uv0.v;
				u02 = uv2.u-uv0.u;
				v02 = uv2.v-uv0.v;
				
				v0.sub(face.v0.position, min);
				v1.sub(face.v1.position, min);
				v2.sub(face.v2.position, min);
				v0.x *= diffExtr.x;
				v0.y *= diffExtr.y;
				v0.z *= diffExtr.z;
				v1.x *= diffExtr.x;
				v1.y *= diffExtr.y;
				v1.z *= diffExtr.z;
				v2.x *= diffExtr.x;
				v2.y *= diffExtr.y;
				v2.z *= diffExtr.z;
				
				shader.data.uv0.value = [ uv0.u, uv0.v ];
				shader.data.uvEdge1.value = [ u01, v01 ];
				shader.data.uvEdge2.value = [ u02, v02 ];
				shader.data.dot00.value = [ u01*u01+v01*v01 ];
				shader.data.dot01.value = [ u01*u02+v01*v02 ];
				shader.data.dot11.value = [ u02*u02+v02*v02 ];
				shader.data.pos0.value = [ v0.x, v0.y, v0.z ];
				shader.data.posEdge1.value = [ v1.x - v0.x, v1.y - v0.y, v1.z - v0.z ];
				shader.data.posEdge2.value = [ v2.x - v0.x, v2.y - v0.y, v2.z - v0.z ];
				
				container.graphics.beginShaderFill(shader);
				container.graphics.moveTo(uv0.u, uv0.v);
				container.graphics.lineTo(uv1.u, uv1.v);
				container.graphics.lineTo(uv2.u, uv2.v);
				container.graphics.endFill();
			}
			
			_positionMap.draw(container, null, null, null, null, true);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateRenderBitmap():void
		{
			if (_colorTransform) {
				if (!_bitmap.transparent && _alpha != 1) {
	                _renderBitmap = new BitmapData(_bitmap.width, _bitmap.height, true);
	                _renderBitmap.draw(_bitmap);
	         	}
	            else _renderBitmap = _bitmap.clone();
	            
				_renderBitmap.colorTransform(_renderBitmap.rect, _colorTransform);
	        }
	        else
	        	_renderBitmap = _bitmap.clone();
		}
		
		/**
		 * Updates the pixel bender shader
		 */
		protected function updatePixelShader(source:Object3D, view : View3D) : void
		{
			if (_useWorldCoords) {
				 if (!_normalMapMatrix) _normalMapMatrix = new MatrixAway3D();
				_normalMapMatrix.inverse(_mesh.sceneTransform);
				
				_posMtx.multiply(_mesh.sceneTransform, _positionMapMatrix);

				// the transpose of the inverse 
				_pointLightShader.data.normalTransformation.value = [ 	_normalMapMatrix.sxx, _normalMapMatrix.sxy, _normalMapMatrix.sxz,
																		_normalMapMatrix.syx, _normalMapMatrix.syy, _normalMapMatrix.syz,
																		_normalMapMatrix.szx, _normalMapMatrix.szy, _normalMapMatrix.szz
																	];
				
				_pointLightShader.data.positionTransformation.value = [ 	_posMtx.sxx, _posMtx.syx, _posMtx.szx, 0,
															 				_posMtx.sxy, _posMtx.syy, _posMtx.szy, 0,
															 				_posMtx.sxz, _posMtx.syz, _posMtx.szz, 0,
															 				_posMtx.tx, _posMtx.ty, _posMtx.tz, 1
																		];
			}
		}
	}
}