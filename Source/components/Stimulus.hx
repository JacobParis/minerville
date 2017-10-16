package components;

class Stimulus {
    public var strength:Float;

    public function new(amount:Float) {
        this.strength = 1;
    }

    public function increaseStrength(amount:Float) {
        this.strength += amount;
    }
}