package away3d.test
{
	import away3d.core.session.AbstractSession;
    import away3d.containers.*;
    import away3d.core.render.*;
    
    /**
    * Represents a single slide of the demo
    */ 
    public class Slide
    {
        public var scene:Scene3D;
        public var renderer:Renderer;
        public var session:AbstractSession;
        public var title:String;
        public var desc:String;

        public function Slide(title:String, desc:String, scene:Scene3D, renderer:Renderer, session:AbstractSession)
        {
            this.scene = scene;
            this.renderer = renderer;
            this.session = session;
            this.title = title;
            this.desc = desc;
        }

    }
}
