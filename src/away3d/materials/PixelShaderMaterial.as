package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	
	import flash.display.*;
	import flash.geom.*;
	
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
		
		private var _posMtx : Matrix3D = new Matrix3D();		
		
		private var _positionMapMatrix : Matrix3D;
		private var _normalMapMatrix : Matrix3D = new Matrix3D();
		
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
			var faces : Vector.<Face> = _mesh.geometry.faces;
			var face : Face;
			var i : uint = faces.length;
			var min : Vector3D = new Vector3D(_mesh.minX, _mesh.minY, _mesh.minZ);
			var max : Vector3D = new Vector3D(_mesh.maxX, _mesh.maxY, _mesh.maxZ);
			var diffExtr : Vector3D;
			var v0 : Vector3D = new Vector3D();
			var v1 : Vector3D = new Vector3D();
			var v2 : Vector3D = new Vector3D();
			var uv0 : UV = new UV();
			var uv1 : UV = new UV();
			var uv2 : UV = new UV();
			var u01 : Number, v01 : Number; 
			var u02 : Number, v02 : Number;
			var w : Number = bitmap.width;
			var h : Number = bitmap.height;
			var shader : Shader = new Shader(new PositionInterpolator());
			var container : Sprite = new Sprite();
			diffExtr = max.subtract(min);
			
			_positionMapMatrix = new Matrix3D(Vector.<Number>([diffExtr.x, 0, 0, 0, 0, diffExtr.y, 0, 0, 0, 0, diffExtr.z, 0, min.x, min.y, min.z, 1]));
			_pointLightShader.data.positionTransformation.value = [ _positionMapMatrix.rawData[0], 0, 0, 0,
															 		0, _positionMapMatrix.rawData[5], 0, 0,
														 			0, 0, _positionMapMatrix.rawData[10], 0,
														 			_positionMapMatrix.rawData[12], _positionMapMatrix.rawData[13], _positionMapMatrix.rawData[14], 1
																	];
			diffExtr.x = 1/diffExtr.x;
			diffExtr.y = 1/diffExtr.y;
			diffExtr.z = 1/diffExtr.z;
			container = new Sprite();
			_positionMap = new BitmapData(w, h, false, 0);
			
			
			while (i--) {
				face = faces[i];
				uv0.u = face.uv0.u*w;
				uv0.v = (1-face.uv0.v)*h;
				uv1.u = face.uv1.u*w;
				uv1.v = (1-face.uv1.v)*h;
				uv2.u = face.uv2.u*w;
				uv2.v = (1-face.uv2.v)*h;
				u01 = uv1.u - uv0.u;
				v01 = uv1.v - uv0.v;
				u02 = uv2.u - uv0.u;
				v02 = uv2.v - uv0.v;
				
				v0 = face.v0.position.subtract(min);
				v1 = face.v1.position.subtract(min);
				v2 = face.v2.position.subtract(min);
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
				 _normalMapMatrix.rawData = _mesh.sceneTransform.rawData;
				_normalMapMatrix.invert();
				
				_posMtx.rawData = _mesh.sceneTransform.rawData;
				_posMtx.prepend(_positionMapMatrix);
				
				// the transpose of the inverse 
				_pointLightShader.data.normalTransformation.value = [ 	_normalMapMatrix.rawData[0], _normalMapMatrix.rawData[1], _normalMapMatrix.rawData[2],
																		_normalMapMatrix.rawData[4], _normalMapMatrix.rawData[5], _normalMapMatrix.rawData[6],
																		_normalMapMatrix.rawData[8], _normalMapMatrix.rawData[9], _normalMapMatrix.rawData[10]
																	];
				
				_pointLightShader.data.positionTransformation.value = [ 	_posMtx.rawData[0], _posMtx.rawData[1], _posMtx.rawData[2], 0,
															 				_posMtx.rawData[4], _posMtx.rawData[5], _posMtx.rawData[6], 0,
															 				_posMtx.rawData[8], _posMtx.rawData[9], _posMtx.rawData[10], 0,
															 				_posMtx.rawData[12], _posMtx.rawData[13], _posMtx.rawData[14], 1
																		];
			}
		}
	}
}