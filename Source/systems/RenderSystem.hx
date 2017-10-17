package systems;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import nodes.RenderNode;
import nodes.MarkerNode;

import components.Marker;

import components.Display;
import components.TilePosition;


class RenderSystem extends System
{
    public var container:DisplayObjectContainer;

    private var nodes:NodeList<MarkerNode>;

    public function new(container:DisplayObjectContainer) {
        super();
        this.container = container;
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

            marker.label.x = position.x;
            marker.label.y = position.y;
        }
    }

    override public function removeFromEngine(engine:Engine):Void {
        this.nodes = null;
    }
}