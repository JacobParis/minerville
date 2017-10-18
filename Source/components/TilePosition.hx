package components;

import util.Point;

class TilePosition extends Position {
    public var absolute(get, never):Point;
    public function new(x:Float, y:Float) {
        super(x,y);
    }

    private inline function get_absolute() {
        return this.point.clone().multiply(GameConfig.tileSize);
    }
    
    public var absoluteX(get, never):Int;
    public var absoluteY(get, never):Int;

    private inline function get_absoluteX():Int {
        return this.point.x * GameConfig.tileSize;
    }

    private inline function get_absoluteY():Int {
        return this.point.y * GameConfig.tileSize;
    }

}