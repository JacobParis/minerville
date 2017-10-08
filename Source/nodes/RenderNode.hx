package nodes;

import openfl.display.DisplayObject;

import ash.core.Node;

import components.Display;
import components.Position;

class RenderNode extends Node<RenderNode> {
    public var position:Position;
    private var display:Display;

    public var displayObject(get_displayObject, never):DisplayObject;

    private inline function get_displayObject():DisplayObject {
        return this.display.displayObject;
    }
}