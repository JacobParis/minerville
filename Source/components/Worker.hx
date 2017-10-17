package components;

import services.TaskService;
import util.Point;
import util.Util;

class Worker {
    public var miningExperience:Float = 10;
    public var carryExperience:Float = 10;
    public var attackExperience:Float = 10;

    public var estimationTweak:Float;
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
        return 1.0;// + this.carryExperience;
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
                return 10 / this.miningSpeed() + walkingTime + this.estimationTweak;
            }
            case WALK: {
                return walkingTime + this.estimationTweak;
            }
            case CARRY: {
                return Point.distance(new Point(10,10), task.location()) / walkingSpeed() + walkingTime + this.estimationTweak;
            }
            case ATTACK: {
                return task.difficulty / attackDamage() + this.estimationTweak;
            }
        }
    }

    public function tweakEstimations(amount:Float) {
        this.estimationTweak += amount / Util.rnd(5, 10);
        //trace(this.estimationTweak);
    }
    /**
     *  Train a skill. Should be called every time a task is completed
     *  @param skill - The skill to train
     */
    public function train(skill:Skills, name:String = "unnamed"):Void {
        var x = 1.01;
        switch(skill) {
            case MINE: {
                this.miningExperience = buff(this.miningExperience, x, 3);
                this.carryExperience = debuff(this.carryExperience, x, 1);

                //trace("Mine Complete by " + name + "!");
                //trace("    Mining: " + (this.miningExperience));
                //trace("    Carry: " + (this.carryExperience));
            }
            case WALK: {}
            case CARRY: {
                this.carryExperience = buff(this.carryExperience, x, 3);
                this.miningExperience =  debuff(this.miningExperience, x, 1);
                //trace("Carry Complete by " + name + "!");
                //trace("    Mining: " + (this.miningExperience));
                //trace("    Carry: " + (this.carryExperience ));
            }
            case ATTACK: {
                this.attackExperience = buff(this.attackExperience, x, 4);
                this.miningExperience = debuff(this.miningExperience, x, 2);
                this.carryExperience = debuff(this.carryExperience, x, 2);
            }
        }

        //trace("Experience: {");
        //trace("    Mining: " + this.miningExperience);
        //trace("    Carry: " + this.carryExperience);
        //trace("}");
    }

    /**
     *  Train a skill. Should be called every time a task is completed
     *  @param skill - The skill to train
     */
    public function detrain(skill:Skills, name:String = "unnamed"):Void {
        var x = 1.01;
        switch(skill) {
            case MINE: {
            }
            case WALK: {}
            case CARRY: {
            }
            case ATTACK: {
            }
        }

        //trace("Experience: {");
        //trace("    Mining: " + this.miningExperience);
        //trace("    Carry: " + this.carryExperience);
        //trace("}");
    }

    inline function buff(value:Float, amount:Float, times:Int):Float {
        return value * Math.pow(amount, times);
    }

    inline function debuff(value:Float, amount:Float, times:Int):Float {
        return value / Math.pow(amount, times);
    }
}

