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
     * Renderer that uses quadrant tree for storing and operating drawing primitives. Quadrant tree speeds up all proximity based calculations.
     */
    public class QuadrantRenderer extends Renderer
    {
        private var _qdrntfilters:Array;
        private var _root:QuadrantTreeNode;
        private var _quadrant:QuadrantTreeNode;
		private var _center:Array;
		private var _result:Vector.<uint> = new Vector.<uint>();
		private var _list:Vector.<uint> = new Vector.<uint>();
		private var _except:Object3D;
		private var _minX:Number;
		private var _minY:Number;
		private var _maxX:Number;
		private var _maxY:Number;
		private var _child:uint;
		private var _children:Array;
		private var i:int;
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _screenClipping:Clipping;
		private var _priQuadrants:Array = new Array();
		
		private function getList(node:QuadrantTreeNode, result:Vector.<uint>):void
        {
            if (node.onlysourceFlag && _except == node.onlysource)
                return;
            
            if (_minX < node.xdiv)
            {
                if (node.lefttopFlag && _minY < node.ydiv)
	                getList(node.lefttop, result);
	            
                if (node.leftbottomFlag && _maxY > node.ydiv)
                	getList(node.leftbottom, result);
            }
            
            if (_maxX > node.xdiv)
            {
                if (node.righttopFlag && _minY < node.ydiv)
                	getList(node.righttop, result);
                
                if (node.rightbottomFlag && _maxY > node.ydiv)
                	getList(node.rightbottom, result);
                
            }
            
            _children = node.center;
            if (_children != null) {
                i = _children.length;
                while (i--)
                {
                	_child = _children[i];
                    if ((_except == null || primitiveSource[_child].source != _except) && primitiveProperties[uint(_child*9 + 3)] > _minX && primitiveProperties[uint(_child*9 + 2)] < _maxX && primitiveProperties[uint(_child*9 + 5)] > _minY && primitiveProperties[uint(_child*9 + 4)] < _maxY)
                        result.push(_child);
                }
            }
        }
        
        private function getParent(node:QuadrantTreeNode, result:Vector.<uint>):void
        {
        	node = node.parent;
        	
            if (node == null || (node.onlysourceFlag && _except == node.onlysource))
                return;

            _children = node.center;
            if (_children != null) {
                i = _children.length;
                while (i--)
                {
                	_child = _children[i];
                    if ((_except == null || primitiveSource[_child].source != _except) && primitiveProperties[uint(_child*9 + 3)] > _minX && primitiveProperties[uint(_child*9 + 2)] < _maxX && primitiveProperties[uint(_child*9 + 5)] > _minY && primitiveProperties[uint(_child*9 + 4)] < _maxY)
                        result.push(_child);
                }
            }
            getParent(node, result);
        }
		
		/**
		 * Defines the array of filters to be used on the drawing primitives.
		 */
		public function get filters():Array
		{
			return _qdrntfilters;
		}
		
		public function set filters(val:Array):void
		{
			_qdrntfilters = val;
		}
		
		/**
		 * Creates a new <code>QuadrantRenderer</code> object.
		 *
		 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
		 */
        public function QuadrantRenderer(...filters)
        {
            _qdrntfilters = filters;
        }
		
		/**
		 * @inheritDoc
		 */
        public override function primitive(priIndex:uint):Boolean
        {
        	if (!_screenClipping.checkPrimitive(this, priIndex))
        		return false;
			
			_priQuadrants[priIndex] = _root.push(this, priIndex);
            
            return true;
        }
        
        /**
        * removes a drawing primitive from the quadrant tree.
        * 
        * @param	pri	The drawing primitive to remove.
        */
        public function remove(priIndex:uint):void
        {
        	_quadrant = _priQuadrants[priIndex];
			_center = _quadrant.center;
        	_center.splice(_center.indexOf(priIndex), 1);
        }
		
		/**
		 * Returns an array containing all primiives overlapping the specifed primitive's quadrant.
		 * 
		 * @param	pri					The drawing primitive to check.
		 * @param	ex		[optional]	Excludes primitives that are children of the 3d object.
		 * @return						An array of drawing primitives.
		 */
        public function getRivals(priIndex:uint, ex:Object3D = null):Vector.<uint>
        {
        	_result.length = 0;
                    
			_minX = primitiveProperties[uint(priIndex*9 + 2)];
			_maxX = primitiveProperties[uint(priIndex*9 + 3)];
			_minY = primitiveProperties[uint(priIndex*9 + 4)];
			_maxY = primitiveProperties[uint(priIndex*9 + 5)];
			_except = ex;
			
            getList(_priQuadrants[priIndex], _result);
            getParent(_priQuadrants[priIndex], _result);
            return _result;
        }
        
		/**
		 * A list of primitives that have been clipped.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public override function list():Vector.<uint>
        {
        	//list and result on separate arrays so that no conflicts occur
        	_list.length = 0;
                    
			_minX = -1000000;
			_minY = -1000000;
			_maxX = 1000000;
			_maxY = 1000000;
			_except = null;
			
            getList(_root, _list);
            
            return _list;
        }
        
        public override function clear():void
        {
        	super.clear();
        	
        	_priQuadrants.length = 0;
			_scene = _view.scene;
			_camera = _view.camera;
			_screenClipping = _view.screenClipping;
			
			if (!_root)
				_root = new QuadrantTreeNode((_screenClipping.minX + _screenClipping.maxX)/2, (_screenClipping.minY + _screenClipping.maxY)/2, _screenClipping.maxX - _screenClipping.minX, _screenClipping.maxY - _screenClipping.minY, 0, this);
			else
				_root.reset((_screenClipping.minX + _screenClipping.maxX)/2, (_screenClipping.minY + _screenClipping.maxY)/2, _screenClipping.maxX - _screenClipping.minX, _screenClipping.maxY - _screenClipping.minY);	
        }
        
        public override function render():void
        {
			
        	//filter primitives array
			for each (var _filter:IPrimitiveQuadrantFilter in _qdrntfilters)
        		_filter.filter(this);
        	
    		// render all primitives
            _root.render(-Infinity);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function toString():String
        {
            return "Quadrant ["+ _qdrntfilters.join("+") + "]";
        }
        
        public override function clone():Renderer
        {
        	var renderer:QuadrantRenderer = new QuadrantRenderer();
        	renderer.filters = filters;
        	return renderer;
        }
    }
}
