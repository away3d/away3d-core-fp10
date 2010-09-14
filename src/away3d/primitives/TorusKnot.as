package away3d.primitives
{
	import away3d.arcane;
    import away3d.core.base.*;
    
    import flash.geom.*;
    
	use namespace arcane;
	
    /**
	 * Creates a 3d pq-torus knot primitive (http://en.wikipedia.org/wiki/Torus_knot)
	 */
    public class TorusKnot extends AbstractPrimitive
    {
        private var grid:Array;
        private var _radius:Number;
        private var _tube:Number;
        private var _segmentsR:int;
        private var _segmentsT:int;
		private var _p : Number = 2;
		private var _q : Number = 3;
		private var _yUp : Boolean;
		private var _heightScale : Number;

		/**
		 * @inheritDoc
		 */
    	protected override function buildPrimitive():void
    	{
    		super.buildPrimitive();
    		
            var i:int;
            var j:int;
			var tang : Vector3D = new Vector3D();
			var n : Vector3D = new Vector3D();
			var bitan : Vector3D = new Vector3D();

            grid = new Array(_segmentsR);
            for (i = 0; i < _segmentsR; ++i) {
                grid[i] = new Array(_segmentsT);
                for (j = 0; j < _segmentsT; ++j) {
					var u:Number = i / _segmentsR * 2 * _p * Math.PI;
					var v:Number = j / _segmentsT * 2 * Math.PI;
					var p : Vector3D = getPos(u, v);
					var p2 : Vector3D = getPos(u+.01, v);
					var cx : Number, cy : Number;

					tang.x = p2.x - p.x; tang.y = p2.y - p.y; tang.z = p2.z - p.z;
					n.x = p2.x + p.x; n.y = p2.y + p.y; n.z = p2.z + p.z; 
					bitan = n.crossProduct(tang);
					n = tang.crossProduct(bitan);
					bitan.normalize();
					n.normalize();

					cx = _tube*Math.cos(v); cy = _tube*Math.sin(v);
					p.x += cx * n.x + cy * bitan.x;
					p.y += cx * n.y + cy * bitan.y;
					p.z += cx * n.z + cy * bitan.z;

					/*var x : Number = _tube * Math.cos(v) * Math.cos(u) + _radius * Math.cos(u) * (1 + _twistAmplitude * Math.cos(_numTwists * u));
					var y : Number = 2.5 * (_tube * Math.sin(v) + _height * _twistAmplitude * Math.sin(_numTwists * u));
					var z : Number = _tube * Math.cos(v) * Math.sin(u) + _radius * Math.sin(u) * (1 + _twistAmplitude * Math.cos(_numTwists * u));*/

					if (_yUp)
						grid[i][j] = createVertex(p.x, p.z, p.y);
					else
						grid[i][j] = createVertex(p.x, -p.y, p.z);

                }
            }

            for (i = 0; i < _segmentsR; ++i) {
                for (j = 0; j < _segmentsT; ++j) {
                    var ip:int = (i+1) % _segmentsR;
                    var jp:int = (j+1) % _segmentsT;
                    var a:Vertex = grid[i ][j]; 
                    var b:Vertex = grid[ip][j];
                    var c:Vertex = grid[i ][jp]; 
                    var d:Vertex = grid[ip][jp];

                    var uva:UV = createUV(i     / _segmentsR, j     / _segmentsT);
                    var uvb:UV = createUV((i+1) / _segmentsR, j     / _segmentsT);
                    var uvc:UV = createUV(i     / _segmentsR, (j+1) / _segmentsT);
                    var uvd:UV = createUV((i+1) / _segmentsR, (j+1) / _segmentsT);

                    addFace(createFace(a, b, c, null, uva, uvb, uvc));
                    addFace(createFace(d, c, b, null, uvd, uvc, uvb));
                }
            }
    	}

		private function getPos(u : Number, v : Number) : Vector3D
		{
			var cu : Number = Math.cos(u);
			var cv : Number = Math.cos(v);
			var su : Number = Math.sin(u);
			var quOverP : Number = _q/_p*u;
			var cs : Number = Math.cos(quOverP);
			var pos : Vector3D = new Vector3D();

			pos.x = _radius*(2+cs)*.5 * cu;
			pos.y = _radius*(2+cs)*su*.5;
			pos.z = _heightScale*_radius*Math.sin(quOverP)*.5;

			return pos;
		}

    	/**
    	 * Defines the overall radius of the torus knot. Defaults to 100.
    	 */
    	public function get radius():Number
    	{
    		return _radius;
    	}

    	public function set radius(val:Number):void
    	{
    		if (_radius == val)
    			return;

    		_radius = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines the tube radius of the torus knot. Defaults to 40.
    	 */
    	public function get tube():Number
    	{
    		return _tube;
    	}
    	
    	public function set tube(val:Number):void
    	{
    		if (_tube == val)
    			return;
    		
    		_tube = val;
    		_primitiveDirty = true;
    	}


		public function get heightScale() : Number
		{
			return _heightScale;
		}

		public function set heightScale(value : Number) : void
		{
			if (_heightScale == value)
				return;

			_heightScale = value;
			_primitiveDirty = true;
		}

		/**
    	 * Defines the number of radial segments that make up the torus knot. Defaults to 15.
    	 */
    	public function get segmentsR():Number
    	{
    		return _segmentsR;
    	}
    	
    	public function set segmentsR(val:Number):void
    	{
    		if (_segmentsR == val)
    			return;
    		
    		_segmentsR = val;
    		_primitiveDirty = true;
    	}

		/**
    	 * Defines the number of tubular segments that make up the torus knot. Defaults to 6.
    	 */
    	public function get segmentsT():Number
    	{
    		return _segmentsT;
    	}

    	public function set segmentsT(val:Number):void
    	{
    		if (_segmentsT == val)
    			return;

    		_segmentsT = val;
    		_primitiveDirty = true;
    	}

		/**
		 * The p-component of the pq-torus knot (the amount of time the knot winds around a circle inside the torus)
		 * p and q should be coprime (gcd == 1)
		 */
		public function get p() : Number
		{
			return _p;
		}

		public function set p(value : Number) : void
		{
			if (_p == value)
    			return;
			_p = value;
			_primitiveDirty = true;
		}

		/**
		 * The q-component of the pq-torus knot (the amount of time the knot winds around a line through the hole in the torus) 
		 * p and q should be coprime (gcd == 1)
		 */
		public function get q() : Number
		{
			return _q;
		}

		public function set q(value : Number) : void
		{
			if (_q == value)
    			return;
			_q = value;
			_primitiveDirty = true;
		}

		
		/**
		 * Creates a new <code>TorusKnot</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function TorusKnot(init:Object = null)
        {
            super(init);

            _radius = ini.getNumber("radius", 200, {min:0});
            _tube = ini.getNumber("tube", 10, {min:0, max:radius});
			_p = ini.getNumber("p", 2, {min:0});
			_q = ini.getNumber("q", 3, {min:0});
			_yUp = ini.getBoolean("yUp", true);
			_heightScale = ini.getNumber("heightScale", 1, {min:0});
            _segmentsR = ini.getInt("segmentsR", 15, {min:3});
            _segmentsT = ini.getInt("segmentsT", 6, {min:3});

			type = "Torus";
        	url = "primitive";
        }
        
		/**
		 * Returns the vertex object specified by the grid position of the mesh.
		 * 
		 * @param	r	The radial position on the primitive mesh.
		 * @param	t	The tubular position on the primitive mesh.
		 */
        public function vertex(r:int, t:int):Vertex
        {
        	if (_primitiveDirty)
    			updatePrimitive();
    		
            return grid[t][r];
        }
    }
}
