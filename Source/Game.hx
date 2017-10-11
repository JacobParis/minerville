package;

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
import services.TaskService;
import services.TileMapService;
import services.UIService;

import systems.AISystem;
import systems.BlockSystem;
import systems.TaskSystem;
import systems.TileRenderSystem;
import systems.TockSystem;


class Game {

    

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

        factory.createGame();

        var tickProvider:ITickProvider = new FrameTickProvider(gameLayer);
        tickProvider.add(input.dispatchEvents);
        tickProvider.add(engine.update);
        tickProvider.add(camera.update);
        tickProvider.start();

        var tockProvider:ITickProvider = new FixedTickProvider(gameLayer, 0.25);
        tockProvider.add(tockSystem.tock);
        tockProvider.add(taskSystem.tock);
        tockProvider.add(aiSystem.tock);
        tockProvider.add(ui.update);
        tockProvider.start();
    }

        
}