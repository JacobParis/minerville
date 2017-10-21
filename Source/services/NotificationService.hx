package services;

import components.GameEvent;

import util.ds.ArrayedQueue;
import util.Util;

class NotificationService {
    public static var instance(default, null):NotificationService = new NotificationService();
    private var queue:Array<GameEvent>;

    private function new() {
        this.queue = new Array<GameEvent>();
    }
	
    public function getNotifications():Array<GameEvent> {
        return this.queue;
    }

    public function addNotification(event:GameEvent) {
        this.queue.push(event);
    }

	public function update(time:Float):Void {
	
	}
}