package away3d.graphs.bsp.builder
{
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Plane3D;
	import away3d.events.IteratorEvent;
	import away3d.graphs.VectorIterator;
	import away3d.graphs.bsp.BSPNode;
	import away3d.graphs.bsp.BSPPortal;
	import away3d.graphs.bsp.BSPTree;
	import away3d.materials.Material;

	use namespace arcane;

	// decorator for IBSPPortalProvider
	internal class BSPTJunctionFixer extends AbstractBuilderDecorator implements IBSPPortalProvider
	{
		private var _index : int;
		private var _iterator : VectorIterator;

		public function BSPTJunctionFixer(wrapped : IBSPPortalProvider)
		{
			super(wrapped, 1);
			setProgressMessage("Fixing T-Junctions");
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
			_iterator.performMethodAsync(fixTJunctionStep, maxTimeOut);
		}

		private function fixTJunctionStep(portal : BSPPortal) : void
		{
			if (canceled) {
				notifyCanceled();
				return;
			}

			++_index;
			removeTJunctions(portal.backNode, portal.frontNode, portal);
			removeTJunctions(portal.frontNode, portal.backNode, portal);
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


		// details of the implementation
		private function removeTJunctions(sourceNode : BSPNode, targetNode : BSPNode, portal : BSPPortal) : void
		{
			var faces : Vector.<Face> = sourceNode.faces;
			var face : Face;
			var i : int = -1;
			var len : int = faces.length;
			var plane : Plane3D = portal.nGon.plane;

			while (++i < len) {
				face = Face(faces[i]);
				if (face.hasEdgeOnPlane(plane, BSPTree.EPSILON) && testTJunctions(sourceNode, face, targetNode.faces, plane)) {
					// one face removed, two created and placed at the end of the list
					--i;
					++len;
				}
			}
		}

		private function testTJunctions(sourceNode : BSPNode, face : Face, targetFaces : Vector.<Face>, plane : Plane3D) : Boolean
		{
			var targetFace : Face;
			var i : int = targetFaces.length;

			while (--i >= 0) {
				targetFace = targetFaces[i];
				if (face.hasEdgeOnPlane(plane, BSPTree.EPSILON) && fixTJunctions(sourceNode, face, targetFace))
					return true;
			}
			return false;
		}

		private function fixTJunctions(sourceNode : BSPNode, face : Face, targetFace : Face) : Boolean
		{
			var i : int = 3;
			var v0 : Vertex = face._v0,
				v1 : Vertex = face._v1,
				v2 : Vertex = face._v2;
			var v : Vertex;
			var t : Number;

			while (--i >= 0) {
				v = targetFace.vertices[i];
				t = getTFraction(v0, v1, v);
				if (t > 0) {
					splitFace(sourceNode, face, 0, v, t);
					return true;
				}
				else {
					t = getTFraction(v1, v2, v);
					if (t > 0) {
						splitFace(sourceNode, face, 1, v, t);
						return true;
					}
					else {
						t = getTFraction(v2, v0, v);
						if (t > 0) {
							splitFace(sourceNode, face, 2, v, t);
							return true;
						}
					}
				}
			}
			return false;
		}

		private function getTFraction(v0 : Vertex, v1 : Vertex, tgt : Vertex) : Number
		{
			// test colinearity
			var dx1 : Number = v1._x - v0._x;
			var dy1 : Number = v1._y - v0._y;
			var dz1 : Number = v1._z - v0._z;
			var dx2 : Number = tgt._x - v0._x;
			var dy2 : Number = tgt._y - v0._y;
			var dz2 : Number = tgt._z - v0._z;
			var cx : Number = dy2 * dz1 - dz2 * dy1;
        	var cy : Number = dz2 * dx1 - dx2 * dz1;
        	var cz : Number = dx2 * dy1 - dy2 * dx1;
        	var t : Number;
        	var minT : Number;
        	var maxT : Number;

        	// tgt is not on edge
        	if (cx*cx+cy*cy+cz*cz > BSPTree.EPSILON) return -1;

        	// pick the divisor with highest absolute value to minimize rounding errors
        	if ((dx1 > 0 && dx1 >= dy1 && dx1 >= dz1) ||
				(dx1 < 0 && dx1 <= dy1 && dx1 <= dz1)) {
				dx1 = 1/dx1;
				t = dx2*dx1;
			}
			else if ((dy1 > 0 && dy1 >= dx1 && dy1 >= dz1) ||
					(dy1 < 0 && dy1 <= dx1 && dy1 <= dz1)) {
				dy1 = 1/dy1;
				t = dy2*dy1;
			}
			else if ((dz1 > 0 && dz1 >= dx1 && dz1 >= dy1) ||
					(dz1 < 0 && dz1 <= dx1 && dz1 <= dy1)) {
				dz1 = 1/dz1;
				t = dz2*dz1;
			}

        	maxT = 1-minT;

        	if (t > 0.002 && t < 0.998) return t;

			return -1;
		}

		private function splitFace(sourceNode : BSPNode, face : Face, index : int, tPoint : Vertex, t : Number) : void
		{
			var face1 : Face;
			var face2 : Face;
			var v0 : Vertex = face._v0;
			var v1 : Vertex = face._v1;
			var v2 : Vertex = face._v2;
			var uv0 : UV = face._uv0;
			var uv1 : UV = face._uv1;
			var uv2 : UV = face._uv2;
			var uv : UV;
			var material : Material = face.material;

			sourceNode.removeFace(face);

			if (index == 0) {
				uv = new UV(uv0._u + t*(uv1._u-uv0._u), uv0._v + t*(uv1._v-uv0._v));
				face1 = new Face(v0, tPoint, v2, material, uv0, uv, uv2);
				face2 = new Face(tPoint, v1, v2, material, uv, uv1, uv2);
			}
			else if (index == 1) {
				uv = new UV(uv1._u + t*(uv2._u-uv1._u), uv1._v + t*(uv2._v-uv1._v));
				face1 = new Face(v0, v1, tPoint, material, uv0, uv1, uv);
				face2 = new Face(tPoint, v2, v0, material, uv, uv2, uv0);
			}
			else if (index == 2) {
				uv = new UV(uv2._u + t*(uv0._u-uv2._u), uv2._v + t*(uv0._v-uv2._v));
				face1 = new Face(v0, v1, tPoint, material, uv0, uv1, uv);
				face2 = new Face(tPoint, v1, v2, material, uv, uv1, uv2);
			}

			sourceNode.addFace(face1);
			sourceNode.addFace(face2);
		}
	}
}