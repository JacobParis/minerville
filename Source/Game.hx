package;

import haxe.Timer;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

import openfl.events.MouseEvent;

import ash.tick.ITickProvider;
import ash.tick.FrameTickProvider;
import ash.tick.FixedTickProvider;
import ash.core.Engine;

import services.CameraService;
import services.EntityFactory;
import services.EventService;
import services.GameDataService;
import services.TaskService;
import services.TechService;
import services.TimeService;
import services.TileMapService;
import services.UIService;

import systems.AISystem;
import systems.BlockSystem;
import systems.ControlSystem;
import systems.RenderSystem;
import systems.TaskSystem;
import systems.TileRenderSystem;
import systems.TockSystem;


class Game {

    private var tickProvider:ITickProvider;
    private var tockProvider:ITickProvider;
    private var backgroundTickProvider:ITickProvider;

    public function new(container:DisplayObjectContainer) {

        var uiLayer = new Sprite();
        var gameLayer = new Sprite();

        container.addChild(gameLayer);
        container.addChild(uiLayer);

        
        var engine = new Engine();
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
        engine.addSystem(controlSystem, 2);

        var tockSystem = new TockSystem();
        engine.addSystem(tockSystem, 2);

        var taskSystem = new TaskSystem();
        engine.addSystem(taskSystem, 3);

        var aiSystem = new AISystem();
        engine.addSystem(aiSystem, 4);

        var blockSystem = new BlockSystem();
        engine.addSystem(blockSystem, 8);

        var tileRenderSystem = new TileRenderSystem(gameLayer);
        engine.addSystem(tileRenderSystem, 9);

        var renderSystem = new RenderSystem(uiLayer);
        engine.addSystem(renderSystem, 10);

        factory.createGame();

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
        tockProvider.add(tockSystem.tock);
        tockProvider.add(blockSystem.tock);
        tockProvider.add(taskSystem.tock);
        tockProvider.add(aiSystem.tock);
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

        
}