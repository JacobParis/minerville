package components;

class Expiry {
    public var remaining:Int;

    public function new(remaining:Int) {
        this.remaining = remaining;
    }
}

class Hardness {
    public var value:Int;

    public function new(hardness:Int) {
        this.value = hardness;
    }
}

class Health {
    public var value:Int;

    public function new(health:Int) {
        this.value = health;
    }
}

class Stimulus {
    public var strength:Float;

    public function new(amount:Float) {
        this.strength = 1;
    }

    public function increaseStrength(amount:Float) {
        this.strength += amount;
    }
}