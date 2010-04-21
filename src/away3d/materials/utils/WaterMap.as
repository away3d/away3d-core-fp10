package away3d.materials.utils
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	/**
	 * Water maps allows you to stitch several procedural water normal maps and update the animation with a single
	 * method call. It extends BitmapData and as such can be used as a run-of-the-mill normal map.
	 * Water maps can be generated with 3D software such as Blender.
	 */
	public class WaterMap extends BitmapData
	{
		private var _sourceMap : BitmapData;
		private var _width : int;
		private var _height : int;
		private var _widthEdge : int;
		private var _heightEdge : int;
		private var _smoothing : Boolean;

		private var _matrix : Matrix;

		/**
		 * Create a WaterMap object
		 *
		 * @param width The width of the material it will be used in
		 * @param height The height of the material it will be used in
		 * @param sourceWidth The original width of 1 tile in the map
		 * @param sourceHeight The original height of 1 tile in the map
		 * @param sourceMap The source stitched animation map
		 * @param smoothing Indicates whether or not to use smoothing on the normal map when upscaling
		 */
		public function WaterMap(width:int, height:int, sourceWidth:int, sourceHeight:int, sourceMap : BitmapData, smoothing : Boolean = true)
		{
			_width = width;
			_height = height;
			_sourceMap = sourceMap;

			super(width, height, false);
			                            
			if (sourceMap.width % sourceWidth || sourceMap.height % sourceHeight)
				throw new Error("sourceMap does not match tile dimensions!");

			_smoothing = smoothing;
			_matrix = new Matrix(width/sourceWidth, 0, 0, height/sourceHeight);
			_widthEdge = -sourceMap.width*_matrix.a +_width;
			_heightEdge = -sourceMap.height*_matrix.d;
		}

		/**
		 * Indicates whether or not to use smoothing on the normal map when upscaling
		 */
		public function get smoothing() : Boolean
		{
			return _smoothing;
		}

		public function set smoothing(value : Boolean) : void
		{
			_smoothing = value;
		}


		/**
		 * Show the next step in the animation cycle
		 */
		public function showNext() : void
		{
			_matrix.tx += _width;
			if (_matrix.tx >= 0) {
				_matrix.tx = _widthEdge;

				_matrix.ty -= _height;
				if (_matrix.ty <= _heightEdge)
					_matrix.ty = 0;
			}
			_sourceMap.lock();
			draw(_sourceMap, _matrix, null, null, null, _smoothing);
			_sourceMap.unlock();
		}
	}
}