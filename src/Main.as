package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import General.Input;

	
	[SWF(width="640", height="480", frameRate="30", backgroundColor="#FFFFFF")]
	/**
	 * ...
	 * @author Bennett Cyphers
	 */
	public class Main extends Sprite 
	{
		private var gameScreen:GameplayScreen;
		private var input:Input;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, update);
			
			gameScreen = new GameplayScreen();
			gameScreen.name = "game";
			addChild(gameScreen);
			
			input = new Input(gameScreen);
		}
		
		private function update(e:Event):void 
		{
			// Update input
			Input.update();
		}
		
	}
	
}