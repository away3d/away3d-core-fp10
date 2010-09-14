package away3d.core.filter
{
	import away3d.arcane;
	import away3d.core.render.*;
	
	use namespace arcane;
	
    /**
    * Sorts drawing primitives by z coordinate.
    */
    public class ZSortFilter implements IPrimitiveFilter
    {
        private var k:uint;
		private var q0:Vector.<uint>;
		private var np0:Vector.<uint>;
		private var i:uint;
		private var j:uint;
		private var _length:uint;
		private var q1:Vector.<uint>;
		private var np1:Vector.<uint>;
		
		private var _screenTs:Vector.<uint>;
		
		/**
		 * @inheritDoc
		 */
        public function filter(renderer:Renderer):void
        {
        	_screenTs = renderer._screenTs;
        	//trace(_screenZs)
        	var _faces_length_1:int = int(_screenTs.length + 1);
	        
	        q0 = new Vector.<uint>(256, true);
	        q1 = new Vector.<uint>(256, true);
	        np0 = new Vector.<uint>(_faces_length_1, true);
	        np1 = new Vector.<uint>(_faces_length_1, true);
	        
	        _length = _screenTs.length;
	        
        	j = 0;
        	
            while (j < _length) {
				np0[uint(j+1)] = q0[k = (255 & _screenTs[j])];
				q0[k] = uint(++j);
            }
			
			i = 256;
			while (i--) {
				j = q0[i];
				while (j) {
					np1[j] = q1[k = (65280 & _screenTs[uint(j-1)]) >> 8];
					j = np0[q1[k] = j];
				}
			}
			
			i = 0;
			k = _length - 1;
            while (i < 255) {
            	j = q1[uint(i++)];
                while (j) {
                    renderer._order[uint(k--)] = j-1;
					j = np1[j];
                }
            }
        	//renderer._order = renderer._screenZs.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);
        }
		
		/**
		 * Used to trace the values of a filter.
		 * 
		 * @return A string representation of the filter object.
		 */
        public function toString():String
        {
            return "ZSort";
        }
    }
}
