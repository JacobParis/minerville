package nodes;

import ash.core.Node;

// import components
import components.TilePosition;
import components.Stationary;

class StationaryObjectNode extends Node<StationaryObjectNode> {
    public var position:TilePosition;
    public var stationary:Stationary;
}