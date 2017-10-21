package services;

import haxe.ds.EnumValueMap;
import haxe.ds.HashMap;

import openfl.Assets;

import openfl.display.BitmapData;
import openfl.display.Tile;
import openfl.display.Tilemap;

import openfl.display.Tileset;
import openfl.display.DisplayObjectContainer;


import openfl.geom.Rectangle;

import ash.core.Entity;

import components.Task;
import components.TileImage;

import services.EntityFactory;
import services.TaskService;

import util.RelativeArray2D;
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

            // Draw a diamond shaped tile pattern with walls at the edge
            var startArea = [
                0,  2,  2,  2,  2,  2,  2,  0,
                2,  2,  1,  1,  4,  1,  2,  2,
                2,  1,  1,  1,  1,  1,  1,  2,
                2,  1,  1,  1,  1,  1,  1,  2,
                2,  7,  1,  1,  5,  1,  7,  2,
                2,  7,  1,  1,  1,  1,  1,  2,
                2,  2,  7,  1,  1,  7,  2,  2,
                0,  2,  2,  2,  2,  2,  2,  0
            ];

            // Create a tile for each tile in the startArea
            for (i in 0...startArea.length) {
                var id = startArea[i];
                var x = i % 8;
                var y = Util.fint(i / 8);

                switch(TileType.createByIndex(id)) {
                    case EMPTY: continue;
                    case ORE: EntityFactory.instance.createOre(new Point(x, y), id);
                    case WALL: EntityFactory.instance.createBlock(new Point(x, y), id, Util.anyOneOf([2,2,3,3,4,4,4,5,6,7,8,9]));
                    case BASE: EntityFactory.instance.createBuilding(new Point(x, y), id, Buildings.BASE);
                    case WORKER: EntityFactory.instance.createWorker("Alice");
                    default: 1;
                }

                var floor = new Tile(this.enumMap.get(TileType.FLOOR), (x + GameConfig.tilesLeft) * GameConfig.tileSize, (y + GameConfig.tilesUp) * GameConfig.tileSize);
                addBackdropTile(new Point(x, y), floor);
            }
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

        var neighbours = [new Point(1, 0), new Point(1, -1), new Point(0, -1), new Point(-1, -1), new Point(-1, 0), new Point(-1, 1),new Point(0, 1), new Point(1, 1)];
        for(neighbour in neighbours) {
            neighbour.add(cell.x, cell.y);

            var neighbourTile = positionMap.get(neighbour);
            if (neighbourTile != null) continue; //There is already a tile here

            var floor = new Tile(this.enumMap.get(TileType.FLOOR), (neighbour.x + GameConfig.tilesLeft) * GameConfig.tileSize, (neighbour.y + GameConfig.tilesUp) * GameConfig.tileSize);
            addBackdropTile(new Point(neighbour.x, neighbour.y), floor);

            var id = this.enumMap.get(TileType.WALL);
            EntityFactory.instance.createBlock(new Point(neighbour.x, neighbour.y), id, Util.anyOneOf([2,2,3,3,4,4,4,5,6,7,8,9]));
        }
        
        EntityFactory.instance.destroyEntity(entity);

        var floor = new Tile(this.enumMap.get(TileType.FLOOR), tile.x, tile.y);
        addBackdropTile(new Point(cell.x, cell.y), floor);

        // TODO this should not be here
        var ore:Entity = EntityFactory.instance.createOre(cell, this.enumMap.get(TileType.ORE));
    }

    /**
     *  Expands the map to the bottom and right and shifts every tile 
     *  to make room if shifting to the left or up
     *  @param dir - Direction the map needs to expand
     */
    function shiftMap(dir:Direction) {
        var amount = 1;
        switch (dir) {
            case RIGHT:
                GameConfig.tilesWide += amount;
                this.backdrops.width += amount * GameConfig.tileSize;
            case LEFT:
                GameConfig.tilesWide += amount;
                GameConfig.tilesLeft += amount;
                this.backdrops.width += amount * GameConfig.tileSize;

                for(i in 0...this.backdrops.numTiles) {
                    var tile:Tile = this.backdrops.getTileAt(i);
                    tile.x += amount * GameConfig.tileSize;
                }
            case DOWN:
                GameConfig.tilesHigh += amount;
                this.backdrops.height += amount * GameConfig.tileSize;
            case UP:
                GameConfig.tilesHigh += amount;
                GameConfig.tilesUp += amount;
                this.backdrops.height += amount * GameConfig.tileSize;

                for(i in 0...this.backdrops.numTiles) {
                    var tile:Tile = this.backdrops.getTileAt(i);
                    tile.y += amount * GameConfig.tileSize;
                }
        }

        //The actives will always be fully enclosed in backdrops so we can just cheat
        this.actives.width = this.backdrops.width;
        this.actives.height = this.backdrops.height;
    }
    public function addBackdropTile(point:Point, tile:Tile):Point {
        var origin = new Point(GameConfig.tilesLeft, GameConfig.tilesUp);

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

        return origin.add(-GameConfig.tilesLeft, -GameConfig.tilesUp);
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

    public function lookAround(position:Point, distance:Int):RelativeArray2D<Null<Bool>> {
		var size = distance * 2 + 1;
		var surroundings:RelativeArray2D<Null<Bool>> = new RelativeArray2D<Null<Bool>>(size, size, new Point(distance,distance), false);
		for(i in 0...surroundings.size) {
			var cell = surroundings.fromIndex(i);
			var block = EntityFactory.instance.stationaryAt(position.x + cell.x - distance, position.y + cell.y - distance) != null;
			//var worker = EntityFactory.instance.stationaryAt(position.x + cell.x - 2, position.y + cell.y - 2) != null;
			surroundings.setIndex(i, block);
		}
		//trace(surroundings);
		return surroundings;
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