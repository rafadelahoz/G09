package;

class Enemy extends Entity
{
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
	
		makeGraphic(16, 16, 0xFF200588);
	}
	
	public function init(variation : Int)
	{
	}
	
	public function onCollisionWithPlayer(player : Player)
	{
		// delegating...
	}
}