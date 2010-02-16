package away3d.core.base
{
    import away3d.materials.ColorMaterial;

    public class Graphics3D
	{
		private var _geometry:Geometry;
		private var _currentFace:Face;
		private var _currentMaterial:ColorMaterial;
		private var _zOffset:Number = 0;
		
		public function set geometry(value:Geometry):void
		{
			_geometry = value;
		}
		
		public function lineStyle(thickness:Number = -1, color:int = -1, alpha:Number = -1):void
		{
			//trace("Geometry.as - lineStyle(" + thickness + ", " + color + ", " + alpha + ").");
		}
		
		public function beginFill(color:int = -1, alpha:Number = -1):void
		{
			//trace("Geometry.as - beginFill(" + color + ", " + alpha + ").");
			
			_currentMaterial = new ColorMaterial();
			
			if(color != -1)
				_currentMaterial.color = color;
				
			if(alpha != -1)
				_currentMaterial.alpha = alpha;
				
			if(_currentFace)
				_currentFace.material = _currentMaterial;
		}
		
		public function endFill():void
		{
			//trace("Geometry.as - endFill().");
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			//trace("Geometry.as - moveTo(" + x + ", " + y + ").");
			
			_currentFace.moveTo(x, -y, _zOffset);
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			//trace("Geometry.as - lineTo(" + x + ", " + y + ").");
			
			_currentFace.lineTo(x, -y, _zOffset);
		}
		
		public function curveTo(cx:Number, cy:Number, ax:Number, ay:Number):void
		{
			//trace("Geometry.as - curveTo(" + cx + ", " + cy + ", " + ax + ", " + ay + ").");
			
			_currentFace.curveTo(cx, -cy, _zOffset, ax, -ay, _zOffset);
		}
		
		public function clear():void
		{
			//trace("Geometry.as - clear().");
			
			for each(var face:Face in _geometry.faces)
				_geometry.removeFace(face);
		}
		
		public function startNewShape():void
		{
			//trace("Geometry.as - startNewShape().");
			
			_currentFace = new Face();
			_currentFace.material = _currentMaterial;
			_geometry.addFace(_currentFace);
		}
	}
}