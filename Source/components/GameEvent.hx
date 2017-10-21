package components;

import enums.EventTypes;

class GameEvent {
    public var type:EventTypes;
    public var value:String;

    public function new(type:EventTypes, value:String) {
        this.type = type;
        this.value = value;
    }
}