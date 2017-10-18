package systems;

import openfl.display.DisplayObjectContainer;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.Marker;
import components.TilePosition;

import nodes.MarkerNode;


import services.CameraService;

class RenderSystem extends System
{
    public var container:DisplayObjectContainer;

    private var nodes:NodeList<MarkerNode>;
    private var camera:CameraService;

    public function new(container:DisplayObjectContainer) {
        super();
        this.container = container;
        this.camera = CameraService.instance;
    }

    override public function addToEngine(engine:Engine):Void {
        this.nodes = engine.getNodeList(MarkerNode);
        
        for (node in nodes) {
            addToDisplay(node);
        }

        this.nodes.nodeAdded.add(addToDisplay);
        this.nodes.nodeRemoved.add(removeFromDisplay);
    }

    private function addToDisplay(node:MarkerNode):Void {
        Main.ui.addChild(node.marker.label);
    }

    private function removeFromDisplay(node:MarkerNode):Void {
        Main.ui.removeChild(node.marker.label);
    }

    override public function update(time:Float):Void {
        for (node in this.nodes) {
            var marker:Marker = node.marker;
            var position:TilePosition = node.position;

            var renderPoint = this.camera.gameToDisplay(position.absolute);
            marker.label.x = renderPoint.x + GameConfig.tileSize;
            marker.label.y = renderPoint.y - GameConfig.tileSize;
        }
    }

    override public function removeFromEngine(engine:Engine):Void {
        this.nodes = null;
    }
}