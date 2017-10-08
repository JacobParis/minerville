package interfaces;

import openfl.events.Event;

interface InputListener {

    public var subscribedEvents:Array<String>;
    public function onEvent(e:Event):Void;
}