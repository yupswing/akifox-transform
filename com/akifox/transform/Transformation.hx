package com.akifox.transform;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.display.Sprite;
import openfl.display.DisplayObject;

/**

@author Simone Cingano (yupswing) [Akifox Studio](http://akifox.com)

@version 1.0.1
[Public repository](https://github.com/yupswing/akifox-transform/)

#### Transformation HAXE/OpenFL Library
The akifox-transform library aims to provide an easy tool
to manage affine transformations using a reliable pivot point.

#### Notes:
This page was very helpful to understand matrix affine transformation
http://www.senocular.com/flash/tutorials/transformmatrix/

*/
class Transformation extends EventDispatcher
{
	/** Constant factor to pass from degrees to radians **/
    public static var DEG2RAD:Float = Math.PI/180;
	/** Constant factor to pass from radians to degrees **/
    public static var RAD2DEG:Float = 180/Math.PI;

    // Pivot Point Anchors (used by setAnchoredPivot and getAnchoredPivot)
    public inline static var ANCHOR_TOP_LEFT:Int = 0;
    public inline static var ANCHOR_TOP_CENTER:Int = 1;
    public inline static var ANCHOR_TOP_RIGHT:Int = 2;
    public inline static var ANCHOR_MIDDLE_LEFT:Int = 3;
    public inline static var ANCHOR_MIDDLE_CENTER:Int = 4;
    public inline static var ANCHOR_MIDDLE_RIGHT:Int = 5;
    public inline static var ANCHOR_BOTTOM_LEFT:Int = 6;
    public inline static var ANCHOR_BOTTOM_CENTER:Int = 7;
    public inline static var ANCHOR_BOTTOM_RIGHT:Int = 8;

    // the pivot anchor point (using Pivot Point Anchors)
    // example: Transformation.ANCHOR_BOTTOM_CENTER
    private var pivotPointAnchor:Int = -1;

    // the pivot offset
	private var offsetPoint:Point;

	// the target object
	private var target:DisplayObject;

	// target properties
    private var realX:Float;
    private var realY:Float;
    private var realWidth:Float;
    private var realHeight:Float;

	/** The debug sprite where debugDraw() draws **/
    public var spriteDebug:Sprite;

	/** 
	* Class instance
	* 
	* @param target  The object target of the transformations
	* @param pivot   An absolute point to set the pivot
	**/
	public function new(target:DisplayObject,?pivot:Point=null)
	{

		super();
		// set the target and get the original properties
		this.target = target;
		realWidth = target.width;
		realHeight = target.height;
		realX = target.x;
		realY = target.y;
		spriteDebug = new Sprite();

		if (pivot==null) {
			//set the pivot point TOPLEFT of the target if nothing specified
			setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
		} else {
			//set the pivot point to the specified coords
			setPivot(pivot);
		}
	}

	/**
	* When the size is changed externally of the Transformation class
   	* you should use this method to update the size internally
	* 
   	* **example:** a textfield object with text changed will change size
    * but the Transformation class can't be aware of that if you don't
   	* call this method
   	*
	**/
    public function updateSize() {
    	/*  */

		// get current translation and the complete matrix
    	var translation:Point = getTranslation();
    	var currentMatrix:Matrix = getMatrix();

    	// remove all transformation
    	this.identity();

    	// get the real width and height without transformations
    	realWidth = target.width;
    	realHeight = target.height;

    	// reset the anchored pivot (based on new size)
    	if (this.pivotPointAnchor!=-1) setAnchoredPivot(this.pivotPointAnchor);

    	// restore the transformation
    	this.setMatrixInternal(currentMatrix);

    	// restore the original translation
        // (the new given anchored pivot will count)
    	this.setTranslation(translation);
    }



	// EVENTS
	// #########################################################################

	/** 
	* The transform event
	* It will be called every time the class change the transformation matrix
	* 
	* **example:** 
	* ```
	* myTransformation.addEventListener(Transformation.TRANSFORM, onMyTransform);
	* ```
	**/
    public static inline var TRANSFORM:String = "TRANSFORM";

	/** 
	* The pivot change event
	* It will be called every time the class change the pivot point
	* 
	* **example:**
	* ```
	* myTransformation.addEventListener(Transformation.PIVOT_CHANGE, onMyPivotChange);
	* ```
	**/
    public static inline var PIVOT_CHANGE:String = "PIVOT_CHANGE";
    
	private function onTransform(){
		dispatchEvent(new Event(TRANSFORM));	
	}

	private function onPivotChange(){
		dispatchEvent(new Event(PIVOT_CHANGE));	
	}



	// STATIC UTILS
	// #########################################################################

	/** 
	* Calculate the distance between two points
	* 
	* @param  p0  First point
	* @param  p1  Second point
	* @return     The distance
	**/
    public static inline function distance(p0:Point, p1:Point) : Float
    {
        var x = p0.x-p1.x;
        var y = p0.y-p1.y;
        return Math.sqrt(x*x + y*y);
    }



	// DEBUG
	// #########################################################################

	/** 
	* Clear the spriteDebug:Sprite object
	**/
	public function debugClear() {
		spriteDebug.graphics.clear();
	}
	/** 
	* Draw in the spriteDebug:Sprite object 
	* 
	* Useful to be called with the event TRANSFORM to have a graphic representation
	* of the ongoing transformation
	* 
	* **example:**
	* ```haxe
	*     // new
	*     myspriteTrs = new Transformation(mysprite);
	*     myspriteTrs.addEventListener(Transformation.TRANSFORM, onTransform);
	*     addChild(myspriteTrs.debugDraw);
	*
	* //[...]
	*
	* public function onTransform(event:Event) {
	*     myspriteTrs.debugDraw();
	* }
	* ```
	* 
	* @param  drawPivot      Draws the pivot point flag
	* @param  drawOrigin     Draws the point 0,0 transformed (top left edge of the original rect)
	* @param  drawOriginal   Draws the original rect untransformed
	* @param  drawBoundaries Draws the rect that enclose the transformed object
	* @param  drawRotation   Draws a circle in the pivot point with radius distance(pivotPoint, point 0,0 transformed)
	**/
	public function debugDraw( drawPivot:Bool=true,
							   drawOrigin:Bool=true,
							   drawOriginal:Bool=true,
							   drawBoundaries:Bool=true,
							   drawRotation:Bool=true) {

		debugClear();
		
		var pivot:Point = getPivot();

		//  p0 .___. p1
		//	   |   |
		//  p2 .___. p3

		var p0:Point = new Point(0,0);
		if (drawOrigin || drawBoundaries) {
			p0 = getPosition();
		}


		// pivot point
		if (drawPivot) {
			spriteDebug.graphics.beginFill(0x00FF00,1);
			spriteDebug.graphics.drawCircle(pivot.x,pivot.y,5);
			spriteDebug.graphics.endFill();
		}

		// original target 0,0 transformed
		if (drawOrigin) {
			spriteDebug.graphics.beginFill(0xFFFF00,0.5);
			spriteDebug.graphics.drawCircle(p0.x,p0.y,5);
			spriteDebug.graphics.endFill();
		}

		// original target boundaries (same as original target rect)
		if (drawOriginal) {
			spriteDebug.graphics.lineStyle(2, 0x0000FF, .5, false);
			spriteDebug.graphics.drawRect(realX,realY,realWidth,realHeight);
		}

		// transformed target boundaries
		if (drawBoundaries) {
			var p1:Point;
			p1 = transformPoint(new Point(realWidth,0));
			var p2:Point;
			p2 = transformPoint(new Point(0,realHeight));
			var p3:Point;
			p3 = transformPoint(new Point(realWidth,realHeight));
			var realZeroX = Math.min(Math.min(Math.min(p0.x,p1.x),p2.x),p3.x);
			var realZeroY = Math.min(Math.min(Math.min(p0.y,p1.y),p2.y),p3.y);
			spriteDebug.graphics.lineStyle(2, 0xFF00FF, .5, false);
			spriteDebug.graphics.drawRect(realZeroX,realZeroY,target.width,target.height);
		}

		// rotation circle
		if (drawRotation) {
			spriteDebug.graphics.lineStyle(2, 0x00FF00, .5, false);
			spriteDebug.graphics.drawCircle(pivot.x,pivot.y,distance(pivot,p0));
		}
	}


    // PIVOT MANAGMENT
	// #########################################################################

    // Pivot Point Anchors
    // -------------------
    //
	//     0,0 - 1,0 - 2,0    x=> LEFT=0 CENTER=1 RIGHT=2
	//      |     |     |     y=> TOP=0 MIDDLE=1 BOTTOM=2
	//     0,1 - 1,1 - 2,1
	//      |     |     |
	//     0,2 - 1,2 - 2,2
	//

	/** 
	* Set the pivot in the Pivot Point Anchor specified (see the constants ANCHOR_*)
	* 
	* @param  pivotPointAnchor  A pivot point anchor
	**/
	public function setAnchoredPivot(pivotPointAnchor:Int) {
		//set the Pivot Point Anchor as specified
		this.pivotPointAnchor = pivotPointAnchor;
		//set the pivot offset based on the Pivot Point Anchor specified
		offsetPoint = getAnchoredPivotOffset(pivotPointAnchor);
		this.onPivotChange();
	}

	/**
	* Set the pivot in an arbitrary point
	*
	* @param point A point
	**/
	public function setPivot(point:Point) {
		//unset the Pivot Point Anchor
		this.pivotPointAnchor = -1;
		//set the pivot offset
		offsetPoint = inverseTransformPoint(point);
		this.onPivotChange();
	}

	/**
	* Set the pivot offset (from target 0,0) in an arbitrary point
	* 
	* @param point A point
	**/
	public function setPivotOffset(point:Point) {
		//unset the Pivot Point Anchor
		this.pivotPointAnchor = -1;
		//set the pivot offset
		offsetPoint = point;
		this.onPivotChange();
	}

	/**
	* Get the pivot absolute position
	*
	* @returns   The pivot point absolute position
	**/
	public function getPivot():Point {
		return transformPoint(offsetPoint);
	}

	/**
	* Get the pivot offset position (from target 0,0)
	*
	* @returns   The pivot point offset position
	**/
	public function getPivotOffset():Point {
		return offsetPoint;
	}

	/** 
	* Get the offset (from target 0,0) position of a specified Pivot Point Anchor (see the constants ANCHOR_*)
	* 
	* @return  The point position
	**/
	public function getAnchoredPivotOffset(?pivotPointAnchor:Int=0):Point {
		return getAnchorPivot(pivotPointAnchor,false);
	}

	/** 
	* Get the absolute position of a specified Pivot Point Anchor (see the constants ANCHOR_*)
	* 
	* @return  The point position
	**/
	public function getAnchoredPivot(?pivotPointAnchor:Int=0):Point 
	{
		return getAnchorPivot(pivotPointAnchor,true);
	}

	// internal (used by getAnchoredPivotOffset and getAnchoredPivot)
	private function getAnchorPivot(pivotPointAnchor:Int,absolute:Bool):Point {
		// realWidth / 2 * 0 is LEFT      .______
		// realWidth / 2 * 1 is CENTER    ___.___
		// realWidth / 2 * 2 is RIGHT     ______.
		// and so on for the Y
		if (pivotPointAnchor<0 || pivotPointAnchor>8) pivotPointAnchor = 0;
		var pivotPositionX = pivotPointAnchor % 3;
		var pivotPositionY = Std.int(pivotPointAnchor / 3);

		var x = realWidth/2*pivotPositionX;
		var y = realHeight/2*pivotPositionY;

		// add the current translation to the point
		// to get the absolute position
		if (absolute) {
			var translation = getPosition();
			x+=translation.x; // pos.x is matrix.tx
			y+=translation.y; // pos.y is matrix.ty
		}
		return new Point(x,y);
	}

	// #########################################################################


    private function setMatrixInternal(m:Matrix,?adjust=false):Void
    {
    	// adjust==true is needed to respect the Pivot Point
    	var originalPoint:Point = new Point(0,0);
    	if (adjust) originalPoint = getPivot();  //this before apply the transform
        target.transform.matrix = m; 			 //apply the transformation
        if (adjust) adjustOffset(originalPoint); //this after apply the transform
        this.onTransform();
    }

	/** 
	* Set the transformation matrix, overwriting the existing one
	*
	* (the pivot point will be respected)
	* 
	* @param matrix  The matrix to be applied
	**/
    public function setMatrix(matrix:Matrix):Void { 
    	// change the matrix and adjust to respect the Pivot Point
    	setMatrixInternal(matrix,true);
    }

	/** 
	* Set the transformation matrix, overwriting the existing one,
	* using the specified values
	*
	* (the pivot point will be respected)
	**/
    public function setMatrixTo(a:Float,b:Float,c:Float,d:Float,tx:Float,ty:Float) {
    	// make a matrix with the specified parameters
    	var m:Matrix = new Matrix(a,b,c,d,tx,ty);
    	// update the matrix and adjust to respect the Pivot Point
    	setMatrixInternal(m,true);
    }

	/** 
	* Get a copy of the current transformation matrix
	*
	* (the pivot point will **not** be respected)
	**/
    public function getMatrix():Matrix
    {
        return target.transform.matrix.clone();
    }


	// #########################################################################


	private function adjustOffset(originalPoint:Point) {

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

		//get the pivot NEW absolute position
        var transformedPoint:Point = m.transformPoint(offsetPoint);
        // get the Pivot position offset between before and after the transformation
        var offset:Point = new Point(transformedPoint.x-originalPoint.x,
        							 transformedPoint.y-originalPoint.y);

        // apply the offset with a translation to the target
        // to keep the pivot relative position coherent
	    m.tx-=offset.x;
	    m.ty-=offset.y;

		//apply the matrix to the target
	    setMatrixInternal(m);

	}



    // POINT TRANSFORMATIONS
	// #########################################################################

	/** 
	* Transform a point using the current transformation matrix
	* 
	* @param point The point to be transformed
	* @returns The transformed point
	**/
    public function transformPoint(point:Point):Point {
        // apply the current transformation on a point
        return target.transform.matrix.transformPoint(point);
    }

	/** 
	* Transform a point using the current transformation matrix
	* but ignoring the translation
	* 
	* @param point The point to be transformed
	* @returns The transformed point
	**/
    public function deltaTransformPoint(point:Point):Point {
        // apply the current transformation on a point
        // [ignore the translation]
        return target.transform.matrix.deltaTransformPoint(point);
    }

	/** 
	* Transform a point using the inverted current transformation matrix
	* This means:
	* ```
	* p == inverseTransformPoint(transformPoint(p)); // is true
	* ```
	* 
	* @param point The point to be transformed
	* @returns The transformed point
	**/
    public function inverseTransformPoint(point:Point):Point {
        // remove the current transformation on a point
        // (give a transformed point to get a 'identity' point)
    	var m:Matrix = getMatrix();
    	m.invert();
        return m.transformPoint(point);
    }

	/** 
	* Transform a point using the inverted current transformation matrix
	* but ignoring the translation
	* This means:
	* ```
	* p == inverseDeltaTransformPoint(deltaTransformPoint(p)); // is true
	* ```
	* 
	* @param point The point to be transformed
	* @returns The transformed point
	**/
    public function inverseDeltaTransformPoint(point:Point):Point {
        // remove the current transformation on a point
        // (give a transformed point to get a 'identity' point)
        // [ignore the translation]
    	var m:Matrix = getMatrix();
    	m.invert();
        return m.deltaTransformPoint(point);
    }



    // IDENTITY
	// #########################################################################

	/** 
	* Reset the matrix (no transformations)
	*
	* (the pivot point will be respected)
	**/
    public function identity(){
		 // reset the matrix
         var m = new Matrix();
         m.tx = realX - offsetPoint.x;
         m.ty = realY - offsetPoint.y;
         setMatrixInternal(m);
    }



    // TRANSLATE TRANSFORMATION
	// #########################################################################

	/** 
	* Delta translation
	* @param dx translation on the X axis
	* @param dy translation on the Y axis
	**/
	public function translate(dx:Float=0, dy:Float=0):Void
	{
	    var m:Matrix = getMatrix();
	    m.tx += dx;
	    m.ty += dy;
	    setMatrixInternal(m);
	}

	/** 
	* Delta translation on X axis
	* @param dx translation on the X axis
	**/
	public function translateX(dx:Float=0):Void { translate(dx,0); } 

	/** 
	* Delta translation on Y axis
	* @param dy translation on the Y axis
	**/
	public function translateY(dy:Float=0):Void { translate(0,dy); }    

	/** 
	* Absolute translation
	* @param translation The specified point
	**/
	public function setTranslation(translation:Point):Void
	{
	    var m:Matrix = getMatrix();
	    var transformedOffset:Point = deltaTransformPoint(offsetPoint);
	    m.tx = translation.x-transformedOffset.x;
	    m.ty = translation.y-transformedOffset.y;
	    setMatrixInternal(m);
	}
	/** 
	* Absolute translation on the X axis
	* @param tx The X coordinate
	**/
	public function setTranslationX(tx:Float=0):Float {
	    var m:Matrix = getMatrix();
	    m.tx = tx-deltaTransformPoint(offsetPoint).x;
	    setMatrixInternal(m);
	    return tx;
	} 
	/** 
	* Absolute translation on the Y axis
	* @param ty The Y coordinate
	**/
	public function setTranslationY(ty:Float=0):Float {
	    var m:Matrix = getMatrix();
	    m.ty = ty-deltaTransformPoint(offsetPoint).y;
	    setMatrixInternal(m);
	    return ty;
	}   

	/** 
	* Get the current translation
	* @returns The current absolute translation point (relative to 0,0)
	**/
	public function getTranslation():Point
	{
		var transformedOffset:Point = deltaTransformPoint(offsetPoint);
	    return new Point(target.transform.matrix.tx+transformedOffset.x,target.transform.matrix.ty+transformedOffset.y);
	}

	/** 
	* Get the current translation on the X axis
	* @returns The current absolute translation X coordinate
	**/
	public function getTranslationX():Float
	{
		return getTranslation().x;
	}

	/** 
	* Get the current translation on the Y axis
	* @returns The current absolute translation Y coordinate
	**/
	public function getTranslationY():Float
	{
		return getTranslation().y;
	}

	/** 
	* Get the current matrix translation (matrix.tx,matrix.ty)
	* (this method ignore the pivot point)
	* @returns The current matrix translation Point(matrix.tx,matrix.ty)
	**/
	public function getPosition():Point
	{
	    return new Point(target.transform.matrix.tx,target.transform.matrix.ty);
	}

	/** 
	* Get the current matrix translation on the X axis (matrix.tx)
	* (this method ignore the pivot point)
	* @returns The current matrix translation matrix.tx
	**/
	public function getPositionX():Float
	{
		return target.transform.matrix.tx;
	}

	/** 
	* Get the current matrix translation on the Y axis (matrix.ty)
	* (this method ignore the pivot point)
	* @returns The current matrix translation matrix.ty
	**/
	public function getPositionY():Float
	{
		return target.transform.matrix.ty;
	}


	/** Use getTranslationX and setTranslationX **/
	public var translationX(get, set):Float;
	private function get_translationX():Float { return getTranslationX(); }
	private function set_translationX(value:Float):Float { return setTranslationX(value); }

	/** Use getTranslationY and setTranslationY **/
	public var translationY(get, set):Float;
	private function get_translationY():Float { return getTranslationY(); }
	private function set_translationY(value:Float):Float { return setTranslationY(value); }



    // SKEW TRANSFORMATION
	// #########################################################################


	/** 
	* Set the skew to a given value in Radians
	*
	* **NOTE:** It applies an absolute skew on the current matrix
	*
	* **NOTE:** -0.1 is a null value for cross-platform compatibility (doesn't apply the transformation)
	* 
	* @param skewXRad Value for the X axis
	* @param skewXRad Value for the Y axis
	**/
	public function setSkewRad(skewXRad:Float, skewYRad:Float):Void
	{

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

		// apply the skew (matrix.c is HORIZONTAL, matrix.b is VERTICAL)
	    if (skewXRad!=-0.1) {
	    	m.c = Math.tan(skewXRad)*getScaleX();
	    }
	    if (skewYRad!=-0.1) {
	    	m.b = Math.tan(skewYRad)*getScaleY();
	    }

		//apply the matrix to the target
	    setMatrixInternal(m,true);
	}

	/** 
	* Set the skew to a given value in Degrees
	*
	* **NOTE:** It applies an absolute skew on the current matrix
	*
	* **NOTE:** -0.1 is a null value for cross-platform compatibility (doesn't apply the transformation)
	* 
	* @param skewXDeg Value for the X axis
	* @param skewYDeg Value for the Y axis
	**/
	public function setSkew(skewXDeg:Float, skewYDeg:Float):Void
	{
		// check null to avoid error on multiplication
		var skewXRad:Float=-0.1;
		var skewYRad:Float=-0.1;
		if (skewXDeg!=-0.1) skewXRad = skewXDeg*DEG2RAD;
		if (skewYDeg!=-0.1) skewYRad = skewYDeg*DEG2RAD;
		setSkewRad(skewXRad,skewYRad);
	}

	/** 
	* Set the skew on the X axis to a given value in Degrees
	*
	* **NOTE:** It applies an absolute skew on the current matrix
	* 
	* @param skewXDeg Value for the X axis
	**/
	public function setSkewX(skewXDeg:Float=-0.1):Float { setSkew(skewXDeg,-0.1); return skewXDeg; }

	/** 
	* Set the skew on the Y axis to a given value in Degrees
	*
	* **NOTE:** It applies an absolute skew on the current matrix
	* 
	* @param skewYDeg Value for the Y axis
	**/
	public function setSkewY(skewYDeg:Float):Float { setSkew(-0.1,skewYDeg); return skewYDeg; }

	/** 
	* Set the skew on the X axis to a given value in Radians
	*
	* **NOTE:** It applies an absolute skew on the current matrix
	* 
	* @param skewXRad Value for the X axis
	**/
	public function setSkewXRad(skewXRad:Float):Float { setSkewRad(skewXRad,-0.1); return skewXRad; }

	/** 
	* Set the skew on the Y axis to a given value in Radians
	*
	* **NOTE:** It applies an absolute skew on the current matrix
	* 
	* @param skewYRad Value for the X axis
	**/
	public function setSkewYRad(skewYRad:Float):Float { setSkewRad(-0.1,skewYRad); return skewYRad; }
	
	/** 
	* Apply a skew in Radians
	*
	* **NOTE:** -0.1 for skewYRad is a null value for cross-platform compatibility (apply the same value on X and Y)
	* **NOTE:** 0.0 means no transformation on that axis
	* 
	* @param skewRad Value for the X axis (and Y axis if the skewY is not specified)
	* @param skewYRad (optional) Value for the Y axis
	**/
	public function skewRad(skewRad:Float, ?skewYRad:Float=-0.1):Void
	{
        //get the target matrix to apply the transformation
	    var m:Matrix = new Matrix();

		var skewXRad:Float = skewRad;
		// if not specified it will set the x and y skew using the same value
		if (skewYRad==-0.1) skewYRad = skewRad;

		// apply the skew (matrix.c is HORIZONTAL, matrix.b is VERTICAL)
	    if (skewXRad!=0.0) {
	    	m.c = Math.tan(skewXRad);
	    }
	    if (skewYRad!=0.0) {
	    	m.b = Math.tan(skewYRad);
	    }
	    
		//apply the matrix to the target
	    m.concat(getMatrix());
	    setMatrixInternal(m,true);
	}

	/** 
	* Apply a skew in Degrees
	*
	* **NOTE:** -0.1 for skewYDeg is a null value for cross-platform compatibility (apply the same value on X and Y)
	* **NOTE:** 0.0 means no transformation on that axis
	* 
	* @param skewDeg Value for the X axis (and Y axis if the skewY is not specified)
	* @param skewYDeg (optional) Value for the Y axis
	**/
	public function skew(skewDeg:Float,?skewYDeg:Float=-0.1):Void {
		var skewXDeg:Float = skewDeg;
		// if not specified it will set the x and y skew using the same value
		if (skewYDeg==-0.1) skewYDeg = skewDeg;
		skewRad(skewXDeg*DEG2RAD,skewYDeg*DEG2RAD);
	}

	/** 
	* Apply a skew on the X axis in Degrees
	* 
	* @param skewXDeg Value for the skew
	**/
	public function skewX(skewXDeg:Float):Void { skew(skewXDeg,0.0); }

	/** 
	* Apply a skew on the X axis in Degrees
	* 
	* @param skewYDeg Value for the skew
	**/
	public function skewY(skewYDeg:Float):Void { skew(0.0,skewYDeg); }
	
	/** 
	* Apply a skew on the X axis in Radians
	* 
	* @param skewXRad Value for the skew
	**/
	public function skewXRad(skewXRad:Float):Void { skewRad(skewXRad,0.0); }
	
	/** 
	* Apply a skew on the Y axis in Radians
	* 
	* @param skewYRad Value for the skew
	**/
	public function skewYRad(skewYRad:Float):Void { skewRad(0.0,skewYRad); }

	/** 
	* **NOTE:** Could not be reliable if the scale is not uniform
	* 
	* @returns the current skew on the X Axis in Radians
	**/
    public function getSkewXRad():Float
    {
    	var px = new Point(0, 1);
		px = deltaTransformPoint(px);
		return -(Math.atan2(px.y, px.x) - Math.PI/2);
    }

   	/** 
	* **NOTE:** Could not be reliable if the scale is not uniform
	* 
	* @returns the current skew on the Y Axis in Radians
	**/
	public function getSkewYRad():Float
	{
		var py = new Point(1, 0);
		py = deltaTransformPoint(py);
		return Math.atan2(py.y, py.x);
	} 

   	/** 
	* **NOTE:** Could not be reliable if the scale is not uniform
	* 
	* @returns the current skew on the X Axis in Degrees
	**/
    public function getSkewX():Float { return getSkewXRad()*RAD2DEG; }

   	/** 
	* **NOTE:** Could not be reliable if the scale is not uniform
	* 
	* @returns the current skew on the Y Axis in Degrees
	**/
	public function getSkewY():Float { return getSkewYRad()*RAD2DEG; }

	/** Use getSkewX and setSkewX **/
	public var skewingX(get, set):Float;
	private function get_skewingX():Float { return getSkewX(); }
	private function set_skewingX(value:Float):Float { return setSkewX(value); }

	/** Use getSkewY and setSkewY **/
	public var skewingY(get, set):Float;
	private function get_skewingY():Float { return getSkewY(); }
	private function set_skewingY(value:Float):Float { return setSkewY(value); }

	/** Use getSkewXRad and setSkewXRad **/
	public var skewingXRad(get, set):Float;
	private function get_skewingXRad():Float { return getSkewXRad(); }
	private function set_skewingXRad(value:Float):Float { return setSkewXRad(value); }

	/** Use getSkewYRad and setSkewYRad **/
	public var skewingYRad(get, set):Float;
	private function get_skewingYRad():Float { return getSkewYRad(); }
	private function set_skewingYRad(value:Float):Float { return setSkewYRad(value); }


	// SCALE TRANSFORMATION
	// #########################################################################

	/** 
	* Apply a scale
	*
	* **NOTE:** yfactor=-0.1 is a null value for cross-platform compatibility (apply the same factor on x and y)
	* 
	* @param factor Factor for the X axis (and Y axis if the yFactor is not specified)
	* @param yFactor (optional) Factor for the Y axis
	**/
	public function scale(factor:Float=1.0, ?yFactor:Float=-0.1):Void
	{

		var xFactor:Float = factor;
		// if not specified it will scale x and y using the same factor
		if (yFactor==-0.1) yFactor = factor;

		//get the pivot absolute position
	    // (keep this BEFORE applying the new matrix to the target)

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

		// apply the scaling
		m.a *= xFactor;
		m.b *= yFactor;
		m.c *= xFactor;
		m.d *= yFactor;
		m.tx *= xFactor;
		m.ty *= yFactor;

		//apply the matrix to the target
	    setMatrixInternal(m,true);

	}

	/** 
	* Apply a scale on the X axis
	* 
	* @param factor Factor for the X axis
	**/
	public function scaleX(factor:Float=1):Void { scale(factor,1.0); }

	/** 
	* Apply a scale on the Y axis
	* 
	* @param factor Factor for the Y axis
	**/
	public function scaleY(factor:Float=1):Void { scale(1.0,factor); }

	/** 
	* Set the scale on a given value
	*
	* **NOTE:** scaleY=-0.1 is a null value for cross-platform compatibility (use the same value for x and y)
	* 
	* @param value Value for the X axis (and Y axis if the scaleY is not specified)
	* @param scaleY (optional) Value for the Y axis
	**/
	public function setScale(value:Float=1.0, ?scaleY:Float=-0.1):Void
	{

		var scaleX:Float = value;
		// if not specified it will set the x and y scale using the same value
		if (scaleY==-0.1) scaleY = value;

        //apply the transformation
		setScaleX(scaleX);
		setScaleY(scaleY);

	}

	/** 
	* Set the scale for the X axis on a given value
	*
	* @param value Value for the X axis
	**/
	public function setScaleX(scaleX:Float):Float
	{
        var m:Matrix = getMatrix();
		var oldValue:Float = getScaleX();
		// avoid division by zero 
		if (oldValue!=0)
		{
			var ratio:Float = scaleX / oldValue;
			m.a *= ratio;
			m.b *= ratio;
		}
		else
		{
			var skewYRad:Float = getSkewYRad();
			m.a = Math.cos(skewYRad) * scaleX;
			m.b = Math.sin(skewYRad) * scaleX;
		}
		setMatrixInternal(m,true);
		return scaleX;
	}

	/** 
	* Set the scale for the Y axis on a given value
	*
	* @param value Value for the Y axis
	**/
	public function setScaleY(scaleY:Float):Float
	{
        var m:Matrix = getMatrix();
		var oldValue:Float = getScaleY();
		// avoid division by zero 
		if (oldValue!=0)
		{
			var ratio:Float = scaleY / oldValue;
			m.c *= ratio;
			m.d *= ratio;
		}
		else
		{
			var skewXRad:Float = getSkewXRad();
			m.c = -Math.sin(skewXRad) * scaleY;
			m.d =  Math.cos(skewXRad) * scaleY;
		}
		setMatrixInternal(m,true);
		return scaleY;
	}

	/** 
	* @returns The current scale factor on the X axis
	**/
	public function getScaleX():Float
	{
        var m:Matrix = target.transform.matrix;
		return Math.sqrt(m.a*m.a + m.b*m.b);
	}
	/** 
	* @returns The current scale factor on the Y axis
	**/
	public function getScaleY():Float
	{
        var m:Matrix = target.transform.matrix;
		return Math.sqrt(m.c*m.c + m.d*m.d);
	}

	/** Use getScaleX and setScaleX **/
	public var scalingX(get, set):Float;
	private function get_scalingX():Float { return getScaleX(); }
	private function set_scalingX(factor:Float):Float { return setScaleX(factor); }

	// /** Use getScaleY and setScaleY **/
	public var scalingY(get, set):Float;
	private function get_scalingY():Float { return getScaleY(); }
	private function set_scalingY(factor:Float):Float { return setScaleY(factor); }



    // FLIP
	// #########################################################################

	/** 
	* Apply a flip (mirroring) on the X axis
	**/
	public function flipX():Void { scaleX(-1); }

	/** 
	* Apply a flip (mirroring) on the Y axis
	**/
	public function flipY():Void { scaleY(-1); }


    // ROTATE TRANSFORMATION
	// #########################################################################

	/** 
	* Apply a rotation
	*
	* @param angle The angle in Radians 
	**/
	public function rotateRad(angle:Float=0):Void 
	{
		//get the pivot absolute position
        var absolutePoint:Point = getPivot();

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

	    //move the target(matrix)
	    //the pivot point will match the origin (0,0)
		m.tx-=absolutePoint.x;
		m.ty-=absolutePoint.y;

		//rotate the target(matrix)
		// SAME AS m.rotate(angle);
		var sin = Math.sin(angle);
		var cos = Math.cos(angle);
		var a = m.a;
		var b = m.b;
		var c = m.c;
		var d = m.d;
		var tx = m.tx;
		var ty = m.ty;
		m.a = a*cos - b*sin;
		m.b = a*sin + b*cos;
		m.c = c*cos - d*sin;
		m.d = c*sin + d*cos;
		m.tx = tx*cos - ty*sin;
		m.ty = tx*sin + ty*cos;

		// restore the target(matrix) position
		m.tx+=absolutePoint.x;
		m.ty+=absolutePoint.y;

		//apply the matrix to the target
		setMatrixInternal(m);
	}

	/** 
	* Apply a rotation
	*
	* @param angle The angle in Degrees 
	**/
	public function rotate(angle:Float):Void { rotateRad(angle*DEG2RAD); }

	/** 
	* Set the rotation on a given value
	*
	* @param angle The absolute angle in Radians
	**/
	public function setRotationRad(angle:Float):Float 
	{
		//get the current angle
		var currentRotation:Float = getRotationRad();
		
		//find the complementary angle to reset the rotation to 0
		var resetAngle:Float = -currentRotation;
			
		//reset the rotation
		rotateRad(resetAngle);
		
		//set the new rotation value
		rotateRad(angle);

		return angle;
	}

	/** 
	* Set the rotation on a given value
	*
	* @param angle The absolute angle in Degrees
	**/
	public function setRotation(angle:Float):Float { return setRotationRad(angle*DEG2RAD); }

	/** 
	* @returns The current angle of rotation in Radians
	**/
	public function getRotationRad():Float 
	{

		// apply the transformation matrix to a point and
		// calculate the rotation happened
		// thanks to http://stackoverflow.com/users/1035293/bugshake

		var translate:Point;
		var scale:Float;

		var m:Matrix = getMatrix();

		// extract translation
		var p:Point = new Point(0,0);
		translate = m.transformPoint(p);
		m.translate( -translate.x, -translate.y);

		// extract (uniform) scale...
		p.x = 1.0;
		p.y = 0.0;
		p = m.transformPoint(p);
		scale = p.length;

		// ...and rotation
		return Math.atan2(p.y, p.x);
	}

	/** 
	* @returns The current angle of rotation in Degrees
	**/
	public function getRotation():Float { return getRotationRad() * RAD2DEG; }

	/** Use getRotation and setRotation **/
	public var rotation(get, set):Float;
	private function get_rotation():Float { return getRotation(); }
	private function set_rotation(angle:Float):Float { return setRotation(angle); }

	/** Use getRotationRad and setRotationRad **/
	public var rotationRad(get, set):Float;
	private function get_rotationRad():Float { return getRotationRad(); }
	private function set_rotationRad(angle:Float):Float { return setRotationRad(angle); }

	// #########################################################################
	// #########################################################################



}


