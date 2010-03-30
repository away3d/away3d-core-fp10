package away3d.materials
{
    import away3d.core.draw.*;

    /**
    * Interface for materials that are capable of drawing 3d sprites.
    */
    public interface ISpriteMaterial extends IMaterial
    {
    	/**
    	 * Sends data from the material coupled with data from the <code>DrawSprite</code> primitive to the render session.
    	 */
        function renderSprite(bill:DrawSprite):void;
    }
}
