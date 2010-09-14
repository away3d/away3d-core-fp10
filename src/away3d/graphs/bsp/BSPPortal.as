package away3d.graphs.bsp
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.geom.*;

	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;

	use namespace arcane;
	
	public final class BSPPortal extends EventDispatcher
	{
		public static const RECURSED_PORTAL_COMPLETE : String = "RecursedPortalComplete";
		public var index : int;
		public var nGon : NGon;
		
		public var sourceNode : BSPNode;
		public var frontNode : BSPNode;
		public var backNode : BSPNode;
		public var listLen : int;
		public var frontList : Vector.<uint>;
		public var visList : Vector.<uint>;
		public var hasVisList : Boolean;
		public var frontOrder : int;
		public var maxTimeout : int = 0;
		
		public var antiPenumbrae : Array = [];
		
		// containing all visible neighbours, through which we can see adjacent leaves
		public var neighbours : Vector.<BSPPortal>;
		
		// iteration for vis testing
		private static var TRAVERSE_PRE : int = 0;
		private static var TRAVERSE_IN : int = 1;
		private static var TRAVERSE_POST : int = 2;
		
		private var _iterationIndex : int;
		private var _state : int;
		private var _currentPortal : BSPPortal;
		private var _needCheck : Boolean;
		private var _numPortals : int;
		private var _backPortal : BSPPortal;
		private var _portals : Vector.<BSPPortal>;	
		
		private static var _sizeLookUp : Vector.<int>;
		
		public var next : BSPPortal;
		
		arcane var _currentAntiPenumbra : Vector.<Plane3D>;
		arcane var _currentParent : BSPPortal;
		arcane var _currentFrontList : Vector.<uint>;
		
		private static var _planePool : Array = [];
		
		public function BSPPortal()
		{
			if (!_sizeLookUp) generateSizeLookUp();
			//leaves = new Vector.<BSPNode>();
			nGon = new NGon();
			// Math.round(Math.random()*0xffffff)
			//nGon.material = new WireColorMaterial(0xffffff, {alpha : .5});
			nGon.vertices = new Vector.<Vertex>();
		}
		
		/**
		 * Generates a look-up table that tells how many visible portals are set in an 8-bit bit mask
		 */
		private function generateSizeLookUp() : void
		{
			var size : int = 255;
			var i : int = 1;
			var bit : int;
			var count : int;
			
			_sizeLookUp = new Vector.<int>(255);
			_sizeLookUp[0x00] = 0;
			
			do {
				count = 0;
				bit = 8;
				while (--bit >= 0)
					if (i & (1 << bit)) ++count;
					
				_sizeLookUp[i] = count;
			} while (++i < size);
			
			_sizeLookUp[0xff] = 8;
		}
		
		/*private function getPlaneFromPool() : Plane3D
		{
			return _planePool.length > 0? _planePool.pop() : new Plane3D();
		}
		
		private function addPlaneToPool(plane : Plane3D) : void
		{
			_planePool.push(plane);
		}*/
		
		/**
		 * Creates an initial portal from a node's partitionplane, encompassing the entire tree
		 */
		public function fromNode(node : BSPNode, root : BSPNode) : Boolean
		{
			var bounds : Array = root._bounds;
			var plane : Plane3D = nGon.plane = node._partitionPlane;
			var dist : Number;
			var radius : Number;
			var distance: Vector3D;
			var direction1 : Vector3D, direction2 : Vector3D;
			var center : Vector3D = new Vector3D(	(root._minX+root._maxX)*.5,
													(root._minY+root._maxY)*.5,
													(root._minZ+root._maxZ)*.5 );
			var normal : Vector3D = new Vector3D(plane.a, plane.b, plane.c);
			var vertLen : int = 0;
			
			sourceNode = node;
			
			distance = center.subtract(bounds[0]);
			radius = distance.length;
			radius = Math.sqrt(radius*radius + radius*radius);
			
			// calculate projection of aabb's center on plane
			dist = plane.distance(center);
			center.x -= dist*plane.a;
			center.y -= dist*plane.b; 
			center.z -= dist*plane.c;
			
			// perpendicular to plane normal & world axis, parallel to plane
			direction1 = getPerpendicular(normal);
			direction1.normalize();
			
			// perpendicular to plane normal & direction1, parallel to plane
			direction2 = new Vector3D();
			direction2 = direction1.crossProduct(normal);
			direction2.normalize();
			
			// form very course bounds of bound projection on plane
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction1.x*radius,
													center.y + direction1.y*radius,
													center.z + direction1.z*radius);
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction2.x*radius,
													center.y + direction2.y*radius,
													center.z + direction2.z*radius);
			
			// invert direction
			direction1.scaleBy(-1);
			direction1.normalize();
			direction2.scaleBy(-1);
			direction2.normalize();
			
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction1.x*radius,
													center.y + direction1.y*radius,
													center.z + direction1.z*radius);
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction2.x*radius,
													center.y + direction2.y*radius,
													center.z + direction2.z*radius);
			
			// trim closely to world's bound planes
			trimToAABB(root);
			
			var prev : BSPNode = node; 
			while (node = node._parent) {
				// portal became too small
				if (!nGon || nGon.vertices.length < 3) return false;
				if (prev == node._positiveNode)
					nGon.trim(node._partitionPlane);
				else
					nGon.trimBack(node._partitionPlane);
				prev = node;
			}
			
			return true;
		}
		
		/**
		 * Clones the portal
		 */
		public function clone() : BSPPortal
		{
			var c : BSPPortal = new BSPPortal();
			c.nGon = nGon.clone();
			c.frontNode = frontNode;
			c.backNode = backNode;
			c.neighbours = neighbours;
			c._currentParent = _currentParent;
			c.frontList = frontList;
			c.visList = visList;
			c.index = index;
			return c;
		}
		
		/**
		 * Trims the portal to the tree's bounds
		 */
		private function trimToAABB(node : BSPNode) : void
		{
			var plane : Plane3D = new Plane3D(0, -1, 0, node._maxY);
			nGon.trim(plane);
			plane.b = 1; plane.d = -node._minY;
			nGon.trim(plane);
			plane.a = 1; plane.b = 0; plane.d = -node._minX;
			nGon.trim(plane);
			plane.a = -1; plane.d = node._maxX;
			nGon.trim(plane);
			plane.a = 0; plane.c = 1; plane.d = -node._minZ;
			nGon.trim(plane);
			plane.c = -1; plane.d = node._maxZ;
			nGon.trim(plane);
		}
		
		/**
		 * Generates a perpendicular vector for the initial portal
		 */
		private function getPerpendicular(normal : Vector3D) : Vector3D
		{
			var p : Vector3D;
			var q : Vector3D = new Vector3D(1, 1, 0);
			var r : Vector3D = new Vector3D(0, 1, 1);
			p = normal.crossProduct(q);
			if (p.length <= BSPTree.EPSILON) {
				p = normal.crossProduct(r);
			}
			return p;
		}
		
		/**
		 * Splits a portal along a plane
		 */
		public function split(plane : Plane3D) : Vector.<BSPPortal>
		{
			var posPortal : BSPPortal;
			var negPortal : BSPPortal;
			var splits : Vector.<NGon> = nGon.split(plane);
			var ngon : NGon;
			var newPortals : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			
			ngon = splits[0];
			if (ngon) {// && ngon.area > BSPTree.EPSILON) {
				posPortal = new BSPPortal();
				posPortal.nGon = ngon;
				//posPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				posPortal.sourceNode = sourceNode;
				posPortal.frontNode = frontNode;
				posPortal.backNode = backNode;
				newPortals[0] = posPortal;
			}
			ngon = splits[1];
			if (ngon) {// && ngon.area > BSPTree.EPSILON) {
				negPortal = new BSPPortal();
				negPortal.nGon = ngon;
				negPortal.sourceNode = sourceNode;
				negPortal.frontNode = frontNode;
				negPortal.backNode = backNode;
				//negPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				newPortals[1] = negPortal;
			}
			
			return newPortals;
		}
		
		
		/**
		 * Returns a Vector containing the current portal as well as an inverted portal. The results will be treated as one-way portals.
		 */
		public function partition() : Vector.<BSPPortal>
		{
			var parts : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			var inverted : BSPPortal = clone();

			inverted.frontNode = backNode;
			inverted.backNode = frontNode;
			inverted.nGon.invert();
			inverted._backPortal = this;
			_backPortal = inverted;
			
			parts[0] = this;
			parts[1] = inverted;
			return parts;
		}
		
		/**
		 * Creates the bit mask lists needed to store visible portals
		 */
		public function createLists(numPortals : int) : void
		{
			_numPortals = numPortals;
			// only using 1 byte per item, as to keep the size look up table small
			listLen = (numPortals >> 5) + 1;
			frontList = new Vector.<uint>(listLen);
			visList = new Vector.<uint>(listLen);
			_currentFrontList = new Vector.<uint>(listLen);
		}
		
		/**
		 * Adds a portal to a bit mask list
		 */
		public function addToList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 5] |=  (1 << (index & 0x1f));
		}
		
		/**
		 * Removes a portal to a bit mask list
		 */
		public function removeFromList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 5] &= ~(1 << (index & 0x1f));
		}
		
		/**
		 * Checks if a portal is within a bit mask list
		 */
		public function isInList(list : Vector.<uint>, index : int) : Boolean
		{
			if (!list) return false;
			return (list[index >> 5] & (1 << (index & 0x1f))) != 0;
		}
		
		/**
		 * Builds the initial front list. Only allow portals in front and facing away.
		 */
		public function findInitialFrontList(portals : Vector.<BSPPortal>) : void
		{
			var len : int = portals.length;
			var srcPlane : Plane3D = nGon.plane;
			var i : int;
			var compNGon : NGon;
			var listIndex : int;
			var bitIndex : int;
			var p : BSPPortal;
			
			do {
				p = portals[i];
				compNGon = p.nGon;
				
				// test if spanning or this portal is in front and other in back
				if (compNGon.classifyForPortalFront(srcPlane) && nGon.classifyForPortalBack(compNGon.plane)) {
					listIndex = index >> 5;
					bitIndex = index & 0x1f;
					// isInList(list.frontList, index)
					if ((p.frontList[listIndex] & (1 << bitIndex)) != 0) {
						// two portals can see eachother
						// removeFromList(list.frontList, index);
						p.frontList[listIndex] &= ~(1 << bitIndex);
						--p.frontOrder;
					}
					else {
						frontList[i >> 5] |=  (1 << (i & 0x1f));
						frontOrder++;
					}
				}
			} while (++i < len);
		}
		
		/**
		 * Finds the current portal's neighbours
		 */
		public function findNeighbours() : void
		{
			var backPortals : Vector.<BSPPortal> = frontNode._backPortals;
			var i : int = backPortals.length;
			
			var current : BSPPortal;
			var currIndex : int;
			var neighLen : int = 0;
			
			neighbours = new Vector.<BSPPortal>();
			
			while (--i >= 0) {
				current = backPortals[i];
				currIndex = current.index;
				
				//if (isInList(frontList, current.index)) {
				if (frontList[currIndex >> 5] & (1 << (currIndex & 0x1f))) {
					neighbours[neighLen++] = current;
					antiPenumbrae[currIndex] = generateAntiPenumbra(current.nGon);
				}
			}
			
			if (neighLen == 0) {
				i = listLen;
				while (--i >= 0)
					frontList[i] = 0;
				neighbours = null;
				frontOrder = 0;
			}
		}
		
		/**
		 * Performs exact testing to find portals visible from this portal.
		 */
		public function findVisiblePortals(portals : Vector.<BSPPortal>) : void
		{
			var i : int = listLen;
			_portals = portals;
			_state = TRAVERSE_PRE;
			_currentPortal = this;
			_needCheck = false;
			_iterationIndex = 0;
			_currentParent = null;
			
			while (--i >= 0)
				_currentFrontList[i] = frontList[i];
				
			findVisiblePortalStep();
		}
		
		private function findVisiblePortalStep() : void
		{
			var next : BSPPortal;
			var startTime : int = getTimer();
			var currNeighbours : Vector.<BSPPortal>;
			var i : int;
			var parent : BSPPortal;
			var currFront : Vector.<uint>;
			
			do {
				if (_currentPortal.frontOrder <= 0)
					_state = TRAVERSE_POST;
				
				if (_needCheck) {
					//if (!isInList(currList, currentPortal.index))
					var currIndex : int = _currentPortal.index;
					parent = _currentPortal._currentParent;
					currFront = parent._currentFrontList;
					if (((currFront[currIndex >> 5] & (1 << (currIndex & 0x1f))) != 0) &&
							determineVisibility(_currentPortal)) {
						//addToList(visList, _currentPortal.index);
						visList[currIndex >> 5] |=  (1 << (currIndex & 0x1f));
						
						// we will be recursing down this one, so need an updated frontlist for this sequence
						i = listLen;
						while (--i >= 0)
							_currentPortal._currentFrontList[i] = currFront[i] & _currentPortal.frontList[i];
					}
					else
						_state = TRAVERSE_POST;
				}
				
				if (_state == TRAVERSE_PRE) {
					currNeighbours = _currentPortal.neighbours;
					if (currNeighbours) {
						next = currNeighbours[0];
						next._iterationIndex = 0;
						next._currentParent = _currentPortal;
						_currentPortal = next;
						_needCheck = true;
					}
					else {
						_state = TRAVERSE_POST;
						_needCheck = false;
					}
				}
				else if (_state == TRAVERSE_IN) {
					currNeighbours = _currentPortal.neighbours;
					if (++_currentPortal._iterationIndex < currNeighbours.length) {
						next = currNeighbours[_currentPortal._iterationIndex];
						next._iterationIndex = 0;
						next._currentParent = _currentPortal;
						_currentPortal = next;
						_needCheck = true;
						_state = TRAVERSE_PRE;
					}
					else {
						_state = TRAVERSE_POST;
						_needCheck = false;
					}
				}
				else if (_state == TRAVERSE_POST) {
					// clear memory
					var pl : Plane3D;
					var anti : Vector.<Plane3D> = _currentPortal._currentAntiPenumbra;
					// don't clean up neighbour penumbra, these are needed!
					// TO DO: are they actually still needed?
					if (anti && _currentPortal._currentParent != this) {
						i = anti.length;
						while (--i >= 0) {
							(pl = anti[i])._alignment = 0;
							_planePool.push(pl);
						}
						_currentPortal._currentAntiPenumbra = null;
					}
					
					_currentPortal = _currentPortal._currentParent;
					if (_currentPortal._iterationIndex < _currentPortal.neighbours.length-1)
						_state = TRAVERSE_IN;
						
					_needCheck = false;
				}
			} while(	(_currentPortal != this || _state != TRAVERSE_POST) &&
						getTimer() - startTime < maxTimeout);
			
			if (_currentPortal == this && _state == TRAVERSE_POST) {
				// update front list
				i = listLen;
				while (--i >= 0)
					frontList[i] = visList[i];
				
				hasVisList = true;
				setTimeout(updateBackPortals, 40);
			}
			else {
				setTimeout(findVisiblePortalStep, 40);
			}
		}
		
		/**
		 * Updates the opposing portals visibility data based on what is calculated on this side
		 */
		private function updateBackPortals() : void
		{
			var currIndex : int;
			var backIndex : int = _backPortal.index >> 5;
			var backBit : uint = ~(1 << (_backPortal.index & 0x1f));
			var i : int;
			var portal : BSPPortal;
			
			do {
				portal = _portals[i];
				currIndex = portal.index;
				
				// if portal not visible, the other way around (via backportals) is invisible too
				if ((visList[currIndex >> 5] & (1 << (currIndex & 0x1f))) == 0)
					portal._backPortal.frontList[backIndex] &= backBit;
			} while (++i < _numPortals);
			
			setTimeout(notifyComplete, 40);
		}
		
		/**
		 * Tests precisely if a target portal is potentially visible from this portal.
		 */
		private function determineVisibility(currentPortal : BSPPortal) : Boolean
		{
			var currAntiPenumbra : Vector.<Plane3D>;
			var len : int;
			var i : int = listLen;
			var j : int;
			var parent : BSPPortal = currentPortal._currentParent;
			var currentNGon : NGon;
			var clone : NGon;
			var currIndex : int = currentPortal.index;
			var vis : Vector.<uint>;
			var back : BSPPortal; 
			var thisBackIndex : int;
			var verts : Vector.<Vertex>;
			var plane : Plane3D;
			var v : Vertex;
			var isOut : Boolean;
			
			if (parent == this) {
				// direct neighbour
				currentPortal._currentAntiPenumbra = antiPenumbrae[currIndex];
				return true;
			}
			
			// if not visible from other side 
			back = currentPortal._backPortal;
			if (back.hasVisList) {
				vis = back.visList;
				thisBackIndex = _backPortal.index;
				// not visible the other way around
				if ((vis[thisBackIndex >> 5] & (1 << (thisBackIndex & 0x1f))) == 0)
					return false;
			}
			
			currentNGon = currentPortal.nGon;
			currAntiPenumbra = parent._currentAntiPenumbra;
			len = currAntiPenumbra.length;
			
			i = len = currAntiPenumbra.length;
	
 			verts = currentNGon.vertices;
			while (--i >= 0) {
				// portal falls out of current antipenumbra	
				//if (currentNGon.isOutAntiPenumbra(currAntiPenumbra[i]))
				//	return false;
				plane = currAntiPenumbra[i];
				j = verts.length;
				while (--j >= 0) {
					isOut = true;
					v = verts[j];
					if (plane.a*v._x + plane.b*v._y + plane.c*v._z + plane.d > BSPTree.EPSILON) {
						isOut = false;
						j = 0;
					}
				}
				if (isOut) return false;
			}
			
			// clone and trim current portal to visible antiPenumbra
			clone = currentNGon.clone();
			
			i = len;
			while (--i >= 0) {
				clone.trim(currAntiPenumbra[i]);
				if (clone.vertices.length < 3) return false;
			}
			
			if (clone.isNeglectable())
				return false;
			
			// create new antiPenumbra for the trimmed portal
			currentPortal._currentAntiPenumbra = generateAntiPenumbra(clone);
			
			return true;
		}
		
		/**
		 * Lets the build tree know the current step is complete
		 */
		private function notifyComplete() : void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Creates the anti-penumbra between this and a target portal. An anti-penumbra is a set of planes encompassing the entire potential visible area through the two portals.
		 */
		private function generateAntiPenumbra(targetNGon : NGon) : Vector.<Plane3D>
		{
			var anti : Vector.<Plane3D> = new Vector.<Plane3D>();
			var vertices1 : Vector.<Vertex> = nGon.vertices;
			var vertices2 : Vector.<Vertex> = targetNGon.vertices;
			var len1 : int = vertices1.length;
			var len2 : int = vertices2.length;
			var plane : Plane3D = _planePool.length > 0? _planePool.pop() : new Plane3D();
			var i : int;
			var j : int;
			var k : int;
			var p : int;
			var v1 : Vertex;
			var classification1 : int, classification2 : int;
			var antiLen : int = 0;
			var firstLen : int;
			var d1x : Number, d1y : Number, d1z : Number,
				d2x : Number, d2y : Number, d2z : Number;
			var v2 : Vertex, v3 : Vertex;
			var nx : Number, ny : Number, nz : Number, l : Number, d : Number;
			var compPlane : Plane3D;
			var check : Boolean;
			var da : Number, db : Number, dc : Number, dd : Number;
			var eps : Number = BSPTree.EPSILON*BSPTree.EPSILON;
			
			i = len2;
			k = i-2;
			v2 = vertices2[i-1];
			while (--i >= 0) {
				v1 = v2;
				v2 = vertices2[k];
				j = len1;
				while (--j >= 0) {
					v3 = vertices1[j];
					//plane.from3vertices(v1, v2, v3);
					//plane.normalize();
					
					// create plane from points
					d1x = v2._x - v1._x;
					d1y = v2._y - v1._y;
					d1z = v2._z - v1._z;
					d2x = v3._x - v1._x;
					d2y = v3._y - v1._y;
					d2z = v3._z - v1._z;
					nx = d1y*d2z - d1z*d2y;
            		ny = d1z*d2x - d1x*d2z;
            		nz = d1x*d2y - d1y*d2x;
            		l = 1/Math.sqrt(nx*nx+ny*ny+nz*nz);
            		nx *= l; ny *= l; nz *= l;
					plane.a = nx;
            		plane.b = ny;
            		plane.c = nz;
					plane.d = d = -(nx*v1._x + ny*v1._y + nz*v1._z);
					
					classification1 = nGon.classifyToPlane(plane);
					classification2 = targetNGon.classifyToPlane(plane);
					
					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
						// planes coming out of the target portal should face inward
						if (classification2 == Plane3D.BACK) {
							plane.a = -nx;
							plane.b = -ny;
							plane.c = -nz;
							plane.d = -d;
						} 
						
						// check if plane already exists
						/*p = antiLen;
	            		check = true;
	            		while (--p >= 0 && check) {
	            			compPlane = anti[p];
	            			da = compPlane.a - nx;
	            			db = compPlane.b - ny;
	            			dc = compPlane.c - nz;
	            			dd = compPlane.d - d;
	            			
	            			if (	da*da+db*db+dc*dc < eps && 
	            					dd < BSPTree.EPSILON && dd > -BSPTree.EPSILON) {
	            				check = false;
	            			}
	            		}*/
	            		
	            		//if (check) {
							anti[antiLen++] = plane;
							plane = _planePool.length > 0? _planePool.pop() : new Plane3D();
	            		//}
	            		
	            		// plane has been found, move on to next edge
	            		j = 0;
					}
				}
				
				if (--k < 0) k = len2-1;
			}
			
			firstLen = antiLen;
			
			i = len1;
			k = i-2;
			v2 = vertices1[i-1];
			while (--i >= 0) {
				v1 = v2;
				v2 = vertices1[k];
				j = len2;
				while (--j >= 0) {
					v3 = vertices2[j];
//					plane.from3vertices(v1, vertices1[j], vertices1[k]);
//					plane.normalize();
					d1x = v2._x-v1._x;
					d1y = v2._y-v1._y;
					d1z = v2._z-v1._z;
					d2x = v3._x-v1._x;
					d2y = v3._y-v1._y;
					d2z = v3._z-v1._z;
					nx = d1y*d2z - d1z*d2y;
            		ny = d1z*d2x - d1x*d2z;
            		nz = d1x*d2y - d1y*d2x;
            		l = 1/Math.sqrt(nx*nx+ny*ny+nz*nz);
            		nx *= l; ny *= l; nz *= l;
            		d = -(nx*v1._x + ny*v1._y + nz*v1._z);
            		
            		plane.a = nx;
	            	plane.b = ny;
	            	plane.c = nz;
	            	plane.d = d;
	            		
					classification1 = nGon.classifyToPlane(plane);
					classification2 = targetNGon.classifyToPlane(plane);
						
					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
						if (classification2 == Plane3D.BACK) {
							plane.a = -nx;
							plane.b = -ny;
							plane.c = -nz;
							plane.d = -d;
						} 
						
						// check if plane already exists
						p = firstLen;
	            		check = true;
	            		while (--p >= 0 && check) {
	            			compPlane = anti[p];
	            			da = compPlane.a - nx;
	            			db = compPlane.b - ny;
	            			dc = compPlane.c - nz;
	            			dd = compPlane.d - d;
	            			if (	da*da+db*db+dc*dc < eps &&
	            					dd <= BSPTree.EPSILON && dd >= -BSPTree.EPSILON) {
	            				check = false;
	            			}
	            		}
	            		
	            		if (check) {
							anti[antiLen++] = plane;
							plane = _planePool.length > 0? _planePool.pop() : new Plane3D();
	            		}
	            		
	            		// plane has been found, move on to next edge
	            		j = 0;
					}
            	}
				if (--k < 0) k = len1-1;
			}
			
			// last plane is unused, push back on pool
			_planePool.push(plane);
			return anti;
		}
		
		
		/**
		 * Checks all the portals in the front list and tests if they fall within any of the neighbours' antipenumbra.
		 */
		public function removePortalsFromNeighbours(portals : Vector.<BSPPortal>) : void
		{
			if (frontOrder <= 0) return;
			
			var current : BSPPortal;
			var i : int = portals.length;
			var len : int = neighbours.length;
			var count : int;
			var j : int;
			var neigh : BSPPortal;
			
			while (--i >= 0) {
				current = portals[i];
				
				// only check if not neighbour and already in front list
				if (isInList(frontList, i) && neighbours.indexOf(current) == -1) {
					count = 0;
					
					j = len;
					while (--j >= 0) {
						neigh = neighbours[j];
						
						// is in front and in anti-pen, escape loop
						if (isInList(neigh.frontList, i) && current.checkAgainstAntiPenumbra(antiPenumbrae[neigh.index]))
							j = 0;
						else
							++count;
					}
					
					// not visible from portal through any neighbour
					if (count == len) {
						removeFromList(frontList, i);
						frontOrder--;
					}
				}
			}
		}
		
		/**
		 * Updates the portal's visibility information based on the neighbour information (if not visible from neighbours, not visible at all)
		 */
		public function propagateVisibility() : void
		{
			var j : int;
			var k : int;
			var list : Vector.<uint> = new Vector.<uint>(listLen);
			var neighbour : BSPPortal;
			var neighList : Vector.<uint>;
			var neighIndex : int;
			
			if (frontOrder <= 0) return;
			
			j = neighbours.length-1;
			
			// find all portals visible from any neighbour
			// first in list, copy front list
			neighbour = neighbours[j];
			neighList = neighbour.frontList;
			k = listLen;
			while (--k >= 0)
				list[k] = neighList[k];

			neighIndex = neighbour.index;
			list[neighIndex >> 5] |=  (1 << (neighIndex & 0x1f));
			
			// add other neighbours' visible lists into the mix
			while (--j >= 0) {
				neighbour = neighbours[j];
				neighList = neighbour.frontList;
				k = listLen;
				while (--k >= 0)
					list[k] |= neighList[k];

				neighIndex = neighbour.index;
				list[neighIndex >> 5] |=  (1 << (neighIndex & 0x1f));
			}
			
			k = listLen;
			// only visible if visible from neighbours and visible from current
			while (--k >= 0)
				frontList[k] &= list[k];
			
			frontOrder = 0;
			k = listLen;
			var val : uint;
			while (--k >= 0) {
				val = frontList[k];
				frontOrder += _sizeLookUp[val & 0xff];
				frontOrder += _sizeLookUp[(val >> 8) & 0xff];
				frontOrder += _sizeLookUp[(val >> 16) & 0xff];
				frontOrder += _sizeLookUp[(val >> 24) & 0xff];
			}
		}
		
		/**
		 * Checks if this node is visible in a given antiPenumbra
		 */
		private function checkAgainstAntiPenumbra(antiPenumbra : Vector.<Plane3D>) : Boolean
		{
			var i : int = antiPenumbra.length;
			
			while (--i >= 0)
				if (nGon.isOutAntiPenumbra(antiPenumbra[i])) return false;

			return true;
		}
	}
}