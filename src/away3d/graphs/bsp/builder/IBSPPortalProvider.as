package away3d.graphs.bsp.builder
{
	import away3d.graphs.bsp.BSPPortal;

	/**
	 * Used for BSP Builder classes through which BSPPortals can be retrieved (be it portal generators or wrappers)
	 */
	public interface IBSPPortalProvider extends IBSPBuilder
	{
		function get portals() : Vector.<BSPPortal>;
	}
}