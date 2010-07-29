package away3d.core.render
{

	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.clip.*;
	import away3d.core.filter.*;
    
    use namespace arcane;
    
    /** 
    * Default renderer for a view.
    * Contains the main render loop for rendering a scene to a view,
    * which resolves the projection, culls any drawing primitives that are occluded or outside the viewport,
    * and then z-sorts and renders them to screen.
    */
    public class BasicRenderer extends Renderer
    {
    	private var _filters:Array;
    	private var _filter:IPrimitiveFilter;
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _screenClipping:Clipping;
        
		/**
		 * Defines the array of filters to be used on the drawing primitives.
		 */
		public function get filters():Array
		{
			return _filters.slice(1);
		}
		
		public function set filters(val:Array):void
		{
			_filters = val;
			_filters.unshift(new ZSortFilter());
		}
		
		/**
		 * Creates a new <code>BasicRenderer</code> object.
		 *
		 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
		 */
        public function BasicRenderer(...filters)
        {
            _filters = filters;
            _filters.unshift(new ZSortFilter());
        }
        
		/**
		 * @inheritDoc
		 */
        public override function primitive(priIndex:uint):Boolean
        {
        	if (!_screenClipping.checkPrimitive(this, priIndex))
        		return false;
        	
            _primitives.push(priIndex);
            _screenZs.push(primitiveScreenZ[priIndex]);
            
			return true;
        }
		
		/**
		 * A list of primitives that have been clipped and blocked.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public override function list():Array
        {
            return _primitives;
        }
        
        public override function clear():void
        {
        	super.clear();
        	
        	_primitives.length = 0;
        	_screenZs.length = 0;
        	_scene = _view.scene;
        	_camera = _view.camera;
        	_screenClipping = _view.screenClipping;
        }
        
        public override function render():void
        {
        	
        	//filter primitives array
			for each (_filter in _filters)
        		_filter.filter(this);
        	
    		// render all primitives
    		var i:int = _order.length;
    		while(i--)
    			renderPrimitive(_primitives[_order[i]]);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function toString():String
        {
            return "Basic [" + _filters.join("+") + "]";
        }
        
        public override function clone():Renderer
        {
        	var renderer:BasicRenderer = new BasicRenderer();
        	renderer.filters = filters;
        	return renderer;
        }
    }
}
