package services;

import openfl.display.Tile;

import openfl.events.Event;
import openfl.events.MouseEvent;

import ash.core.Entity;
import ash.core.Engine;
import ash.core.NodeList;
import ash.fsm.EntityStateMachine;
import ash.tools.ComponentPool;

import interfaces.InputListener;

import components.Building;
import components.GameState;
import components.Health;
import components.Ore;
import components.Position;
import components.TileImage;
import components.Worker;

import components.ai.Walking;

import components.markers.ClickedEh;

import nodes.BlockNode;
import nodes.TileNode;

import graphics.AsciiView;

import services.TileMapService;

import util.Point;

/**
 *  This Service provides the infrastructure to create and register specific 
 *  entities so that I don't need to assemble them from components every time
 *  
 *  As a second function it allows me to attach markers to entities
 *  
 *  As a third function it can test if an entity occupies a specific grid cell
 */
class EntityFactory {
    public static var instance(default, null):EntityFactory = new EntityFactory();

    private var engine:Engine;

    private function new() { }

    public function initialize(engine:Engine):EntityFactory {
        this.engine = engine;
        return this;
    }

    public function destroyEntity(entity:Entity):Void {
        this.engine.removeEntity(entity);
    }

    public function markEntityAtPosition(x:Float, y:Float, marker:String) {
        var entity = testHit(x, y);
        if(entity == null) return;

        trace("Add clickmarker");
        entity.add(new ClickedEh());
    }

    /**
     *  Tests if a block is present in a specific cell
     *  @param x - X Cell
     *  @param y - Y Cell
     *  @return Null<Entity>
     */
    public function testHit(x:Float, y:Float):Null<Entity> {
        var nodes:NodeList<TileNode> = engine.getNodeList(TileNode);
        for(node in nodes) {
            var left = (node.position.x + GameConfig.tilesLeft) * GameConfig.tileSize;
            if(x < left) continue;

            var right = left + GameConfig.tileSize;
            if(x > right) continue;

            var top = (node.position.y + GameConfig.tilesUp) * GameConfig.tileSize;
            if(y < top) continue;

            var bottom = top + GameConfig.tileSize;
            if(y > bottom) continue;

            return node.entity;
        }
        return null;
    }

    /* Create Game Entity */
    public function createGame():Entity {
        var gameEntity:Entity = new Entity()
        .add(new GameState());

        this.engine.addEntity(gameEntity);
        return gameEntity;
    }

    public function createBuilding(cell:Point, id:Int, name:Buildings):Entity {
        var tile:Tile = new Tile(id);
        var building:Entity = new Entity(name.getName())
        .add(new Position(cell.x, cell.y))
        .add(new TileImage(tile, true))
        .add(new Building());

        this.engine.addEntity(building);
        return building;
    }

    public function createBlock(cell:Point, id:Int, health:Int):Entity {
        var tile:Tile = new Tile(id);
        var block:Entity = new Entity()
        .add(new Position(cell.x, cell.y))
        .add(new TileImage(tile))
        .add(new Health(health));

        this.engine.addEntity(block);
        return block;
    }

    public function createWorker(name:String):Entity {
        var base:Entity = this.engine.getEntityByName(Buildings.BASE.getName());
        var position:Position = base.get(Position);
        var tile:Tile = new Tile(5);
        var worker:Entity = new Entity(name)
        .add(new Position(position.x + 1, position.y))
        .add(new TileImage(tile, true))
        .add(new Worker());
        
        this.engine.addEntity(worker);
        return worker;
    }

    public function createOre(cell:Point, id:Int):Entity {
        var tile:Tile = new Tile(id);
        var ore:Entity = new Entity()
        .add(new Position(cell.x, cell.y))
        .add(new TileImage(tile, true))
        .add(new Ore());

        this.engine.addEntity(ore);
        return ore;
    }

    public function getWalkingToBase():Walking {
        var base:Entity = this.engine.getEntityByName(Buildings.BASE.getName());
        var position:Position = base.get(Position);

        return new Walking(position.x, position.y, base);
    }
}

enum Buildings {
    BASE;
    REFINERY;
    FACTORY;
    SILO;
    HOUSE;
}

enum Workers {
    WORKER;
    MINER;
    WARRIOR;
}