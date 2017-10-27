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
    private var factory:EntityFactory;

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
        this.factory = EntityFactory.instance;

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
        });

        // Draw a diamond shaped tile pattern with walls at the edge
        
        var start = "
        -XXXXXXXXXX-
        -X_G____GGX-
        XXG__@W___XX
        X__________X
        X__________X
        X__________X
        X__________X
        XX_G____G_XX
        -XX_G__G_XX-
        --XXXXXXXX--";

        loadTilePattern(start, new Point(-5,-2));
        
        return this;
    }

    public function loadTilePattern(pattern:String, topright:Point, overwrite:Bool = false):Array<Point> {
        var newTileLocations:Array<Point> = [];
        var stripNewlines = (~/\n/g).replace(pattern, "¬");
        var filteredPattern = (~/\s/g).replace(stripNewlines, "");
        var rowLength = 0;
        for (i in 0...filteredPattern.length) {
            var x = (rowLength == 0) ? i : i % rowLength;
            var y = (rowLength == 0) ? 0 : Util.fint(i / rowLength);
            var position = new Point(topright.x + x - 1, topright.y + y);
            

            var tileType:TileType;
            switch(filteredPattern.charAt(i)) {
                case " ": continue;
                case "-": continue;
                case "¬": {
                    trace(rowLength, i);
                    if(rowLength == 0) rowLength = i;
                    continue;
                }
                case "X": tileType = TileType.WALL;
                case "@": tileType = TileType.BASE;
                case "W": tileType = TileType.WORKER;
                case "G": tileType = TileType.ORE;
                default: tileType = TileType.FLOOR;
            }

            // If we want to only fill in blank tiles
            // Overwrite = false + Clip = false
            if(!overwrite && tileType != TileType.ORE && positionMap.get(position) != null) continue;

            // If we want to only fill in solid tiles
            // Overwrite = true + Clip = True
            if(overwrite && positionMap.get(position) == null) continue;
            
            // If the current tile is the same as the one we are placing, Don't
            if(positionMap.get(position) != null && positionMap.get(position).id == this.enumMap.get(tileType)) continue;

            newTileLocations.push(position);
            var id = enumMap.get(tileType);

            var floor = new Tile(this.enumMap.get(TileType.FLOOR), (position.x + GameConfig.tilesLeft) * GameConfig.tileSize, (position.y + GameConfig.tilesUp) * GameConfig.tileSize);
            addBackdropTile(position, floor);
            
            switch(tileType) {
                case ORE: this.factory.createOre(position, id);
                case WALL: {
                    trace("WALL", position);
                    var id = 0;
                    var hardness = 1;
                    var health = 1;
                    if(Util.chance(0.8)) {
                        id = this.enumMap.get(TileType.WALL);
                        health = Util.rnd(20, 30);
                    } else {
                        id = this.enumMap.get(TileType.WALL_STONE);
                        health = Util.rnd(40, 60);
                        hardness = 2;
                    }
                    this.factory.createBlock(position, id, health, hardness);
                }
                case BASE: this.factory.createBuilding(position, id, Buildings.BASE);
                case WORKER: this.factory.createWorker();
                default: 1;
            }

        }

        return newTileLocations;
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

        this.factory.destroyEntity(entity);

        loadTilePattern("
        XXX
        XGX
        XXX", cell.add(-1,-1));
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
			var block = this.factory.stationaryAt(position.x + cell.x - distance, position.y + cell.y - distance) != null;
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
    WALL_STONE;
    WALL_DAMAGED;
    BASE;
    WORKER;
    WORKER_ORE;
    ORE;
    PICKAXE;
}

enum Direction {
    RIGHT;
    UP;
    LEFT;
    DOWN;
}