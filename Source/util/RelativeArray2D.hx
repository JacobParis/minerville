package util;

class RelativeArray2D<T> extends Array2D<T> {
    public var offset:Point;

    public function new(width:Int, height:Int, offset:Point, fill:Dynamic) {
        super(width, height, fill);

        this.offset = offset;
    }

    public function setOffset(offset:Point) {
        this.offset = offset;
    }

    private inline function absoluteX(x:Int) {
        return x + offset.x;
    }

    private inline function absoluteY(y:Int) {
        return y + offset.y;
    }

    public function getr(x:Int, y:Int) {
        return super.get(absoluteX(x), absoluteY(y));
    }
    public function setr(x:Int, y:Int, value:T) {
        return super.set(absoluteX(x), absoluteY(y), value);
    }

    public function fromIndexRelative(i:Int):Point {
        var point = super.fromIndex(i);
        return point.add(-offset.x, -offset.y);
    }
}