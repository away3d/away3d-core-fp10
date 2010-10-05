package away3d.graphs.bsp.builder
{
	import away3d.arcane;
	import away3d.core.geom.*;

	import away3d.events.*;
	import away3d.graphs.*;

	import flash.events.*;
	import flash.utils.*;

	use namespace arcane;

	public class SimplePlanePicker extends EventDispatcher implements IBSPPlanePicker
	{
		private var _splitWeight : Number = 10;
		private var _balanceWeight : Number = 1;
		private var _xzAxisWeight : Number = 1.5;
		private var _yAxisWeight : Number = 1.2;
		private var _maxTimeOut : Number = 500;
		private var _completeEvent : Event;

		private var _bestPlane : Plane3D;
		private var _canceled : Boolean;
		private var _iterator : VectorIterator;
		private var _faces : Vector.<NGon>;
		private var _bestScore : Number;

		public function SimplePlanePicker()
		{
			super();
			_completeEvent = new Event(Event.COMPLETE);
		}

		// to do: rename to ngons
		public function pickPlane(faces : Vector.<NGon>) : void
		{
			_faces = faces;
			_bestPlane = null;
			_canceled = false;
			_iterator = new VectorIterator(Vector.<Object>(faces));
			_iterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onIterationComplete, false, 0, true);
			_iterator.performMethodAsync(pickPlaneStep);
		}

		public function cancel() : void
		{
			_canceled = true;
			if (_iterator) {
				_iterator.cancelAsyncTraversal();
				_iterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onIterationComplete);
			}
		}

		public function get pickedPlane() : Plane3D
		{
			return _bestPlane;
		}

		public function get splitWeight() : Number
		{
			return _splitWeight;
		}

		public function set splitWeight(value : Number) : void
		{
			_splitWeight = value;
		}

		public function get balanceWeight() : Number
		{
			return _balanceWeight;
		}

		public function set balanceWeight(value : Number) : void
		{
			_balanceWeight = value;
		}

		public function get xzAxisWeight() : Number
		{
			return _xzAxisWeight;
		}

		public function set xzAxisWeight(value : Number) : void
		{
			_xzAxisWeight = value;
		}

		public function get yAxisWeight() : Number
		{
			return _yAxisWeight;
		}

		public function set yAxisWeight(value : Number) : void
		{
			_yAxisWeight = value;
		}

		public function get maxTimeOut() : int
		{
			return _maxTimeOut;
		}

		public function set maxTimeOut(value : int) : void
		{
			_maxTimeOut = value;
		}


		private function pickPlaneStep(face : NGon) : void
		{
			if (_canceled) {
				dispatchEvent(new Event(Event.CANCEL));
				return;
			}

			if (!face._isSplitter) {
				getPlaneScore(face.plane, _faces);
				if (_bestScore == 0) {
					_iterator.cancelAsyncTraversal();
					setTimeout(onIterationComplete, 40);
				}
			}
		}

		/**
		 * Calculates the score for a given plane. The lower the score, the better a partition plane it is.
		 * Score is -1 if the plane is completely unsuited.
		 */
		private function getPlaneScore(candidate : Plane3D, faces : Vector.<NGon>) : void
		{
			var score : Number;
			var classification : int;
			var plane : Plane3D;
			var face : NGon;
			var i : int = faces.length;
			var posCount : int, negCount : int, splitCount : int;

			while (--i >= 0) {
				face = faces[i];
				classification = face.classifyToPlane(candidate);
				if (classification == -2) {
					plane = face.plane;
					if (candidate.a * plane.a + candidate.b * plane.b + candidate.c * plane.c > 0)
						++posCount;
					else
						++negCount;
				}
				else if (classification == Plane3D.BACK)
					++negCount;
				else if (classification == Plane3D.FRONT)
					++posCount;
				else
					++splitCount;
			}

			// all polys are on one side
			if ((posCount == 0 || negCount == 0) && splitCount == 0)
				return;
			else {
				score = Math.abs(negCount-posCount)*_balanceWeight + splitCount*_splitWeight;
				if (candidate._alignment != Plane3D.X_AXIS || candidate._alignment != Plane3D.Z_AXIS) {

					if (candidate._alignment != Plane3D.Y_AXIS)
						score *= _xzAxisWeight;
					else
						score *= _yAxisWeight;
				}

			}

			if (score >= 0 && score < _bestScore) {
				_bestScore = score;
				_bestPlane = candidate;
			}
		}

		private function onIterationComplete(event : IteratorEvent = null) : void
		{
			dispatchEvent(_completeEvent);
		}
	}
}