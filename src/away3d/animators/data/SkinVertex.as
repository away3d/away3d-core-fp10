package away3d.animators.data
{
	import away3d.core.base.*;
	
	import flash.geom.*;
	
    public class SkinVertex
    {
    	private var _i:int;
    	private var _position:Vector3D = new Vector3D();
		public var baseVertex:Vertex;
        public var skinnedVertex:Vertex;
        public var weights:Array = [];
        public var controllers:Array = [];
		
        public function SkinVertex(vertex:Vertex)
        {
            skinnedVertex = vertex;
            baseVertex = vertex.clone();
        }

        public function update() : void
        {
        	//reset values
            skinnedVertex.reset();
            
            _i = weights.length;
            while (_i--) {
				_position = (controllers[_i] as SkinController).sceneTransform.transformVector(baseVertex.position);
				_position.scaleBy(weights[_i]);
				skinnedVertex.add(_position);
            }
        }
    }
}
