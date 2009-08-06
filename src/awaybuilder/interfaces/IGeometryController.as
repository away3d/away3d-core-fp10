package awaybuilder.interfaces
{
	import awaybuilder.vo.SceneGeometryVO;
	
	
	
	public interface IGeometryController
	{
		function enableInteraction ( ) : void
		function disableInteraction ( ) : void
		function enableGeometryInteraction ( geometry : SceneGeometryVO ) : void
		function disableGeometryInteraction ( geometry : SceneGeometryVO ) : void
	}
}