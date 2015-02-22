**WARNING: THIS REPO IS A WORK IN PROGRESS**.

# akifox-transform (com.akifox.transform)
**Transformation HAXE/OpenFL Library**

The akifox-transform library aims to provide an easy tool to manage affine transformations using a reliable pivot point.
What are the affine transformation you might ask...
- read <a href="http://en.wikipedia.org/wiki/Affine_transformation">this wikipedia page</a>
- read <a href="http://www.senocular.com/flash/tutorials/transformmatrix/">this great flash tutorial</a>

You can find a working example in the <a href="https://github.com/yupswing/akifox-transform/tree/master/example">example folder</a>. (read below for more information)

## Install and try

As soon as stable it will be submitted an haxelib package.
For now just follow this instructions:

<code>git clone https://github.com/yupswing/akifox-transform.git</code><br/>
<code>cd akifox-transform/example</code><br/>
<code>lime test neko</code><br/>

You should get a window with a OpenFL logo square.
- <code>Space<code> to reset the transformations
- Drag to move
- Click to change the pivot point
- Drag+<code>Shift</code> to rotate around the pivot point
- Drag+<code>Alt</code> to scale related to the pivot point
- Drag+<code>Ctrl</code> to skew related to the pivot point (center of the cross is 0,0)
- <code>UP</code> Flip X 
- <code>DOWN</code> Flip Y 
- <code>RIGHT</code> Rotate 15deg
- <code>LEFT</code> Rotate -15deg
- <code>1</code> to <code>9</code> to set the pivot point on the relative anchor point (TOPLEFT, MIDDLELEFT,BOTTOMLEFT,TOPCENTER... BOTTOMRIGHT)

<img src="https://dl.dropboxusercontent.com/u/683344/akifox/git/openfl-transform-sample.png"/>

## Using the library
**I DON'T RECOMMEND USING IT RIGHT NOW BECAUSE IT'S A WORK IN PROGRESS AND IT WILL CHANGE MAYBE RADICALLY IN THE PROCESS OF BECOMING STABLE**

Once you got a DisplayObject (Sprites, Bitmap...) you can create a Transformation object linked to it.
(Don't use more than one transformation at a given time. I will code this check later on)

<pre>
import com.akifox.transform.Transformation;
[...]
    trf = new Transformation(YOUROBJECT);
    trf.setAnchoredPivot(Transformation.LEFT,Transformation.TOP);
                               
    // these are the Pivot Point coordinates (they will not change unless
    // you change the pivot point position)
    var pivotCoordinates:Point = trf.getPivot();

    trf.rotate(20); //rotate 20degress clockwise
</pre>

## Work in progress
- [ ] Unit test
- [ ] Cleaning and documenting code
  - [ ] Better README.md when it will become stable.
- [ ] Package in a haxelib library
- [x] Events (Transform and Pivot change)
- [x] Pivot point managing
- [x] Translate
  - [x] Get
  - [x] Set
  - [x] Sum
- [x] Skew
  - [x] Get
  - [x] Set 
  - [x] Sum
- [x] Scale
  - [x] Get
  - [x] Set 
  - [x] Sum
- [ ] Flip
  - [ ] Get (is it possible?)
  - [x] Set 
- [x] Rotate
  - [x] Get
  - [x] Set 
  - [x] Sum

  - [x] Sum
