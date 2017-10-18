package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

import haxe.ui.Toolkit;
import haxe.ui.containers.VBox;
import haxe.ui.macros.ComponentMacros;

class Main extends Sprite {
    public static var ui:VBox;
	
	public function new() {
        super();
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(event:Event):Void {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        Toolkit.init();

        Main.ui = ComponentMacros.buildComponent("assets/ui/main.xml");
        new Game(this);
        this.addChild(Main.ui);
        
    }

    private static function main() {
        Lib.current.addChild(new Main());
    }
    
    public static function log(v:Dynamic) {
        js.Browser.window.console.log(v);
    }
}