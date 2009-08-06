package awaybuilder
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.events.Loader3DEvent;
	import away3d.loaders.*;
	import away3d.loaders.data.*;
	import away3d.loaders.utils.*;
	import away3d.materials.*;
	
	import awaybuilder.abstracts.*;
	import awaybuilder.camera.*;
	import awaybuilder.events.*;
	import awaybuilder.geometry.*;
	import awaybuilder.interfaces.*;
	import awaybuilder.material.*;
	import awaybuilder.utils.*;
	import awaybuilder.vo.*;
	
	import flash.display.*;
	import flash.events.*;
	
	public class SceneBuilder extends AbstractBuilder implements IBuilder , IAssetContainer , ISceneContainer
	{
		public var coordinateSystem : String ;
		public var precision : uint ;
		
		protected var view : View3D ;
		protected var cameras : Array = [ ] ;
		protected var geometry : Array = [ ] ;
		protected var sections : Array = [ ] ;
		protected var mainSections : Array ;
		protected var cameraFactory : CameraFactory ;
		protected var materialFactory : MaterialFactory ;
		protected var geometryFactory : GeometryFactory ;
		protected var bitmapDataAssets : Array = [ ] ;
		protected var displayObjectAssets : Array = [ ] ;
		protected var colladaAssets : Array = [ ] ;
		protected var materialPropertyFactory : MaterialPropertyFactory ;

		
		
		public function SceneBuilder ( )
		{
			super ( ) ;
			this.materialPropertyFactory = new MaterialPropertyFactory ( ) ;
		}

		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		override public function build ( view : View3D , sections : Array ) : void
		{
			this.view = view ;
			this.mainSections = sections ;
			this.createCameraFactory ( ) ;
			this.createGeometryFactory ( ) ;
			this.createMaterialFactory ( ) ;
			this.createSections ( ) ;
			this.applyValues ( ) ;
			this.dispatchEvent ( new Event ( Event.COMPLETE ) ) ;
		}
		
		
		
		override public function addBitmapDataAsset ( id : String , data : BitmapData ) : void
		{
			this.bitmapDataAssets[ id ] = data ;
		}
		
		
		
		override public function addDisplayObjectAsset ( id : String , data : DisplayObject ) : void
		{
			this.displayObjectAssets[ id ] = data ;
		}
		
		
		
		override public function addColladaAsset ( id : String , data : XML ) : void
		{
			this.colladaAssets[ id ] = data ;
		}
		
		
		
		override public function getCameras ( ) : Array
		{
			return this.cameras ;
		}

		
		
		override public function getGeometry ( ) : Array
		{
			return this.geometry ;
		}

		
		
		override public function getSections ( ) : Array
		{
			return this.sections ;
		}

		
		
		override public function getSectionById ( id : String ) : SceneSectionVO
		{
			var result : SceneSectionVO ;
			
			for each ( var section : SceneSectionVO in this.sections )
			{
				if ( section.id == id ) result = section ;
			}
			
			if ( ! result ) throw new Error ( "section with id [" + id + "] not found" ) ;
			return result ;
		}
		
		
		
		override public function getCameraById ( id : String ) : SceneCameraVO
		{
			for each ( var vo : SceneCameraVO in this.cameras )
			{
				if ( vo.id == id ) return vo ;
			}
			
			if ( this.cameras.length == 0 )
			{
				throw new Error ( "no cameras available" ) ;
			}
			else
			{
				throw new Error ( "camera with id [" + id + "] not found" ) ;
			}
		}
		
		
		
		override public function getGeometryById ( id : String ) : SceneGeometryVO
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.id == id ) return vo ;
			}
			
			if ( this.geometry.length == 0 )
			{
				throw new Error ( "no geometry available" ) ;
			}
			else
			{
				throw new Error ( "geometry with id [" + id + "] not found" ) ;
			}
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Protected Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function createCameraFactory ( ) : void
		{
			this.cameraFactory = new CameraFactory ( ) ;
		}

		
		
		protected function createGeometryFactory ( ) : void
		{
			this.geometryFactory = new GeometryFactory ( ) ;
			this.geometryFactory.coordinateSystem = this.coordinateSystem ;
			this.geometryFactory.precision = this.precision ;
		}
		
		
		
		protected function createMaterialFactory ( ) : void
		{
			this.materialFactory = new MaterialFactory ( ) ;
		}
		
		
		
		protected function createSections ( ) : void
		{
			for each ( var section : SceneSectionVO in this.mainSections )
			{
				if ( section.enabled ) this.createSection ( section ) ;
			}
		}
		
		
		
		protected function createSection ( section : SceneSectionVO ) : void
		{
			if ( section.enabled )
			{
				this.view.scene.addChild ( section.pivot ) ;
				this.createCameras ( section ) ;
				this.createGeometry ( section ) ;
				this.createSubSections ( section ) ;
				this.sections.push ( section ) ;
			}
		}
		
		
		
		protected function createSubSections ( section : SceneSectionVO ) : void
		{
			for each ( var subSection : SceneSectionVO in section.sections )
			{
				this.createSection ( subSection ) ;
			}
		}
		
		
		
		protected function applyValues ( ) : void
		{
			this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;
			
			for each ( var geometryVO : SceneGeometryVO in this.geometry )
			{
				switch ( geometryVO.geometryType )
				{
					case GeometryType.COLLADA :
					{
						break ;
					}
					default :
					{
						this.applyPosition ( geometryVO.mesh , geometryVO.values ) ;
						this.applyMeshRotation ( geometryVO.mesh , geometryVO.values ) ;
						this.applyScale ( geometryVO.mesh as Mesh , geometryVO.values ) ;
					}
				}
			}
			
			// FIXME: Implement group position and scale conversion.
			for each ( var sectionVO : SceneSectionVO in this.mainSections )
			{
				this.applyPosition ( sectionVO.pivot , sectionVO.values ) ;
				this.applyGroupRotation ( sectionVO.pivot , sectionVO.values ) ;
				this.applyPivotScale ( sectionVO.pivot , sectionVO.values ) ;
			}
			
			for each ( var cameraVO : SceneCameraVO in this.cameras )
			{
				/* FIXME: Camera to be relative to section pivot coordinates.
				this.applyPosition ( cameraVO.positionContainer , cameraVO.values ) ;
				this.applyMeshRotation ( cameraVO.positionContainer , cameraVO.values ) ;
				
				cameraVO.camera.transform = cameraVO.positionContainer.sceneTransform ;
				*/
				
				this.applyPosition ( cameraVO.camera , cameraVO.values ) ;
				this.applyCameraRotation ( cameraVO.camera , cameraVO.values ) ;
			}
			
			this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;
		}
		
		
		
		protected function applyColladaValues ( target : Object3D , values : SceneObjectVO , vo : SceneGeometryVO ) : void
		{
			if ( vo.flipTexture ) this.flipTexture ( target ) ;
			if ( vo.smoothTexture ) this.smoothMaterials ( target.materialLibrary ) ;
			this.applyPosition ( target , values ) ;
			this.applyColladaRotation ( target , values ) ;
			this.applyColladaScale ( target , values , vo ) ;
		}

		
		
		protected function flipTexture ( handle : Object3D ) : void
		{
			for each ( var geometryData : GeometryData in handle.geometryLibrary.getGeometryArray ( ) )
			{
				for each ( var uv : UV in geometryData.uvs )
				{
					uv.u = 1 - uv.u ;
					uv.v = 1 - uv.v ;
				}
			}
		}

		
		
		protected function smoothMaterials ( materialLibrary : MaterialLibrary ) : void
		{
			for each ( var materialData : MaterialData in materialLibrary )
			{
				materialData.material[ MaterialAttributes.SMOOTH ] = true ;
			}
		}
		
		
		
		protected function createCameras ( section : SceneSectionVO ) : void
		{
			for each ( var vo : SceneCameraVO in section.cameras )
			{
				/* FIXME: Camera to be relative to section pivot coordinates.
				vo.parentSection = section ;
				vo.positionContainer = new ObjectContainer3D ( ) ;
				
				section.pivot.addChild ( vo.positionContainer ) ;
				*/
				
				vo = this.cameraFactory.build ( vo ) ;
				this.cameras.push ( vo ) ;
			}
		}
		
		
		
		protected function createGeometry ( section : SceneSectionVO ) : void
		{
			for each ( var geometry : SceneGeometryVO in section.geometry )
			{
				var useDefaultGeometry : Boolean = true ;
				
				this.createMaterial ( geometry ) ;
				
				for each ( var attribute : DynamicAttributeVO in geometry.geometryExtras )
				{
					switch ( attribute.key )
					{
						case GeometryAttributes.CLASS :
						{
							geometry = this.geometryFactory.build ( attribute , geometry ) ;
							useDefaultGeometry = false ;
							break ;
						}
					}
				}
				
				if ( useDefaultGeometry ) geometry = geometryFactory.buildDefault ( geometry ) ;
				this.applyExternalAssets ( section , geometry ) ;
			}
		}
		
		
		
		protected function createMaterial ( geometry : SceneGeometryVO ) : void
		{
			var useDefaultMaterial : Boolean = true ;
			
			for each ( var attribute : DynamicAttributeVO in geometry.materialExtras )
			{
				switch ( attribute.key )
				{
					case MaterialAttributes.CLASS :
					{
						geometry = materialFactory.build ( attribute , geometry ) ;
						useDefaultMaterial = false ;
						break ;
					}
				}
			}
			
			if ( useDefaultMaterial ) geometry = materialFactory.buildDefault ( geometry ) ;
		}
		
		
		
		protected function applyExternalAssets ( section : SceneSectionVO , vo : SceneGeometryVO ) : void
		{
			var applySpecialProperties : Boolean ;
			
			switch ( vo.materialType )
			{
				case MaterialType.BITMAP_MATERIAL :
				{
					var bitmapData : BitmapData = this.bitmapDataAssets[ vo.assetClass ] ;
					
					vo.materialData = bitmapData ;
					vo.material = new BitmapMaterial ( bitmapData ) ;
					Mesh ( vo.mesh ).material = vo.material as BitmapMaterial ;
					applySpecialProperties = true ;
					break ;
				}
				case MaterialType.BITMAP_FILE_MATERIAL :
				{
					vo.material = new BitmapFileMaterial ( vo.assetFile ) ;
					Mesh ( vo.mesh ).material = vo.material as BitmapFileMaterial ;
					
					if ( vo.assetFileBack )
					{
						vo.materialBack = new BitmapFileMaterial ( vo.assetFileBack ) ;
						Mesh ( vo.mesh ).back = vo.materialBack as BitmapFileMaterial ;
					}
					
					applySpecialProperties = true ;
					break ;
				}
				case MaterialType.MOVIE_MATERIAL :
				{
					var movieClip : MovieClip = this.displayObjectAssets[ vo.assetClass ] ;
					
					vo.materialData = movieClip ;
					vo.material = new MovieMaterial ( movieClip ) ;
					Mesh ( vo.mesh ).material = vo.material as MovieMaterial ;
					applySpecialProperties = true ;
					break ;
				}
				case MaterialType.PHONG_BITMAP_MATERIAL :
				{
					var phongBitmapData : BitmapData = this.bitmapDataAssets[ vo.assetClass ] ;
					
					vo.materialData = phongBitmapData ;
					vo.material = new PhongBitmapMaterial ( phongBitmapData ) ;
					// TODO: Implement across all materials.
					vo.materialType = vo.materialType ;
					vo = this.materialPropertyFactory.build ( vo ) ;
					Mesh ( vo.mesh ).material = vo.material as PhongBitmapMaterial ;
					break ;
				}
			}
			
			if ( applySpecialProperties )
			{
				vo.material[ MaterialAttributes.SMOOTH ] = vo.smooth ;
				vo.material[ MaterialAttributes.PRECISION ] = vo.precision ;
			}
			
			switch ( vo.geometryType )
			{
				case GeometryType.COLLADA :
				{
					if ( vo.assetClass != null )
					{
						var xml : XML = this.colladaAssets[ vo.assetClass ] ;
						var container : ObjectContainer3D = Collada.parse ( xml ) ;
						
						vo.mesh = container ;
						section.pivot.addChild ( container ) ;
						this.applyColladaValues ( container , vo.values , vo ) ;
					}
					else if ( vo.assetFile != null )
					{
						var loader : Loader3D = Collada.load ( vo.assetFile ) ;
						
						loader.extra = vo ;
						loader.addOnSuccess ( this.onColladaLoadSuccess ) ;
						section.pivot.addChild ( loader ) ;
					}
					
					break ;
				}
				default :
				{
					if ( vo.enabled ) section.pivot.addChild ( vo.mesh ) ;
				}
			}
			
			this.geometry.push ( vo ) ;
		}

		
		
		protected function onColladaLoadSuccess ( event : Loader3DEvent ) : void
		{
			var loader : Loader3D = event.loader ;
			var vo : SceneGeometryVO = loader.extra as SceneGeometryVO ;
			var geometryEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.COLLADA_COMPLETE ) ;
			
			vo.mesh = loader.handle ;
			this.applyColladaValues ( loader.handle , vo.values , vo ) ;
			geometryEvent.data = vo ;
			this.dispatchEvent ( geometryEvent ) ;
		}
		
		
		
		protected function applyPosition ( target : Object3D , values : SceneObjectVO ) : void
		{
			target.x = this.precision * ConvertCoordinates.positionX ( values.x , this.coordinateSystem ) ;
			target.y = this.precision * ConvertCoordinates.positionY ( values.y , this.coordinateSystem ) ;
			target.z = this.precision * ConvertCoordinates.positionZ ( values.z , this.coordinateSystem ) ;
		}
		
		
		
		protected function applyMeshRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			target.rotationX = ConvertCoordinates.meshRotationX ( values.rotationX , this.coordinateSystem ) ;
			target.rotationY = ConvertCoordinates.meshRotationY ( values.rotationY , this.coordinateSystem ) ;
			target.rotationZ = ConvertCoordinates.meshRotationZ ( values.rotationZ , this.coordinateSystem ) ;
		}
		
		
		
		protected function applyGroupRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			target.rotationX = ConvertCoordinates.groupRotationX ( values.rotationX , this.coordinateSystem ) ;
			target.rotationY = ConvertCoordinates.groupRotationY ( values.rotationY , this.coordinateSystem ) ;
			target.rotationZ = ConvertCoordinates.groupRotationZ ( values.rotationZ , this.coordinateSystem ) ;
		}
		
		
		
		protected function applyColladaRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			target.rotationX = ConvertCoordinates.colladaRotationX ( values.rotationX , this.coordinateSystem ) ;
			target.rotationY = ConvertCoordinates.colladaRotationY ( values.rotationY , this.coordinateSystem ) ;
			target.rotationZ = ConvertCoordinates.colladaRotationZ ( values.rotationZ , this.coordinateSystem ) ;
		}
		
		
		
		protected function applyCameraRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			target.rotationX = ConvertCoordinates.cameraRotationX ( values.rotationX , this.coordinateSystem ) ;
			target.rotationY = ConvertCoordinates.cameraRotationY ( values.rotationY , this.coordinateSystem ) ;
			target.rotationZ = ConvertCoordinates.cameraRotationZ ( values.rotationZ , this.coordinateSystem ) ;
		}
		
		
		
		protected function applyScale ( target : Mesh , values : SceneObjectVO ) : void
		{
			target.scaleX = values.scaleX ;
			target.scaleY = values.scaleY ;
			target.scaleZ = values.scaleZ ;
		}
		
		
		
		protected function applyPivotScale ( target : Object3D , values : SceneObjectVO ) : void
		{
			// FIXME: Use custom geometry scaling property instead of geometry x scale value?
			target.scale ( values.scaleX ) ;
		}

		
		
		protected function applyColladaScale ( target : Object3D , values : SceneObjectVO , vo : SceneGeometryVO ) : void
		{
			var multiplier : uint = 1 ;
			var scale : Number = values.scaleX ;
			
			switch ( this.coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					// NOTE: The divider is due to the Collada class having an internal scaling multiplier of 100.
					multiplier = this.precision / 100 ;
					break ;
				}
			}
			
			if ( vo.colladaScale > 0 ) scale = vo.colladaScale ;
			target.scale ( multiplier * scale ) ;
		}
	}
}