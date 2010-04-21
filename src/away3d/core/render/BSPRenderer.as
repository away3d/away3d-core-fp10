package away3d.core.render
{
	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
    
    use namespace arcane;
    
   /** 
    * BSP renderer for a view.
    * Should not be used directly, it's used automatically in the BSPTree class
    */
    public class BSPRenderer implements IRenderer, IPrimitiveConsumer
    {
    	private var _filters:Array;
    	private var _filter:IPrimitiveFilter;
        private var _primitives:Array = new Array();
        private var _newPrimitives:Array = new Array();
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _screenClipping:Clipping;
        private var _blockers:Array;
        private var _sorting : Boolean;
        
		/**
		 * Creates a new <code>BSPRenderer</code> object.
		 *
		 */
        public function BSPRenderer(...filters)
        {
            _filters = filters;
            _filters.push(new ZSortFilter());
        }
        
        
        /**
		 * Defines the array of filters to be used on the drawing primitives.
		 */
		public function get filters():Array
		{
			return _filters.slice(0, _filters.length - 1);
		}
		
		public function set filters(val:Array):void
		{
			_filters = val;
			_filters.push(new ZSortFilter());
		}
        
		/**
		 * @inheritDoc
		 */
        public function primitive(pri:DrawPrimitive):Boolean
        {
        	if (!_screenClipping.checkPrimitive(pri))
        		return false;
        	
           /*  for each (var _blocker:Blocker in _blockers) {
                if (_blocker.screenZ > pri.minZ)
                    continue;
                if (_blocker.block(pri))
                    return false;
            } */
            
            if (pri.ignoreSort) {
            	if (_sorting) {
					for each(_filter in _filters)
						_newPrimitives = _filter.filter(_newPrimitives, _scene, _camera, _screenClipping);
					
					_primitives = _primitives.concat(_newPrimitives);
					_newPrimitives.length = 0;
					_sorting = false;
				}
            	_primitives.push(pri);
            }
           	else {
           		_sorting = true;
           		_newPrimitives.push(pri);
           	}
            
            return true;
        }
		
		/**
		 * A list of primitives that have been clipped and blocked.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public function list():Array
        {
            return _primitives;
        }
        
        public function clear(view:View3D):void
        {
        	_primitives.length = 0;
			_scene = view.scene;
        	_camera = view.camera;
        	_screenClipping = view.screenClipping;
        	_blockers = view.blockerarray.list();
        }
        
        public function render(view:View3D):void
        {
        	var i : int;
        	var len : int;
        	
            if (_sorting) {
				for each(_filter in _filters)
					_newPrimitives = _filter.filter(_newPrimitives, _scene, _camera, _screenClipping);
				
//				i = -1;
//				len = _newPrimitives.length;
//				while (++i < len)
//					DrawPrimitive(_newPrimitives[i]).render();

				_primitives = _primitives.concat(_newPrimitives);

				_newPrimitives.length = 0;
			}
			_sorting = false;

			i = -1;
			len = _primitives.length;

			// render all primitives
            while (++i < len)
                DrawPrimitive(_primitives[i]).render();
        }
        
		/**
		 * @inheritDoc
		 */
        public function toString():String
        {
            return "BSPRenderer";
        }
        
        public function clone():IPrimitiveConsumer
        {
        	return new BSPRenderer();
		}
	}
}
