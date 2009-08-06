package awaybuilder.geometry
{	import away3d.core.base.Mesh;	import away3d.materials.ITriangleMaterial;	import away3d.primitives.Cone;	import away3d.primitives.Cube;	import away3d.primitives.Cylinder;	import away3d.primitives.Plane;	import away3d.primitives.Sphere;	import away3d.primitives.Torus;	import away3d.primitives.data.CubeMaterialsData;		import awaybuilder.vo.DynamicAttributeVO;	import awaybuilder.vo.SceneGeometryVO;
	
	
	
	public class GeometryFactory
	{
		public var coordinateSystem : String ;
		
		protected var propertyFactory : GeometryPropertyFactory ;
		protected var _precision : uint ;
		
		
		
		public function GeometryFactory ( )
		{
			this.propertyFactory = new GeometryPropertyFactory ( ) ;
		}
		
		
				////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function build ( attribute : DynamicAttributeVO , vo : SceneGeometryVO ) : SceneGeometryVO
		{
			var s : uint = this.precision ;
			
			switch ( attribute.value )
			{
				case GeometryType.COLLADA :
				{
					vo = this.propertyFactory.build ( vo ) ;
					break ;
				}
				case GeometryType.CONE :
				{
					var cone : Cone = new Cone ( ) ;
					
					cone.height = s ;
					cone.radius = s ;
					cone.material = vo.material as ITriangleMaterial ;
					
					vo.mesh = cone ;
					vo = this.propertyFactory.build ( vo ) ;
					
					break ;
				}
				case GeometryType.CUBE :
				{
					var cube : Cube = new Cube ( ) ;
					var materialsData : CubeMaterialsData = new CubeMaterialsData ( ) ;
					
					materialsData.back = vo.material as ITriangleMaterial ;
					materialsData.bottom = vo.material as ITriangleMaterial ;
					materialsData.front = vo.material as ITriangleMaterial ;
					materialsData.left = vo.material as ITriangleMaterial ;
					materialsData.right = vo.material as ITriangleMaterial ;
					materialsData.top = vo.material as ITriangleMaterial ;
					
					cube.depth = s ;
					cube.height = s ;
					cube.width = s ;
					cube.cubeMaterials = materialsData ;
					
					vo.mesh = cube ;
					vo = this.propertyFactory.build ( vo ) ;
					
					break ;
				}
				case GeometryType.CYLINDER :
				{
					var cylinder : Cylinder = new Cylinder ( ) ;
					
					cylinder.height = s ;
					cylinder.radius = s ;
					cylinder.material = vo.material as ITriangleMaterial ;
					
					vo.mesh = cylinder ;
					vo = this.propertyFactory.build ( vo ) ;
					
					break ;
				}
				case GeometryType.PLANE :
				{
					var plane : Plane = new Plane ( ) ;
					
					plane.width = s ;
					plane.height = s ;
					plane.material = vo.material as ITriangleMaterial ;
					
					if ( vo.assetFileBack ) plane.back = vo.materialBack as ITriangleMaterial ;
					
					vo.mesh = plane ;
					vo = this.propertyFactory.build ( vo ) ;
					
					break ;
				}
				case GeometryType.SPHERE :
				{
					var sphere : Sphere = new Sphere ( ) ;
					
					sphere.radius = s ;
					sphere.material = vo.material as ITriangleMaterial ;
					
					vo.mesh = sphere ;
					vo = this.propertyFactory.build ( vo ) ;
					
					break ;
				}
				case GeometryType.TORUS :
				{
					var torus : Torus = new Torus ( ) ;
					
					torus.radius = s ;
					torus.tube = s ;
					torus.material = vo.material as ITriangleMaterial ;
					
					vo.mesh = torus ;
					vo = this.propertyFactory.build ( vo ) ;
					
					break ;
				}
				default :
				{
					vo = this.buildDefault ( vo ) ;
				}
			}
			
			vo.geometryType = attribute.value ;
			
			return vo ;
		}
		
		
		
		public function buildDefault ( vo : SceneGeometryVO ) : SceneGeometryVO
		{
			var s : uint = this.precision ;
			var plane : Plane = new Plane ( ) ;
			
			plane.width = s ;
			plane.height = s ;
			plane.bothsides = true ;
			plane.material = vo.material as ITriangleMaterial ;
			
			vo.mesh = plane ;
			
			return vo ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Getters and Setters
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function set precision ( value : uint ) : void
		{
			this._precision = value ;
			this.propertyFactory.precision = value ;
		}
		
		
		
		public function get precision ( ) : uint
		{
			return this._precision ;
		}
	}}