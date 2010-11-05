package away3d.containers
{
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.traverse.*;
    import away3d.events.*;
	import away3d.lights.*;
    import away3d.loaders.data.*;
    import away3d.loaders.utils.*;
    
    import flash.geom.*;
    
    use namespace arcane;
    
    /**
    * 3d object container node for other 3d objects in a scene
    */
    public class ObjectContainer3D extends Mesh
    {
		/** @private */
        arcane function internalAddChild(child:Object3D):void
        {
            _children.push(child);
			
			child.addOnVisibilityUpdate(onSessionUpdate);
			child.addOnSceneTransformChange(onSessionUpdate);
            child.addOnPositionChange(onDimensionsChange);
            child.addOnScaleChange(onDimensionsChange);
            child.addOnDimensionsChange(onDimensionsChange);

            notifyDimensionsChange();
            
            if (_session)	
        		session.updateSession();
        }
		/** @private */
        arcane function internalRemoveChild(child:Object3D):void
        {
            var index:int = children.indexOf(child);
            if (index == -1)
                return;
			
			child.removeOnVisibilityUpdate(onSessionUpdate);
			child.removeOnSceneTransformChange(onSessionUpdate);
            child.removeOnPositionChange(onDimensionsChange);
            child.removeOnScaleChange(onDimensionsChange);
            child.removeOnDimensionsChange(onDimensionsChange);
			
            _children.splice(index, 1);

            notifyDimensionsChange();
            
            if (_session)	
        		_session.updateSession();
        }
		/** @private */
        arcane function incrementPolyCount(delta:int):void
        {
        	_polyCount += delta;
        	
        	if(this.parent)
        		parent.incrementPolyCount(delta);
        }
        
        private var _children:Vector.<Object3D> = new Vector.<Object3D>();
        private var _polyCount:int;
        
        private function getMaxChild(prop:String):Number
		{
			var child:Object3D;
			var maxVal:Number = -Infinity;
			for each (child in _children)
				if (maxVal < child[prop])
					maxVal = child[prop];
			
			return maxVal;
		}
		
		private function getMinChild(prop:String):Number
		{
			var child:Object3D;
			var minVal:Number = Infinity;
			for each (child in _children)
				if (minVal > child[prop])
					minVal = child[prop];
			
			return minVal;
		}
		
        private function onSessionUpdate(event:Object3DEvent):void
        {
			if (event.object.ownCanvas && _session)
        		_session.updateSession();
        }
        
        private function onDimensionsChange(event:Object3DEvent):void
        {
            notifyDimensionsChange();
        }
        
        private function updatePolyCount(child:Object3D, add:Boolean = true):void
        {
        	var k:int = add ? 1 : -1;
        	var deltaPoly:int;
        	
        	if(child is Mesh)
        		deltaPoly = k*Mesh(child).elements.length;
        	else if(child is ObjectContainer3D)
        		deltaPoly = k*ObjectContainer3D(child).polyCount;
        	
        	incrementPolyCount(deltaPoly);
        }
        
        protected override function updateDimensions():void
        {
        	//update bounding radius
        	var children:Vector.<Object3D> = _children.concat();
        	
        	if (children.length) {
	        	
	        	if (_scaleX < 0)
	        		_boundingScale = -_scaleX;
	        	else
	        		_boundingScale = _scaleX;
            	
            	if (_scaleY < 0 && _boundingScale < -_scaleY)
            		_boundingScale = -_scaleY;
            	else if (_boundingScale < _scaleY)
            		_boundingScale = _scaleY;
            	
            	if (_scaleZ < 0 && _boundingScale < -_scaleZ)
            		_boundingScale = -_scaleZ;
            	else if (_boundingScale < _scaleZ)
            		_boundingScale = _scaleZ;
            	
	        	var mradius:Number = 0;
	        	var cradius:Number;
	            var num:Vector3D;
	            for each (var child:Object3D in children) {
	            	num = child.position.subtract(_pivotPoint);
	            	
	                cradius = num.length + child.parentBoundingRadius;
	                if (mradius < cradius)
	                    mradius = cradius;
	            }
	            
	            _boundingRadius = mradius;
	            
	            //update max/min X
	            _maxX = getMaxChild("parentMaxX");
	            _minX = getMinChild("parentMinX");
	            
	            //update max/min Y
	            _maxY = getMaxChild("parentMaxY");
	            _minY = getMinChild("parentMinY");
	            
	            //update max/min Z
	            _maxZ = getMaxChild("parentMaxZ");
	            _minZ = getMinChild("parentMinZ");
         	}
         	
            super.updateDimensions();
        }
        
        /**
        * Returns the children of the container as an array of 3d objects
        */
        public function get children():Vector.<Object3D>
        {
            return _children;
        }
                        
        /**
         * Returns the number of elements in the container,
         * including elements in child nodes.
         * Elements can be faces, segments or 3d sprites.
         * @return int
         */        
        public function get polyCount():int
        {
        	return _polyCount;
        }
        
    	
	    /**
	    * Creates a new <code>ObjectContainer3D</code> object
	    * 
	    * @param	...initarray		An array of 3d objects to be added as children of the container on instatiation. Can contain an initialisation object
	    */
        public function ObjectContainer3D(...initarray:Array)
        {
        	var init:Object;
        	var childarray:Vector.<Object3D> = new Vector.<Object3D>();
        	
            for each (var object:Object in initarray)
            	if (object is Object3D)
            		childarray.push(object as Object3D);
            	else
            		init = object;
            
            super(init);
            
            for each (var child:Object3D in childarray)
                addChild(child);
        }
        
		/**
		 * Adds an array of 3d objects to the scene as children of the container
		 * 
		 * @param	...childarray		An array of 3d objects to be added
		 */
        public function addChildren(...childarray):void
        {
            for each (var child:Object3D in childarray)
                addChild(child);
        }
        
		/**
		 * Adds a 3d object to the scene as a child of the container
		 * 
		 * @param	child	The 3d object to be added
		 * @throws	Error	ObjectContainer3D.addChild(null)
		 */
        public function addChild(child:Object3D):void
        {
            if (child == null)
                throw new Error("ObjectContainer3D.addChild(null)");
            
            updatePolyCount(child);
            
            child.parent = this;
        }
        
		/**
		 * Removes a 3d object from the child array of the container
		 * 
		 * @param	child	The 3d object to be removed
		 * @throws	Error	ObjectContainer3D.removeChild(null)
		 */
        public function removeChild(child:Object3D):void
        {
            if (child == null)
                throw new Error("ObjectContainer3D.removeChild(null)");
            if (child.parent != this)
                return;
            updatePolyCount(child, false);
            child.parent = null;
        }
        
		/**
		 * Adds a light as a child of the container
		 * 
		 * @param	light	The light object to be added
		 * @throws	Error	ObjectContainer3D.addLight(null)
		 */
        public function addLight(light:AbstractLight):void
        {
            if (light == null)
                throw new Error("ObjectContainer3D.addLight(null)");
            
            light.parent = this;
        }
        
		/**
		 * Removes a light from the container
		 * 
		 * @param	child	The light object to be removed
		 * @throws	Error	ObjectContainer3D.removeLight(null)
		 */
        public function removeLight(light:AbstractLight):void
        {
            if (light == null)
                throw new Error("ObjectContainer3D.removeLight(null)");
            
            if (light.parent != this)
                return;
            
            light.parent = null;
        }
        
		/**
		 * Returns a 3d object specified by name from the child array of the container
		 * 
		 * @param	name	The name of the 3d object to be returned
		 * @return			The 3d object, or <code>null</code> if no such child object exists with the specified name
		 */
        public function getChildByName(childName:String):Object3D
        {	
			var child:Object3D;
            for each(var object3D:Object3D in children) {
            	if (object3D.name)
					if (object3D.name == childName)
						return object3D;
				
            	if (object3D is ObjectContainer3D) {
	                child = (object3D as ObjectContainer3D).getChildByName(childName);
	                if (child)
	                    return child;
	            }
            }
			
            return null;
        }
        
		/**
		 * Returns a bone object specified by name from the child array of the container
		 * 
		 * @param	name	The name of the bone object to be returned
		 * @return			The bone object, or <code>null</code> if no such bone object exists with the specified name
		 */
        public function getBoneByName(boneName:String):Bone
        {	
			var bone:Bone;
            for each(var object3D:Object3D in children) {
            	if (object3D is Bone) {
            		bone = object3D as Bone;
            		
	            	if (bone.name)
						if (bone.name == boneName)
							return bone;
					
					if (bone.boneId)
						if (bone.boneId == boneName)
							return bone;
            	}
            	if (object3D is ObjectContainer3D) {
	                bone = (object3D as ObjectContainer3D).getBoneByName(boneName);
	                if (bone)
	                    return bone;
	            }
            }
			
            return null;
        }
        
		/**
		 * Removes a 3d object from the child array of the container
		 * 
		 * @param	name	The name of the 3d object to be removed
		 */
        public function removeChildByName(name:String):void
        {
            removeChild(getChildByName(name));
        }
        
		/**
		 * @inheritDoc
		 */
        public override function traverse(traverser:Traverser):void
        {
            if (traverser.match(this))
            {
                traverser.enter(this);
                traverser.apply(this);
                for each (var child:Object3D in children)
                    child.traverse(traverser);
                traverser.leave(this);
            }
        }
        
		/**
		 * Adjusts each pivot point of the container object's children so that they lies at the center of each childs geoemtry.
		 */
		public function centerMeshes():void
        {
        	for each (var child:Object3D in children)
            	child.centerPivot();
        }
        
		/**
		 * @inheritDoc
		 */
		public override function centerPivot():void
        {
        	for each (var child:Object3D in children)
            	child.centerPivot();
            
            super.centerPivot();
        }
        
		/**
 		* Apply the local rotations to child objects without altering the appearance of the object container
 		*/
		public override function applyRotations():void
		{
			var x:Number;
			var y:Number;
			var z:Number;
			var x1:Number;
			var y1:Number;
			//var z1:Number;
			
			var rad:Number = Math.PI / 180;
			var rotx:Number = rotationX * rad;
			var roty:Number = rotationY * rad;
			var rotz:Number = rotationZ * rad;
			var sinx:Number = Math.sin(rotx);
			var cosx:Number = Math.cos(rotx);
			var siny:Number = Math.sin(roty);
			var cosy:Number = Math.cos(roty);
			var sinz:Number = Math.sin(rotz);
			var cosz:Number = Math.cos(rotz);

			for each (var child:Object3D in children) {
				 
				x = child.x;
				y = child.y;
				z = child.z;

				y1 = y;
				y = y1*cosx+z*-sinx;
				z = y1*sinx+z*cosx;
				
				x1 = x;
				x = x1*cosy+z*siny;
				z = x1*-siny+z*cosy;
			
				x1 = x;
				x = x1*cosz+y*-sinz;
				y = x1*sinz+y*cosz;
 				
 				child.moveTo(x, y, z);
			}
			
            rotationX = 0;
            rotationY = 0;
            rotationZ = 0;
		}
		
		/**
 		* Apply the given position to child objects without altering the appearance of the object container
 		*/
		public override function applyPosition(dx:Number, dy:Number, dz:Number):void
		{
			var x:Number;
			var y:Number;
			var z:Number;
			
			for each (var child:Object3D in children) {
				x = child.x;
				y = child.y;
				z = child.z;
				child.moveTo(x - dx, y - dy, z - dz);
			}
			
			var dV:Vector3D = new Vector3D(dx, dy, dz);
            dV = _transform.deltaTransformVector(dV);
            dV = dV.add(position);
            moveTo(dV.x, dV.y, dV.z);  
		}
		
		/**
		 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(object:Object3D = null):Object3D
        {
            var container:ObjectContainer3D = (object as ObjectContainer3D) || new ObjectContainer3D();
            super.clone(container);
			
			var child:Object3D;
            for each (child in children)
            	if (!(child is Bone))
                	container.addChild(child.clone());
                
            return container;
        }
		
		/**
		 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object, including bones and geometry
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function cloneAll(object:Object3D = null):Object3D
        {
            var container:ObjectContainer3D = (object as ObjectContainer3D) || new ObjectContainer3D();
            super.clone(container);
			
			var _child:ObjectContainer3D;
            for each (var child:Object3D in children) {
            	if (child is Bone) {
            		_child = new Bone();
                	container.addChild(_child);
                	(child as Bone).cloneAll(_child);
            	} else if (child is ObjectContainer3D) {
            		_child = new ObjectContainer3D();
                	container.addChild(_child);
                	(child as ObjectContainer3D).cloneAll(_child);
            	} else if (child is Mesh) {
                	container.addChild((child as Mesh).cloneAll());
            	} else {
                	container.addChild(child.clone());
             	}
            }
            
            if (animationLibrary) {
        		container.animationLibrary = new AnimationLibrary();
            	for each (var _animationData:AnimationData in animationLibrary) 
            		_animationData.clone(container);
            }
            
            if (materialLibrary) {
        		container.materialLibrary = new MaterialLibrary();
            	for each (var _materialData:MaterialData in materialLibrary)
            	{
            		_materialData.clone(container);
            	}
            }
            
            //find existing root
            var root:ObjectContainer3D = container;
            
            while (root.parent)
            	root = root.parent;
            
        	if (container == root)
        		cloneBones(container, root);
        	
            return container;
        }
        
        private function cloneBones(container:ObjectContainer3D, root:ObjectContainer3D):void
        {
        	//wire up new bones to new skincontrollers if available
        	var _container_children:Vector.<Object3D> = container.children;
            for each (var child:Object3D in _container_children) {
            	if (child is ObjectContainer3D) {
            		(child as ObjectContainer3D).cloneBones(child as ObjectContainer3D, root);
             	} else if (child is Mesh) {
             		/*
                	var geometry:Geometry = (child as Mesh).geometry;
                	var skinControllers:Array = geometry.skinControllers;
                	var rootBone:Bone;
                	var skinController:SkinController;
                	
					for each (skinController in skinControllers) {
						var bone:Bone = root.getBoneByName(skinController.name);
		                if (bone) {
		                    skinController.joint = bone.joint;
		                    
		                    if (!(bone.parent.parent is Bone))
		                    	rootBone = bone;
		                } else
		                	Debug.warning("no joint found for " + skinController.name);
		            }
		            //geometry.rootBone = rootBone;
		            
		            for each (skinController in skinControllers) {
		            	//skinController.inverseTransform = new Matrix3D();
		            	skinController.inverseTransform = child.parent.inverseSceneTransform;
		            }
		            */
				}
            }
		}	
    }
}
