package components;

import openfl.display.DisplayObject;

class Display {
    public var displayObject(default, null):DisplayObject;

    public function new(displayObject:DisplayObject) {
        this.displayObject = displayObject;
    }
}