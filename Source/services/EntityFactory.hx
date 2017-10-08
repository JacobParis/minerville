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
import components.Position;
import components.TileImage;
import components.Worker;

import components.markers.ClickedEh;

import nodes.BlockNode;

import graphics.AsciiView;

import services.TileMapService;

import util.Point;

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

    private function testHit(x:Float, y:Float):Null<Entity> {
        var nodes:NodeList<BlockNode> = engine.getNodeList(BlockNode);
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

    public function createBuilding(cell:Point, id:Int, name:Building):Entity {
        var tile:Tile = new Tile(id, cell.x * GameConfig.tileSize, cell.y * GameConfig.tileSize);
        var building:Entity = new Entity(name.getName())
        .add(new Position(cell.x, cell.y))
        .add(new TileImage(tile));

        this.engine.addEntity(building);
        return building;
    }

    public function createBlock(cell:Point, id:Int, health:Int):Entity {
        var tile:Tile = new Tile(id, cell.x * GameConfig.tileSize, cell.y * GameConfig.tileSize);
        var block:Entity = new Entity()
        .add(new Position(cell.x, cell.y))
        .add(new TileImage(tile))
        .add(new Health(health));

        this.engine.addEntity(block);
        return block;
    }

    public function createWorker():Entity {
        var base = this.engine.getEntityByName(Building.BASE.getName());
        var position = base.get(Position);

        var tile:Tile = new Tile(5);
        var worker:Entity = new Entity()
        .add(new Position(position.x + 1, position.y))
        .add(new TileImage(tile))
        .add(new Worker());
        
        return worker;
    }
}

enum Building {
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