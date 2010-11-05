package away3d.loaders.data
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.events.*;
	import away3d.materials.*;
	
	use namespace arcane;
	
	/**
	 * Data class for teh material of a 3d object
	 */
	public class MeshMaterialData
	{
		private var _material:Material;
        
		private function onMaterialUpdate(event:MaterialEvent):void
		{
			if (geometry)
				geometry.onMaterialUpdate(event);
		}
		
        public var geometry:Geometry;
        
		/**
		 * The name of the material used as a unique reference for the mesh.
		 */
		public var symbol:String;
		
		/**
		* A list of faces which are to be drawn with the material.
		*/		
		public var faceList:Vector.<uint> = new Vector.<uint>();
		
		
		/**
		 * Array of indexes representing the elements that use the material.
		 */
		public var elements:Vector.<Element> = new Vector.<Element>();
		
        public function get material():Material
        {
        	return _material;
        }
        
        public function set material(val:Material):void
        {
        	if (val == _material)
        		return;
        	
        	if (_material)
        		_material.removeOnMaterialUpdate(onMaterialUpdate);
        	
        	_material = val;
        	
        	if (_material)
        		_material.addOnMaterialUpdate(onMaterialUpdate);
        	
        	var i:uint =elements.length;
        	while (i--) {
        		elements[i].material = _material as Material;		
        	}
        }
        
        public function clone():MeshMaterialData
		{
			var cloneMeshMatData:MeshMaterialData = new MeshMaterialData();
			
    		for each(var element:Element in elements)
    		{
    			var parentGeometry:Geometry = element.parent;
    			var correspondingElement:Element = parentGeometry.cloneElementDictionary[element];
    			cloneMeshMatData.elements.push(correspondingElement);
    		}
    		
    		return cloneMeshMatData;
		}
	}
}