package away3d.graphs.bsp.builder
{
	import away3d.arcane;
	import away3d.core.geom.NGon;
	import away3d.core.geom.Plane3D;
	import away3d.events.BSPBuildEvent;
	import away3d.events.IteratorEvent;
	import away3d.graphs.VectorIterator;
	import away3d.graphs.bsp.*;

	use namespace arcane;

	/**
	 * Generates bevel planes used for collision detection (prevents offsets causing false collisions at angles > 180�)
	 */
	internal class BSPCollisionPlaneBuilder extends AbstractBuilderDecorator implements IBSPPortalProvider
	{
		private var _index : int;
		private var _iterator : VectorIterator;

		private var _warningEvent : BSPBuildEvent;

		public function BSPCollisionPlaneBuilder(wrapped : IBSPPortalProvider)
		{
			super(wrapped, 1);
			_warningEvent = new BSPBuildEvent(BSPBuildEvent.BUILD_WARNING);
			_warningEvent.message = "An invalid bevel plane was found. This could indicate inverted faces or other integrity errors in the model.";
			
			setProgressMessage("Building collision beveling planes");
		}

		override public function destroy() : void
		{
			
		}

		public function get portals() : Vector.<BSPPortal>
		{
			return IBSPPortalProvider(wrapped).portals;
		}

		override protected function buildPart() : void
		{
			_iterator = new VectorIterator(Vector.<Object>(portals));
			_iterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onIterationComplete);
			_iterator.addEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onIterationTick);
			_iterator.performMethodAsync(buildBevelPlanes, maxTimeOut);
		}

		private function buildBevelPlanes(portal : BSPPortal) : void
		{
			if (canceled) {
				notifyCanceled();
				return;
			}
			++_index;

			generateBevelPlanes(portal.backNode, portal.frontNode);
			generateBevelPlanes(portal.frontNode, portal.backNode);
		}

		private function onIterationComplete(event : IteratorEvent) : void
		{
			_iterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onIterationComplete);
			_iterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onIterationTick);
			notifyComplete();
		}

		private function onIterationTick(event : IteratorEvent) : void
		{
			notifyProgress(_index, portals.length);
		}


		// details of the loop implementation
		private function generateBevelPlanes(sourceNode : BSPNode, targetNode : BSPNode) : void
		{
			var node : BSPNode = sourceNode._parent;

			while (node && node._convex) {
				createBevelPlanes(node, sourceNode._ngons, targetNode._ngons);
				node = node._parent;
			}
		}

		// to do: there are no bevel planes if partition planes form concave shape
		public function createBevelPlanes(node : BSPNode, sourceNGons : Vector.<NGon>, targetNGons : Vector.<NGon>) : void
		{
			var i : int = sourceNGons.length, j : int;
			var srcNGon : NGon, tgtNGon : NGon;
			var tgtPlane : Plane3D;
			var tgtLen : int = targetNGons.length;
			var bevel : Plane3D;
			var a1 : Number, b1 : Number, c1 : Number;
			var a2 : Number, b2 : Number, c2 : Number;
			var partitionPlane : Plane3D = node.partitionPlane;
			var bevels : Vector.<Plane3D> = node._bevelPlanes;

			a1 = partitionPlane.a;
			b1 = partitionPlane.b;
			c1 = partitionPlane.c;

			while (--i >= 0) {
				srcNGon = sourceNGons[i];

				// nGon is coinciding with partition plane, we need to check it
				if (srcNGon.classifyToPlane(partitionPlane) == -2) {
					j = tgtLen;
					while (--j >= 0) {
						tgtNGon = targetNGons[j];
						tgtPlane = tgtNGon.plane;
						a2 = tgtPlane.a;
						b2 = tgtPlane.b;
						c2 = tgtPlane.c;

						// if angle between planes < 0 and adjacent, create bevel plane
						if (a1*a2+b1*b2+c1*c2 < -BSPTree.EPSILON &&
							srcNGon.adjacent(tgtNGon)) {
							bevel = new Plane3D(a1+a2, b1+b2, c1+c2, partitionPlane.d+tgtPlane.d);
							bevel.normalize();
							if (isNaN(bevel.a) || isNaN(bevel.b) || isNaN(bevel.c) || isNaN(bevel.d)) {
								dispatchEvent(_warningEvent);
							}
							else {
								if (!bevels) node._bevelPlanes = bevels = new Vector.<Plane3D>();

								// do not add more than one of the same
								if (!contains(bevels, bevel))
									node._bevelPlanes.push(bevel);
							}
						}
					}
				}
			}
		}

		private function contains(list : Vector.<Plane3D>, bevel : Plane3D) : Boolean
		{
			var i : int = list.length;
			var comp : Plane3D;

			while (--i >= 0) {
				comp = list[i];
				if (comp.a == bevel.a && comp.b == comp.b && comp.c == comp.c && comp.d == comp.d)
					return true;
			}

			return false;
		}
	}
}