package away3d.materials 
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.loaders.data.*;
	import away3d.events.*;

	import flash.events.*;
	
	use namespace arcane;
	    
	/**
	 * Dispatched when the any visual aspect of the material changes.
	 * 
	 * @eventType away3d.events.MaterialEvent
	 */
	[Event(name="materialUpdated",type="away3d.events.MaterialEvent")]
	
	/**
	 * Base class for all materials
	 */
	public class Material extends EventDispatcher
	{
		arcane var _materialData:MaterialData;
		
		/** @private */
        arcane var _id:int;
        /** @private */
        arcane function updateMaterial(source:Object3D, view:View3D):void
        {
        	throw new Error("Not implemented");
        }
        /** @private */
        arcane function renderSegment(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void
        {
        	throw new Error("Not implemented");
        }
        /** @private */
        arcane function renderTriangle(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void
        {
        	throw new Error("Not implemented");
        }
        /** @private */
        arcane function renderSprite(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void
        {
        	throw new Error("Not implemented");
        }
		/**
    	 * Indicates whether the material is visible
    	 */
        public function get visible():Boolean
        {
        	return true;
        }
		
		function Material()
		{
			_materialData = new MaterialData();
		}
		/**
    	 * Unique identifier
    	 */
        public function get id():int
        {
        	return _id;
        }
        
		/**
		 * Duplicates the material properties to another material object.  Usage: existingMaterial = materialToClone.clone( existingMaterial ) as Material;
		 * 
		 * @param	object	[optional]	The new material instance into which all properties are copied. The default is <code>Material</code>.
		 * @return						The new material instance with duplicated properties applied.
		 */
        public function clone(material:Material = null):Material
        {
        	var mat:Material = material || new Material();
        	
        	return mat;
        }
		
		/**
		 * Default method for adding a materialupdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMaterialUpdate(listener:Function):void
        {
        	addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
        }
        
		/**
		 * Default method for removing a materialupdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMaterialUpdate(listener:Function):void
        {
        	removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
        }
	}
}
