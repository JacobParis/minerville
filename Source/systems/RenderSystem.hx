package systems;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import nodes.RenderNode;

import components.Display;
import components.Position;


class RenderSystem extends System
{
    public var container:DisplayObjectContainer;

    private var nodes:NodeList<RenderNode>;

    public function new(container:DisplayObjectContainer) {
        super();
        this.container = container;
    }

    override public function addToEngine(engine:Engine):Void {
        this.nodes = engine.getNodeList(RenderNode);
        
        for (node in nodes) {
            addToDisplay(node);
        }

        this.nodes.nodeAdded.add(addToDisplay);
        this.nodes.nodeRemoved.add(removeFromDisplay);
    }

    private function addToDisplay(node:RenderNode):Void {
        container.addChild(node.displayObject);
    }

    private function removeFromDisplay(node:RenderNode):Void {
        container.removeChild(node.displayObject);
    }

    override public function update(time:Float):Void {
        for (node in this.nodes) {
            var displayObject:DisplayObject = node.displayObject;
            var position:Position = node.position;

            displayObject.x = position.position.x;
            displayObject.y = position.position.y;
        }
    }

    override public function removeFromEngine(engine:Engine):Void {
        this.nodes = null;
    }
}