package components;

import services.TaskService;
import util.Point;

class Worker {
    public var miningExperience:Float;
    public var carryExperience:Float;
    public var attackExperience:Float;

    public function new() {}

    /** A worker is likely to accept any task that surpasses its threshold. 
     *  A skilled miner will thus have a very low mining threshold **/
    public function mineThreshold():Float {
        return 1 / this.miningSpeed();
    }

    inline function miningSpeed():Float {
        return 1.0 + this.miningExperience;
    }

    public function carryThreshold():Float {
        return 1 / (walkingSpeed() + carryLimit());
    }

    inline function walkingSpeed():Float {
        return 1.0 + this.carryExperience;
    }
   
    inline function carryLimit():Float {
        return 1.0 + this.carryExperience;
    }

    public function attackThreshold():Float {
        return 1 / attackDamage();
    }
    inline function attackDamage():Float {
        return this.attackExperience;
    }

    public function estimateTaskLength(task:Task, currentLocation:Point):Float {
        var walkingTime = Point.distance(task.location(), currentLocation) / walkingSpeed();

        switch(task.action) {
            case MINE: {
                return task.difficulty / this.miningSpeed() + walkingTime;
            }
            case WALK: {
                return walkingTime;
            }
            case CARRY: {
                return Point.distance(new Point(10,10), task.location()) / walkingSpeed() + walkingTime;
            }
            case ATTACK: {
                return task.difficulty / attackDamage();
            }
        }
    }

    /**
     *  Train a skill. Should be called every time a task is completed
     *  @param skill - The skill to train
     */
    public function train(skill:Skills):Void {
        var x = 1.01;
        switch(skill) {
            case MINE: {
                buff(this.miningExperience, x, 3);
                debuff(this.carryExperience, x, 1);
            }
            case WALK: {}
            case CARRY: {
                buff(this.carryExperience, x, 4);
                debuff(this.miningExperience, x, 1);
            }
            case ATTACK: {
                buff(this.attackExperience, x, 4);
                debuff(this.miningExperience, x, 2);
                debuff(this.carryExperience, x, 2);
            }
        }
    }

    inline function buff(value:Float, amount:Float, times:Int):Float {
        return value * Math.pow(amount, times);
    }

    inline function debuff(value:Float, amount:Float, times:Int):Float {
        return value / Math.pow(amount, times);
    }
}

