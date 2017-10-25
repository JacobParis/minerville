package systems;

//import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Tile;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.TileImage;
import components.SmoothMovement;

import nodes.TileNode;

import services.TileMapService;

import util.Point;

/**
 *  This system displays tile objects using the tilemap as a 
 *  displaylist replacement
 */
class TileRenderSystem extends System {
    private var nodes:NodeList<TileNode>;
	private var container:DisplayObjectContainer;
	private var map:TileMapService;

    private var oldLeft:Int;
    private var oldUp:Int;

    public function new(container:DisplayObjectContainer) {
        super();
        this.container = container;
		this.map = TileMapService.instance;
        this.oldLeft = GameConfig.tilesLeft;
        this.oldUp = GameConfig.tilesUp;
    }

    override public function addToEngine(engine:Engine):Void {
        this.nodes = engine.getNodeList(TileNode);
        
        for (node in nodes) {
            addToDisplay(node);
        }

        this.nodes.nodeAdded.add(addToDisplay);
        this.nodes.nodeRemoved.add(removeFromDisplay);
    }

    private function addToDisplay(node:TileNode):Void {
        node.tile.x = (node.position.x + GameConfig.tilesLeft) * GameConfig.tileSize;
        node.tile.y = (node.position.y + GameConfig.tilesUp) * GameConfig.tileSize;
        if(node.tile.isForeground) {
            map.addForegroundTile(node.tile.tile);
        } else {
            
		    map.addBackdropTile(new Point(node.position.x, node.position.y), node.tile.tile);
        }
    }

    private function removeFromDisplay(node:TileNode):Void {
		map.removeTile(node.tile.tile);
    }

    override public function update(time:Float):Void {
        var originChanged = (this.oldLeft != GameConfig.tilesLeft) || (this.oldUp != GameConfig.tilesUp);
        for (node in this.nodes) {
            
            if(node.entity.has(SmoothMovement) && !originChanged) {
                var targetX = (node.position.x + GameConfig.tilesLeft) * GameConfig.tileSize;
                var targetY = (node.position.y + GameConfig.tilesUp) * GameConfig.tileSize;
                node.tile.x = node.tile.tile.x + Math.min(Math.max((targetX - node.tile.tile.x), -16), 16);
                node.tile.y = node.tile.tile.y + Math.min(Math.max((targetY - node.tile.tile.y), -16), 16);
            } else {
                node.tile.x = (node.position.x + GameConfig.tilesLeft) * GameConfig.tileSize;
                node.tile.y = (node.position.y + GameConfig.tilesUp) * GameConfig.tileSize;
                if(originChanged) {
                    this.oldLeft = GameConfig.tilesLeft;
                    this.oldUp = GameConfig.tilesUp;
                }
            }
        }
    }

    override public function removeFromEngine(engine:Engine):Void {
        this.nodes = null;
    }
}