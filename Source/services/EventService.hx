package services;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;

import interfaces.InputListener;

import util.ds.ArrayedQueue;
import util.Util;

/**
 *  This Service allows other services to subscribe to events and dispatches
 *  events when they occur. I should look into replacing this with the Ash
 *  signal library
 */
class EventService {
    public static var instance(default, null):EventService = new EventService();

    private var container:DisplayObjectContainer;
    private var eventQueue:ArrayedQueue<Event>;
    private var listeners:Array<InputListener>;

    private function new() {}
    
    public function initialize(container:DisplayObjectContainer, events:Array<String>):EventService {
        this.eventQueue = new ArrayedQueue();
        this.listeners = new Array();

        this.container = container;

        for(event in events) {
            this.container.addEventListener(event, addEvent);
        }

        return this;
    }

    private function addEvent(e:Event) {
        this.eventQueue.enqueue(e);
    }

    public function addListeners(listener:InputListener) {
        this.listeners.push(listener);
    }

    public function dispatchEvents(time:Float):Void {
        while(!this.eventQueue.isEmpty()) {
            var e = this.eventQueue.dequeue();

            for(listener in this.listeners) {
                for(event in listener.subscribedEvents) {
                    if(event == e.type) listener.onEvent(e);
                }
            }
        }
        
    }
}