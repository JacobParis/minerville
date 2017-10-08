package util;

typedef EasingFunction = Float->Float->Float->Float->Float->Float;

class Easing
{
	// simple linear tweening - no easing:Float, no acceleration
	public static function linear(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		return delta * time / duration + startValue;
	}
			
	// quadratic easing in - accelerating from zero velocity
	public static function easeInQuad(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		return delta * time * time + startValue;
	}
			
	// quadratic easing out - decelerating to zero velocity
	public static function easeOutQuad(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		return - delta * time * (time - 2) + startValue;
	}

	// quadratic easing in/out - acceleration until halfway:Float, then deceleration
	public static function easeInOutQuad(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration / 2;
		if(time < 1) return delta / 2 * time * time + startValue;
		time --;
		return - delta / 2 * (time * (time - 2) - 1) + startValue;
	}

	// cubic easing in - accelerating from zero velocity
	public static function easeInCubic(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		return delta * Math.pow(time, 3) + startValue;
	}

	// cubic easing out - decelerating to zero velocity
	public static function easeOutCubic(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		time --;
		return delta * (Math.pow(time, 3) + 1) + startValue;
	}

	// cubic easing in/out - acceleration until halfway:Float, then deceleration
	public static function easeInOutCubic(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration / 2;
		if(time < 1) return delta / 2 * Math.pow(time, 3) + startValue;
		time -= 2;
		return delta / 2 * (Math.pow(time, 3) + 2) + startValue;
	}

	// quartic easing in - accelerating from zero velocity
	public static function easeInQuart(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		return delta * Math.pow(time, 4) + startValue;
	}

	// quartic easing out - decelerating to zero velocity
	public static function easeOutQuart(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		time --;
		return - delta * (Math.pow(time, 4) - 1) + startValue;
	}

	// quartic easing in/out - acceleration until halfway:Float, then deceleration
	public static function easeInOutQuart(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration / 2;
		if(time < 1) return delta / 2 * Math.pow(time, 4) + startValue;
		time -= 2;
		return - delta / 2 * (Math.pow(time, 4) - 2) + startValue;
	}

	// quintic easing in - accelerating from zero velocity
	public static function easeInQuint(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		return delta * Math.pow(time, 5) + startValue;
	}

	// quintic easing out - decelerating to zero velocity
	public static function easeOutQuint(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		time --;
		return delta * (Math.pow(time, 5) + 1) + startValue;
	}

	// quintic easing in/out - acceleration until halfway:Float, then deceleration
	public static function easeInOutQuint(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration / 2;
		if(time < 1) return delta / 2 * Math.pow(time, 5) + startValue;
		time -= 2;
		return delta / 2 * (Math.pow(time, 5) + 2) + startValue;
	}

	// sinusoidal easing in - accelerating from zero velocity
	public static function easeInSine(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		return - delta * Math.cos(time / duration * (Math.PI / 2)) + delta + startValue;
	}	

	// sinusoidal easing out - decelerating to zero velocity
	public static function easeOutSine(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		return delta * Math.sin(time / duration * (Math.PI / 2)) + startValue;
	}		

	// sinusoidal easing in/out - accelerating until halfway:Float, then decelerating
	public static function easeInOutSine(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		return - delta / 2 * (Math.cos(Math.PI * time / delta) - 1) + startValue;
	}		

	// exponential easing in - accelerating from zero velocity
	public static function easeInExpo(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		return delta * Math.pow(2, 10 * (time / duration - 1) ) + startValue;
	}

	// exponential easing out - decelerating to zero velocity
	public static function easeOutExpo(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		return delta * (-Math.pow(2, - 10 * time / duration ) + 1 ) + startValue;
	}		

	// exponential easing in/out - accelerating until halfway:Float, then decelerating
	public static function easeInOutExpo(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration / 2;
		if(time < 1) return delta / 2 * Math.pow(2, 10 * (time - 1) ) + startValue;
		time --;
		return delta / 2 * (-Math.pow(2, - 10 * time) + 2 ) + startValue;
	}

	// circular easing in - accelerating from zero velocity
	public static function easeInCirc(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		return - delta * (Math.sqrt(1 - time * time) - 1) + startValue;
	}

	// circular easing out - decelerating to zero velocity
	public static function easeOutCirc(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration;
		time --;
		return delta * Math.sqrt(1 - time * time) + startValue;
	}			

	// circular easing in/out - acceleration until halfway:Float, then deceleration
	public static function easeInOutCirc(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		time /= duration / 2;
		if(time < 1) return - delta / 2 * (Math.sqrt(1 - time * time) - 1) + startValue;
		time -= 2;
		return delta / 2 * (Math.sqrt(1 - time * time) + 1) + startValue;
	}	 

	// back easing in - back up on source
	// o=1.70158 for a 10% bounce
	public static function easeInBack(time:Float, startValue:Float, delta:Float, duration:Float, o:Float): Float
	{
		return delta * (time /= delta) * time * ((o + 1) * time - o) + startValue;
	}
	 
	// back easing out - overshoot target
	// o=1.70158 for a 10% bounce
	public static function easeOutBack(time:Float, startValue:Float, delta:Float, duration:Float, o:Float): Float
	{
		return delta * ((time = time / delta-1) * time * ((o+1) * time + o) + 1) + startValue;
	}
	 
	// back easing in/out - back up on source then overshoot target
	// o=1.70158 for a 10% bounce
	public static function easeInOutBack(time:Float, startValue:Float, delta:Float, duration:Float, o:Float): Float
	{
		if ((time /=duration / 2) < 1) return delta / 2 * (time * time * (((o *= (1.525)) + 1) * time - o)) + startValue;
		return delta / 2 * ((time -= 2) * time * (((o *= (1.525)) + 1) * time + o) + 2) + startValue;
	}

	// bounce easing in
	public static function easeInBounce(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		return delta - easeOutBounce (duration - time, 0, delta, delta) + startValue;
	}
	 
	// bounce easing out
	public static function easeOutBounce(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		if ((time /= delta) < (1 / 2.75))
			return delta * (7.5625 * time * time) + startValue;
		else if (time < (2 / 2.75))
			return delta * (7.5625 * (time -= (1.5 / 2.75)) * time + .75) + startValue;
		else if (time < (2.5 / 2.75))
			return delta * (7.5625 * (time -= (2.25 / 2.75)) * time + .9375) + startValue;
		return delta * (7.5625 * (time -= (2.625 / 2.75)) * time + .984375) + startValue;
	}
	 
	// bounce easing in/out
	public static function easeInOutBounce(time:Float, startValue:Float, delta:Float, duration:Float, ?o:Float): Float
	{
		if (time < duration / 2) return easeInBounce (time * 2, 0, delta, delta) * .5 + startValue;
		return easeOutBounce(time * 2 - duration, 0, delta, delta) * .5 + delta * .5 + startValue;
	}
}
