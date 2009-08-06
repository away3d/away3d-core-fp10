/*
VERSION: 1.0
DATE: 1/21/2009
ACTIONSCRIPT VERSION: 3.0
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenLite.com
DESCRIPTION:
	Stores basic info about individual property tweens in TweenLite/Max.
	
AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.utils.tween {

	public class TweenInfo {
		public var target:Object;
		public var property:String;
		public var start:Number;
		public var change:Number;
		public var name:String;
		public var isPlugin:Boolean;
		
		public function TweenInfo($target:Object, $property:String, $start:Number, $change:Number, $name:String, $isPlugin:Boolean) {
			this.target = $target;
			this.property = $property;
			this.start = $start;
			this.change = $change;
			this.name = $name;
			this.isPlugin = $isPlugin;
		}
	}
}