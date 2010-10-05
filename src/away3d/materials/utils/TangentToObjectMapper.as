package away3d.materials.utils
{
	import away3d.core.base.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	/**
	 * A util class that transforms a tangent space normal map to an object space normal map.
	 */
	public class TangentToObjectMapper
	{
		private static var _objectMap : BitmapData;
		
		[Embed(source="../../pbks/TangentToObjectSmooth.pbj", mimeType="application/octet-stream")]
		private static var TangentToObjectKernelSmooth : Class;
		
		[Embed(source="../../pbks/TangentToObject.pbj", mimeType="application/octet-stream")]
		private static var TangentToObjectKernel : Class;
		
		/**
		 * Transform a tangent space normal map to an object space normal map for a specific mesh
		 * 
		 * @param tangentMap The source tangent space map to be transformed
		 * @param targetMesh The target mesh for which the object space map is generated
		 * @param smoothNormals Interpolates the triangle normals. Set to true for rounded surfaces, false for sharp edges.
		 * 
		 * @return An object space normal map for the target mesh.
		 */
		public static function transform(tangentMap : BitmapData, targetMesh : Mesh, smoothNormals : Boolean = false) : BitmapData
		{
			_objectMap = new BitmapData(tangentMap.width, tangentMap.height, false, 0);
			createTriangleTBN(targetMesh);
			if (smoothNormals) {
				createVertexTBN(targetMesh);
				renderNormalMapSmooth(targetMesh, tangentMap);
			}
			else {
				renderNormalMap(targetMesh, tangentMap);
			}
			
			return _objectMap; 
		}
		
		private static function createTriangleTBN(model : Mesh) : void
		{
			var faces : Vector.<Face> = model.geometry.faces;
			var face : Face;
			var i : uint = faces.length;
			var tangent : Vector3D;
			var bitangent : Vector3D;
			var edge1 : Vector3D = new Vector3D();
			var edge2 : Vector3D = new Vector3D();
			var st1 : UV = new UV();
			var st2 : UV = new UV();
			var denom : Number;
			
			while (i--) {
				face = faces[i];
				edge1 = face.v1.position.subtract(face.v0.position);
				edge2 = face.v2.position.subtract(face.v0.position);
				st1.u = face.uv1.u - face.uv0.u;
				st1.v = face.uv1.v - face.uv0.v;
				st2.u = face.uv2.u - face.uv0.u;
				st2.v = face.uv2.v - face.uv0.v;
				denom = 1.0/(st1.u*st2.v-st2.u*st1.v);
				tangent = new Vector3D();
				bitangent = new Vector3D();
				tangent.x = denom*(st2.v*edge1.x - st1.v*edge2.x);
				tangent.y = denom*(st2.v*edge1.y - st1.v*edge2.y);
				tangent.z = denom*(st2.v*edge1.z - st1.v*edge2.z);
				bitangent.x = denom*(st1.u*edge2.x - st2.u*edge1.x);
				bitangent.y = denom*(st1.u*edge2.y - st2.u*edge1.y);
				bitangent.z = denom*(st1.u*edge2.z - st2.u*edge1.z);
				
				face.normalDirty = true;
				tangent.normalize();
				bitangent.normalize();
				
				if (!face.extra) face.extra = new Object();
				
				face.extra.tangent = tangent;
				face.extra.bitangent = bitangent;
			}
		}
		
		private static function createVertexTBN(model : Mesh) : void
		{
			var vertices : Vector.<Vertex> = model.geometry.vertices;
			var v : Vertex;
			var i : uint = vertices.length;
			var tangent : Vector3D;
			var bitangent : Vector3D;
			var normal : Vector3D;
			var face : Face;
			var faces : Vector.<Element>;
			var j : int;

			while (i--) {
				v = vertices[i];
				tangent = new Vector3D();
				bitangent = new Vector3D();
				normal = new Vector3D();
				faces = v.parents;
				j = faces.length;
				
				while (j--) {
					face = faces[j] as Face;
					tangent.x += face.extra.tangent.x;
					tangent.y += face.extra.tangent.y;
					tangent.z += face.extra.tangent.z;
					bitangent.x += face.extra.bitangent.x;
					bitangent.y += face.extra.bitangent.y;
					bitangent.z += face.extra.bitangent.z;
					normal.x += face.normal.x;
					normal.y += face.normal.y;
					normal.z += face.normal.z;
				}
				
				tangent.normalize();
				bitangent.normalize();
				normal.normalize();

				if (!v.extra) v.extra = new Object();
				v.extra.tangent = tangent;
				v.extra.bitangent = bitangent;
				v.extra.normal = normal;
			}
		}
		
		private static function renderNormalMapSmooth(model : Mesh, tangentMap : BitmapData) : void
		{
			var faces : Vector.<Face> = model.geometry.faces;
			var face : Face;
			var i : uint = faces.length;
			var normal0 : Vector3D;
			var tangent0 : Vector3D;
			var bitangent0 : Vector3D;
			var normal : Vector3D;
			var tangent : Vector3D;
			var bitangent : Vector3D;
			var uv0 : UV = new UV();
			var uv1 : UV = new UV();
			var uv2 : UV = new UV();
			var u01 : Number, v01 : Number; 
			var u02 : Number, v02 : Number;
			var w : Number = _objectMap.width;
			var h : Number = _objectMap.height;
			var shader : Shader = new Shader(new TangentToObjectKernelSmooth());
			var container : Sprite = new Sprite();
			
			shader.data.normalMap.input = tangentMap;
			
			while (i--) {
				face = faces[i];
				uv0.u = face.uv0.u*w;
				uv0.v = (1-face.uv0.v)*h;
				uv1.u = face.uv1.u*w;
				uv1.v = (1-face.uv1.v)*h;
				uv2.u = face.uv2.u*w;
				uv2.v = (1-face.uv2.v)*h;
				u01 = uv1.u-uv0.u;
				v01 = uv1.v-uv0.v;
				u02 = uv2.u-uv0.u;
				v02 = uv2.v-uv0.v;
				
				shader.data.uv0.value = [ uv0.u, uv0.v ];
				shader.data.uvEdge1.value = [ u01, v01 ];
				shader.data.uvEdge2.value = [ u02, v02 ];
				shader.data.dot00.value = [ u01*u01+v01*v01 ];
				shader.data.dot01.value = [ u01*u02+v01*v02 ];
				shader.data.dot11.value = [ u02*u02+v02*v02 ];
				
				tangent0 = face.v0.extra.tangent;
				bitangent0 = face.v0.extra.bitangent;
				normal0 = face.v0.extra.normal;

				shader.data.tbn0.value = [ 	tangent0.x, tangent0.y, tangent0.z,
											bitangent0.x, bitangent0.y, bitangent0.z,
											normal0.x, normal0.y, normal0.z
										];
				
				tangent = face.v1.extra.tangent;
				bitangent = face.v1.extra.bitangent;
				normal = face.v1.extra.normal;
				shader.data.tbn1.value = [ 	tangent.x-tangent0.x, tangent.y-tangent0.y, tangent.z-tangent0.z,
											bitangent.x-bitangent0.x, bitangent.y-bitangent0.y, bitangent.z-bitangent0.z,
											normal.x-normal0.x, normal.y-normal0.y, normal.z-normal0.z
										];
										
				tangent = face.v2.extra.tangent;
				bitangent = face.v2.extra.bitangent;
				normal = face.v2.extra.normal;
				shader.data.tbn2.value = [ 	tangent.x-tangent0.x, tangent.y-tangent0.y, tangent.z-tangent0.z,
											bitangent.x-bitangent0.x, bitangent.y-bitangent0.y, bitangent.z-bitangent0.z,
											normal.x-normal0.x, normal.y-normal0.y, normal.z-normal0.z
										];
				
				container.graphics.beginShaderFill(shader);
				container.graphics.moveTo(uv0.u, uv0.v);
				container.graphics.lineTo(uv1.u, uv1.v);
				container.graphics.lineTo(uv2.u, uv2.v);
				container.graphics.endFill();
			}
			_objectMap.draw(container);
		}
		
		private static function renderNormalMap(model : Mesh, tangentMap : BitmapData) : void
		{
			var faces : Vector.<Face> = model.geometry.faces;
			var face : Face;
			var i : uint = faces.length;
			var normal : Vector3D = new Vector3D();
			var tangent : Vector3D = new Vector3D();
			var bitangent : Vector3D = new Vector3D();
			var uv0 : UV = new UV();
			var uv1 : UV = new UV();
			var uv2 : UV = new UV();
			var w : Number = _objectMap.width;
			var h : Number = _objectMap.height;
			var shader : Shader = new Shader(new TangentToObjectKernel());
			var container : Sprite = new Sprite();
			
			shader.data.normalMap.input = tangentMap;
			
			while (i--) {
				face = faces[i];
				uv0.u = face.uv0.u*w;
				uv0.v = (1-face.uv0.v)*h;
				uv1.u = face.uv1.u*w;
				uv1.v = (1-face.uv1.v)*h;
				uv2.u = face.uv2.u*w;
				uv2.v = (1-face.uv2.v)*h;
				
				tangent = face.extra.tangent;
				bitangent = face.extra.bitangent;
				normal = face.normal;

				shader.data.tbn.value = [ 	tangent.x, tangent.y, tangent.z,
											bitangent.x, bitangent.y, bitangent.z,
											normal.x, normal.y, normal.z
										];
				
				container.graphics.beginShaderFill(shader);
				container.graphics.moveTo(uv0.u, uv0.v);
				container.graphics.lineTo(uv1.u, uv1.v);
				container.graphics.lineTo(uv2.u, uv2.v);
				container.graphics.endFill();
			}
			_objectMap.draw(container);
		}
	}
}