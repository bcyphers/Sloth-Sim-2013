package Sprites 
{	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Bennett Cyphers
	 */
	public class UI extends Sprite 
	{
		[Embed(source = "../../assets/tired_bar.png")]
		private static const tiredBar:Class;	
		
		[Embed(source = "../../assets/poop_bar.png")]
		private static const poopBar:Class;
		
		[Embed(source = "../../assets/hungry_bar.png")]
		private static const hungryBar:Class;
		
		[Embed(source = "../../assets/bar_outline.png")]
		private static const barShell:Class;
			
		private var tiredSprite:Sprite;
		private var hungrySprite:Sprite;
		private var poopSprite:Sprite;
		private var barShells:Sprite;
		
		static var FULL_BAR_WIDTH:Number = 3 * GameplayScreen.PHYSICS_SCALE;
		
		private var time:int = getTimer();
		private var sloth:Sloth;
		
		public function UI(sloth:Sloth) 
		{
			super();
			
			this.sloth = sloth;
			
			addEventListener(Event.ADDED_TO_STAGE, Init);
			addEventListener(Event.ENTER_FRAME, Update);
		}
		
		public function Init(e:Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			
			var startX:Number = -stage.stageWidth / 2;
			var startY:Number = -stage.stageHeight / 2;
			
			barShells = new Sprite();
			
			var tiredImg:Bitmap = new tiredBar();
			tiredSprite = new Sprite();
			tiredSprite.addChild(tiredImg);
			tiredSprite.width = FULL_BAR_WIDTH;
			tiredSprite.height = FULL_BAR_WIDTH / 3;
			tiredSprite.x = startX + tiredSprite.height / 2;
			tiredSprite.y = startY + tiredSprite.height / 2;
			addChild(tiredSprite);
			
			var tiredShell:Bitmap = new barShell();
			tiredShell.width = FULL_BAR_WIDTH;
			tiredShell.height = FULL_BAR_WIDTH / 3;
			tiredShell.x = startX + tiredShell.height / 2;
			tiredShell.y = startY + tiredShell.height / 2;
			barShells.addChild(tiredShell);
			
			var hungryImg:Bitmap = new hungryBar();
			hungrySprite = new Sprite();
			hungrySprite.addChild(hungryImg);
			hungrySprite.width = FULL_BAR_WIDTH;
			hungrySprite.height = FULL_BAR_WIDTH / 3;
			hungrySprite.x = -hungrySprite.width / 2;
			hungrySprite.y = startY + hungrySprite.height / 2;
			addChild(hungrySprite);

			var hungryShell:Bitmap = new barShell();
			hungryShell.width = FULL_BAR_WIDTH;
			hungryShell.height = FULL_BAR_WIDTH / 3;
			hungryShell.x = -hungryShell.width / 2;
			hungryShell.y = startY + hungryShell.height / 2;
			barShells.addChild(hungryShell);
		
			var poopImg:Bitmap = new poopBar();
			poopSprite = new Sprite();
			poopSprite.addChild(poopImg);
			poopSprite.width = FULL_BAR_WIDTH;
			poopSprite.height = FULL_BAR_WIDTH / 3;
			poopSprite.x = -startX - poopSprite.width - poopSprite.height / 2;
			poopSprite.y = startY + poopSprite.height / 2;
			addChild(poopSprite);
			
			var poopShell:Bitmap = new barShell();
			poopShell.width = FULL_BAR_WIDTH;
			poopShell.height = FULL_BAR_WIDTH / 3;
			poopShell.x = -startX - poopShell.width - poopShell.height / 2;
			poopShell.y = startY + poopShell.height / 2;
			barShells.addChild(poopShell);
			addChild(barShells);
		}
		
		public function Update(e:Event) : void
		{
			// Get delta time
			var elapsed:Number = (getTimer() - time) / 1000;
			time = getTimer();
			
			tiredSprite.width = FULL_BAR_WIDTH * sloth.Tired / 1000.0;
			hungrySprite.width = FULL_BAR_WIDTH * sloth.Hungry / 1000.0;
			poopSprite.width = FULL_BAR_WIDTH * sloth.Poop / 1000.0;
		}
		
	}

}