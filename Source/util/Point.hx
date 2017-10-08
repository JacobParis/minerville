package util;

// 2D integer point
class Point
{
	public var x:Int;
	public var y:Int;
	
	public function new(x:Float, y:Float)
	{
		set(Util.fint(x), Util.fint(y));
	}


	public function set(x:Float, y:Float): Point
	{
		this.x = Util.fint(x);
		this.y = Util.fint(y);
		
		return this;
	}

	public function add(x:Float, y:Float): Point
	{
		this.x += Util.fint(x);
		this.y += Util.fint(y);
        
		return this;
	}

	public function multiply(x:Float, ?y:Float):Point {
		this.x = Util.fint(this.x * x);
				
		if(y == null) 
			this.y = Util.fint(this.y * x);
		else
			this.y = Util.fint(this.y * y);

		return this;
	}

	public function divide(x:Float, ?y:Float):Point {
		if(x == 0) {
			trace("Cannot divide X by 0");
			x = 1;
		}

		if(y == 0) {
			trace("Cannot divide Y by 0");
			y = 1;
		}
		
		this.x = Util.fint(this.x / x);
				
		if(y == null) 
			this.y = Util.fint(this.y / x);
		else
			this.y = Util.fint(this.y / y);

		return this;
	}

	public function hashCode():Int {
		return this.x * 1024 + this.y;
	}

	public function toString():String {
		return "( " + this.x + " , " + this.y + " )";
	}
	// Makes an array of Point2D objects from a flat array of x + y values
	public static function makeArray(array:Array<Int>): Array<Point>
	{
		var result = new Array<Point>();
		while(array.length > 0)
		{
			var v1 = array.shift();
			var v2 = array.shift();
			if(v2 == null)
				throw "Unbalanced set of x/y pairs passed to makeArray";
			result.push(new Point(v1, v2));
		}

		return result;
	}
}