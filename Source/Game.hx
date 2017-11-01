package;

import haxe.Timer;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

import openfl.events.MouseEvent;

import ash.tick.ITickProvider;
import ash.tick.FrameTickProvider;
import ash.tick.FixedTickProvider;
import ash.core.Engine;
import ash.core.System;

import services.CameraService;
import services.EntityFactory;
import services.EventService;
import services.GameDataService;
import services.TaskService;
import services.TechService;
import services.TimeService;
import services.TileMapService;
import services.UIService;

import systems.WorkerTaskSystem;
import systems.BlockSystem;
import systems.ControlSystem;
import systems.EventSystem;
import systems.LootSystem;
import systems.RenderSystem;
import systems.TaskSystem;
import systems.TileRenderSystem;
import systems.TravelSystem;
import systems.WorkerSystem;
import systems.WorkerMiningSystem;



class Game {

    private var engine:Engine;
    private var nextSystemPriority:Int = 1;

    private var tickProvider:ITickProvider;
    private var tockProvider:ITickProvider;
    private var backgroundTickProvider:ITickProvider;

    public function new(container:DisplayObjectContainer) {

        var uiLayer = new Sprite();
        var gameLayer = new Sprite();

        container.addChild(gameLayer);
        container.addChild(uiLayer);

        
        this.engine = new Engine();
        var factory = EntityFactory.instance.initialize(engine);

        var ui = UIService.instance.initialize(uiLayer);
        var map = TileMapService.instance.initialize(gameLayer);
        var camera = CameraService.instance.initialize(gameLayer);
        TaskService.instance.initialize();
        // TODO see about refactoring this to use Ash Signals
        var input = EventService.instance.initialize(gameLayer, [
            MouseEvent.MOUSE_DOWN,
            MouseEvent.MOUSE_UP,
            MouseEvent.MOUSE_WHEEL
        ]);
        input.addListeners(camera);
        
        var tech = TechService.instance.initialize();
        var time = TimeService.instance;

        var controlSystem = new ControlSystem();
        addSystem(controlSystem);


        var lootSystem = new LootSystem();
        addSystem(lootSystem);

        var taskSystem = new TaskSystem();
        addSystem(taskSystem);

        var travelSystem = new TravelSystem();
        addSystem(travelSystem);

        var workerSystem = new WorkerSystem();
        addSystem(workerSystem);

        var workerTaskSystem = new WorkerTaskSystem();
        addSystem(workerTaskSystem);

        var workerMiningSystem = new WorkerMiningSystem();
        addSystem(workerMiningSystem);

        var blockSystem = new BlockSystem();
        addSystem(blockSystem);

        var eventSystem = new EventSystem();
        addSystem(eventSystem);
        
        var tileRenderSystem = new TileRenderSystem(gameLayer);
        addSystem(tileRenderSystem);

        var renderSystem = new RenderSystem(uiLayer);
        addSystem(renderSystem);

        tickProvider = new FrameTickProvider(gameLayer);
        tickProvider.add(input.dispatchEvents);
        tickProvider.add(engine.update);
        tickProvider.add(camera.update);
        tickProvider.start();

        backgroundTickProvider = new FixedTickProvider(gameLayer, 0.2);
        backgroundTickProvider.add(time.tock);
        backgroundTickProvider.start();

        tockProvider = new FixedTickProvider(gameLayer, 0.2);
        tockProvider.add(controlSystem.tock);
        tockProvider.add(lootSystem.tock);
        tockProvider.add(blockSystem.tock);
        tockProvider.add(taskSystem.tock);
        tockProvider.add(travelSystem.tock);
        tockProvider.add(workerSystem.tock);
        tockProvider.add(workerTaskSystem.tock);
        tockProvider.add(workerMiningSystem.tock);
        tockProvider.add(ui.update);
        tockProvider.start();


        untyped __js__ ("document.addEventListener(\"visibilitychange\", $bind(this, this.handleVisibilityChange));");
    }

    public function handleVisibilityChange(e:Dynamic) {
        if(e == null || e.target == null || e.target.visibilityState == null) return;


        switch(e.target.visibilityState) {
            case "hidden": {
                tickProvider.stop();
                tockProvider.stop();
                TimeService.instance.pause();
            }
            case "visible": {
                tickProvider.start();
                tockProvider.start();

                // Hacky thing to make the startday work
                // Hopefully becomes obselete when the server comes in
                Timer.delay(TimeService.instance.resume, 200);
            }
        }
    }

    private function addSystem(system:System):System {
        this.engine.addSystem(system, this.nextSystemPriority++);

        return system;
    }

        
}