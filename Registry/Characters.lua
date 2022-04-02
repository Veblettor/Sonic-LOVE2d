Characters = 
{
	
	{
	
		Name = "Sonic";
	
		Acceleration = 0.046875;
		Deceleration = 0.5;
		Friction = 0.046875;
		TopSpeed = 6;
	
	
		SlopeWalkFactor = 0.125;
		SlopeRollUp = 0.078125;
		SlopeRollDown = 0.3125;
		WallStickTolerance = 2.5;
		
		AirAcceleration = 0.09375;
		JumpPower = 6.5;
		Gravity = 0.21875;
	
		Animations = 
		{
		
			Idle = 
			{
				SpriteSheet = love.graphics.newImage("Assets/Sprites/Characters/Sonic/Idle.png");
				FrameCount = 1;
				FrameWidth = 30;
				FrameHeight = 37;
				FrameDelay = 1;
			};
		
			Walking = 
			{
				SpriteSheet = love.graphics.newImage("Assets/Sprites/Characters/Sonic/Walking.png");
				FrameCount = 6;
				FrameWidth = 37;
				FrameHeight = 39;
			
			};
			
			Running = 
			{
				SpriteSheet = love.graphics.newImage("Assets/Sprites/Characters/Sonic/Running.png");
				FrameCount = 4;
				FrameWidth = 32;
				FrameHeight = 36;
			};
			
			Rolling = 
			{
				SpriteSheet = love.graphics.newImage("Assets/Sprites/Characters/Sonic/Roll.png");
				FrameWidth = 30;
				FrameHeight = 30;
				FrameCount = 5;
				
			};
		};
	
	}
}

return Characters