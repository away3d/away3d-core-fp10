package away3d.primitives
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.primitives.data.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	public class NURBS extends AbstractPrimitive
	{
		private var _controlNet:Array;
		private var _uOrder:Number;
		private var _vOrder:Number;
		private var _numVContolPoints:int;
		private var _numUContolPoints:int;
		private var _uSegments:int;
		private var _vSegments:int;
		private var _uKnotSequence:Array;
		private var _vKnotSequence:Array;
		private var _renderMode:int;
		private var _pointCache:Array = [];
		private var _mbasis:Array = new Array();
		private var _nbasis:Array = new Array();
		private var _nplusc:int;
		private var _mplusc:int;
		private var _uRange:Number;
		private var _vRange:Number;	
		private var _autoGenKnotSeq:Boolean = false;
		private var _invert:Boolean;
		private var _tmpPM:WeightedVertex = new WeightedVertex();
		private var _tmpP1:WeightedVertex = new WeightedVertex();
		private var _tmpP2:WeightedVertex = new WeightedVertex();
		private var _tmpN1:Vector3D = new Vector3D();
		private var _tmpN2:Vector3D = new Vector3D();
		
		public var surface:Array = new Array();
		
		public static const NURBS_MESH:int = 0;
		public static const CONTROL_POINT_NET:int = 1;
		
		
		/**
		 * Defines the control point net to describe the NURBS surface
		 */
		public function get controlNet():Array {
			return _controlNet;
		}
		
		public function set controlNet(value:Array):void {
			if (_controlNet == value)
				return;
				
			_controlNet = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the number of control points along the U splines that influence any given point on the curve
		 */
		public function get uOrder():int {
			return _uOrder;
		}
		
		public function set uOrder(value:int):void {
			if (_uOrder == value)
				return;
				
			_uOrder = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the number of control points along the V splines that influence any given point on the curve
		 */
		public function get vOrder():int {
			return _vOrder;
		}
		
		public function set vOrder(value:int):void {
			if (_vOrder == value)
				return;
				
			_vOrder = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the number of control points along the U splines
		 */
		public function get uControlPoints():int {
			return _numUContolPoints;
		}
		
		public function set uControlPoints(value:int):void {
			if (_numUContolPoints == value)
				return;
				
			_numUContolPoints = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the number of control points along the V splines
		 */
		public function get vControlPoints():int {
			return _numVContolPoints;
		}
		
		public function set vControlPoints(value:int):void {
			if (_numVContolPoints == value)
				return;
				
			_numVContolPoints = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the knot sequence in the U direction that determines where and how the control points 
		 * affect the NURBS curve.
		 */
		public function get uKnot():Array {
			return _uKnotSequence;
		}
		
		public function set uKnot(value:Array):void {
			if (_uKnotSequence == value)
				return;
				
			_uKnotSequence = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the knot sequence in the V direction that determines where and how the control points 
		 * affect the NURBS curve.
		 */
		public function get vKnot():Array {
			return _vKnotSequence;
		}
		
		public function set vKnot(value:Array):void {
			if (_vKnotSequence == value)
				return;
				
			_vKnotSequence = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the number segments (triangle pair) the final curve will be divided into in the U direction
		 */
		public function get uSegments():int {
			return _uSegments;
		}
		
		public function set uSegments(value:int):void {
			if (_uSegments == value)
				return;
				
			_uSegments = value;
			_primitiveDirty = true;
		}
		
		/**
		 * Defines the number segments (triangle pair) the final curve will be divided into in the V direction
		 */
		public function get vSegments():int {
			return _vSegments;
		}
		
		public function set vSegments(value:int):void {
			if (_vSegments == value)
				return;
				
			_vSegments = value;
			_primitiveDirty = true;
		}

		/**
		 * NURBS primitive generates a segmented mesh that fits the curved surface defined by the specified
		 * control points based on weighting, order influence and knot sequence
		 *  
		 * @param cNet Array of control points (WeightedVertex array)
		 * @param uCtrlPnts Number of control points in the U direction
		 * @param vCtrlPnts Number of control points in the V direction
		 * @param init Init object for the mesh
		 * 
		 */
		public function NURBS(cNet:Array, uCtrlPnts:int, vCtrlPnts:int, init:Object = null) {
			
			super(init);
			
			_controlNet = cNet;
			_numUContolPoints = uCtrlPnts;
			_numVContolPoints = vCtrlPnts;
			_renderMode = ini.getInt("renderMode", NURBS_MESH);
			_uOrder = ini.getInt("uOrder", 4);
			_vOrder = ini.getInt("vOrder", 4);
			_uKnotSequence = ini.getArray("uKnot");
			_vKnotSequence = ini.getArray("vKnot");
			_uSegments = ini.getInt("uSegments", 8);
			_vSegments = ini.getInt("vSegments", 8);
			_nplusc = uCtrlPnts + _uOrder;
			_mplusc = vCtrlPnts + _vOrder;
			
			// Generate the open uniform knot vectors if not already defined
			if (!_uKnotSequence || _uKnotSequence.length==0) { _uKnotSequence = knot(_numUContolPoints, _uOrder); _autoGenKnotSeq = true; } else _uKnotSequence.splice(0, 0, 0);
			if (!_vKnotSequence || _vKnotSequence.length==0) { _vKnotSequence = knot(_numVContolPoints, _vOrder); _autoGenKnotSeq = true; } else _vKnotSequence.splice(0, 0, 0);
			_uRange = (_uKnotSequence[_nplusc] - _uKnotSequence[1]);
			_vRange = (_vKnotSequence[_mplusc] - _uKnotSequence[1]);

			_primitiveDirty = true;

			type = "primitive";
			type = "NURBS";

			if (_renderMode == NURBS_MESH) 
				buildNURBS();
			else 
				buildControlSegments();
		}
		
		/** @private */
		private function buildControlSegments():void {
			var cnt:int = 0;
			var cLen:int = _numUContolPoints * _numVContolPoints;
			for (var i:int = 0; i < _numVContolPoints; i++) {
				for (var j:int = 0; j < _numUContolPoints; j++) {
					if (cnt < (_numUContolPoints - 1)) {
						addSegment(new Segment( _controlNet[cnt],  _controlNet[cnt + 1]));
					} 
					if ((cnt % _numUContolPoints) == 0 && (cnt + _numUContolPoints) < (cLen - 1)) {
						addSegment(new Segment( _controlNet[cnt],  _controlNet[cnt + _numUContolPoints]));
					} 
					if (cnt >= _numUContolPoints && (cnt % _numUContolPoints) != 0) {
						addSegment(new Segment(_controlNet[cnt], _controlNet[cnt - 1]));                                                                
						addSegment(new Segment(_controlNet[cnt], _controlNet[cnt - _numUContolPoints]));;
					}
					cnt++;
				}
			}
		}
		
		/** @private */
		private function buildNURBS():void {
			// Define presets
			var tmp:int = (_uSegments+1) * (_vSegments+1);
			var i:int;
			var icount:int = 0;
			var j:int;
			var v0:WeightedVertex = new WeightedVertex();
			var v1:WeightedVertex = new WeightedVertex();
			var v2:WeightedVertex = new WeightedVertex();
			var v3:WeightedVertex = new WeightedVertex();
			var uv0:UV = new UV();
			var uv1:UV = new UV();
			var uv2:UV = new UV();
			var uv3:UV = new UV();

			// Initialise the vertex array
			surface = new Array();
			for (i = 0; i < tmp; i++) surface[i] = new WeightedVertex();

			// Iterate through the surface points (u=>0-1, v=>0-1)
			var stepuinc:Number = 1 / _uSegments;
			var stepvinc:Number = 1 / _vSegments;

			_pointCache = [];
			
			for (var vinc:Number = 0; vinc < (1+(stepvinc/2)); vinc+=stepvinc) {
				for (var uinc:Number = 0; uinc < (1+(stepuinc/2)); uinc+=stepuinc) {

					nurbPoint(surface[icount], uinc, vinc);
					icount++;
				}
			}

			// Render the mesh faces
			var vPos:int = 0;
			for (i = 1; i <= _vSegments; i++) {
				for (j = 1; j <= _uSegments; j++) {
					v0 = surface[vPos];
					v1 = surface[vPos+1];
					v2 = surface[vPos+_uSegments+1];
					v3 = surface[vPos+_uSegments+2];
					uv0 = new UV((j-1)/_uSegments, (i-1)/_vSegments);
					uv1 = new UV(j/_uSegments, (i-1)/_vSegments);
					uv2 = new UV((j-1)/_uSegments, i/_vSegments);
					uv3 = new UV(j/_uSegments, i/_vSegments);
					if (_invert) {
						if (v0 != v1 && v1 != v2 && v0 != v2)
							addFace(new Face(v0, v1, v2, null, uv0, uv1, uv2));
						if (v1 != v2 && v2 != v3 && v1 != v3)
							addFace(new Face(v2, v1, v3, null, uv2, uv1, uv3));
					} else {
						if (v0 != v1 && v1 != v2 && v0 != v2)
							addFace(new Face(v1, v0, v2, null, uv1, uv0, uv2));
						if (v1 != v2 && v2 != v3 && v1 != v3)
							addFace(new Face(v1, v2, v3, null, uv1, uv2, uv3));
					}  
					vPos++;
				}
				vPos++;
			}
		}		
		
		/** @private */
		private function nurbPoint(np:WeightedVertex, uS:Number, vS:Number) : void {
			var key:String = uS.toString() + "," + vS.toString();
			
			if (_pointCache[key]) {
				np.x = _pointCache[key].x;
				np.y = _pointCache[key].y;
				np.z = _pointCache[key].z;
			} else {
				
				var pbasis:Number;
				var jbas:int;
				var j1:int;
				var u:Number = _uKnotSequence[1] + (_uRange * uS);
				var v:Number = _vKnotSequence[1] + (_vRange * vS);
				
	
				if (_vKnotSequence[_mplusc] - v < 0.00005) v = _vKnotSequence[_mplusc];
				_mbasis = basis(_vOrder, v, _numVContolPoints, _vKnotSequence);    /* basis function for this value of w */
				if (_uKnotSequence[_nplusc] - u < 0.00005) u = _uKnotSequence[_nplusc];
				_nbasis = basis(_uOrder, u, _numUContolPoints, _uKnotSequence);    /* basis function for this value of u */
	
				np.x = np.y = np.z = 0;
	
				var sum:Number = sumrbas();
				for (var i:int = 1; i <= _numVContolPoints; i++) {
					if (_mbasis[i] != 0) {
						jbas = _numUContolPoints * (i - 1);
						for (var j:int = 1; j <= _numUContolPoints; j++) {
							if (_nbasis[j] != 0) {
								j1 = jbas + j - 1;
								pbasis = _controlNet[j1].w * _mbasis[i] * _nbasis[j] / sum;	
								np.x = (np.x + _controlNet[j1].x * pbasis);  /* calculate surface point */
								np.y = (np.y + _controlNet[j1].y * pbasis);
								np.z = (np.z + _controlNet[j1].z * pbasis);
							}
						}
					}
				}
				np.nurbData["position"] = new Point(uS, vS);
			}
		}
		
		/**
		 * Return a 3d point representing the surface point at the required U(0-1) and V(0-1) across the
		 * NURBS curved surface.
		 *  
		 * @param surfacePoint     Point being updated
		 * @param uS               U position on the surface
		 * @param vS               V position on the surface
		 * @param vecOffset        Offset the point on the surface by this vector
		 * @param uTol
		 * @param vTol
		 * @return                 The offset surface point being returned
		 * 
		 */
		public function getSurfacePoint(surfacePoint:Vector3D, uS:Number, vS:Number, vecOffset:Number, uTol:Number = 0.01, vTol:Number = 0.01):Vector3D {
			nurbPoint(_tmpPM, uS, vS);
			nurbPoint(_tmpP1, uS+uTol, vS);
			nurbPoint(_tmpP2, uS, vS+vTol);

			_tmpN1 = new Vector3D(_tmpP1.x - _tmpPM.x, _tmpP1.y - _tmpPM.y, _tmpP1.z - _tmpPM.z);
			_tmpN2 = new Vector3D(_tmpP2.x - _tmpPM.x, _tmpP2.y - _tmpPM.y, _tmpP2.z - _tmpPM.z);
			surfacePoint = _tmpN2.crossProduct(_tmpN1);
			surfacePoint.normalize();
			surfacePoint.scaleBy(-vecOffset);

			surfacePoint.x += _tmpPM.x;
			surfacePoint.y += _tmpPM.y;
			surfacePoint.z += _tmpPM.z;

			return surfacePoint;

		}

		/** @private */
		private function sumrbas():Number { 
			var i:int;
			var j:int;
			var jbas:int = 0;
			var j1:int = 0;
			var sum:Number;
	
			sum = 0;

			for (i = 1; i <= _numVContolPoints; i++) {
				if (_mbasis[i] != 0) {
					jbas = _numUContolPoints * (i - 1);
					for (j = 1; j <= _numUContolPoints; j++) {
						if (_nbasis[j] != 0) {
							j1 = jbas + j - 1;
							sum = sum + _controlNet[j1].w * _mbasis[i] * _nbasis[j];
						}
					}
				}
			}
			return sum;
		}
		
		/** @private */
		private function knot(n:int, c:int):Array {
			var nplusc:int = n + c;
			var nplus2:int = n + 2;
			var x:Array = new Array(36);
			
			x[1] = 0;
			for (var i:int = 2; i <= nplusc; i++) {
				if ((i > c) && (i < nplus2)) {
					x[i] = x[i - 1] + 1;
				} else {
					x[i] = x[i - 1];
				}
			}
			return x;
		}

		/** @private */
		private function basis(nurbOrder:int, t:Number, numPoints:int, knot:Array):Array {
			var nPlusO:int;
			var i:int;
			var k:int;
			var d:Number;
			var e:Number;
			var temp:Array = new Array(36);

			nPlusO = numPoints + nurbOrder;

			/* calculate the first order basis functions n[i][1]	*/

			for (i = 1; i<= nPlusO-1; i++) {
				if (( t >= knot[i]) && (t < knot[i+1])) {
					temp[i] = 1;
				} else {
					temp[i] = 0;
				}
			}

			/* calculate the higher order basis functions */

			for (k = 2; k <= nurbOrder; k++) {
				for (i = 1; i <= nPlusO-k; i++) {
					if (temp[i] != 0) {   /* if the lower order basis function is zero skip the calculation */
						d = ((t - knot[i]) * temp[i]) / (knot[i + k - 1] - knot[i]);
					} else {
						d = 0;
					}

					if (temp[i+1] != 0) {     /* if the lower order basis function is zero skip the calculation */
						e = ((knot[i + k] - t) * temp[i + 1]) / (knot[i + k] - knot[i + 1]);
					} else {
						e = 0;
					}

					temp[i] = d + e;
				}
			}
			
			if (t == knot[nPlusO]) {		/*    pick up last point	*/
				temp[numPoints] = 1;
			}
			return temp;
		}
		
		/**
		 *  Rebuild the mesh as there is significant change to the structural parameters
		 * 
		 */
    	protected override function buildPrimitive():void
    	{
			super.buildPrimitive();
			
			geometry = new Geometry();
			if (_renderMode == CONTROL_POINT_NET) {
				buildControlSegments();
			} else {
				_nplusc = _numUContolPoints + _uOrder;
				_mplusc = _numVContolPoints + _vOrder;
				
				// Generate the open uniform knot vectors if not already defined
				if (_autoGenKnotSeq) _uKnotSequence = knot(_numUContolPoints, _uOrder);
				if (_autoGenKnotSeq) _vKnotSequence = knot(_numVContolPoints, _vOrder);
				_uRange = (_uKnotSequence[_nplusc] - _uKnotSequence[1]);
				_vRange = (_vKnotSequence[_mplusc] - _uKnotSequence[1]);

				buildNURBS();
			}
		}

		/**
		 *  Refresh the mesh without reconstructing all the supporting data. This should be used only
		 *  when the control point positions change.
		 * 
		 */		
		public function refreshNURBS(coontrolPointsChanged:Boolean = false):void {
			if (coontrolPointsChanged) {
				buildPrimitive();
			}
			if (_renderMode == CONTROL_POINT_NET) {
				geometry = new Geometry();
				buildControlSegments();
			} else {
				for each (var v:WeightedVertex in vertices) {
					nurbPoint(v, v.nurbData["position"].x, v.nurbData["position"].y);
				}
			}
		}
	}
}
