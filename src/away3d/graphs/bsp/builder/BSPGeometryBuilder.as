package away3d.graphs.bsp.builder
{
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Vertex;
	import away3d.core.geom.NGon;
	import away3d.events.*;
	import away3d.graphs.*;
	import away3d.graphs.bsp.*;

	import flash.events.*;
	import flash.geom.*;

	use namespace arcane;

	internal class BSPGeometryBuilder extends EventDispatcher implements IBSPBuilder
	{
		private var _tree : BSPTree;
		private var _progressEvent : BSPBuildEvent;

		private var _totalFaces : int;
		private var _assignedFaces : int;

		private var _iterator : TreeIterator;

		private var _buildNode : BSPNode;
		private var _numNodes : int = 0;
		private var _nodeCount : int;
		private var _canceled : Boolean;

		private var _planePicker : IBSPPlanePicker;

		public function BSPGeometryBuilder(planePicker : IBSPPlanePicker = null)
		{
			_tree = new BSPTree();
			_progressEvent = new BSPBuildEvent(BSPBuildEvent.BUILD_PROGRESS);
			_progressEvent.message = "Building BSP tree";
			_progressEvent.totalParts = numSteps;
			_progressEvent.count = 1;
			_planePicker = planePicker || new SimplePlanePicker();
		}

		public function destroy() : void
		{
		}

		public function get numNodes() : int
		{
			return _numNodes;
		}

		public function get numSteps() : int
		{
			return 1;
		}

		public function get tree() : BSPTree
		{
			return _tree;
		}

		public function get rootNode() : BSPNode
		{
			return _tree.rootNode;
		}

		public function get maxTimeOut() : int
		{
			return _planePicker.maxTimeOut;
		}

		public function set maxTimeOut(value : int) : void
		{
			_planePicker.maxTimeOut = value;
		}

		public function get splitWeight() : Number
		{
			return _planePicker.splitWeight;
		}


		public function set splitWeight(value : Number) : void
		{
			_planePicker.splitWeight = value;
		}

		public function get balanceWeight() : Number
		{
			return _planePicker.balanceWeight;
		}

		public function set balanceWeight(value : Number) : void
		{
			_planePicker.balanceWeight = value;
		}

		public function get xzAxisWeight() : Number
		{
			return _planePicker.xzAxisWeight;
		}

		public function set xzAxisWeight(value : Number) : void
		{
			_planePicker.xzAxisWeight = value;
		}

		public function get yAxisWeight() : Number
		{
			return _planePicker.yAxisWeight;
		}

		public function set yAxisWeight(value : Number) : void
		{
			_planePicker.yAxisWeight = value;
		}

		public function get leaves() : Vector.<BSPNode>
		{
			return tree.leaves;
		}

		public function cancel() : void
		{
			_canceled = true;
		}

		public function build(source : Array) : void
		{
			_numNodes = 0;
			_totalFaces = source.length;
			_iterator = new TreeIterator(rootNode);
			_buildNode = BSPNode(_iterator.reset());
			_canceled = false;
			rootNode._buildFaces = convertFaces(source);
			buildStep(null);
		}


		private function onBuildComplete() : void
		{
			try {
				rootNode.gatherLeaves(tree.leaves);
			}
			catch (error : Error) {
				var errorEvent : BSPBuildEvent = new BSPBuildEvent(BSPBuildEvent.BUILD_ERROR);
				errorEvent.message = error.message;
				dispatchEvent(errorEvent);
			}

			_nodeCount = 0;
			_tree.init();

			dispatchEvent(new BSPBuildEvent(BSPBuildEvent.BUILD_COMPLETE));
		}

		/**
		 * converts faces to N-Gons
		 */
		private function convertFaces(faces : Array) : Vector.<NGon>
		{
			var polys : Vector.<NGon> = new Vector.<NGon>();
			var ngon : NGon;
			var len : int = faces.length;
			var i : int, c : int;
			var u : Vector3D, v : Vector3D, cross : Vector3D;
			var v1 : Vertex, v2 : Vertex, v3 : Vertex;
			var face : Face;

			u = new Vector3D();
			v = new Vector3D();
			cross = new Vector3D();
			                                                           
			do {
				face = faces[i];

				v1 = face.vertices[0];
				v2 = face.vertices[1];
				v3 = face.vertices[2];
				// check if collinear (caused by t-junctions)
				u.x = v2.x-v1.x;
				u.y = v2.y-v1.y;
				u.z = v2.z-v1.z;
				v.x = v1.x-v3.x;
				v.y = v1.y-v3.y;
				v.z = v1.z-v3.z;
				cross = v.crossProduct(u);
				if (cross.length > BSPTree.EPSILON) {
					ngon = new NGon();
					ngon.fromTriangle(face);
					polys[c++] = ngon;
				}
			} while (++i < len);
			return polys;
		}
		// even tho iterator only knows about ITreeNode, we know it will be BSPNode, so type strictly

		private function buildStep(event : Event) : void
		{
			if (_canceled) {
				dispatchEvent(new BSPBuildEvent(BSPBuildEvent.BUILD_CANCELED));
				return;
			}

			// not the first (ie root node)
			if (event) {
				_assignedFaces += _buildNode._assignedFaces;
				_totalFaces += _buildNode._newFaces;
				_buildNode.removeEventListener(Event.COMPLETE, buildStep);
				_buildNode.removeEventListener(BSPBuildEvent.BUILD_WARNING, propagateBuildEvent);
				_buildNode.removeEventListener(BSPBuildEvent.BUILD_ERROR, propagateBuildEvent);
				_buildNode = BSPNode(_iterator.next());
			}

			notifyProgress(_assignedFaces, _totalFaces);

			if (_buildNode) {
				_buildNode.nodeId = _numNodes++;
				_buildNode.addEventListener(Event.COMPLETE, buildStep, false, 0, true);
				_buildNode.addEventListener(BSPBuildEvent.BUILD_WARNING, propagateBuildEvent, false, 0, true);
				_buildNode.addEventListener(BSPBuildEvent.BUILD_ERROR, propagateBuildEvent, false, 0, true);
				_buildNode.build();
			}
			else
				onBuildComplete();
		}

		private function notifyProgress(steps : int, total : int) : void
       	{
			_progressEvent.percentPart = steps/total;
			dispatchEvent(_progressEvent);
		}

		private function propagateBuildEvent(event : BSPBuildEvent) : void
		{
			dispatchEvent(event);
		}
	}
}