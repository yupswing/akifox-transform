# openfl-transform-examples

**THIS REPO IS A WORK IN PROGRESS**

This samples (just one for now) shows the capabilities of the Transformation class included in the **akifox library** (which is my personal haxe develop library)

## Goal

This class (and this example shows how to implement it) aims to provide an easy tool to manage affine transformations using a reliable pivot point.

## Install and try

<code>git clone --recursive https://github.com/yupswing/openfl-transformation-samples.git</code><br/>
<code>cd openfl-transformation-samples</code><br/>
<code>lime test neko</code><br/>

You should get a window with a red square.
- Space to reset the transformations
- Drag to move
- Click to change pivot point
- Drag+<code>Shift</code> to rotate around the pivot point
- <code>1</code> to <code>9</code> to set the pivot point on the relative anchor point (TOPLEFT, MIDDLELEFT,BOTTOMLEFT,TOPCENTER... BOTTOMRIGHT)

<img src="https://dl.dropboxusercontent.com/u/683344/akifox/git/openfl-transform-sample.png"/>

## Using the Class
**I DON'T RECOMMEND USING IT RIGHT NOW BECAUSE IT'S A WORK IN PROGRESS AND IT WILL CHANGE MAYBE RADICALLY IN THE PROCESS OF BECOMING STABLE**

Once you got a DisplayObject (Sprites, Bitmap...) you can create a Transformation object linked to it.
(Don't use more than one transformation at a given time. I will code this check later on)

<pre>
trf = new Transformation(YOUROBJECT);
trf.setInternalPoint([1,1]); // imagine a square with 9 anchor points
                               // 0,0 is top left / 1,1 is center / 2,2 is bottom right
                               
// these are the Pivot Point coordinates (they will not change unless
// you change the pivot point position)
var pivotCoordinates:Point = trf.getAbsolutePoint();

trf.rotate(20); //rotate 20degress clockwise

</pre>

## Working on
- Skew (not reliable right now)
- Flip
- Scale
- Cleaning and documenting code
- Better README.md when it will become stable.
