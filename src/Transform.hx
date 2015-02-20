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
		pivot.setInternalPoint(Transformation.CENTER,Transformation.MIDDLE);
		rp = pivot.getAbsolutePoint();

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, setrotationpoint);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, this_onMouseDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onSpecialKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onSpecialKeyUp);

		//kind of unit primitive testing
		/*pivot.setInternalPoint(2,2); // 0,0
		pivot.moveTo(30,30); //30,30
		pivot.translate(100,30); //130,160
		pivot.moveTo(100,50); //100,50
		pivot.translate(150); //250,50
		pivot.setInternalPoint(0,0); // 150,-50
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

	var skewing = false;
	var scaling = false;
	var rotating = false;
	var moving = false;

	var dCenterMousedown:Float;
	var center:Point;


	private function this_onMouseDown (event:MouseEvent):Void {
		dragged = false;
		mousedown = new Point(Std.int(event.stageX),Std.int(event.stageY));
		center = pivot.getAbsolutePoint();
		dCenterMousedown = Points.distance(mousedown,center);
		setAngle(false);

		stage_onMouseMove(event);

		stage.addEventListener (MouseEvent.MOUSE_MOVE, stage_onMouseMove);
		stage.addEventListener (MouseEvent.MOUSE_UP, stage_onMouseUp);

	}


	private function stage_onMouseMove (event:MouseEvent):Void {
		if (!dragged && (event.shiftKey || event.altKey || event.ctrlKey)) dragged = true;
		if (!dragged && Points.distance(mousedown,new Point(Std.int(event.stageX),Std.int(event.stageY))) > 5) dragged = true;
		if (dragged) {
			if (event.shiftKey || event.altKey || event.ctrlKey) {
				if (event.shiftKey) setAngle();
				if (event.altKey) setScale(event);
				if (event.ctrlKey) setSkew(event);
			} 
			else {
				moving = true;
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

	private function setSkew(event:MouseEvent) {
/*		var dNowMousedownXY = new Point(Std.int(event.stageX)-mousedown.x,Std.int(event.stageY)-mousedown.y);
		var xs = ((dNowMousedownXY.x/dCenterMousedown));
		var ys = ((dNowMousedownXY.y/dCenterMousedown));*/

		var xs = (Std.int(event.stageX)-Lib.current.stage.stageWidth/2)/(Lib.current.stage.stageWidth/2);
		var ys = (Std.int(event.stageY)-Lib.current.stage.stageHeight/2)/(Lib.current.stage.stageHeight/2);

		pivot.setSkewX(xs*50);
		pivot.setSkewY(ys*50);
	}


	private function stage_onMouseUp (event:MouseEvent):Void {
		if (!dragged) {
			//click
			setpivot(event);
		}
		dragged = false;

		skewing = false;
		scaling = false;
		rotating = false;
		moving = false;

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

		var radius = Points.distance(pt,new Point(r.x,r.y));

		if (rotating || scaling) {
			graphics.lineStyle(2, 0x00FF00, .5, false);
			graphics.moveTo(pt.x,pt.y);
			graphics.lineTo(rp.x,rp.y);
		}

		if (rotating) {
			graphics.lineStyle(2, 0x00FF00, .5, false);
			graphics.drawCircle(pt.x,pt.y,radius);
		}

		if (skewing) {
			graphics.lineStyle(2, 0x0000FF, .5, false);
			graphics.moveTo(0,Std.int(Lib.current.stage.stageWidth/2));
			graphics.lineTo(Std.int(Lib.current.stage.stageWidth),Std.int(Lib.current.stage.stageWidth/2));
			graphics.moveTo(Std.int(Lib.current.stage.stageHeight/2),0);
			graphics.lineTo(Std.int(Lib.current.stage.stageHeight/2),Std.int(Lib.current.stage.stageHeight));
		}

	}

	private function setpivot (event:MouseEvent):Void {
		pivot.setAbsolutePoint(Std.int(event.stageX),Std.int(event.stageY));
		drawme();
	}

	private function setrotationpoint (event:MouseEvent):Void {
		rp = new Point(Std.int(event.stageX),Std.int(event.stageY));
		drawme();
	}

	private function onSpecialKeyDown(event:KeyboardEvent):Void {
		
		switch (event.keyCode) {
			
			case Keyboard.SHIFT: rotating = true;
			case Keyboard.CONTROL: skewing = true;
			case Keyboard.ALTERNATE: scaling = true;
			
		}
		drawme();
	}

	private function onSpecialKeyUp(event:KeyboardEvent):Void {
		
		switch (event.keyCode) {
			case Keyboard.SHIFT: rotating = false;
			case Keyboard.CONTROL: skewing = false;
			case Keyboard.ALTERNATE: scaling = false;
		}
		drawme();
	}

	private function onKeyUp(event:KeyboardEvent):Void {
		if (dragged) return;
		
		switch (event.keyCode) {
			case Keyboard.UP: pivot.flipX();
			case Keyboard.DOWN: pivot.flipY();
			case Keyboard.RIGHT: pivot.rotate(-15);
			case Keyboard.LEFT: pivot.rotate(15);
			case Keyboard.SPACE: pivot.identity();
			case Keyboard.NUMBER_1: pivot.setInternalPoint(0,0);
			case Keyboard.NUMBER_2: pivot.setInternalPoint(0,1);
			case Keyboard.NUMBER_3: pivot.setInternalPoint(0,2);
			case Keyboard.NUMBER_4: pivot.setInternalPoint(1,0);
			case Keyboard.NUMBER_5: pivot.setInternalPoint(1,1);
			case Keyboard.NUMBER_6: pivot.setInternalPoint(1,2);
			case Keyboard.NUMBER_7: pivot.setInternalPoint(2,0);
			case Keyboard.NUMBER_8: pivot.setInternalPoint(2,1);
			case Keyboard.NUMBER_9: pivot.setInternalPoint(2,2);
			
		}
	}
	
}
