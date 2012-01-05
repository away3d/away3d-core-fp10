﻿package away3d.containers
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.session.*;
	import away3d.core.traverse.*;
	import away3d.lights.*;
	
	import flash.utils.*;
    
	use namespace arcane;
	
    /**
    * The root container of all 3d objects in a single scene
    */
    public class Scene3D extends ObjectContainer3D
    {
    	/** @private */
        arcane function setId(object:Object3D):void
		{
			var i:int = 0;
			
			while(_objects.length > i && _objects[i])
				i++;
			
			_objects[i] = object;
			
			object._id = i;
		}
		/** @private */
        arcane function clearId(id:int):void
		{
			delete _objects[id];
		}
     	/** @private */
        arcane function internalRemoveLight(light:AbstractLight):void
        {
        	var index:int;
        	
        	if (light is AmbientLight3D) {
        		index = _ambientLights.indexOf(light);
	            if (index == -1)
	                return;
        		_ambientLights.splice(index, 1);
        	} else if (light is DirectionalLight3D) {
        		index = _directionalLights.indexOf(light);
	            if (index == -1)
	                return;
        		_directionalLights.splice(index, 1);
        	} else if (light is PointLight3D) {
        		index = _pointLights.indexOf(light);
	            if (index == -1)
	                return;
        		_pointLights.splice(index, 1);
        	}
        	
        	_numLights--;
        }
		/** @private */
        arcane function internalAddLight(light:AbstractLight):void
        {
        	if (light is AmbientLight3D)
        		_ambientLights.push(light as AmbientLight3D);
        	else if (light is DirectionalLight3D)
        		_directionalLights.push(light as DirectionalLight3D);
        	else if (light is PointLight3D)
        		_pointLights.push(light as PointLight3D); 
        		
        	_numLights++;
        }
        /** @private */
        arcane function flagObject(object:Object3D):void
        {
			for each (_view in viewDictionary)
				_view._updatedObjects[object] = true;
        }
        /** @private */
        arcane function flagSession(session:AbstractSession):void
        {
        	for each (_view in viewDictionary)
				_view._updatedSessions[session] = true;
        }
        
        private var _ambientLights:Vector.<AmbientLight3D> = new Vector.<AmbientLight3D>();
        private var _directionalLights:Vector.<DirectionalLight3D> = new Vector.<DirectionalLight3D>();
        private var _pointLights:Vector.<PointLight3D> = new Vector.<PointLight3D>();
        private var _numLights:uint;
    	private var _objects:Vector.<Object3D> = new Vector.<Object3D>();
        private var _view:View3D;
        
        public var viewDictionary:Dictionary = new Dictionary(true);
        
		/**
		 * Traverser object for all custom <code>tick()</code> methods
		 * 
		 * @see away3d.core.base.Object3D#tick()
		 */
        public var tickTraverser:TickTraverser = new TickTraverser();
                
        /**
        * Defines whether scene events are automatically triggered by the view, or manually by <code>updateScene()</code>
        */
		public var autoUpdate:Boolean;
		
    	/**
    	 * Interface for physics (not implemented)
    	 */
        public var physics:IPhysicsScene;
        
        public function get ambientLights():Vector.<AmbientLight3D>
        {
			return _ambientLights;
        }
        
        public function get directionalLights():Vector.<DirectionalLight3D>
        {
			return _directionalLights;
        }
        
        public function get pointLights():Vector.<PointLight3D>
        {
			return _pointLights;
        }
        
        public function get numLights():uint
        {
			return _numLights;
        }
    	
		/**
		 * Creates a new <code>Scene3D</code> object
		 * 
	    * @param	...initarray		An array of 3d objects to be added as children of the scene on instatiation. Can contain an initialisation object
		 */
        public function Scene3D(...initarray)
        {
            var init:Object;
            var childarray:Vector.<Object3D> = new Vector.<Object3D>();
            
            for each (var object:Object in initarray)
            	if (object is Object3D)
            		childarray.push(object as Object3D);
            	else
            		init = object;
			
			//force ownCanvas and ownLights
			if (init)
				init["ownCanvas"] = true;
			else
				init = {ownCanvas:true};
            
            super(init);
			
			autoUpdate = ini.getBoolean("autoUpdate", true);
			
            var ph:Object = ini.getObject("physics");
            if (ph is IPhysicsScene)
                physics = ph as IPhysicsScene;
            if (ph is Boolean)
                if (ph == true)
                    physics = null; // new RobPhysicsEngine();
            if (ph is Object)
                physics = null; // new RobPhysicsEngine(ph); // ph - init object
                
            for each (var child:Object3D in childarray)
                addChild(child);
        }
		
		/**
		 * Calling manually will update 3d objects that execute updates on their <code>tick()</code> methods.
		 * Uses the <code>TickTraverser</code> to traverse all tick methods in the scene.
		 * 
		 * @see	away3d.core.base.Object3D#tick()
		 * @see	away3d.core.traverse.TickTraverser
		 */
        public function updateTime(time:int = -1):void
        {
        	//set current time
            if (time == -1)
                time = getTimer();
            
            //traverser scene ticks
            tickTraverser.now = time;
            traverse(tickTraverser);
            
            
            if (physics != null)
                physics.updateTime(time);
        }
    }
}
