package away3d.core.utils 
{

	/**
	 * @author robbateman
	 */
	public class FaceNormalShaderVO 
	{
		public var kar:Number;
		public var kag:Number;
		public var kab:Number;
		public var kdr:Number;
		public var kdg:Number;
		public var kdb:Number;
		public var ksr:Number;
		public var ksg:Number;
		public var ksb:Number;
		
		public function FaceNormalShaderVO(kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number)
		{
			this.kar = kar;
			this.kag = kag;
			this.kab = kab;
			this.kdr = kdr;
			this.kdg = kdg;
			this.kdb = kdb;
			this.ksr = ksr;
			this.ksg = ksg;
			this.ksb = ksb;
		}
	}
}
