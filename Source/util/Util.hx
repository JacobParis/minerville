package util;

/*
 * Some general purpose Haxe functions.
 * Notably includes integer versions of some standard float Math funcs.
 * TODO Split into separate Util classes by usage or first parameter (for mixins)
 */
class Util
{
	public static function shuffle<T>(arr:Array<T>): Void
	{
        var i:Int = arr.length, j:Int, t:T;
        while (--i > 0)
        {
                t = arr[i];
                arr[i] = arr[j = rnd(0, i-1)];
                arr[j] = t;
        }
	}

	public static function anyOneOf<T>(arr:Array<T>): T
	{
		if(arr == null || arr.length == 0)
			return null;
		return arr[rnd(0, arr.length - 1)];
	}

	public static function rnd(min:Int,max:Int):Int
	{
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}	

	public static function chance(chance:Float):Bool {
		return rnd(0, 100) < chance * 100;
	}
	
    public static function roundTo(value:Float, precision:Int): Float
    {
        var factor = Math.pow(10, precision);
        return Math.round(value*factor) / factor;
    }

	public static function fsign(v:Float): Int
	{
		if(v < 0.0)
			return -1;
		if(v > 0.0)
			return 1;
		return 0;
	}

	public static function sign(i:Int): Int
	{		
		if(i == 0)
			return 0;
		return i < 0 ? -1 : 1;
	}

	public static function min(a:Int, b:Int): Int
	{
		return (a < b ? a : b);
	}

	public static function max(a:Int, b:Int): Int
	{
		return (a > b ? a : b);
	}

    public static function clamp(x:Int, min:Int, max:Int):Int {
        if (x < min) return min;
        if (x > max) return max;
        return x;
    }

	public static function abs(num:Int): Int
	{
		return (num < 0 ? -num : num);
	}

	public static function int(num:Int):Int
	{
		return (num < 0 ? Math.ceil(num) : Math.floor(num));
	}
	
	public inline static function fint(v:Float):Int
	{
		return (v < 0.0 ? Math.ceil(v) : Math.floor(v));
	}
	
	public static function fceil(v:Float):Int
	{
		return (v > 0.0 ? Math.ceil(v) : Math.floor(v));
	}
	
    public static function diff(a:Int, b:Int): Int
    {
        return (a > b ? a - b : b - a);
    }

    public static function fdiff(a:Float, b:Float): Float
    {
        return (a > b ? a - b : b - a);
    }

    // Returns true if both numbers match withing tolerance decimal places.
    public static function matches(a:Float, b:Float, tolerance:Int = 0): Bool
    {
        return (roundTo(a, tolerance) == roundTo(b, tolerance));
    }

    public static function assert( cond : Bool, ?pos : haxe.PosInfos )
    {
      if(!cond)
          haxe.Log.trace("Assert in " + pos.className + "::" + pos.methodName, pos);
    }

    public static function isNumeric(str:String): Bool
    {
    	if(str == null)
    		return false;

    	return (~/^\d+$/).match(str);
    }

    public static function isAlpha(str:String): Bool
    {
    	if(str == null)
    		return false;
    		
    	return (~/^[A-Za-z]$/).match(str);
    }

    public static function isAlphaNumeric(str:String): Bool
    {
    	return isNumeric(str) || isAlpha(str);
    }

    // Same as String.split but empty strings result in an empty array
    public static function split(str:String, delim:String): Array<String>
    {
    	var arr = new Array<String>();
    	if(str == null || str.length == 0)
    		return arr;
    	return str.split(delim);
    }

    // Like Array.filter but returns an array of indeces to the array (keys), rather than the array values.
    // Also, the comparison func receives an array index, not an array value.
    public static function indexFilter<T>(arr:Array<T>, func:Int->Bool): Array<Int>
    {
    	var result = new Array<Int>();
    	for(i in 0...arr.length)
    	{
    		if(func(i))
    			result.push(i);
    	}
    	return result;
    }

    public static function find<T>(arr:Array<T>, obj:T): Int
    {
    	for(i in 0...arr.length)
    		if(arr[i] == obj)
    			return i;
    	return -1;
    }

    public static function contains<T>(arr:Array<T>, obj:T): Bool
    {
    	return (find(arr, obj) != -1);
    }

    public static function dumpEntity(entity:ash.core.Entity, depth:Int = 1, preventRecursion = true): String
    {
    	var result = entity.name + ":{\n";
    	var sep = "";
    	for(c in entity.getAll())
    	{
    		result += sep + dump(c, depth, preventRecursion);
    		sep = ",\n";
    	}
    	return result + "}";
    }

	public static function dump(o:Dynamic, depth:Int = 1, preventRecursion = true): String
	{
		var recursed = (preventRecursion == false ? null : new Array<Dynamic>());
		return internalDump(o, recursed, depth);
	}

	private static function internalDump(o:Dynamic, recursed:Array<Dynamic>, depth:Int): String
	{
		if (o == null)
			return "<NULL>";

		if(Std.is(o, Int) || Std.is(o, Float) || Std.is(o, Bool) || Std.is(o, String))
			return Std.string(o);

		if(recursed != null && Util.find(recursed, o) != -1)
		 	return "<RECURSION>";

		var clazz = Type.getClass(o);
		if(clazz == null)
			return "<" + Std.string(Type.typeof(o)) + ">";
		
		if(recursed != null)
			recursed.push(o);

		if(depth == 0)
			return "<MAXDEPTH>";

		var result = Type.getClassName(clazz) + ":{";
		var sep = "";

		for(f in Reflect.fields(o))
		{
			result += sep + f + ":" + internalDump(Reflect.field(o, f), recursed, depth - 1);
			sep = ", ";
		}
		return result + "}";
	}
}