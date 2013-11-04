package Sprites 
{	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.Math.*;
	
	
	//[Embed(source = "../assets/tree.png")]
	/**
	 * ...
	 * @author Bennett Cyphers
	 */
	public class Tree extends Sprite 
	{
		private var branches:Array;
		private var trunk:b2Body;
		
		private const trunk_width:Number = 1;
		private const trunk_height:Number = 7.5;
		private const branch_width:Number = .5;
		private const branch_length:Number = 2.5;
		
		public function Tree(world:b2World) 
		{
			// Vars used to create bodies
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			var fixtureDef:b2FixtureDef;
			var jd:b2RevoluteJointDef = new b2RevoluteJointDef();
			var starting_pos:b2Vec2 = new b2Vec2(5, 7);
			branches = new Array();
			
			// Add the sloth's body
			bodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_staticBody;
			bodyDef.position = starting_pos;
			
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(trunk_width, trunk_height);
			fixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.5;
			fixtureDef.restitution = 0;
			fixtureDef.filter.categoryBits = GameplayScreen.CATEGORY_TREE_TRUNK;
			fixtureDef.filter.maskBits = ~GameplayScreen.CATEGORY_SLOTH_ARMS;
			
			/*bodyDef.userData = new PhysBox(); 
			bodyDef.userData.width = rX * 2 * 30; 
			bodyDef.userData.height = rY * 2 * 30; */
			trunk = world.CreateBody(bodyDef);
			trunk.CreateFixture(fixtureDef);
			
			// Create branches
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(branch_length, branch_width);
			fixtureDef.shape = boxShape;
			fixtureDef.isSensor = true;
			fixtureDef.filter.categoryBits = GameplayScreen.CATEGORY_TREE_BRANCH;
			fixtureDef.filter.maskBits = ~(GameplayScreen.CATEGORY_SLOTH_ARMS + GameplayScreen.CATEGORY_SLOTH_BODY);
			
			// First lower
			bodyDef.position.x += branch_length + branch_width;
			
			branches[0] = world.CreateBody(bodyDef);
			branches[0].CreateFixture(fixtureDef);
			
			// Lower fork top
			bodyDef.position.x += (branch_length - branch_width * .4) * 2;
			bodyDef.position.y -= branch_width * 2;
			bodyDef.angle = -Math.asin(.4);
			
			branches[1] = world.CreateBody(bodyDef);
			branches[1].CreateFixture(fixtureDef);
			
			// Lower fork bottom
			bodyDef.position.y += branch_width * 4;
			bodyDef.angle = Math.asin(.4);
			
			branches[2] = world.CreateBody(bodyDef);
			branches[2].CreateFixture(fixtureDef);
			
			// Lower secondary top
			bodyDef.position.x += (branch_length - branch_width * .4) * 2;
			bodyDef.position.y -= branch_width * 6;
			bodyDef.angle = 0;
			
			branches[3] = world.CreateBody(bodyDef);
			branches[3].CreateFixture(fixtureDef);
		}
		
	}

}