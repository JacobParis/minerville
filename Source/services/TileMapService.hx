package services;

import haxe.ds.EnumValueMap;
import haxe.ds.HashMap;

import openfl.Assets;

import openfl.display.BitmapData;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.TileArray;

import openfl.display.Tileset;
import openfl.display.DisplayObjectContainer;

import openfl.events.MouseEvent;

import openfl.geom.Rectangle;
import openfl.geom.Matrix;

import ash.core.Engine;
import ash.core.Entity;

import components.Health;
import components.Task;
import components.TileImage;

import services.EntityFactory;
import services.TaskService;

import util.ds.ArrayedQueue;
import util.Point;

import util.Util;

/**
 *  This Service should strictly handle the storage and display of backdrops
 *  assets
 */
class TileMapService {
    public static var instance(default, null):TileMapService = new TileMapService();

    private var container:DisplayObjectContainer;
    public var enumMap:EnumValueMap<TileType, Int>;
    private var backdrops:Tilemap;
    private var actives:Tilemap;

    private var positionMap:HashMap<Point, Null<Tile>>;


    private function new() {
        this.enumMap = new EnumValueMap();
        this.positionMap = new HashMap();
     }

    public function initialize(container:DisplayObjectContainer):TileMapService {
        this.container = container;

        Assets.loadBitmapData("assets/underground.png")
        .onComplete(function (bitmapData:BitmapData) {
            var tileset = new Tileset(bitmapData);

            // Assign each tile to TileType in order
            for(i in 0...TileType.getConstructors().length) {
                var id = tileset.addRect(new Rectangle(2, (GameConfig.tileSize + 2) * i + 2, GameConfig.tileSize, GameConfig.tileSize));
                this.enumMap.set(TileType.createByIndex(i), id);
            }
            
            this.backdrops = new Tilemap(GameConfig.tilesWide * GameConfig.tileSize, GameConfig.tilesHigh * GameConfig.tileSize, tileset);
            this.actives = new Tilemap(GameConfig.tilesWide * GameConfig.tileSize, GameConfig.tilesHigh * GameConfig.tileSize, tileset);
            
            container.addChild(this.backdrops);
            container.addChild(this.actives);

            // Figure out which coordinates will show the center of the visible screen at start
            var virtualWidth:Int = Util.fint(container.stage.stageWidth / GameConfig.tileSize);
            var virtualHeight:Int = Util.fint(container.stage.stageHeight / GameConfig.tileSize);

            // Draw a diamond shaped tile pattern with walls at the edge
            var startArea = [
                0,  0,  0,  2,  2, 0,  0,  0,
                0,  0,  2,  1,  1, 2,  0,  0,
                0,  2,  1,  1,  1, 1,  2,  0,
                2,  1,  1,  1,  1, 1,  1,  2,
                2,  1,  1,  1,  1, 1,  1,  2,
                0,  2,  1,  1,  1, 1,  2,  0,
                0,  0,  2,  1,  1, 2,  0,  0,
                0,  0,  0,  2,  2, 0,  0,  0
            ];

            var centerX:Int = Util.fint(virtualWidth / 2);
            var centerY:Int = Util.fint(virtualHeight / 2);

            // Create a tile for each tile in the startArea
            for (i in 0...startArea.length) {
                var id = startArea[i];
                if(id == this.enumMap.get(TileType.EMPTY)) continue;
                
                var x = i % 8 + centerX - 3;
                var y = Util.fint(i / 8) + centerY - 3;
                
                if(x == centerX && y == centerY) continue;

                if(id == this.enumMap.get(TileType.FLOOR)) {
                    // Create static tile
                    var tile = new Tile(id, x * GameConfig.tileSize, y * GameConfig.tileSize);
                    addBackdropTile(new Point(x, y), tile);
                    continue;
                }
                
                EntityFactory.instance.createBlock(new Point(x, y), id, Util.anyOneOf([2,2,3,3,4,4,4,5,6,7,8,9]));
                
            }

            // Create base
            var id = this.enumMap.get(TileType.BASE);
            EntityFactory.instance.createBuilding(new Point(centerX, centerY), id, Buildings.BASE);
            EntityFactory.instance.createWorker("Alice");
            EntityFactory.instance.createWorker("Bob");
            EntityFactory.instance.createWorker("Carol");
            //EntityFactory.instance.createWorker("Doug");
            //EntityFactory.instance.createWorker("Evelyn");
            //EntityFactory.instance.createWorker("Fred");
            //EntityFactory.instance.createWorker("Georgia");


        });

        
        
        return this;
    }

    /**
     *  Replaces a block with ore and creates neighbouring blocks in the empty spaces around it
     *  @param entity - The block to destroy
     */
    public function destroyBlock(entity:Entity) {
        var tile:Tile = entity.get(TileImage).tile;

        var cell:Point = new Point(tile.x , tile.y )
        .divide(GameConfig.tileSize)
        .add(-GameConfig.tilesLeft, -GameConfig.tilesUp);

        var neighbours = [new Point(1, 0), new Point(0, -1), new Point(-1, 0), new Point(0, 1)];
        for(neighbour in neighbours) {
            neighbour.add(cell.x, cell.y);

            var neighbourTile = positionMap.get(neighbour);
            if (neighbourTile == null) {
                var id = this.enumMap.get(TileType.WALL);
    
                var block = EntityFactory.instance.createBlock(new Point(neighbour.x, neighbour.y), id, Util.anyOneOf([2,2,3,3,4,4,4,5,6,7,8,9]));
                TaskService.instance.addTask(new Task(Skills.MINE, block));
            }

        }

        var floorTile = new Tile(this.enumMap.get(TileType.FLOOR), tile.x  , tile.y );
        
        EntityFactory.instance.destroyEntity(entity);
        addBackdropTile(cell, floorTile);

        // TODO this should not be here
        var ore:Entity = EntityFactory.instance.createOre(cell, this.enumMap.get(TileType.ORE));
        TaskService.instance.addTask(new Task(Skills.CARRY, ore));
        
    }

    /**
     *  Expands the map to the bottom and right and shifts every tile 
     *  to make room if shifting to the left or up
     *  @param dir - Direction the map needs to expand
     */
    function shiftMap(dir:Direction) {
        switch (dir) {
            case RIGHT:
                GameConfig.tilesWide += 1;
                this.backdrops.width += GameConfig.tileSize;
            case LEFT:
                GameConfig.tilesWide += 1;
                GameConfig.tilesLeft += 1;
                this.backdrops.width += GameConfig.tileSize;

                for(i in 0...this.backdrops.numTiles) {
                    var tile:Tile = this.backdrops.getTileAt(i);
                    tile.x += GameConfig.tileSize;
                }
            case DOWN:
                GameConfig.tilesHigh += 1;
                this.backdrops.height += GameConfig.tileSize;
            case UP:
                GameConfig.tilesHigh += 1;
                GameConfig.tilesUp += 1;
                this.backdrops.height += GameConfig.tileSize;

                for(i in 0...this.backdrops.numTiles) {
                    var tile:Tile = this.backdrops.getTileAt(i);
                    tile.y += GameConfig.tileSize;
                }
        }

        //The actives will always be fully enclosed in backdrops so we can just cheat
        this.actives.width = this.backdrops.width;
        this.actives.height = this.backdrops.height;
    }
    public function addBackdropTile(point:Point, tile:Tile) {
        if(point.x + 1 > GameConfig.tilesWide - GameConfig.tilesLeft) {
            shiftMap(Direction.RIGHT);
        }

        if(point.x - 1 < -GameConfig.tilesLeft) {
            shiftMap(Direction.LEFT);

        }

        if(point.y + 1 > GameConfig.tilesHigh - GameConfig.tilesUp) {
            shiftMap(Direction.DOWN);
        }

        if(point.y - 1 < -GameConfig.tilesUp) {
            shiftMap(Direction.UP);
        }

        if(positionMap.get(point) != null) {
            backdrops.removeTile(positionMap.get(point));
        }
        positionMap.set(point, tile);
        backdrops.addTileAt(tile, backdrops.numTiles + 1);
    }

    public function addForegroundTile(tile:Tile) {
        actives.addTileAt(tile, actives.numTiles + 1);
    }
    
    public function removeTile(tile:Tile) {
        var point = new Point(tile.x,tile.y);
        if(positionMap.get(point) != null) {
            positionMap.set(point, null);
        }

        actives.removeTile(tile);
        backdrops.removeTile(tile);
    }

    
}

enum TileType {
    EMPTY;
    FLOOR;
    WALL;
    WALL_DAMAGED;
    BASE;
    WORKER;
    WORKER_ORE;
    ORE;
}

enum Direction {
    RIGHT;
    UP;
    LEFT;
    DOWN;
}