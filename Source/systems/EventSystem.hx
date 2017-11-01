package systems;

import haxe.Timer;

import ash.core.Engine;
import ash.core.System;

import components.Markers;
import components.TilePosition;
import components.GameEvent;

import services.UIService;
import services.EntityFactory;
import services.TileMapService;
import services.CameraService;
import services.NotificationService;

import util.Util;

/**
 *  This system causes and handles events as time passes while not idle
 */
class EventSystem extends System {
	private var engine:Engine;
    public function new() {
        super();
    }
	
	// REMEMBER TO REGISTER THIS System
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;

	}
	
	override public function update(_):Void {
		var base = engine.getEntityByName("BASE");

		if(base == null) return;
		if(!base.has(ClickMarker)) return;

		base.remove(ClickMarker);

		UIService.instance.showNotifications();
	}
	
	
	public function tock(_):Void {
		// Cave-in
		if(Util.chance(0.01) && Util.chance(0.1)) {
			CameraService.instance.triggerShake();

			var block = EntityFactory.instance.findBlock();
			var cavein = "
			-X-
			XXX
			-X-";

			var position:TilePosition = block.get(TilePosition);

			var event = new GameEvent(DISASTER, "Cave-In at " + position.point);
			NotificationService.instance.addNotification(event);

			Timer.delay(function () {
				 var newPoints = TileMapService.instance.loadTilePattern(cavein, position.point.clone().add(-1,-1), true);

				for(cell in newPoints) {
					var crushedWorker = EntityFactory.instance.workerAt(cell.x, cell.y);
					if(crushedWorker == null) continue;

					crushedWorker.add(new DeadMarker("cave-in"));
				}
			}, 400);

		}
	}
}