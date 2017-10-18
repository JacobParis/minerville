package components;

import haxe.ui.components.Label;
import haxe.ui.components.Button;

class Marker {
    public var text:String;
    public var label:Button;
    
    public function new(text:String) {
        this.label = new Button();
        this.label.text = text;
        this.label.addClass("marker");
    }
}