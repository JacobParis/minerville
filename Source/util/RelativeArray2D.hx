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

    @:expose("array2D") @:keep
	public static function fromString(s:String):RelativeArray2D<Bool> {
		var array = new RelativeArray2D<Bool>(9, 9, new Point(4, 4), false);

		for(i in 0...s.length) {
			var x = i % 9;
			var y = Util.fint(i / 9);

			switch(s.charAt(i)) {
				case "\u2B1B": array.set(x, y, true);
				case "\u2B1C": array.set(x, y, false);
				default: array.set(x, y, null);
			}
		}

		return array;
	}
}