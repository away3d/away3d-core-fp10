/*
VERSION: 1.0
DATE: 1/29/2009
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	This class works in conjunction with the TweenLiteVars or TweenMaxVars class to grant
	strict data typing and code hinting (in most code editors) for filter tweens. See the documentation in
	the TweenLiteVars or TweenMaxVars for more information.


AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/


package gs.utils.tween {
	public class SubVars {
		public var isTV:Boolean = true;
		public var exposedVars:Object;
		
		public function SubVars() {
			this.exposedVars = {};
		}

	}
}