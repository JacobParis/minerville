package systems;

//import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Tile;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.Position;
import components.TileImage;

import nodes.TileNode;

import services.TileMapService;

import util.Point;

class TileRenderSystem extends System {
    private var nodes:NodeList<TileNode>;
	private var container:DisplayObjectContainer;
	private var map:TileMapService;

    public function new(container:DisplayObjectContainer) {
        super();
        this.container = container;
		this.map = TileMapService.instance;
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
		map.addTile(new Point(node.position.x, node.position.y), node.tile.tile);
    }

    private function removeFromDisplay(node:TileNode):Void {
		map.removeTile(node.tile.tile);
    }

    override public function update(time:Float):Void {
        for (node in this.nodes) {
            node.tile.x = (node.position.x + GameConfig.tilesLeft) * GameConfig.tileSize;
            node.tile.y = (node.position.y + GameConfig.tilesUp) * GameConfig.tileSize;
        }
    }

    override public function removeFromEngine(engine:Engine):Void {
        this.nodes = null;
    }
}