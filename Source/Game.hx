package;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

import openfl.events.Event;
import openfl.events.MouseEvent;

import openfl.Lib;

import ash.tick.ITickProvider;
import ash.tick.FrameTickProvider;
import ash.tick.FixedTickProvider;
import ash.core.Engine;

import util.KeyPoll;

import services.CameraService;
import services.EntityFactory;
import services.EventService;
import services.GameDataService;
import services.TileMapService;
import services.UIService;

import systems.BlockSystem;
//import systems.RenderSystem;
import systems.TileRenderSystem;
import systems.TockSystem;


class Game {

    private var container:DisplayObjectContainer;
    private var uiLayer:DisplayObjectContainer;
    private var gameLayer:DisplayObjectContainer;
    private var engine:Engine;
    private var factory:EntityFactory;
    private var input:EventService;
    private var camera:CameraService;
    private var map:TileMapService;
    private var ui:UIService;
    private var config:GameConfig;
    private var tickProvider:ITickProvider;
    private var tockProvider:ITickProvider;
    private var tockSystem:TockSystem;
    
    private var keyPoll:KeyPoll;

    public function new(container:DisplayObjectContainer, width:Float, height:Float) {
        this.container = container;

        this.uiLayer = new Sprite();
        this.gameLayer = new Sprite();

        this.container.addChild(this.gameLayer);
        this.container.addChild(this.uiLayer);

        //this.keyPoll = new KeyPoll(gameLayer.stage);
        
        this.engine = new Engine();
        this.factory = EntityFactory.instance.initialize(this.engine);

        this.ui = UIService.instance.initialize(uiLayer);
        this.map = TileMapService.instance.initialize(gameLayer);
        this.camera = CameraService.instance.initialize(gameLayer);

        this.input = EventService.instance.initialize(gameLayer, [
            MouseEvent.MOUSE_DOWN,
            MouseEvent.MOUSE_UP,
            MouseEvent.MOUSE_WHEEL
        ]);
        this.input.addListeners(this.camera);
        
        this.tockSystem = new TockSystem();
        engine.addSystem(tockSystem, 2);

        var blockSystem = new BlockSystem();
        engine.addSystem(blockSystem, 8);

        var tileRenderSystem = new TileRenderSystem(gameLayer);
        engine.addSystem(tileRenderSystem, 9);

        factory.createGame();
    }

    public function start():Void {
        tickProvider = new FrameTickProvider(gameLayer);
        tickProvider.add(this.input.dispatchEvents);
        tickProvider.add(this.engine.update);
        tickProvider.add(this.camera.update);
        tickProvider.start();

        tockProvider = new FixedTickProvider(gameLayer, 0.5);
        tockProvider.add(this.tockSystem.tock);
        tockProvider.add(this.ui.update);
        tockProvider.start();
    }
}