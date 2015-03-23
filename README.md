[![akifox-transform](https://img.shields.io/badge/library-akifox%20transform%202.2.0-brightgreen.svg)]()
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Haxe 3](https://img.shields.io/badge/language-Haxe%203-orange.svg)](http://www.haxe.org)
[![OpenFL 2](https://img.shields.io/badge/require-OpenFL 2-red.svg)](http://www.openfl.org)
[![Cross platform](https://img.shields.io/badge/platform-cross%20platform-lightgrey.svg)](http://www.openfl.org)

[![Library](https://img.shields.io/badge/type-haxelib%20library-orange.svg)](http://lib.haxe.org/p/akifox-transform)
[![Haxelib](https://img.shields.io/badge/distr-v2.2.0-yellow.svg)](http://lib.haxe.org/p/akifox-transform)

# akifox-transform (com.akifox.transform.Transformation)
**HAXE/OpenFL Affine transformation class**

The akifox-transform class aims to provide an easy tool to manage affine transformations using a reliable pivot point.
What are the affine transformation you might ask...
- read <a href="http://en.wikipedia.org/wiki/Affine_transformation">this wikipedia page</a>
- read <a href="http://www.senocular.com/flash/tutorials/transformmatrix/">this great flash tutorial</a>

## Example demo

![Screenshot](https://dl.dropboxusercontent.com/u/683344/akifox/akifox-transform/transformation-example.png)

**Flash build:** <a href="https://dl.dropboxusercontent.com/u/683344/akifox/akifox-transform/transformation-example.swf" target="_blank">transformation-example.swf</a>

You should get a window with a OpenFL logo square.
- <code>Z</code> to toggle debug drawings
- <code>SPACE</code> to reset the transformations
- Drag to move
- Click to change the Pivot Point
- Drag+<code>SHIFT</code> to rotate around the pivot point
- Drag+<code>ALT</code> to scale related to the pivot point
- Drag+<code>CMD</code>/<code>CTRL</code> to skew related to the pivot point (the cross center represents a 0,0 skew)
- <code>1</code> to <code>9</code> to set the pivot point on the relative anchor point (TOPLEFT, MIDDLELEFT,BOTTOMLEFT,TOPCENTER... BOTTOMRIGHT)
- <code>UP</code>, <code>DOWN</code>, <code>RIGHT</code>, <code>LEFT</code> Move 15px
- <code>Q</code>, <code>A</code> to Skew X ±15deg
- <code>W</code>, <code>S</code> to Skew Y ±15deg
- <code>E</code>, <code>D</code> to Scale */1.5
- <code>R</code>, <code>F</code> to Rotate ±15deg


## Install

You can easily install the library thru haxelib

```
haxelib install akifox-transform
```

In your project add the library reference in your ```project.xml```

```
<haxelib name="akifox-transform" />
```

and finally you can import it in your project class with this import
```
import com.akifox.transform.Transformation;
```

## Documentation

You can read the full Library documentation <a href="https://dl.dropboxusercontent.com/u/683344/akifox/akifox-transform/docs/index.html" target="_blank">here</a>



## Using the library

The Transformation class works on Matrix objects.
Anyway usually once you've got a DisplayObject (Sprites, Bitmap...) you want to link this to a Transformation.


````haxe
import com.akifox.transform.Transformation

// [...]
    trf = new Transformation();
    trf.bind(yourDisplayObject);
    trf.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
    
    // these are the Pivot Point coordinates (they will not change unless
    // you change the pivot point position)
    var pivotCoordinates:Point = trf.getPivot();

    trf.rotate(20); //rotate by 20deg clockwise
    trf.skewX(30); //skew X axis by 30deg
    Actuate.tween(trf,1,{'scalingX':2,'scalingY'"2}); //scale 2X in 1s using Actuate
````

## Best practice

The idea behind the library wants the developer to use the transformation to change the object affine transformation properties.

So you can work on the large amount of transformation properties and methods as:

These assignments modify the target/matrix property according to the pivot point
(all of the degree ones are provided in Rad as well)
````
trf.x = valuePixels;
trf.y = valuePixels;
trf.rotation = valueDegrees;
trf.skewingX = valueDegrees;
trf.skewingY = valueDegrees;
trf.scaling = valueFactor; //set X and Y scale to this factor
trf.scalingX = valueFactor;
trf.scalingY = valueFactor;
````

The methods provide instead a algebric sum change according to the pivot point
(all of the degree ones are provided in Rad as well)
````
trf.translate(addPixelsX,addPixelsY);
trf.translateX(addPixels);
trf.translateY(addPixels);
trf.rotate(addDegrees);
trf.skewX(addDegree);
trf.skewY(addDegree);
trf.scale(multiplyFactor);
trf.scaleX(multiplyFactor);
trf.scaleY(multiplyFactor);
````

-----

There are some interesting examples in different classes on the [PLIK library](https://github.com/yupswing/plik) that shows how to encapsulate the transformation class with an object.
See the [Gfx Class](https://github.com/yupswing/plik/blob/master/com/akifox/plik/Gfx.hx), or Text, or SpriteContainer for an example.

#### Transformation class
- [ ] *Unit test*
- [x] Cleaning and documenting code
- [x] Pivot point managing
- [x] Support for motion.Actuate (properties linked to functions get and set)
- [x] Events (Transform and Pivot change)
- [x] Translate
  - [x] Get
  - [x] Set
  - [x] Add
- [x] Skew
  - [x] Get
  - [x] Set 
  - [x] Add
- [x] Scale
  - [x] Get
  - [x] Set 
  - [x] Add
- [ ] Flip
  - [ ] Get (it looks like impossible!)
  - [x] Set 
- [x] Rotate
  - [x] Get
  - [x] Set 
  - [x] Add
