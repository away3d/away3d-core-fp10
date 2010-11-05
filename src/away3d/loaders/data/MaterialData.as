package away3d.loaders.data
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.materials.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
	/**
	 * Data class for the material data of a face.
	 * 
	 * @see away3d.loaders.data.FaceData
	 */
	public class MaterialData
	{
		private var _material:Material;
		
		/**
		 * String representing a texture material.
		 */
		public static const TEXTURE_MATERIAL:String = "textureMaterial";
		
		/**
		 * String representing a shaded material.
		 */
		public static const SHADING_MATERIAL:String = "shadingMaterial";
		
		/**
		 * String representing a color material.
		 */
		public static const COLOR_MATERIAL:String = "colorMaterial";
		
		/**
		 * String representing a wireframe material.
		 */
		public static const WIREFRAME_MATERIAL:String = "wireframeMaterial";
		
		/**
		 * The name of the material used as a unique reference.
		 */
		public var name:String;
		
		/**
		 * Optional ambient color of the material.
		 */
		public var ambientColor:uint;
		
		/**
		 * Optional diffuse color of the material.
		 */
		public var diffuseColor:uint;
		
		/**
		 * Optional specular color of the material.
		 */
		public var specularColor:uint;
		
		/**
		 * Optional shininess of the material.
		 */
		public var shininess:Number;
		
		/**
		 * Reference to the filename of the texture image.
		 */
		public var textureFileName:String;
		
		public var meshMaterials:Vector.<MeshMaterialData> = new Vector.<MeshMaterialData>();
		
		/**
		 * Reference to the bitmapData object of the texture image.
		 */
		public var textureBitmap:BitmapData;
        
		/**
		 * defines the material object of the resulting material.
		 */
		public function get material():Material
        {
        	return _material;
        }
		
		public function set material(val:Material):void
        {
        	if (_material == val)
                return;
            
            _material = val;
			_material._materialData = this;
			
            if (_material is BitmapMaterial)
            	textureBitmap = (_material as BitmapMaterial).bitmap;
            
            var _meshMaterialData:MeshMaterialData;
        	for each (_meshMaterialData in meshMaterials)
        		_meshMaterialData.material = _material;
        }
        		
		/**
		 * String representing the material type.
		 */
		public var materialType:String = WIREFRAME_MATERIAL;
        
		public function clone(targetObj:Object3D):MaterialData
		{
			var cloneMatData:MaterialData = targetObj.materialLibrary.addMaterial(name);
			
    		cloneMatData.materialType = materialType;
    		cloneMatData.ambientColor = ambientColor;
    		cloneMatData.diffuseColor = diffuseColor;
    		cloneMatData.shininess = shininess;
    		cloneMatData.specularColor = specularColor;
    		cloneMatData.textureBitmap = textureBitmap;
    		cloneMatData.textureFileName = textureFileName;
    		cloneMatData.material = material;
    		
    		for each(var _meshMaterialData:MeshMaterialData in meshMaterials)
    		{
				cloneMatData.meshMaterials.push(_meshMaterialData.clone());
    		}
    		
    		return cloneMatData;
		}
	}
}