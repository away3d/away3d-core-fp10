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
        
		/**
		 * @inheritDoc
		 */
        public function filter(renderer:Renderer):void
        {
        	renderer._order = renderer._screenZs.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);
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
