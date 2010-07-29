package away3d.core.filter
{
	import away3d.core.project.PrimitiveType;
    import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.clip.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
	import away3d.core.utils.*;
    
    import flash.utils.*;

    /**
    * Corrects triangle z-sorting
    */
    public class AnotherRivalFilter implements IPrimitiveQuadrantFilter
    {
        private var maxdelay:int;
    	
    	private var renderer:QuadrantRenderer;
    	private var start:int;
        private var check:int;
    
        private var primitives:Array;
        private var turn:int;
        
        private var maxZ:Number;
        private var minZ:Number;
        private var maxdeltaZ:Number;
        
        private var rivals:Array;
        private var parts:Array;
        
        private var ZOrderDeeper:int = 1;
        private var ZOrderIrrelevant:int = 0;
        private var ZOrderHigher:int = -1;
        private var ZOrderSame:int = 0;
		
		private var q0x:Number;
        private var q0y:Number;
        private var q1x:Number;
        private var q1y:Number;
        private var q2x:Number;
        private var q2y:Number;
    
        private var ql01a:Number;
        private var ql01b:Number;
        private var ql01c:Number;
        private var ql01s:Number;
        private var ql01r0:Number;
        private var ql01r1:Number;
        
        private var ql12a:Number;
        private var ql12b:Number;
        private var ql12c:Number;
        private var ql12s:Number;
        private var ql12r0:Number;
        private var ql12r1:Number;
        
        private var ql20a:Number;
        private var ql20b:Number;
        private var ql20c:Number;
        private var ql20s:Number;
        private var ql20r0:Number;
        private var ql20r1:Number;
    
        private var rla:Number;
        private var rlb:Number;
        private var rlc:Number;
        private var rlq0:Number;
        private var rlq1:Number;
        private var rlq2:Number;
        
        private var q01r:Boolean;
        private var q12r:Boolean;
        private var q20r:Boolean;
    
        private var q01rx:Number;
        private var q01ry:Number;
        private var q12rx:Number;
        private var q12ry:Number;
        private var q20rx:Number;
        private var q20ry:Number;
        private var count:int;
        private var cx:Number;
        private var cy:Number;
        
        private var q01rd:Number;
        private var q12rd:Number;
        private var q20rd:Number;
        
        private var w0x:Number;
        private var w0y:Number;
        private var w1x:Number;
        private var w1y:Number;
        private var w2x:Number;
        private var w2y:Number;
    	
        private var ql01w0:Number;
        private var ql01w1:Number;
        private var ql01w2:Number;
        
        private var ql12w0:Number;
        private var ql12w1:Number;
        private var ql12w2:Number;
        
        private var ql20w0:Number;
        private var ql20w1:Number;
        private var ql20w2:Number;
        
        private var wl01a:Number;
        private var wl01b:Number;
        private var wl01c:Number;
        private var wl01s:Number;
        private var wl01q0:Number;
        private var wl01q1:Number;
        private var wl01q2:Number;
        
        private var wl12a:Number;
        private var wl12b:Number;
        private var wl12c:Number;
        private var wl12s:Number;
        private var wl12q0:Number;
        private var wl12q1:Number;
        private var wl12q2:Number;
        
        private var wl20a:Number;
        private var wl20b:Number;
        private var wl20c:Number;
        private var wl20s:Number;
        private var wl20q0:Number;
        private var wl20q1:Number;
        private var wl20q2:Number;
        
        private var q01w01:Boolean;
        private var q12w01:Boolean;
        private var q20w01:Boolean;
        private var q01w12:Boolean;
        private var q12w12:Boolean;
        private var q20w12:Boolean;
        private var q01w20:Boolean;
        private var q12w20:Boolean;
        private var q20w20:Boolean;
        
        private var q01w01x:Number;
        private var q01w01y:Number;
        private var q12w01x:Number;
        private var q12w01y:Number;
        private var q20w01x:Number;
        private var q20w01y:Number;
        private var q01w12x:Number;
        private var q01w12y:Number;
        private var q12w12x:Number;
        private var q12w12y:Number;
        private var q20w12x:Number;
        private var q20w12y:Number;
        private var q01w20x:Number;
        private var q01w20y:Number;
        private var q12w20x:Number;
        private var q12w20y:Number;
        private var q20w20x:Number;
        private var q20w20y:Number;
        
        private var q01w01d:Number;
        private var q12w01d:Number;
        private var q20w01d:Number;
        private var q01w12d:Number;
        private var q12w12d:Number;
        private var q20w12d:Number;
        private var q01w20d:Number;
        private var q12w20d:Number;
        private var q20w20d:Number;
        
        private var _viewSourceObjectQ:ViewSourceObject;
        private var _viewSourceObjectW:ViewSourceObject;
        private var _startIndex:uint;
        private var _minX:Number;
        private var _maxX:Number;
        private var _minY:Number;
        private var _maxY:Number;
        private var _index:uint;
        
        private function zconflict(q:uint, w:uint):int
        {
			if (renderer.primitiveType[q] == PrimitiveType.FACE) { 
                if (renderer.primitiveType[w] == PrimitiveType.FACE)
                    return zconflictTT(q, w);
                if (renderer.primitiveType[w] == PrimitiveType.SEGMENT)
                    return zconflictTS(q, w);
                if (renderer.primitiveType[w] == PrimitiveType.SPRITE3D)
                    return zconflictTB(q, w);
            } else if (renderer.primitiveType[q] == PrimitiveType.SEGMENT) {
                if (renderer.primitiveType[w] == PrimitiveType.FACE)
                    return -zconflictTS(w, q);
            } else if (renderer.primitiveType[q] == PrimitiveType.SPRITE3D) {
				if (renderer.primitiveType[w] == PrimitiveType.FACE)
                    return -zconflictTB(w, q);
                if (renderer.primitiveType[w] == PrimitiveType.SPRITE3D)
                    return zconflictBB(q, w);
            }
            return ZOrderIrrelevant;
        }
    
        private function zconflictBB(q:uint, w:uint):int
        {
            if (renderer.primitiveScreenZ[q] > renderer.primitiveScreenZ[w])
                return ZOrderDeeper;
            if (renderer.primitiveScreenZ[q] < renderer.primitiveScreenZ[w])
                return ZOrderHigher;
    
            return ZOrderSame;
        }

        private function zconflictTB(q:uint, w:uint):int
        {
        	_viewSourceObjectQ = renderer.primitiveSource[q];
        	_viewSourceObjectW = renderer.primitiveSource[w];
        	_minX = renderer.primitiveProperties[w*9 + 2];
        	_maxX = renderer.primitiveProperties[w*9 + 3];
        	_minY = renderer.primitiveProperties[w*9 + 4];
        	_maxY = renderer.primitiveProperties[w*9 + 5];
        	
        	_index = _viewSourceObjectW.screenIndices[renderer.primitiveProperties[w*9]]*3;
        	w0x = _viewSourceObjectW.screenVertices[_index];
        	w0y = _viewSourceObjectW.screenVertices[_index + 1];
        	
			if (_viewSourceObjectQ.contains(q, renderer, w0x, w0y))
                return zcompare(q, w, w0x, w0y);
            else
            if (_viewSourceObjectQ.contains(q, renderer, _minX, _minY))
                return zcompare(q, w, _minX, _minY);
            else
            if (_viewSourceObjectQ.contains(q, renderer, _minX, _maxY))
                return zcompare(q, w, _minX, _maxY);
            else
            if (_viewSourceObjectQ.contains(q, renderer, _maxX, _minY))
                return zcompare(q, w, _maxX, _minY);
            else
            if (_viewSourceObjectQ.contains(q, renderer, _maxX, _maxY))
                return zcompare(q, w, _maxX, _maxY);
            else
                return ZOrderIrrelevant;
        }
        
        private function zconflictTS(q:uint, w:uint):int
        {
        	_viewSourceObjectQ = renderer.primitiveSource[q];
        	_startIndex = renderer.primitiveProperties[q*9];
        	
        	_index = _viewSourceObjectQ.screenIndices[_startIndex]*3;
			q0x = _viewSourceObjectQ.screenVertices[_index];
            q0y = _viewSourceObjectQ.screenVertices[_index + 1];
            _index = _viewSourceObjectQ.screenIndices[_startIndex + 1]*3;
            q1x = _viewSourceObjectQ.screenVertices[_index];
            q1y = _viewSourceObjectQ.screenVertices[_index + 1];
            _index = _viewSourceObjectQ.screenIndices[_startIndex + 2]*3;
            q2x = _viewSourceObjectQ.screenVertices[_index];
            q2y = _viewSourceObjectQ.screenVertices[_index + 1];
    		
        	_viewSourceObjectW = renderer.primitiveSource[w];
        	_startIndex = renderer.primitiveProperties[w*9];
        	
    		_index = _viewSourceObjectW.screenIndices[_startIndex]*3;
            w0x = _viewSourceObjectW.screenVertices[_index];
            w0y = _viewSourceObjectW.screenVertices[_index + 1];
            _index = _viewSourceObjectW.screenIndices[_startIndex + 1]*3;
            w1x = _viewSourceObjectW.screenVertices[_index];
            w1y = _viewSourceObjectW.screenVertices[_index + 1];
    
            ql01a = q1y - q0y;
            ql01b = q0x - q1x;
            ql01c = -(ql01b*q0y + ql01a*q0x);
            ql01s = ql01a*q2x + ql01b*q2y + ql01c;
            ql01r0 = (ql01a*w0x + ql01b*w0y + ql01c) * ql01s;
            ql01r1 = (ql01a*w1x + ql01b*w1y + ql01c) * ql01s;
    
            if ((ql01r0 <= 0.0001) && (ql01r1 <= 0.0001))
                return ZOrderIrrelevant;
    		
            ql12a = q2y - q1y;
            ql12b = q1x - q2x;
            ql12c = -(ql12b*q1y + ql12a*q1x);
            ql12s = ql12a*q0x + ql12b*q0y + ql12c;
            ql12r0 = (ql12a*w0x + ql12b*w0y + ql12c) * ql12s;
            ql12r1 = (ql12a*w1x + ql12b*w1y + ql12c) * ql12s;
    		
            if ((ql12r0 <= 0.0001) && (ql12r1 <= 0.0001))
                return ZOrderIrrelevant;
    		
            ql20a = q0y - q2y;
            ql20b = q2x - q0x;
            ql20c = -(ql20b*q2y + ql20a*q2x);
            ql20s = ql20a*q1x + ql20b*q1y + ql20c;
            ql20r0 = (ql20a*w0x + ql20b*w0y + ql20c) * ql20s;
            ql20r1 = (ql20a*w1x + ql20b*w1y + ql20c) * ql20s;
    
            if ((ql20r0 <= 0.0001) && (ql20r1 <= 0.0001))
                return ZOrderIrrelevant;
    
            rla = w1y - w0y;
            rlb = w0x - w1x;
            rlc = -(rlb*w0y + rla*w0x);
            rlq0 = (rla*q0x + rlb*q0y + rlc);
            rlq1 = (rla*q1x + rlb*q1y + rlc);
            rlq2 = (rla*q2x + rlb*q2y + rlc);
    
            if ((rlq0*rlq1 >= 0.0001) && (rlq1*rlq2 >= 0.0001) && (rlq2*rlq0 >= 0.0001))
                return ZOrderIrrelevant;
    
            if (((ql01r0 > -0.0001) && (ql12r0 > -0.0001) && (ql20r0 > -0.0001))
             && ((ql01r1 > -0.0001) && (ql12r1 > -0.0001) && (ql20r1 > -0.0001)))
            {
                return zcompare(q, w, (w0x+w1x)/2, (w0y+w1y)/2);
            }
    
            q01r = ((rlq0*rlq1 < 0.0001) && (ql01r0*ql01r1 < 0.0001));
            q12r = ((rlq1*rlq2 < 0.0001) && (ql12r0*ql12r1 < 0.0001));
            q20r = ((rlq2*rlq0 < 0.0001) && (ql20r0*ql20r1 < 0.0001));
    		
            count = 0;
            cx = 0;
            cy = 0;
    
            if ((ql01r0 > 0.0001) && (ql12r0 > 0.0001) && (ql20r0 > 0.0001))
            {
                cx += w0x;
                cy += w0y;
                count += 1;
            }
    
            if ((ql01r1 > 0.0001) && (ql12r1 > 0.0001) && (ql20r1 > 0.0001))
            {
                cx += w1x;
                cy += w1y;
                count += 1;
            }
    
            if (q01r)
            { 
                q01rd = ql01a*rlb - ql01b*rla;
                if (q01rd*q01rd > 0.0001)
                {
                    q01rx = (ql01b*rlc - ql01c*rlb) / q01rd;
                    q01ry = (ql01c*rla - ql01a*rlc) / q01rd;
                    cx += q01rx;
                    cy += q01ry;
                    count += 1;
                }
            }
    
            if (q12r)
            { 
                q12rd = ql12a*rlb - ql12b*rla;
                if (q12rd*q12rd > 0.0001)
                {
                    q12rx = (ql12b*rlc - ql12c*rlb) / q12rd;
                    q12ry = (ql12c*rla - ql12a*rlc) / q12rd;
                    cx += q12rx;
                    cy += q12ry;
                    count += 1;
                }
            }
    
            if (q20r)
            { 
                q20rd = ql20a*rlb - ql20b*rla;
                if (q20rd*q20rd > 0.0001)
                {
                    q20rx = (ql20b*rlc - ql20c*rlb) / q20rd;
                    q20ry = (ql20c*rla - ql20a*rlc) / q20rd;
                    cx += q20rx;
                    cy += q20ry;
                    count += 1;
                }
            }
    
            return zcompare(q, w, cx / count, cy / count);
        }
    

        
        private function zconflictTT(q:uint, w:uint):int
        {
        	_viewSourceObjectQ = renderer.primitiveSource[q];
        	_startIndex = renderer.primitiveProperties[q*9];
        	
        	_index = _viewSourceObjectQ.screenIndices[_startIndex]*3;
			q0x = _viewSourceObjectQ.screenVertices[_index];
            q0y = _viewSourceObjectQ.screenVertices[_index + 1];
            _index = _viewSourceObjectQ.screenIndices[_startIndex + 1]*3;
            q1x = _viewSourceObjectQ.screenVertices[_index];
            q1y = _viewSourceObjectQ.screenVertices[_index + 1];
            _index = _viewSourceObjectQ.screenIndices[_startIndex + 2]*3;
            q2x = _viewSourceObjectQ.screenVertices[_index];
            q2y = _viewSourceObjectQ.screenVertices[_index + 1];
    		
        	_viewSourceObjectW = renderer.primitiveSource[w];
    		_startIndex = renderer.primitiveProperties[w*9];
    		
    		_index = _viewSourceObjectW.screenIndices[_startIndex]*3;
            w0x = _viewSourceObjectW.screenVertices[_index];
            w0y = _viewSourceObjectW.screenVertices[_index + 1];
            _index = _viewSourceObjectW.screenIndices[_startIndex + 1]*3;
            w1x = _viewSourceObjectW.screenVertices[_index];
            w1y = _viewSourceObjectW.screenVertices[_index + 1];
            _index = _viewSourceObjectW.screenIndices[_startIndex + 2]*3;
            w2x = _viewSourceObjectW.screenVertices[_index];
            w2y = _viewSourceObjectW.screenVertices[_index + 1];
    
            ql01a = q1y - q0y;
            ql01b = q0x - q1x;
            ql01c = -(ql01b*q0y + ql01a*q0x);
            ql01s = ql01a*q2x + ql01b*q2y + ql01c;
            ql01w0 = (ql01a*w0x + ql01b*w0y + ql01c) * ql01s;
            ql01w1 = (ql01a*w1x + ql01b*w1y + ql01c) * ql01s;
            ql01w2 = (ql01a*w2x + ql01b*w2y + ql01c) * ql01s;
    
                if ((ql01w0 <= 0.0001) && (ql01w1 <= 0.0001) && (ql01w2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            ql12a = q2y - q1y;
            ql12b = q1x - q2x;
            ql12c = -(ql12b*q1y + ql12a*q1x);
            ql12s = ql12a*q0x + ql12b*q0y + ql12c;
            ql12w0 = (ql12a*w0x + ql12b*w0y + ql12c) * ql12s;
            ql12w1 = (ql12a*w1x + ql12b*w1y + ql12c) * ql12s;
            ql12w2 = (ql12a*w2x + ql12b*w2y + ql12c) * ql12s;
    
                if ((ql12w0 <= 0.0001) && (ql12w1 <= 0.0001) && (ql12w2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            ql20a = q0y - q2y;
            ql20b = q2x - q0x;
            ql20c = -(ql20b*q2y + ql20a*q2x);
            ql20s = ql20a*q1x + ql20b*q1y + ql20c;
            ql20w0 = (ql20a*w0x + ql20b*w0y + ql20c) * ql20s;
            ql20w1 = (ql20a*w1x + ql20b*w1y + ql20c) * ql20s;
            ql20w2 = (ql20a*w2x + ql20b*w2y + ql20c) * ql20s;
    
                if ((ql20w0 <= 0.0001) && (ql20w1 <= 0.0001) && (ql20w2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            wl01a = w1y - w0y;
            wl01b = w0x - w1x;
            wl01c = -(wl01b*w0y + wl01a*w0x);
            wl01s = wl01a*w2x + wl01b*w2y + wl01c;
            wl01q0 = (wl01a*q0x + wl01b*q0y + wl01c) * wl01s;
            wl01q1 = (wl01a*q1x + wl01b*q1y + wl01c) * wl01s;
            wl01q2 = (wl01a*q2x + wl01b*q2y + wl01c) * wl01s;
    
                if ((wl01q0 <= 0.0001) && (wl01q1 <= 0.0001) && (wl01q2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            wl12a = w2y - w1y;
            wl12b = w1x - w2x;
            wl12c = -(wl12b*w1y + wl12a*w1x);
            wl12s = wl12a*w0x + wl12b*w0y + wl12c;
            wl12q0 = (wl12a*q0x + wl12b*q0y + wl12c) * wl12s;
            wl12q1 = (wl12a*q1x + wl12b*q1y + wl12c) * wl12s;
            wl12q2 = (wl12a*q2x + wl12b*q2y + wl12c) * wl12s;
    
                if ((wl12q0 <= 0.0001) && (wl12q1 <= 0.0001) && (wl12q2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            wl20a = w0y - w2y;
            wl20b = w2x - w0x;
            wl20c = -(wl20b*w2y + wl20a*w2x);
            wl20s = wl20a*w1x + wl20b*w1y + wl20c;
            wl20q0 = (wl20a*q0x + wl20b*q0y + wl20c) * wl20s;
            wl20q1 = (wl20a*q1x + wl20b*q1y + wl20c) * wl20s;
            wl20q2 = (wl20a*q2x + wl20b*q2y + wl20c) * wl20s;
    
                if ((wl20q0 <= 0.0001) && (wl20q1 <= 0.0001) && (wl20q2 <= 0.0001))
                    return ZOrderIrrelevant;
            
                if (((wl01q0*wl01q0 <= 0.0001) || (wl12q0*wl12q0 <= 0.0001) || (wl20q0*wl20q0 <= 0.0001))
                 && ((wl01q1*wl01q1 <= 0.0001) || (wl12q1*wl12q1 <= 0.0001) || (wl20q1*wl20q1 <= 0.0001))
                 && ((wl01q2*wl01q2 <= 0.0001) || (wl12q2*wl12q2 <= 0.0001) || (wl20q2*wl20q2 <= 0.0001)))
                {
                    return zcompare(q, w, (q0x+q1x+q2x)/3, (q0y+q1y+q2y)/3);
                }
            
                if (((ql01w0*ql01w0 <= 0.0001) || (ql12w0*ql12w0 <= 0.0001) || (ql20w0*ql20w0 <= 0.0001))
                 && ((ql01w1*ql01w1 <= 0.0001) || (ql12w1*ql12w1 <= 0.0001) || (ql20w1*ql20w1 <= 0.0001))
                 && ((ql01w2*ql01w2 <= 0.0001) || (ql12w2*ql12w2 <= 0.0001) || (ql20w2*ql20w2 <= 0.0001)))
                {
                    return zcompare(q, w, (w0x+w1x+w2x)/3, (w0y+w1y+w2y)/3);
                }
    
            q01w01 = ((wl01q0*wl01q1 < 0.0001) && (ql01w0*ql01w1 < 0.0001));
            q12w01 = ((wl01q1*wl01q2 < 0.0001) && (ql12w0*ql12w1 < 0.0001));
            q20w01 = ((wl01q2*wl01q0 < 0.0001) && (ql20w0*ql20w1 < 0.0001));
            q01w12 = ((wl12q0*wl12q1 < 0.0001) && (ql01w1*ql01w2 < 0.0001));
            q12w12 = ((wl12q1*wl12q2 < 0.0001) && (ql12w1*ql12w2 < 0.0001));
            q20w12 = ((wl12q2*wl12q0 < 0.0001) && (ql20w1*ql20w2 < 0.0001));
            q01w20 = ((wl20q0*wl20q1 < 0.0001) && (ql01w2*ql01w0 < 0.0001));
            q12w20 = ((wl20q1*wl20q2 < 0.0001) && (ql12w2*ql12w0 < 0.0001));
            q20w20 = ((wl20q2*wl20q0 < 0.0001) && (ql20w2*ql20w0 < 0.0001));
            
            count = 0;
            cx = 0;
            cy = 0;
    
            if ((ql01w0 > 0.0001) && (ql12w0 > 0.0001) && (ql20w0 > 0.0001))
            {
                cx += w0x;
                cy += w0y;
                count += 1;
            }
    
            if ((ql01w1 > 0.0001) && (ql12w1 > 0.0001) && (ql20w1 > 0.0001))
            {
                cx += w1x;
                cy += w1y;
                count += 1;
            }
    
            if ((ql01w2 > 0.0001) && (ql12w2 > 0.0001) && (ql20w2 > 0.0001))
            {
                cx += w2x;
                cy += w2y;
                count += 1;
            }
    
            if ((wl01q0 > 0.0001) && (wl12q0 > 0.0001) && (wl20q0 > 0.0001))
            {
                cx += q0x;
                cy += q0y;
                count += 1;
            }
    
            if ((wl01q1 > 0.0001) && (wl12q1 > 0.0001) && (wl20q1 > 0.0001))
            {
                cx += q1x;
                cy += q1y;
                count += 1;
            }
    
            if ((wl01q2 > 0.0001) && (wl12q2 > 0.0001) && (wl20q2 > 0.0001))
            {
                cx += q2x;
                cy += q2y;
                count += 1;
            }
    
            if (q01w01)
            { 
                q01w01d = ql01a*wl01b - ql01b*wl01a;
                if (q01w01d*q01w01d > 0.0001)
                {
                    q01w01x = (ql01b*wl01c - ql01c*wl01b) / q01w01d;
                    q01w01y = (ql01c*wl01a - ql01a*wl01c) / q01w01d;
                    cx += q01w01x;
                    cy += q01w01y;
                    count += 1;
                }
            }
    
            if (q12w01)
            { 
                q12w01d = ql12a*wl01b - ql12b*wl01a;
                if (q12w01d*q12w01d > 0.0001)
                {
                    q12w01x = (ql12b*wl01c - ql12c*wl01b) / q12w01d;
                    q12w01y = (ql12c*wl01a - ql12a*wl01c) / q12w01d;
                    cx += q12w01x;
                    cy += q12w01y;
                    count += 1;
                }
            }
    
            if (q20w01)
            { 
                q20w01d = ql20a*wl01b - ql20b*wl01a;
                if (q20w01d*q20w01d > 0.0001)
                {
                    q20w01x = (ql20b*wl01c - ql20c*wl01b) / q20w01d;
                    q20w01y = (ql20c*wl01a - ql20a*wl01c) / q20w01d;
                    cx += q20w01x;
                    cy += q20w01y;
                    count += 1;
                }
            }
    
            if (q01w12)
            { 
                q01w12d = ql01a*wl12b - ql01b*wl12a;
                if (q01w12d*q01w12d > 0.0001)
                {
                    q01w12x = (ql01b*wl12c - ql01c*wl12b) / q01w12d;
                    q01w12y = (ql01c*wl12a - ql01a*wl12c) / q01w12d;
                    cx += q01w12x;
                    cy += q01w12y;
                    count += 1;
                }
            }
    
            if (q12w12)
            { 
                q12w12d = ql12a*wl12b - ql12b*wl12a;
                if (q12w12d*q12w12d > 0.0001)
                {
                    q12w12x = (ql12b*wl12c - ql12c*wl12b) / q12w12d;
                    q12w12y = (ql12c*wl12a - ql12a*wl12c) / q12w12d;
                    cx += q12w12x;
                    cy += q12w12y;
                    count += 1;
                }
            }
    
            if (q20w12)
            { 
                q20w12d = ql20a*wl12b - ql20b*wl12a;
                if (q20w12d*q20w12d > 0.0001)
                {
                    q20w12x = (ql20b*wl12c - ql20c*wl12b) / q20w12d;
                    q20w12y = (ql20c*wl12a - ql20a*wl12c) / q20w12d;
                    cx += q20w12x;
                    cy += q20w12y;
                    count += 1;
                }
            }
    
            if (q01w20)
            { 
                q01w20d = ql01a*wl20b - ql01b*wl20a;
                if (q01w20d*q01w20d > 0.0001)
                {
                    q01w20x = (ql01b*wl20c - ql01c*wl20b) / q01w20d;
                    q01w20y = (ql01c*wl20a - ql01a*wl20c) / q01w20d;
                    cx += q01w20x;
                    cy += q01w20y;
                    count += 1;
                }
            }
    
            if (q12w20)
            { 
                q12w20d = ql12a*wl20b - ql12b*wl20a;
                if (q12w20d*q12w20d > 0.0001)
                {
                    q12w20x = (ql12b*wl20c - ql12c*wl20b) / q12w20d;
                    q12w20y = (ql12c*wl20a - ql12a*wl20c) / q12w20d;
                    cx += q12w20x;
                    cy += q12w20y;
                    count += 1;
                }
            }
    
            if (q20w20)
            { 
                q20w20d = ql20a*wl20b - ql20b*wl20a;
                if (q20w20d*q20w20d > 0.0001)
                {
                    q20w20x = (ql20b*wl20c - ql20c*wl20b) / q20w20d;
                    q20w20y = (ql20c*wl20a - ql20a*wl20c) / q20w20d;
                    cx += q20w20x;
                    cy += q20w20y;
                    count += 1;
                }
            }
    
            return zcompare(q, w, cx / count, cy / count);
        }
    	
    	private var qz:Number;
    	private var wz:Number;
    	
        private function zcompare(q:uint, w:uint, x:Number, y:Number):int
        {
        	qz = _viewSourceObjectQ.getUVT(q, renderer, x, y)[2];
            wz = _viewSourceObjectW.getUVT(w, renderer, x, y)[2];
    
            if (qz > wz)
                return ZOrderDeeper;
            if (qz < wz)
                return ZOrderHigher;
    
            return ZOrderSame;
        }
        
		/**
		 * Creates a new <code>AnotherRivalFilter</code> object.
		 *
		 * @param	maxdelay	[optional]		The maximum time the filter can take to resolve z-depth before timing out.
		 */
        public function AnotherRivalFilter(maxdelay:int = 60000)
        {
            this.maxdelay = maxdelay;
        }
        
		/**
		 * @inheritDoc
		 */
        public function filter(renderer:QuadrantRenderer):void
        {
        	this.renderer = renderer;
            start = getTimer();
            check = 0;
    
            primitives = renderer.list();
            turn = 0;
            
            while (primitives.length > 0) {
            	
                var leftover:Array = [];
                var priIndex:uint;
                for each (priIndex in primitives) {
                	
                    ++check;
                    
                    if (check == 10)
                        if (getTimer() - start > maxdelay)
                            return;
                        else
                            check = 0;
					
                    maxZ = renderer.primitiveProperties[priIndex*9 + 7] + 1000;
                    minZ = renderer.primitiveProperties[priIndex*9 + 6] - 1000;
                    maxdeltaZ = 0;
                    
                    rivals = renderer.getRivals(priIndex);
                    var rival:uint;
                    for each (rival in rivals) {
                    	
                        if (rival == priIndex)
                            continue;
    
                        switch (zconflict(priIndex, rival)) {
                            case ZOrderIrrelevant:
                                break;
                            case ZOrderDeeper:
                            	if (minZ < renderer.primitiveScreenZ[rival])
                            		minZ = renderer.primitiveScreenZ[rival];
                                break;
                            case ZOrderHigher:
                            	if (maxZ > renderer.primitiveScreenZ[rival])
                            		maxZ = renderer.primitiveScreenZ[rival];
                                break;
                        }
                    }
                    
                    if (maxZ >= renderer.primitiveScreenZ[priIndex] && renderer.primitiveScreenZ[priIndex] >= minZ) {
                        // screenZ still sits between the maxZ and minZ
                    } else if (maxZ >= minZ) {
                    	//screenZ has to be re-calculated for the new maxZ and minZ
                        renderer.primitiveScreenZ[priIndex] = (maxZ + minZ) / 2;
                    } else {
                    	//there is no value for screenZ, triangle is flagged for tesselation
                        if (turn % 3 == 2) {
                            parts = renderer.primitiveSource[priIndex].quarter(priIndex, renderer);
                            
                            if (parts == null)
                            	continue;
                            	
                            renderer.remove(priIndex);
                            var part:uint;
                            for each (part in parts)
                                if (renderer.primitive(part))
                                    leftover.push(part);
                        }
                        else
                            leftover.push(priIndex);
                    }
                }
                
                primitives = leftover;
                
                turn += 1;
                
                if (turn == 20)
                    break;
            }
        }
        
		/**
		 * Used to trace the values of a filter.
		 * 
		 * @return A string representation of the filter object.
		 */
        public function toString():String
        {
            return "AnotherRivalFilter" + ((maxdelay == 60000) ? "" : "("+maxdelay+"ms)");
        }
    }
}