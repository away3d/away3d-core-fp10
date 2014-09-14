﻿package away3d.containers
{
	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.project.*;
	import away3d.core.render.*;
	import away3d.core.session.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	import away3d.core.utils.*;
	import away3d.core.vos.*;
	import away3d.events.*;
	import away3d.materials.*;
	import away3d.overlays.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	use namespace arcane;
	
	 /**
	 * Dispatched when a user moves the cursor while it is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseMove",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user presses the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseDown",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user releases the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseUp",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOver",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor away from a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOut",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when the view begins rendering
	 * 
	 * @eventType away3d.events.ViewEvent
	 */
	[Event(name="renderBegin",type="away3d.events.ViewEvent")]
    			
	 /**
	 * Dispatched when the view completes rendering
	 * 
	 * @eventType away3d.events.ViewEvent
	 */
	[Event(name="renderComplete",type="away3d.events.ViewEvent")]
	
	/**
	 * Sprite container used for storing camera, scene, session, renderer and clip references, and resolving mouse events
	 */
	public class View3D extends Sprite
	{
		/** @private */
        arcane var _updatedObjects:Dictionary = new Dictionary(true);
        /** @private */
        arcane var _updatedSessions:Dictionary = new Dictionary(true);
		/** @private */
		arcane var _mouseIsOverView:Boolean;
		/** @private */
		arcane var _screenClipping:Clipping;
		/** @private */
		arcane var _interactiveLayer:Sprite = new Sprite();
    	/** @private */
    	arcane var _primitiveProjector:PrimitiveProjector;
		/** @private */
        arcane function dispatchMouseEvent(event:MouseEvent3D):void
        {
            if (!hasEventListener(event.type))
                return;

            dispatchEvent(event);
        }
		private var _loaderWidth:Number;
		private var _loaderHeight:Number;
		private var _loaderDirty:Boolean;
		private var _screenClippingDirty:Boolean;
		private var _viewZero:Point = new Point();
		private var _x:Number;
		private var _y:Number;
		private var _stageWidth:Number;
		private var _stageHeight:Number;
		private var _newStageWidth:Number;
		private var _newStageHeight:Number;
		private var _cameraVarsStore:CameraVarsStore = new CameraVarsStore();
		private var _hitManager:HitManager;
		private var _clickArray:Vector.<Object3D> = new Vector.<Object3D>();
		private var _outArray:Vector.<Object3D> = new Vector.<Object3D>();
        private var _overArray:Vector.<Object3D> = new Vector.<Object3D>();
        private var _scene:Scene3D;
		private var _session:AbstractSession;
		private var _clipping:Clipping;
		private var _camera:Camera3D;
		private var _renderer:Renderer;
		private var _ini:Init;
		private var _mousedown:Boolean;
        private var _lastmove_mouseX:Number;
        private var _lastmove_mouseY:Number;
		private var _internalsession:AbstractSession;
		private var _renderStart:ViewEvent;
		private var _renderBegin:ViewEvent;
		private var _renderComplete:ViewEvent;
		private var _viewDirty:Boolean;
		private var _viewupdated:ViewEvent;
		private var _pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
		arcane var _projtraverser:ProjectionTraverser = new ProjectionTraverser();
		private var _viewSourceObject:ViewSourceObject;
		private var _spriteVO:SpriteVO = new SpriteVO();
        
        private var _overlays:Dictionary = new Dictionary();
		
		
		private function notifyViewUpdate():void
		{
			if (_viewDirty)
				return;
			
			_viewDirty = true;
			
			if (!hasEventListener(ViewEvent.VIEW_UPDATED))
                return;
			
            if (!_viewupdated)
                _viewupdated = new ViewEvent(ViewEvent.VIEW_UPDATED, this);
            
            dispatchEvent(_viewupdated);
		}
		
		private function notifyRenderStart():void
		{
			if(!hasEventListener(ViewEvent.RENDER_START))return;
			
			//dispatch event
			if(!_renderStart)
				_renderStart = new ViewEvent(ViewEvent.RENDER_START, this);
			
			dispatchEvent(_renderStart);
		}
		
		private function notifyRenderBegin():void
		{
			if(!hasEventListener(ViewEvent.RENDER_BEGIN))return;
			
			//dispatch event
			if(!_renderBegin)
				_renderBegin = new ViewEvent(ViewEvent.RENDER_BEGIN, this);
			
			dispatchEvent(_renderBegin);
		}
		
		private function notifyRenderComplete():void
		{
			if(!hasEventListener(ViewEvent.RENDER_COMPLETE))return;
			
			//dispatch event
			if(!_renderComplete)
				_renderComplete = new ViewEvent(ViewEvent.RENDER_COMPLETE, this);
			
			dispatchEvent(_renderComplete);
		}
		
		private function createStatsMenu(event:Event = null):void
		{
			statsPanel = new Stats(this, stage.frameRate); 
			statsOpen = false;
			
			stage.addEventListener(Event.RESIZE, onStageResized, false, 0, true);
		}
		
		private function onStageResized(event:Event):void
		{
			_screenClippingDirty = true;
		}
		
		private function onSessionUpdate(event:SessionEvent):void
		{
			if (event.target is BitmapSession)
				_updatedSessions[event.target] = event.target;
		}
		
		private function onCameraTransformChange(e:Object3DEvent):void
		{
			notifyViewUpdate();
		}
		
		private function onCameraUpdated(e:CameraEvent):void
		{
			notifyViewUpdate();
		}
		
		private function onClippingUpdated(e:ClippingEvent):void
		{
			_screenClippingDirty = true;
		}
		
		private function onScreenUpdated(e:ClippingEvent):void
		{
			notifyViewUpdate();
		}
		
		private function onSessionChange(e:Object3DEvent):void
		{
			_session.sessions = [e.object.session];
		}
		
        private function onMouseDown(e:MouseEvent):void
        {
            _mousedown = true;
            fireMouseEvent(MouseEvent3D.MOUSE_DOWN, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseUp(e:MouseEvent):void
        {
            _mousedown = false;
            fireMouseEvent(MouseEvent3D.MOUSE_UP, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }

        private function onRollOut(e:MouseEvent):void
        {
        	_mouseIsOverView = false;
        	
        	fireMouseEvent(MouseEvent3D.MOUSE_OUT, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }
        
        private function onRollOver(e:MouseEvent):void
        {
        	_mouseIsOverView = true;
        	
            fireMouseEvent(MouseEvent3D.MOUSE_OVER, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }
        
        private function bubbleMouseEvent(event:MouseEvent3D, array:Vector.<Object3D>):void
        {
            var tar:Object3D = event.object;
            while (tar != null)
            {
            	array.unshift(tar);
            	
                tar.dispatchMouseEvent(event);
                
                tar = tar.parent;
            }
        }
        
        private function traverseRollEvent(event:MouseEvent3D, array:Vector.<Object3D>, overFlag:Boolean):void
        {
        	for each (var tar:Object3D in array) {
        		tar.dispatchMouseEvent(event);
        		if (overFlag)
        			buttonMode = buttonMode || tar.useHandCursor;
        		else if (buttonMode && tar.useHandCursor)
        			buttonMode = false;
        	}
        }
        
        private function processOverlays():void
        {
        	for each(var overlay:IOverlay in _overlays)
		{
        		if (overlay) overlay.update();
		}
        }
        
        /**
         * A background sprite positioned under the rendered scene.
         */
        public var background:Sprite = new Sprite();
        
        /**
         * An overlay sprite positioned on top of the rendered scene.
         */
        public var overlay:Sprite = new Sprite();
        
        /**
         * A container for 2D overlays positioned over the rendered scene.
         */
        public var foreground:Sprite = new Sprite();
		
        /**
         * Enables/Disables stats panel.
         * 
         * @see away3d.core.stats.Stats
         */
	  	public function set stats(b:Boolean):void
        {
            if(statsPanel != null)
            	statsPanel = null;
            
            if(b && stage) 
                createStatsMenu();
            else if (b) 
                addEventListener(Event.ADDED_TO_STAGE, createStatsMenu);    
        }
		
        /**
         * Enables/Disables mouse interactivity.
         */
        public var mouseEvents:Boolean;
        
        /**
         * Keeps track of whether the stats panel is currently open.
         * 
         * @see away3d.core.stats.Stats
         */
        public var statsOpen:Boolean;
        
        /**
         * Object instance of the stats panel.
         * 
         * @see away3d.core.stats.Stats
         */
        public var statsPanel:Stats;
                
		/**
		 * Optional string for storing source url.
		 */
		public var sourceURL:String;
		
        /**
         * Forces mousemove events to fire even when cursor is static.
         */
        public var mouseZeroMove:Boolean;

        /**
         * Current object under the mouse.
         */
        public var mouseObject:Object3D;
        
        /**
         * Current material under the mouse.
         */
        public var mouseMaterial:Material;
        
        /**
         * Defines whether the view always redraws on a render, or just redraws what 3d objects change. Defaults to false.
         * 
         * @see #render()
         */
        public var forceUpdate:Boolean;
        
        /**
         * Renderer object used to traverse the scenegraph and output the drawing primitives required to render the scene to the view.
         */
        public function get renderer():Renderer
        {
        	return _renderer;
        }
    	
        public function set renderer(val:Renderer):void
        {
        	if (_renderer == val)
        		return;
        	
        	_renderer = val;
        	
			notifyViewUpdate();
			
        	if (_renderer)
        		_session.renderer = _renderer;
        	else
        		throw new Error("View cannot have renderer set to null");
        }
		
		/**
		 * Flag used to determine if the camera has updated the view.
         * 
         * @see #camera
         */
        public function get updated():Boolean
        {
        	return _viewDirty;
        }
        
        /**
         * Clipping area used when rendering.
         * 
         * If null, the visible edges of the screen are located with the <code>Clipping.screen()</code> method.
         * 
         * @see #render()
         * @see away3d.core.render.Clipping.scene()
         */
        public function get clipping():Clipping
        {
        	return _clipping;
        }
    	
        public function set clipping(val:Clipping):void
        {
        	if (_clipping == val)
        		return;
        	
        	if (_clipping) {
        		_clipping.removeOnClippingUpdate(onClippingUpdated);
        		_clipping.removeOnScreenUpdate(onScreenUpdated);
        	}
        		
        	_clipping = val;
        	_clipping.view = this;
        	
        	if (_clipping) {
        		_clipping.addOnClippingUpdate(onClippingUpdated);
        		_clipping.addOnScreenUpdate(onScreenUpdated);
        	} else {
        		throw new Error("View cannot have clip set to null");
        	}
        	
        	notifyViewUpdate();
        	
        	_screenClippingDirty = true;
        }
        
        /**
         * Camera used when rendering.
         * 
         * @see #render()
         */
        public function get camera():Camera3D
        {
        	return _camera;
        }
    	
        public function set camera(val:Camera3D):void
        {
        	if (_camera == val)
        		return;
        	
        	if (_camera) {
        		_camera.removeOnSceneTransformChange(onCameraTransformChange);
        		_camera.removeOnCameraUpdate(onCameraUpdated);
        	}
        	
        	_camera = val;
        	_camera.view = this;
        	
        	notifyViewUpdate();
        	
        	if (_camera) {
        		_camera.addOnSceneTransformChange(onCameraTransformChange);
        		_camera.addOnCameraUpdate(onCameraUpdated);
        	} else {
        		throw new Error("View cannot have camera set to null");
        	}
        }
        
		/**
		 * Scene used when rendering.
         * 
         * @see render()
         */
        public function get scene():Scene3D
        {
        	return _scene;
        }
    	
        public function set scene(val:Scene3D):void
        {
        	if (_scene == val)
        		return;
        	
        	if (_scene) {
        		delete _scene.viewDictionary[this];
        		_scene.removeOnSessionChange(onSessionChange);
        		if (_session)
        			_session.internalRemoveSceneSession(_scene.ownSession);
	        }
        	
        	_scene = val;
        	
			notifyViewUpdate();
			
        	if (_scene) {
        		_scene.addOnSessionChange(onSessionChange);
        		_scene.viewDictionary[this] = this;
        		if (_session)
        			_session.internalAddSceneSession(_scene.ownSession);
        	} else {
        		throw new Error("View cannot have scene set to null");
        	}
        }
        
        /**
         * Session object used to draw all drawing primitives returned from the renderer to the view container.
         * 
         * @see #renderer
         * @see #getContainer()
         */
        public function get session():AbstractSession
        {
        	return _session;
        }
    	
        public function set session(val:AbstractSession):void
        {
        	if (_session == val)
        		return;
        	
        	if (_session) {
        		_session.removeOnSessionUpdate(onSessionUpdate);
	        	if (_scene)
	        		_session.internalRemoveSceneSession(_scene.ownSession);
	        	if (_renderer)
	        		_session.renderer = null;
        	}
        	
        	_session = val;
        	
			notifyViewUpdate();
			
        	if (_session) {
				_session.addOnSessionUpdate(onSessionUpdate);
	        	if (_scene)
	        		_session.internalAddSceneSession(_scene.ownSession);
	        	if (_renderer)
	        		_session.renderer = _renderer;
        	} else {
        		throw new Error("View cannot have session set to null");
        	}
        	
        	//clear children
        	while (numChildren)
        		removeChildAt(0);
        	
        	//add children
        	addChild(background);
            addChild(_session.getContainer(this));
            addChild(_interactiveLayer);
            addChild(overlay);
            addChild(foreground);
        }
        
        public function get screenClipping():Clipping
        {
        	if (_screenClippingDirty) {
        		updateScreenClipping();
        		_screenClippingDirty = false;
        		
        		return _screenClipping = _clipping.screen(this, _loaderWidth, _loaderHeight);
        	}
        	
        	return _screenClipping;
        }
        
        public function get cameraVarsStore():CameraVarsStore
        {
        	return _cameraVarsStore;
        }
        
        
        public function get viewSourceObject():ViewSourceObject
        {
        	return _viewSourceObject;
        }
        
        public function get hitManager():HitManager
        {
        	return _hitManager;
        }
        
		/**
		 * Creates a new <code>View3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function View3D(init:Object = null)
		{
			_ini = Init.parse(init) as Init;
			
            var stats:Boolean = _ini.getBoolean("stats", true);
			session = _ini.getObject("session") as AbstractSession || new SpriteSession();
            scene = _ini.getObjectOrInit("scene", Scene3D) as Scene3D || new Scene3D();
            camera = _ini.getObjectOrInit("camera", Camera3D) as Camera3D || new Camera3D({x:0, y:0, z:-1000, lookat:"center"});
			renderer = _ini.getObject("renderer") as Renderer || new BasicRenderer();
			clipping = _ini.getObject("clipping", Clipping) as Clipping || new RectangleClipping();
			x = _ini.getNumber("x", 0);
			y = _ini.getNumber("y", 0);
			forceUpdate = _ini.getBoolean("forceUpdate", false);
			mouseZeroMove = _ini.getBoolean("mouseZeroMove", false);
			mouseEvents = _ini.getBoolean("mouseEvents", true);
			
			//setup blendmode for hidden interactive layer
            _interactiveLayer.blendMode = BlendMode.ALPHA;
            
            //setup the view property on child classes
            _primitiveProjector = new PrimitiveProjector(this);
			_cameraVarsStore.view = this;
            _pritraverser.view = this;
            _projtraverser.view = this;
            
            //setup view source object for draw display vo
            _viewSourceObject = new ViewSourceObject(null);
			_viewSourceObject.screenVertices = Vector.<Number>([0, 0]);
			_viewSourceObject.screenIndices = Vector.<int>([0]);
			_viewSourceObject.screenUVTs = Vector.<Number>([0, 0, 0]);
			
			//setup events on view
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.ROLL_OUT, onRollOut);
            addEventListener(MouseEvent.ROLL_OVER, onRollOver);
            
            //setup hit manager
            _hitManager = new HitManager(this);
            
            //setup stats panel creation
            if (stats)
				addEventListener(Event.ADDED_TO_STAGE, createStatsMenu);			
		}
        
        /**
         * Collects all information from the given type of 3d mouse event into a <code>MouseEvent3D</code> object that can be accessed from the <code>getMouseEvent()</code> method.
         * 
         * @param	type					The type of 3d mouse event being triggered - can be MOUSE_UP, MOUSE_DOWN, MOUSE_OVER, MOUSE_OUT, and MOUSE_MOVE.
         * @param	x						The x coordinate being used for the 3d mouse event.
         * @param	y						The y coordinate being used for the 3d mouse event.
         * @param	ctrlKey		[optional]	The ctrl key value being used for the 3d mouse event.
         * @param	shiftKey	[optional]	The shift key value being used for the 3d mouse event.
         * 
         * @see #getMouseEvent()
         * @see away3d.events.MouseEvent3D
         */
        public function fireMouseEvent(type:String, x:Number, y:Number, ctrlKey:Boolean = false, shiftKey:Boolean = false):void
        {
        	if (!mouseEvents)
        		return;
        	
        	_hitManager.findHit(_internalsession, x, y);
        	
            var event:MouseEvent3D = _hitManager.getMouseEvent(type);
            _outArray.length = 0;
            _overArray.length = 0;
            _clickArray.length = 0;
            event.ctrlKey = ctrlKey;
            event.shiftKey = shiftKey;
			
			if (type != MouseEvent3D.MOUSE_OUT && type != MouseEvent3D.MOUSE_OVER) {
	            dispatchMouseEvent(event);
	            bubbleMouseEvent(event, _clickArray);
			}
            
            //catch mouseOver/mouseOut rollOver/rollOut object3d events
            if (mouseObject != _hitManager.object || mouseMaterial != _hitManager.material) {
                if (mouseObject != null) {
                    event = _hitManager.getMouseEvent(MouseEvent3D.MOUSE_OUT);
                    event.object = mouseObject;
                    event.material = mouseMaterial;
                    event.ctrlKey = ctrlKey;
            		event.shiftKey = shiftKey;
                    dispatchMouseEvent(event);
                    bubbleMouseEvent(event, _outArray);
                }
                if (_hitManager.object != null) {
                    event = _hitManager.getMouseEvent(MouseEvent3D.MOUSE_OVER);
                    event.ctrlKey = ctrlKey;
            		event.shiftKey = shiftKey;
                    dispatchMouseEvent(event);
                    bubbleMouseEvent(event, _overArray);
                }
                
                if (mouseObject != _hitManager.object) {
                	
	                var i:int = 0;
	                
	                while (_outArray.length > i && _overArray.length > i && _outArray[i] == _overArray[i])
	                	++i;
	                
	                if (mouseObject != null) {
	                	event = _hitManager.getMouseEvent(MouseEvent3D.ROLL_OUT);
	                	event.object = mouseObject;
	                	event.material = mouseMaterial;
	                	event.ctrlKey = ctrlKey;
	            		event.shiftKey = shiftKey;
		                traverseRollEvent(event, _outArray.slice(i), false);
	                }
	                
	                if (_hitManager.object != null) {
	                	event = _hitManager.getMouseEvent(MouseEvent3D.ROLL_OVER);
	                	event.ctrlKey = ctrlKey;
	            		event.shiftKey = shiftKey;
		                traverseRollEvent(event, _overArray.slice(i), true);
	                }
                }
                
                mouseObject = _hitManager.object;
                mouseMaterial = _hitManager.material;
            }
            
        }
        
        /** 
	     * Adds an overlay effect on top of the view container.
	     */
        public function addOverlay(value:IOverlay):void
        {
        	if(_overlays[value])
        		return;
        	
        	_overlays[value] = value;
        	
        	overlay.addChild(value as Sprite);
        }
        
        /** 
	     * Removes an overlay effect on top of the view container.
	     */
        public function removeOverlay(value:IOverlay):void
        {
        	if(_overlays[value])
        	{
        		overlay.removeChild(value as Sprite);
        		_overlays[value] = null;
        	}
        }
        
        /**
         * Returns the <code>DisplayObject</code> container of the rendered scene.
         * 
         * @return	The <code>DisplayObject</code> containing the output from the render session of the view.
         * 
         * @see #session
         * @see away3d.core.render.BitmapRenderSession
         * @see away3d.core.render.SpriteRenderSession
         */
		public function getContainer():DisplayObject
		{
			return _session.getContainer(this);
		}
		
        /**
         * Returns the <code>bitmapData</code> of the rendered scene.
         * 
         * <code>session</code> is required to be an instance of <code>BitmapRenderSession</code>, otherwise an error is thrown.
         * 
         * @throws	Error	incorrect session object - require BitmapRenderSession.
         * @return	The rendered view image.
         * 
         * @see #session
         * @see away3d.core.render.BitmapRenderSession
         */
		public function getBitmapData():BitmapData
		{
			if (_session is BitmapSession)
				return (_session as BitmapSession).getBitmapData(this);
			else
				throw new Error("incorrect session object - require BitmapRenderSession");	
		}
		
		public function updateScreenClipping():void
		{
        	//check for loaderInfo update
        	try {
        		_loaderWidth = loaderInfo.width;
        		_loaderHeight = loaderInfo.height;
        		if (_loaderDirty) {
        			_loaderDirty = false;
        			_screenClippingDirty = true;
        		}
        	} catch (error:Error) {
        		_loaderDirty = true;
        		
        		if (stage) {
	        		_loaderWidth = stage.stageWidth;
	        		_loaderHeight = stage.stageHeight;
	        	} else {
	        		_loaderWidth = 550;
	        		_loaderHeight = 400;
	        	}
        	}
        	
			//check for global view movement
        	_viewZero.x = 0;
        	_viewZero.y = 0;
        	_viewZero = localToGlobal(_viewZero);
        	
        	if (stage) {
        		_newStageWidth = stage.stageWidth;
        		_newStageHeight = stage.stageHeight;
        	} else {
        		_newStageWidth = 550;
        		_newStageHeight = 400;
        	}
        	
			if (_x != _viewZero.x || _y != _viewZero.y || _stageWidth != _newStageWidth || _stageHeight != _newStageHeight) {
        		_x = _viewZero.x;
        		_y = _viewZero.y;
        		_stageWidth = _newStageWidth;
        		_stageHeight = _newStageHeight;
        		_screenClippingDirty = true;
   			}
		}
		
        /**
         * Clears previously rendered view from all render sessions.
         * 
         * @see #session
         */
        public function clear():void
        {
        	notifyViewUpdate();
        	
        	if (_internalsession)
        		_internalsession.clear(this);
        }
        
        /**
         * Renders a snapshot of the view to the render session's view container.
         * 
         * @see #session
         */
        public function render():void
        {
            notifyRenderStart();
        	
            //update camera
        	_camera.update();
        	
        	//clear camera view transforms
        	_cameraVarsStore.reset();
        	
        	//traverse projections
        	_projtraverser.view = this;
			_scene.traverse(_projtraverser);
            
        	//update session
        	if (_internalsession != _session)
        		_internalsession = _session;
	        
            //clear session
            _session.clear(this);
            
            //draw scene into view session
            if (_session.updated) {
            	if (_scene.ownSession is SpriteSession)
					(_scene.ownSession as SpriteSession).cacheAsBitmap = true;
				_spriteVO.displayObject = _scene.session.getContainer(this);
	         	_session.getRenderer(this).primitive(_session.getRenderer(this).createDrawDisplayObject(_spriteVO, 0, _viewSourceObject, 1));
			}
            
            //traverse primitives
            _scene.traverse(_pritraverser);
            
            notifyRenderBegin();
            
            //render scene
            _session.render(this);
            
        	_viewDirty = false;
			
			//dispatch stats
            if (statsOpen)
            	statsPanel.updateStats(_session.getTotalFaces(this), camera);
        	
        	//debug check
            Init.checkUnusedArguments();
			
			//process overlay effects
			processOverlays();
			
			//check for mouse interaction
            fireMouseMoveEvent();
            
            //notify render complete
            notifyRenderComplete();
        }
        
		/**
		 * Defines a source url string that can be accessed though a View Source option in the right-click menu.
		 * 
		 * Requires the stats panel to be enabled.
		 * 
		 * @param	url		The url to the source files.
		 */
		public function addSourceURL(url:String):void
		{
			sourceURL = url;
			if (statsPanel)
				statsPanel.addSourceURL(url);
		}

        /**
         * Manually fires a mouseMove3D event.
         */
        public function fireMouseMoveEvent(force:Boolean = false):void
        {
        	if(!_mouseIsOverView)
        		return;
        	
            if (!(mouseZeroMove || force))
                if ((mouseX == _lastmove_mouseX) && (mouseY == _lastmove_mouseY))
                    return;

            fireMouseEvent(MouseEvent3D.MOUSE_MOVE, mouseX, mouseY);

             _lastmove_mouseX = mouseX;
             _lastmove_mouseY = mouseY;
        }
		
		/**
		 * Default method for adding a mouseMove3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseMove(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseMove3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseMove(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
        }
		
		/**
		 * Default method for adding a mouseDown3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseDown3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
        }
		
		/**
		 * Default method for adding a mouseUp3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseUp event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
        }
		
		/**
		 * Default method for adding a 3d mouseOver event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOver(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseOver event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOver(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
        }
		
		/**
		 * Default method for adding a 3d mouseOut event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOut(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseOut event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOut(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
        }
        
		/**
		 * Default method for adding a viewUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnViewUpdate(listener:Function):void
        {
            addEventListener(ViewEvent.VIEW_UPDATED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a viewUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnViewUpdate(listener:Function):void
        {
            removeEventListener(ViewEvent.VIEW_UPDATED, listener, false);
        }
	}
}