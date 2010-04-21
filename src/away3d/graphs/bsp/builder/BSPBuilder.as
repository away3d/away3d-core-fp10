package away3d.graphs.bsp.builder
{
	import away3d.graphs.bsp.builder.BSPCollisionPlaneBuilder;
	import away3d.graphs.bsp.builder.BSPGeometryBuilder;
	import away3d.graphs.bsp.builder.BSPPVSBuilder;
	import away3d.graphs.bsp.builder.BSPPortalBuilder;
	import away3d.graphs.bsp.builder.BSPTJunctionFixer;
	import away3d.graphs.bsp.builder.IBSPBuilder;
	import away3d.graphs.bsp.builder.IBSPPortalProvider;

	public class BSPBuilder
	{
		public static function generateBuilder(fixTJunctions : Boolean = false, buildCollisionPlanes : Boolean = false, buildPVS : Boolean = false) : IBSPBuilder
		{
			var builder : IBSPBuilder = new BSPGeometryBuilder();

			// wrap with builder decorators as necessary
			if (fixTJunctions || buildCollisionPlanes || buildPVS)
				builder = new BSPPortalBuilder(builder);

			if (fixTJunctions)
				builder = new BSPTJunctionFixer(IBSPPortalProvider(builder));

			if (buildCollisionPlanes)
				builder = new BSPCollisionPlaneBuilder(IBSPPortalProvider(builder));

			if (buildPVS)
				builder = new BSPPVSBuilder(IBSPPortalProvider(builder));

			return builder;
		}
	}
}