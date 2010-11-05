package away3d.loaders.data
{
	/**
	 * Data class for a face object.
	 */
	public class FaceData
	{
		/**
		 * Index of vertex 0.
		 */
		public var v0:uint;
		
		/**
		 * Index of vertex 1.
		 */
		public var v1:uint;
		
		/**
		 * Index of vertex 2.
		 */
		public var v2:uint;
		
		/**
		 * Index of uv coordinate 0.
		 */
		public var uv0:uint;
		
		/**
		 * Index of uv coordinate 1.
		 */
		public var uv1:uint;
		
		/**
		 * Index of uv coordinate 2.
		 */
		public var uv2:uint;
		
		/**
		 * Determines whether the face is visible.
		 */
		public var visible:Boolean;
		
		/**
		 * Holds teh material data for the face.
		 */
		public var meshMaterialData:MeshMaterialData;
	}
}