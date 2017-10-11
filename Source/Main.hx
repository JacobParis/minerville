package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

class Main extends Sprite {
	
	public function new() {
        super();
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(event:Event):Void {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);

        new Game(this);
    }

    private static function main() {
        Lib.current.addChild(new Main());
    }
    
    public static function log(v:Dynamic) {
        js.Browser.window.console.log(v);
    }
}