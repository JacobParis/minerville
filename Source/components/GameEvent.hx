package components;

import enums.Types;

class GameEvent {
    public var type:EventTypes;
    public var value:String;

    public function new(type:EventTypes, value:String) {
        this.type = type;
        this.value = value;
    }
}