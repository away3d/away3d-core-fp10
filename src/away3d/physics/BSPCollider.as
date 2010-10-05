package away3d.physics
{
	import away3d.cameras.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.graphs.bsp.*;
	
	import flash.geom.*;

	use namespace arcane;
	
	// TO DO: perform auto-update
	
	/**
	 * BSPCollider manages an object to move around in a BSPTree while doing collision detection.
	 * This can be used to create FPS-style navigation.
	 */
	public class BSPCollider
	{
		private var _minBounds : Vector3D;
		private var _maxBounds : Vector3D;
		private var _maxClimbHeight : Number = 10;
		
		private var _object : Object3D;
		private var _bspTree : BSPTree;
		
		private var _velocity : Vector3D = new Vector3D();
		
		private var _startPos : Vector3D = new Vector3D();
		private var _targetPos : Vector3D = new Vector3D();
		private var _tempPos : Vector3D = new Vector3D();
		private var _flyMode : Boolean = true;
		private var _maxIterations : Number = 5;
		private var _onSolidGround : Boolean;
		private var _stuck : Boolean;
		
		private var _method : int = BSPTree.TEST_METHOD_ELLIPSOID;

		/**
		 * Creates a BSPCollider object.
		 * 
		 * @param object The object that moves around in the world. This can be a Camera3D (FPS) or a Mesh
		 * @bspTree The BSP tree against which collisions need to be checked
		 */
		public function BSPCollider(object : Object3D, bspTree : BSPTree)
		{
			if (object is Mesh) {
				_minBounds = new Vector3D(object.minX, object.minY, object.minZ);
				_maxBounds = new Vector3D(object.maxX, object.maxY, object.maxZ);
			}
			else {
				_minBounds = new Vector3D(-100, -100, -100);
				_maxBounds = new Vector3D(100, 100, 100);
			}
			_object = object;
			_bspTree = bspTree;
		}
		
		/**
		 * The maximum height difference allowed to bridge when a collision is found, used for steps etc. Only used when calling move with flyMode set to true.
		 */
		public function get maxClimbHeight() : Number
		{
			return _maxClimbHeight;
		}
		
		public function set maxClimbHeight(maxClimbHeight : Number) : void
		{
			_maxClimbHeight = maxClimbHeight;
		}
		
		public function get flyMode() : Boolean
		{
			return _flyMode;
		}
		
		public function set flyMode(flyMode : Boolean) : void
		{
			_flyMode = flyMode;
			_onSolidGround &&= !flyMode;
		}
		
		public function get maxIterations() : Number
		{
			return _maxIterations;
		}
		
		public function set maxIterations(maxIterations : Number) : void
		{
			_maxIterations = maxIterations;
		}
		
		public function move(x : Number, y : Number, z : Number) : Vector3D
		{
			var newVelocity : Vector3D;
//			if (flyMode || _maxClimbHeight == 0 || y >= 0) {
				newVelocity = moveBy(x, y, z);
//			}
//			else {
				// in two steps to allow climbing stairs
//				newVelocity = moveBy(x, 0, z);
				
				// do not apply downward force if we're already on solid ground
//				if (!_onSolidGround) {
//					newVelocity.y = moveBy(0, y, 0).y;
					if (_onSolidGround) newVelocity.y = 0;
//				}
//				else
//					newVelocity.y = 0;
//			}
				
			return newVelocity;
		}
		
		private var _halfExtents : Vector3D = new Vector3D();
		
		/**
		 * Moves the object to a target point. If a collision is found, the trajectory is adapted.
		 * 
		 * @return Whether or not a collision occured.
		 */		
		private function moveBy(x : Number, y : Number, z : Number) : Vector3D
		{
			var directChild : Boolean;
			var it : int;
			var collPlane : Plane3D;
			var BSPTransform : Matrix3D = _bspTree.sceneTransform;
			var inverseBSPTransform : Matrix3D = _bspTree.inverseSceneTransform;
			var diffY : Number;
			var newForce : Vector3D = new Vector3D();
			var climbed : Boolean;
			var hit : Boolean;
			
			if (x == 0 && y == 0 && z == 0) return newForce;
			
			directChild = _object.parent == _object.scene || _object is Camera3D;
			
			if (directChild) {
				_startPos.x = _object.x;
				_startPos.y = _object.y;
				_startPos.z = _object.z;
			}
			else
				_startPos = _object.scenePosition.clone();
			
			// convert positions to bsp space
			if (_flyMode) {
				// work in local space
				_targetPos.x = x;
				_targetPos.y = y;
				_targetPos.z = z;
				
				// transform to world space
				_targetPos = _object.sceneTransform.transformVector(_targetPos);
			}
			else {
				// work in world space
				_velocity.x = x;
				_velocity.y = 0;
				_velocity.z = z;
				_velocity = _object.sceneTransform.deltaTransformVector(_velocity);
				
				_targetPos.x = _startPos.x + _velocity.x;
				_targetPos.y = _startPos.y + y;
				_targetPos.z = _startPos.z + _velocity.z;
			}
			
			// transform to bsp local space
			_startPos = inverseBSPTransform.transformVector(_startPos);
			_targetPos = inverseBSPTransform.transformVector(_targetPos);
			
			updateBounds();
			
			// local velocity information
			_velocity.x = _targetPos.x - _startPos.x;
			_velocity.y = _targetPos.y - _startPos.y;
			_velocity.z = _targetPos.z - _startPos.z;
			
			hit = _bspTree.traceCollision(_startPos, _targetPos, _method, _halfExtents);
			collPlane = hit? _bspTree._collisionPlane : null;
			
			if (_onSolidGround && collPlane && !_flyMode && _maxClimbHeight > 0) {
				var ny : Number = collPlane.b;
				if (ny < 0) ny = -ny;
				
				// check if we're not dealing with a slope
				if (ny < .05) {
					_startPos.y += _maxClimbHeight;
					_targetPos.y += _maxClimbHeight;
//					_targetPos.x += _velocity.x*2;
//					_targetPos.z += _velocity.z*2;
					
					if (_bspTree.traceCollision(_startPos, _targetPos, _method, _halfExtents)) {
						_startPos.y -= _maxClimbHeight;
						_targetPos.y -= _maxClimbHeight;
					}
					else {
						// to do: PROJECT BACK DOWN
						projectDown(_targetPos);
						climbed = true;
						collPlane = null;
						hit = false;
//						_onSolidGround = false;
					}
//					_targetPos.x -= _velocity.x*2;
//					_targetPos.z -= _velocity.z*2;
				}
			}
			
			// until we find a position that is valid, keep checking where to "slide" the object
			while (collPlane && it++ < _maxIterations) {
				// check if x or z are changed, if so, see if we can climb up
				slideTarget(collPlane);
				hit = _bspTree.traceCollision(_startPos, _targetPos, _method, _halfExtents);
				collPlane = hit? _bspTree._collisionPlane : null;
			}
			
			// if no vertical difference between intended movement and blocked movement,
			// it means we're free-falling and cannot climb up
			if (!_flyMode && !climbed) {
				diffY = _targetPos.y - _startPos.y - _velocity.y;
				diffY = _targetPos.y - _startPos.y - y;
				if (diffY < 0) diffY = -diffY;
				_onSolidGround = diffY > 0.1;
			}
			
			// object allowed to move
			if (!hit) {
				resetBounds();
				// transform to world space
				_targetPos = BSPTransform.transformVector(_targetPos);
				
				if (!directChild)
					_targetPos = _object.parent.inverseSceneTransform.transformVector(_targetPos);
				
				newForce.x = _targetPos.x-_object.x;
				newForce.y = _targetPos.y-_object.y;
				if (newForce.y > y) newForce.y = y;
				newForce.z = _targetPos.z-_object.z;
				_object.x = _targetPos.x;
				_object.y = _targetPos.y;
				_object.z = _targetPos.z;
				
				_stuck = false;
			}
			else {
				newForce.x = 0;
				newForce.y = 0;
				newForce.z = 0;
				
				// stuck in solid node if hit detected without a collision plane
				_stuck = (collPlane == null);
			}
			
			return newForce;
		}
		
		private function projectDown(targetPos : Vector3D) : void
		{
			_tempPos.x = targetPos.x;
			_tempPos.y = targetPos.y - _maxClimbHeight*2;
			_tempPos.z = targetPos.z;
			
			if (_bspTree.traceCollision(targetPos, _tempPos, _method, _halfExtents))
				targetPos.y = targetPos.y+(_bspTree.collisionRatio-BSPTree.EPSILON)*(_tempPos.y-targetPos.y);
		}

		private var _offsetX : Number = 0;
		private var _offsetY : Number = 0;
		private var _offsetZ : Number = 0;
		
		private function updateBounds() : void
		{
			if (_method == BSPTree.TEST_METHOD_POINT) {
				_halfExtents.x = 0;
				_halfExtents.y = 0;
				_halfExtents.z = 0;
				return;
			}
			
			_halfExtents.x = (_maxBounds.x - _minBounds.x)*.5;
			_halfExtents.y = (_maxBounds.y - _minBounds.y)*.5;
			_halfExtents.z = (_maxBounds.z - _minBounds.z)*.5;
			_offsetX = _maxBounds.x - _halfExtents.x;
			_offsetY = _maxBounds.y - _halfExtents.y;
			_offsetZ = _maxBounds.z - _halfExtents.z;
			_startPos.x += _offsetX;
			_startPos.y += _offsetY;
			_startPos.z += _offsetZ;
			_targetPos.x += _offsetX;
			_targetPos.y += _offsetY;
			_targetPos.z += _offsetZ;
		}
		
		private function resetBounds() : void
		{
			if (_method == BSPTree.TEST_METHOD_POINT) return;
			_targetPos.x -= _offsetX;
			_targetPos.y -= _offsetY;
			_targetPos.z -= _offsetZ;
		}

		private function slideTarget(plane : Plane3D) : void
		{
			var dist : Number;
			var a : Number = plane.a,
				b : Number = plane.b,
				c : Number = plane.c,
				d : Number = plane.d;
			var offset : Number = 0;
			var ox : Number, oy : Number, oz : Number;
			
			if (testMethod == BSPTree.TEST_METHOD_AABB)
							offset = 	(a > 0? a*_halfExtents.x : -a*_halfExtents.x) +
										(b > 0? b*_halfExtents.y : -b*_halfExtents.y) +
										(c > 0? c*_halfExtents.z : -c*_halfExtents.z);
			else if (testMethod == BSPTree.TEST_METHOD_ELLIPSOID) {
				ox = a*_halfExtents.x;
				oy = b*_halfExtents.y;
				oz = c*_halfExtents.z;
				offset = Math.sqrt(ox*ox + oy*oy + oz*oz);
			}
			
			dist = offset + BSPTree.EPSILON - a * _targetPos.x - b*_targetPos.y - c*_targetPos.z - d;
			
			_targetPos.x += a*dist;
			_targetPos.y += b*dist;
			_targetPos.z += c*dist;
		}

		public function get minBounds() : Vector3D
		{
			return _minBounds;
		}
		
		public function set minBounds(minBounds : Vector3D) : void
		{
			_minBounds = minBounds;
		}
		
		public function get maxBounds() : Vector3D
		{
			return _maxBounds;
		}
		
		public function set maxBounds(maxBounds : Vector3D) : void
		{
			_maxBounds = maxBounds;
		}
		
		public function get onSolidGround() : Boolean
		{
			return _onSolidGround;
		}
		
		public function get testMethod() : int
		{
			return _method;
		}
		
		public function set testMethod(method : int) : void
		{
			_method = method;
		}
		
		public function get stuck() : Boolean
		{
			return _stuck;
		}
		
		public function set stuck(stuck : Boolean) : void
		{
			_stuck = stuck;
		}
	}
}