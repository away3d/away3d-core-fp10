package awaybuilder.geometry
{
	import away3d.core.base.Object3D;
	
	import awaybuilder.abstracts.AbstractGeometryController;
	import awaybuilder.events.GeometryEvent;
	import awaybuilder.interfaces.IGeometryController;
	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.SceneSectionVO;
	
	import flash.events.Event;
	
	
	
	public class GeometryController extends AbstractGeometryController implements IGeometryController
	{
		protected var geometry : Array ;
		
		
		
		public function GeometryController ( geometry : Array )
		{
			super ( ) ;
			this.geometry = geometry ;
		}

		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Override Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		override public function enableInteraction ( ) : void
		{
			for each ( var geometry : SceneGeometryVO in this.geometry )
			{
				this.enableGeometryInteraction ( geometry ) ;
			}
		}
		
		
		
		override public function disableInteraction ( ) : void
		{
			for each ( var geometry : SceneGeometryVO in this.geometry )
			{
				this.disableGeometryInteraction ( geometry ) ;
			}
		}
		
		
		
		override public function enableGeometryInteraction ( geometry : SceneGeometryVO ) : void
		{
			if ( geometry.mesh )
			{
				this.disableGeometryInteraction ( geometry ) ;
				geometry.mesh.useHandCursor = geometry.useHandCursor ;
				if ( geometry.mouseDownEnabled ) geometry.mesh.addOnMouseDown ( this.geometryMouseDown ) ;
				if ( geometry.mouseMoveEnabled ) geometry.mesh.addOnMouseMove ( this.geometryMouseMove) ;
				if ( geometry.mouseOutEnabled ) geometry.mesh.addOnMouseOut ( this.geometryMouseOut ) ;
				if ( geometry.mouseOverEnabled ) geometry.mesh.addOnMouseOver ( this.geometryMouseOver ) ;
				if ( geometry.mouseUpEnabled ) geometry.mesh.addOnMouseUp ( this.geometryMouseUp ) ;
			}
		}
		
		
		
		override public function disableGeometryInteraction ( geometry : SceneGeometryVO ) : void
		{
			geometry.mesh.useHandCursor = false ;
			geometry.mesh.removeOnMouseDown ( this.geometryMouseDown ) ;
			geometry.mesh.removeOnMouseMove ( this.geometryMouseMove ) ;
			geometry.mesh.removeOnMouseOut ( this.geometryMouseOut ) ;
			geometry.mesh.removeOnMouseOver ( this.geometryMouseOver ) ;
			geometry.mesh.removeOnMouseUp ( this.geometryMouseUp ) ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Protected Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function extractGeometry ( mainSection : SceneSectionVO , allGeometry : Array , cascade : Boolean = false ) : Array
		{
			for each ( var geometry : SceneGeometryVO in mainSection.geometry )
			{
				allGeometry.push ( geometry ) ;
			}
			
			if ( cascade )
			{
				for each ( var subSection : SceneSectionVO in mainSection.sections )
				{
					var a : Array = this.extractGeometry ( subSection , allGeometry ) ;
					allGeometry.concat ( a ) ;
				}
			}
			
			return allGeometry ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Event Handlers
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function geometryMouseDown ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.DOWN ) ;
					
					interactionEvent.data = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseMove ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.MOVE ) ;
					
					interactionEvent.data = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseOut ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.OUT ) ;
					
					interactionEvent.data = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseOver ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.OVER ) ;
					
					interactionEvent.data = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseUp ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.UP ) ;
					
					interactionEvent.data = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
	}
}