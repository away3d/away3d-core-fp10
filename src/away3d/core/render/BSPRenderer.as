package away3d.core.render
{
	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.filter.*;
    
    use namespace arcane;
    
   /** 
    * BSP renderer for a view.
    * Should not be used directly, it's used automatically in the BSPTree class
    */
    public class BSPRenderer extends Renderer
    {
    	private var _filters:Array;
    	private var _filter:IPrimitiveFilter;
    	private var _i:uint;
    	private var _orderLength:uint;
    	private var _primitivesLength:uint;
        private var _allPrimitives:Array = new Array();
        private var _allOrder:Array = new Array();
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _screenClipping:Clipping;
        private var _sorting : Boolean;
        
        private function filterNonBSP():void
        {
        	_order.length = _screenTs.length;
        	
			for each(_filter in _filters)
				_filter.filter(this);
			
			_i = 0;
			_orderLength = _order.length;
			_primitivesLength = _allPrimitives.length;

			while (_i < _orderLength) {
				_allOrder.push(_order[_orderLength - _i - 1] + _primitivesLength);
				_allPrimitives.push(_primitives[_i]);
				_i++;
			}
			
			_primitives.length = 0;
			_screenTs.length = 0;
			_sorting = false;
        }
        
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
        public override function primitive(priIndex:uint):Boolean
        {
        	if (!_screenClipping.checkPrimitive(this, priIndex))
        		return false;
        	
			if ((primitiveSource[priIndex].source as Mesh)._preSorted) {
				if (_sorting)
					filterNonBSP();

				_allOrder.push(_allPrimitives.length);
            	_allPrimitives.push(priIndex);
            }
           	else {
           		_sorting = true;
				_primitives[_primitives.length] = priIndex;
				_screenTs[_screenTs.length] = 75000*_camera.zoom/primitiveScreenZ[priIndex];
           	}
            
            return true;
        }
		
		/**
		 * A list of primitives that have been clipped and blocked.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public override function list():Vector.<uint>
        {
            return _allPrimitives;
        }
        
        public override function clear():void
        {
        	super.clear();
        	
        	_primitives.length = 0;
        	_screenTs.length = 0;
        	_allPrimitives.length = 0;
        	_allOrder.length = 0;
			_scene = _view.scene;
        	_camera = _view.camera;
        	_screenClipping = _view.screenClipping;
        	_coeffScreenT = 75000*_camera.zoom;
        }
        
        public override function render():void
        {
            if (_sorting)
				filterNonBSP();

			// render all primitives
    		_i = 0;
			_orderLength = _allOrder.length;
			while(_i < _orderLength)
    			renderPrimitive(_allPrimitives[_allOrder[_i++]]);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function toString():String
        {
            return "BSPRenderer";
        }
        
        public override function clone():Renderer
        {
        	var renderer:BSPRenderer = new BSPRenderer();
        	renderer.filters = filters;
        	return renderer;
		}
	}
}
