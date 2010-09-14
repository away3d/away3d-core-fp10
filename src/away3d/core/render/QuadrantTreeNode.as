package away3d.core.render
{
	import away3d.arcane;
    import away3d.core.base.*;
    
    use namespace arcane;
    /**
    * Quadrant tree node
    */
    public final class QuadrantTreeNode
    {
    	private var render_order:Array;
        private var render_center_length:int = -1;
        private var render_center_index:int = -1;
        private var halfwidth:Number;
        private var halfheight:Number;
        private var level:int;
        private var maxlevel:int = 4;
        
        private function render_other(limit:Number):void
        {
        	if (lefttopFlag)
                lefttop.render(limit);
            if (leftbottomFlag)
                leftbottom.render(limit);
            if (righttopFlag)
                righttop.render(limit);
            if (rightbottomFlag)
                rightbottom.render(limit);
        }
        
        /**
        * Array of primitives indices that belong to the quadrant.
        */
        public var center:Array = new Array();
        
        /**
        * Array of primitives screenZs that belong to the quadrant.
        */
        public var screenZs:Array = new Array();
        
        /**
        * The quadrant tree node for the top left quadrant.
        */
        public var lefttop:QuadrantTreeNode;
        
        /**
        * The quadrant tree node for the bottom left quadrant.
        */
        public var leftbottom:QuadrantTreeNode;
        
        /**
        * The quadrant tree node for the top right quadrant.
        */
        public var righttop:QuadrantTreeNode;
        
        /**
        * The quadrant tree node for the bottom right quadrant.
        */
        public var rightbottom:QuadrantTreeNode;
        
        /**
        * Determines if the bounds of the top left quadrant need re-calculating.
        */
        public var lefttopFlag:Boolean;
        
        /**
        * Determines if the bounds of the bottom left quadrant need re-calculating.
        */
        public var leftbottomFlag:Boolean;
        
        /**
        * Determines if the bounds of the top right quadrant need re-calculating.
        */
        public var righttopFlag:Boolean;
        
        /**
        * Determines if the bounds of the bottom right quadrant need re-calculating.
        */
        public var rightbottomFlag:Boolean;
                
        /**
        * Determines if the quadrant node contains only one source.
        */
		public var onlysourceFlag:Boolean = true;
		
		/**
		 * hold the 3d object referenced when <code>onlysourceFlag</code> is true.
		 */
        public var onlysource:Object3D;
        
        /**
        * The x coordinate of the quadrant division.
        */
        public var xdiv:Number;
        
        /**
        * The x coordinate of the quadrant division.
        */
        public var ydiv:Number;
		
		/**
		 * The quadrant renderer.
		 */
        public var renderer:QuadrantRenderer;
        		
		/**
		 * The quadrant parent.
		 */
        public var parent:QuadrantTreeNode;
		
		/**
		 * Creates a new <code>PrimitiveQuadrantTreeNode</code> object.
		 *
		 * @param	xdiv	The x coordinate for the division between left and right child quadrants.
		 * @param	ydiv	The y coordinate for the division between top and bottom child quadrants.
		 * @param	width	The width of the quadrant node.
		 * @param	xdiv	The height of the quadrant node.
		 * @param	level	The iteration number of the quadrant node.
		 * @param	parent	The parent quadrant of the quadrant node.
		 */
        public function QuadrantTreeNode(xdiv:Number, ydiv:Number, width:Number, height:Number, level:int, renderer:QuadrantRenderer, parent:QuadrantTreeNode = null)
        {
            this.level = level;
            this.xdiv = xdiv;
            this.ydiv = ydiv;
            halfwidth = width / 2;
            halfheight = height / 2;
            this.renderer = renderer;
            this.parent = parent;
        }
		
		/**
		 * Adds a primitive to the quadrant
		 */
        public function push(renderer:QuadrantRenderer, priIndex:uint):QuadrantTreeNode
        {
            if (onlysourceFlag) {
	            if (onlysource != null && onlysource != renderer.primitiveSource[priIndex].source)
	            	onlysourceFlag = false;
                onlysource = renderer.primitiveSource[priIndex].source;
            }
			
			if (level < maxlevel) {
	            if (renderer.primitiveProperties[uint(priIndex*9 + 3)] <= xdiv)
	            {
	                if (renderer.primitiveProperties[uint(priIndex*9 + 5)] <= ydiv)
	                {
	                    if (lefttop == null) {
	                    	lefttopFlag = true;
	                        lefttop = new QuadrantTreeNode(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1, renderer, this);
	                    } else if (!lefttopFlag) {
	                    	lefttopFlag = true;
	                    	lefttop.reset(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight);
	                    }
	                    return lefttop.push(renderer, priIndex);
	                }
	                else if (renderer.primitiveProperties[uint(priIndex*9 + 4)] >= ydiv)
	                {
	                	if (leftbottom == null) {
	                    	leftbottomFlag = true;
	                        leftbottom = new QuadrantTreeNode(xdiv - halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight, level+1, renderer, this);
	                    } else if (!leftbottomFlag) {
	                    	leftbottomFlag = true;
	                    	leftbottom.reset(xdiv - halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight);
	                    }
	                    return leftbottom.push(renderer, priIndex);
	                }
	            }
	            else if (renderer.primitiveProperties[uint(priIndex*9 + 2)] >= xdiv)
	            {
	                if (renderer.primitiveProperties[uint(priIndex*9 + 5)] <= ydiv)
	                {
	                	if (righttop == null) {
	                    	righttopFlag = true;
	                        righttop = new QuadrantTreeNode(xdiv + halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1, renderer, this);
	                    } else if (!righttopFlag) {
	                    	righttopFlag = true;
	                    	righttop.reset(xdiv + halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight);
	                    }
	                    return righttop.push(renderer, priIndex);
	                }
	                else if (renderer.primitiveProperties[uint(priIndex*9 + 4)] >= ydiv)
	                {
	                	if (rightbottom == null) {
	                    	rightbottomFlag = true;
	                        rightbottom = new QuadrantTreeNode(xdiv + halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight, level+1, renderer, this);
	                    } else if (!rightbottomFlag) {
	                    	rightbottomFlag = true;
	                    	rightbottom.reset(xdiv + halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight);
	                    }
	                    return rightbottom.push(renderer, priIndex);
	                }
	            }
			}
			
			//no quadrant, store in primitives array
			center.push(priIndex);
			return this;
        }
        
        /**
        * Clears the quadrant of all primitives and child nodes
        */
		public function reset(xdiv:Number, ydiv:Number, width:Number, height:Number):void
		{
			this.xdiv = xdiv;
			this.ydiv = ydiv;
			halfwidth = width / 2;
            halfheight = height / 2;
			
            lefttopFlag = false;
            leftbottomFlag = false;
            righttopFlag = false;
            rightbottomFlag = false;
            center.length = 0;
            
            onlysourceFlag = true;
            onlysource = null;
            
            render_center_length = -1;
            render_center_index = -1;
		}
		
		
		/**
		 * Sorts and renders the contents of the quadrant tree
		 */
        public function render(limit:Number):void
        {
            if (render_center_length == -1) {
                render_center_length = center.length;
                if (render_center_length) {
                	render_center_index = 0;
                	screenZs.length = 0;
                	
                	while (render_center_index < render_center_length)
                		screenZs.push(renderer.primitiveScreenZ[center[render_center_index++]]);
                	
                    render_order = screenZs.sort(Array.DESCENDING | Array.NUMERIC | Array.RETURNINDEXEDARRAY);
				}
                render_center_index = 0;
            }
			
            while (render_center_index < render_center_length)
            {
            	var screenIndex:uint = render_order[render_center_index];
                var screenZ:Number = screenZs[screenIndex];
				
                if (screenZ < limit)
                    break;
				
                render_other(screenZ);
				
                renderer.renderPrimitive(center[screenIndex]);

                render_center_index++;
            }
			
            render_other(limit);
        }
    }
}
