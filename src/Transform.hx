package;

import motion.easing.Quad;
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.filters.BlurFilter;
import openfl.filters.DropShadowFilter;
import openfl.geom.Point;
import openfl.media.Sound;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.Assets;
import openfl.Lib;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.ui.Mouse;

import akifox.debug.Performance;
import akifox.Utils;
import akifox.gui.TextFieldSmooth;
import akifox.Transformation;
import akifox.Points;

class Transform extends Sprite {

	var r:Sprite;

	var ox = 200;
	var oy = 200;
	var ow = 100;
	var oh = 100;

	var rp:Point;

	var pivot:Transformation;
	
	public function new () {
		
		super();

		Mouse.hide();

		r = new Sprite();
		r.x = ox;
		r.y = ox;
		r.alpha = 0.5;

		r.graphics.beginFill(0xFF0000,1);
		r.graphics.drawRect(0,0,ow,oh);
		r.graphics.endFill();
		addChild(r);

		pivot = new Transformation(r);
		pivot.setInternalPoint([2,2]); // imagine a square with 9 anchor points
									   // 0,0 is top left 1,1 is center and 2,2 is bottom right
		rp = pivot.getAbsolutePoint();

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, setrotationpoint);
		Lib.current.stage.addEventListener (MouseEvent.MOUSE_DOWN, this_onMouseDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);

		//kind of unit primitive testing
		/*pivot.moveTo(30,30); //30,30
		pivot.translate(100,30); //130,160
		pivot.moveTo(100,50); //100,50
		pivot.translate(150); //250,50
		pivot.setInternalPoint([0,0]); // 150,-50
		pivot.translate(0,200); //150,150
		trace(pivot.getAbsolutePoint()); //SHOULD BE 150,150*/

		//pivot.scale(2);

		drawme();

	}


	// Event Handlers

	var mousedown:Point;
	var dragged:Bool=false;

	var angle:Float=0;
	var langle:Float=0;

	var dCenterMousedown:Float;
	var center:Point;


	private function this_onMouseDown (event:MouseEvent):Void {
		mousedown = new Point(Std.int(event.stageX),Std.int(event.stageY));
		center = pivot.getAbsolutePoint();
		dCenterMousedown = Points.distance(mousedown,center);
		setAngle(false);

		stage.addEventListener (MouseEvent.MOUSE_MOVE, stage_onMouseMove);
		stage.addEventListener (MouseEvent.MOUSE_UP, stage_onMouseUp);

	}


	private function stage_onMouseMove (event:MouseEvent):Void {
		if (!dragged && Points.distance(mousedown,new Point(Std.int(event.stageX),Std.int(event.stageY))) > 5) {
			dragged = true;
		} else {
			if (event.shiftKey || event.altKey || event.ctrlKey) {
				if (event.shiftKey) setAngle();
				if (event.altKey) setScale(event);
				//if (event.ctrlKey)
			} 
			else {
				setPosition(event.stageX,event.stageY);
			}
		}

	}

	private function setPosition(x:Float,y:Float) {
		pivot.moveTo(x,y);
	}

	private function setAngle(?rotate:Bool=true) {
		var pt:Point = pivot.getAbsolutePoint();
		var aa:Point = Points.clone(rp);
		aa.x-=pt.x;
		aa.y-=pt.y;
		angle = Math.atan2(aa.x, aa.y);
		if (rotate) pivot.rotate(-(angle-langle)/Transformation.DEG2RAD);
		langle=angle;
	}

	private function setScale(event:MouseEvent) {
		var dNowCenter = Points.distance(center,new Point(Std.int(event.stageX),Std.int(event.stageY)));
		pivot.setScale(dNowCenter/dCenterMousedown);
	}


	private function stage_onMouseUp (event:MouseEvent):Void {
		if (!dragged) {
			//click
			setpivot(event);
		}
		dragged = false;

		stage.removeEventListener (MouseEvent.MOUSE_MOVE, stage_onMouseMove);
		stage.removeEventListener (MouseEvent.MOUSE_UP, stage_onMouseUp);
		drawme();

	}

	private function drawme(){
		var pt:Point = pivot.getAbsolutePoint();

		graphics.clear();

		//pivot point
		graphics.beginFill(0x00FF00,1);
		graphics.drawCircle(pt.x,pt.y,5);
		graphics.endFill();

		//rotation point
		graphics.beginFill(((dragged)?0xFF0000:0x0000FF),1);
		graphics.drawCircle(rp.x,rp.y,5);
		graphics.endFill();

		//transformed rect
		graphics.lineStyle(2, 0x0000FF, .5, false);
		graphics.drawRect(r.x,r.y,r.width,r.height);

		//original rect
		graphics.lineStyle(2, 0xFF00FF, .5, false);
		graphics.drawRect(ox,oy,ow,oh);
		graphics.lineStyle(2, 0x00FF00, .5, false);

		var radius = Points.distance(pt,new Point(r.x,r.y));

		if (dragged) {
			//transformed rect
			//var endX = pt.x + radius * Math.sin(angle);
			//var endY = pt.y + radius * Math.cos(angle);
			graphics.lineStyle(2, 0x0000FF, .5, false);
			graphics.moveTo(pt.x,pt.y);
			graphics.lineTo(rp.x,rp.y);
		}

		//circle rotation
		graphics.drawCircle(pt.x,pt.y,radius);

	}

	private function setpivot (event:MouseEvent):Void {
		pivot.setAbsolutePoint(Std.int(event.stageX),Std.int(event.stageY));
		drawme();
	}

	private function setrotationpoint (event:MouseEvent):Void {
		rp = new Point(Std.int(event.stageX),Std.int(event.stageY));
		drawme();
	}

	private function onKeyDown(event:KeyboardEvent):Void {
		if (dragged) return;
		
		switch (event.keyCode) {
			
			//case Keyboard.UP: 
			//	pivot.skew(50);
			//case Keyboard.DOWN:
			//	pivot.skew(-50);
			case Keyboard.RIGHT: pivot.rotate(-15);
			case Keyboard.LEFT: pivot.rotate(15);
			case Keyboard.SPACE: pivot.identity();
			case Keyboard.NUMBER_1: pivot.setInternalPoint([0,0]);
			case Keyboard.NUMBER_2: pivot.setInternalPoint([0,1]);
			case Keyboard.NUMBER_3: pivot.setInternalPoint([0,2]);
			case Keyboard.NUMBER_4: pivot.setInternalPoint([1,0]);
			case Keyboard.NUMBER_5: pivot.setInternalPoint([1,1]);
			case Keyboard.NUMBER_6: pivot.setInternalPoint([1,2]);
			case Keyboard.NUMBER_7: pivot.setInternalPoint([2,0]);
			case Keyboard.NUMBER_8: pivot.setInternalPoint([2,1]);
			case Keyboard.NUMBER_9: pivot.setInternalPoint([2,2]);
			
		}
		drawme();
	}
	
}
