package;

import openfl.Lib;
import openfl.Assets;

import openfl.geom.Point;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;

import openfl.ui.Mouse;
import openfl.ui.Keyboard;

import com.akifox.transform.Transformation;

class Main extends Sprite {

	var lastPoint:Point;
	var debugdraw = true;
	var myspriteTrs:Transformation;

    // SETUP
	// #########################################################################

	public function new () {

		super();

		Mouse.hide();

		var ox = 200;
		var oy = 200;
		var ow = 100;
		var oh = 100;

		ox = Std.int(Lib.current.stage.stageWidth/2-ow/2);
		oy = Std.int(Lib.current.stage.stageHeight/2-oh/2);

		// example with sprite
		/* var mysprite:Sprite = new Sprite();
		mysprite.graphics.beginFill(0xFF0000,1);
		mysprite.graphics.drawRect(0,0,ow,oh);
		mysprite.graphics.endFill();*/

		// example with bitmap
		var bitmapData = Assets.getBitmapData ("graphics/test.png");
		var mysprite:Bitmap = new Bitmap(bitmapData);
		mysprite.smoothing = true;

		// set properties
		mysprite.x = ox;
		mysprite.y = oy;
		mysprite.alpha = 0.8;

		// create a transformation object bound to the sprite
		// the matrix identity set the transformation identity with a default translation to the center
		var matrixIdentity = new openfl.geom.Matrix(1,0,0,1,ox,oy);
		myspriteTrs = new Transformation(matrixIdentity);
		myspriteTrs.bind(mysprite);
		myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		lastPoint = myspriteTrs.getPivot();


		// event listeners
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, updatePointer);

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);

		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onSpecialKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onSpecialKeyUp);

		myspriteTrs.addEventListener(Transformation.TRANSFORM, onTransform);
		myspriteTrs.addEventListener(Transformation.PIVOT_CHANGE, onPivotChange);


		addChild(mysprite);
		addChild(myspriteTrs.spriteDebug);

		// first draw
		drawInterface();
		myspriteTrs.debugDraw();

	}


    // EVENTS FROM THE TRANSFORMATION CLASS
	// #########################################################################
	
	public function onTransform(event:Event) {
		if (debugdraw) myspriteTrs.debugDraw();
	}
	public function onPivotChange(event:Event) {
		if (debugdraw) myspriteTrs.debugDraw();
	}



	// #########################################################################
	// #########################################################################
    // INTERACTIVE
	// #########################################################################

	// general input vars
	var mousedownPoint:Point; //point on click
	var centerPoint:Point; //pivot point
	var dragged:Bool=false;

	// action flags
	var skewingMode = false;
	var scalingMode = false;
	var rotatingMode = false;
	var movingMode = false;

	// rotation vars
	var rotationAngle:Float=0;
	var lastRotationAngle:Float=0;

	// scale vars
	var distanceCenterMousedown:Float;
	var currentScale:Float;

	// isometrize vars
    var axisX:Point;
	var axisY:Point;


	private function stage_onMouseDown (event:MouseEvent):Void {
		dragged = false;
		centerPoint = myspriteTrs.getPivot();
		mousedownPoint = new Point(Std.int(event.stageX),Std.int(event.stageY));

		// scale setup
		currentScale = myspriteTrs.getScaleX(); // scale x and y will be the same
		distanceCenterMousedown = Transformation.distance(mousedownPoint,centerPoint);

		// rotation setup
		changeRotation(false);

		// isometrize setup
    	axisX = new Point(1, 0);        //vector for x - axis
    	axisY = new Point(0, 1);        //vector for y - axis

    	// simulate a first movement to execute possible actions (modifiers key)
		stage_onMouseMove(event);

		// event listeners for dragging
		stage.addEventListener (MouseEvent.MOUSE_MOVE, stage_onMouseMove);
		stage.addEventListener (MouseEvent.MOUSE_UP, stage_onMouseUp);

	}


	private function stage_onMouseMove (event:MouseEvent):Void {
		if (!dragged && (event.shiftKey || event.altKey || event.ctrlKey)) dragged = true;
		if (!dragged && Transformation.distance(mousedownPoint,new Point(Std.int(event.stageX),Std.int(event.stageY))) > 5) dragged = true;
		if (dragged) {
			if (event.shiftKey || event.altKey || event.ctrlKey) {
				if (event.shiftKey) changeRotation();
				if (event.altKey) changeScale(event);
				if (event.ctrlKey) changeSkew(event);
			} else {
				// * isometrize test
				//changeIsometrize(event);
				#if ios
				// * iphone test
				rotatingMode = true;
				scalingMode = true;
				changeRotation();
				changeScale(event);
				#else
				// * normal test
				movingMode = true;
				changePosition(event);
				#end
			}
		}
	}

	private function stage_onMouseUp (event:MouseEvent):Void {
		if (!dragged) {
			// normal click
			changePivot(event);
		}
		dragged = false;

		skewingMode = event.ctrlKey;
		scalingMode = event.altKey;
		rotatingMode = event.shiftKey;
		movingMode = false;

		stage.removeEventListener (MouseEvent.MOUSE_MOVE, stage_onMouseMove);
		stage.removeEventListener (MouseEvent.MOUSE_UP, stage_onMouseUp);
		drawInterface();

	}

	private function updatePointer (event:MouseEvent):Void {
		lastPoint = new Point(Std.int(event.stageX),Std.int(event.stageY));
		drawInterface();
	}


    // CHANGE FUNCTIONS (sprite transformations)
	// #########################################################################

	private function changePivot (event:MouseEvent):Void {
		myspriteTrs.setPivot(new Point(Std.int(event.stageX),Std.int(event.stageY)));
	}

	private function changePosition(event:MouseEvent) {
		myspriteTrs.setTranslation(new Point(Std.int(event.stageX),Std.int(event.stageY)));
	}

	private function changeRotation(?rotate:Bool=true) {
		var pt:Point = myspriteTrs.getPivot();
		var aa:Point = new Point(lastPoint.x,lastPoint.y);
		aa.x-=pt.x;
		aa.y-=pt.y;
		rotationAngle = Math.atan2(aa.x, aa.y);
		if (rotate) myspriteTrs.rotate(-(rotationAngle-lastRotationAngle)/Transformation.DEG2RAD);
		lastRotationAngle=rotationAngle;
		//trace('get',myspriteTrs.getRotation());
	}

	private function changeScale(event:MouseEvent) {
		var dNowCenter = Transformation.distance(centerPoint,new Point(Std.int(event.stageX),Std.int(event.stageY)));
		myspriteTrs.setScale(dNowCenter/distanceCenterMousedown*currentScale);
		//trace('set/get',dNowCenter/distanceCenterMousedown*currentScale,myspriteTrs.getScaleX());
	}

	private function changeSkew(event:MouseEvent) {
		var xs = (Std.int(event.stageX)-Lib.current.stage.stageWidth/2)/(Lib.current.stage.stageWidth/2);
		var ys = (Std.int(event.stageY)-Lib.current.stage.stageHeight/2)/(Lib.current.stage.stageHeight/2);
		myspriteTrs.setSkew(xs*50,ys*50);
	}

	private function changeIsometrize(event:MouseEvent) {
		// source: http://code.tutsplus.com/tutorials/understanding-affine-transformations-with-matrix-mathematics--active-10884
		var x:Float=event.stageX;
		var y:Float=event.stageY;
		var f1:Point = myspriteTrs.getPivot();
		//f1.x>0 //front side
		axisX.setTo(x - f1.x, y - f1.y);  //determine orientation (but magnitude changed as well)
    	axisX.normalize(1);         	  //fix magnitude of vector with new orientation to 1 unit
    	myspriteTrs.setMatrixTo(axisX.x, axisX.y, axisY.x, axisY.y, 200, 200);
	}


    // INTERFACE
	// #########################################################################

	private function drawInterface(){
		var pt:Point = myspriteTrs.getPivot();

		graphics.clear();

		//rotation point
		graphics.beginFill(((dragged)?0xFF0000:0x0000FF),1);
		graphics.drawCircle(lastPoint.x,lastPoint.y,5);
		graphics.endFill();

		if (rotatingMode || scalingMode) {
			graphics.lineStyle(2, 0x00FF00, .5, false);
			graphics.moveTo(pt.x,pt.y);
			graphics.lineTo(lastPoint.x,lastPoint.y);
		}

		if (skewingMode) {
			graphics.lineStyle(2, 0x0000FF, .5, false);
			graphics.moveTo(Std.int(Lib.current.stage.stageWidth/2),0);
			graphics.lineTo(Std.int(Lib.current.stage.stageWidth/2),Std.int(Lib.current.stage.stageHeight));
			graphics.moveTo(0,Std.int(Lib.current.stage.stageHeight/2));
			graphics.lineTo(Std.int(Lib.current.stage.stageWidth),Std.int(Lib.current.stage.stageHeight/2));
		}

	}


    // INPUT
	// #########################################################################

	private function onSpecialKeyDown(event:KeyboardEvent):Void {
		
		switch (event.keyCode) {
			case Keyboard.SHIFT: rotatingMode = true;
			case Keyboard.CONTROL: skewingMode = true;
			case Keyboard.ALTERNATE: scalingMode = true;
		}
		drawInterface();
	}

	private function onSpecialKeyUp(event:KeyboardEvent):Void {
		
		switch (event.keyCode) {
			case Keyboard.SHIFT: rotatingMode = false;
			case Keyboard.CONTROL: skewingMode = false;
			case Keyboard.ALTERNATE: scalingMode = false;
		}
		drawInterface();
	}

	private function onKeyUp(event:KeyboardEvent):Void {
		if (dragged) return;
		
		switch (event.keyCode) {
			// Z for debugging
			case Keyboard.Z: debugToggle();
			// space to reset
			case Keyboard.SPACE: myspriteTrs.identity();
			// arrows to move
			case Keyboard.UP: myspriteTrs.translateY(-15);
			case Keyboard.DOWN: myspriteTrs.translateY(15);
			case Keyboard.LEFT: myspriteTrs.translateX(-15);
			case Keyboard.RIGHT: myspriteTrs.translateX(15);
			// Q A W S to skew
			case Keyboard.Q: myspriteTrs.skewX(15); 
			case Keyboard.A: myspriteTrs.skewX(-15);
			case Keyboard.W: myspriteTrs.skewY(15);
			case Keyboard.S: myspriteTrs.skewY(-15);
			// E D to skew
			case Keyboard.E: myspriteTrs.scale(1.5);
			case Keyboard.D: myspriteTrs.scale(1/1.5);
			// R F to rotate
			case Keyboard.R: myspriteTrs.rotate(-15);
			case Keyboard.F: myspriteTrs.rotate(15);
			// T G to translate with actuate
			case Keyboard.T: Actuate.tween (myspriteTrs, 1, { translationX: 100, translationY:100 } );
			case Keyboard.G: Actuate.tween (myspriteTrs, 1, { translationX: 200, translationY:200 } );
			// pivot anchored point
			case Keyboard.NUMBER_1: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
			case Keyboard.NUMBER_2: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_TOP_CENTER);
			case Keyboard.NUMBER_3: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_TOP_RIGHT);
			case Keyboard.NUMBER_4: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_LEFT);
			case Keyboard.NUMBER_5: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
			case Keyboard.NUMBER_6: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_RIGHT);
			case Keyboard.NUMBER_7: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_LEFT);
			case Keyboard.NUMBER_8: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_CENTER);
			case Keyboard.NUMBER_9: myspriteTrs.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_RIGHT);
		}
	}

	private function debugToggle(){
		if (debugdraw) myspriteTrs.debugClear();
		else myspriteTrs.debugDraw();
		debugdraw = !debugdraw;
	}
	
}
