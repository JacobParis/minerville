package components.tocks;

class BlockTock extends Tock {

    public var health:Int;

    public function new(health:Int) {
        this.health = health;
        super();
    }
}