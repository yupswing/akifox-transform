package;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.system.Capabilities;
import openfl.Assets;
import openfl.Lib;


class Main extends Sprite {
	
	private var Game:Transform; 
	
	
	public function new () {
		
		super ();
		
		initialize ();
		construct ();
		
		Lib.current.stage.addEventListener (Event.RESIZE, stage_onResize);
		
	}
	
	
	private function initialize ():Void {
		
		Game = new Transform ();
		
	}
	
	
	private function construct ():Void {
		
		addChild (Game);
		
	}
	
	
	private function resize (newWidth:Int, newHeight:Int):Void {
		
		//Game.resize (newWidth, newHeight);
		
	}
	
	
	private function stage_onResize (event:Event):Void {
		
		resize (Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		
	}
	
	
}
