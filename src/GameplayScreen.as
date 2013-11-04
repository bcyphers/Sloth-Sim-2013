package  
{
	import flash.display.*;
	import flash.events.Event;
	import flash.utils.getTimer;
	import Sprites.*;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import General.Input;
	
	/**
	 * ...
	 * @author Bennett Cyphers
	 */
	public class GameplayScreen extends Sprite 
	{
		public static const CATEGORY_BOUNDS:Number = 1;
		public static const CATEGORY_SLOTH_BODY:Number = 2;
		public static const CATEGORY_SLOTH_ARMS:Number = 4;
		public static const CATEGORY_SLOTH_CLAWS:Number = 8;
		public static const CATEGORY_TREE_BRANCH:Number = 16;
		public static const CATEGORY_TREE_TRUNK:Number = 32;
		
		public static const PHYSICS_SCALE:Number = 30;
		
		private var time:Number = getTimer();
		
		public var world:b2World;
		public var velocityIterations:int = 10;
		public var positionIterations:int = 10;
		public var bomb:b2Body;
		public var physScale:Number = 30;
		
		// world mouse position
		public var mouseJoint:b2MouseJoint;
		static public var mouseXWorldPhys:Number;
		static public var mouseYWorldPhys:Number;
		static public var mouseXWorld:Number;
		static public var mouseYWorld:Number;
		
		private var sloth:Sloth;
		private var tree:Tree;
		private var ui:UI;
		
		public function GameplayScreen() 
		{
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, Update);
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		private function Init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			world = new b2World(gravity, doSleep);
			
			// set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			dbgDraw.SetSprite(this);
			dbgDraw.SetDrawScale(physScale);
			dbgDraw.SetFillAlpha(0.3);
			dbgDraw.SetLineThickness(1.0);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(dbgDraw);
			
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			
			// Add ground body
			bodyDef = new b2BodyDef();
			
			bodyDef.position.Set(10, 15);
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(30, 3);
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.3;
			fixtureDef.density = 0; // static bodies require zero density
			fixtureDef.filter.categoryBits = CATEGORY_BOUNDS;
			fixtureDef.filter.maskBits = ~CATEGORY_BOUNDS;
			
			body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			sloth = new Sloth(world);
			addChild(sloth);
			ui = new UI(sloth);
			addChild(ui);
			tree = new Tree(world);
		}
		
		public function Update(e:Event):void {
			// Get delta time
			var elapsed:Number = (getTimer() - time) / 1000;
			time = getTimer();
			
			trace("entering update loop. Elapsed = " + elapsed);
			
			if (sloth.Alive) {
				// Update mouse joint
				UpdateMouseWorld();
				MouseDrag(); 
			}
			
			var posX:Number = sloth.GetBody().GetWorldCenter().x * PHYSICS_SCALE;
            var posY:Number = sloth.GetBody().GetWorldCenter().y * PHYSICS_SCALE;
			
			ui.x = posX;
			ui.y = posY;
            
            this.x = stage.stageWidth / 2 - posX;
			this.y = stage.stageHeight / 2 - posY;
			
			// Update physics world
			world.Step(elapsed, velocityIterations, positionIterations);
			world.ClearForces();
			world.DrawDebugData();
			
			for (var bb:b2Body = world.GetBodyList(); bb; bb = bb.GetNext())
			{
				if ((bb as b2Body).GetUserData() is Sprite)
				{
					var sprite:Sprite = bb.GetUserData() as Sprite;
					sprite.x = bb.GetPosition().x * GameplayScreen.PHYSICS_SCALE;
					sprite.y = bb.GetPosition().y * GameplayScreen.PHYSICS_SCALE;
					sprite.rotation = bb.GetAngle() * (180 / Math.PI);
				}
			}
		}
		
		
		//======================
		// Update mouseWorld
		//======================
		public function UpdateMouseWorld():void{
			mouseXWorldPhys = (Input.mouseX)/physScale; 
			mouseYWorldPhys = (Input.mouseY)/physScale; 
			
			mouseXWorld = (Input.mouseX); 
			mouseYWorld = (Input.mouseY); 
		}
		
		
		//======================
		// Mouse Drag 
		//======================
		public function MouseDrag():void{
			// mouse press
			if (Input.mouseDown && !mouseJoint){
				
				var body:b2Body = GetBodyAtMouse(
					function (x) 
					{
						var fixture:b2Fixture = (x as b2Fixture);
						return fixture.GetFilterData().categoryBits == CATEGORY_SLOTH_CLAWS;
					} 
				);
				
				if (body)
				{
					if (body.GetUserData() != null) {
						world.DestroyJoint((body.GetUserData() as b2RevoluteJoint));
						body.SetUserData(null);
					}
					
					var md:b2MouseJointDef = new b2MouseJointDef();
					md.bodyA = world.GetGroundBody();
					md.bodyB = body;
					md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
					md.collideConnected = true;
					md.maxForce = 300.0 * body.GetMass();
					mouseJoint = world.CreateJoint(md) as b2MouseJoint;
					body.SetAwake(true);
				}
			}
			
			
			// mouse release
			if (!Input.mouseDown){
				if (mouseJoint)
				{
					// Only check for collisions with the tree
					var body:b2Body = GetBodyAtPoint(
						function (x) 
						{
							var fixture:b2Fixture = (x as b2Fixture);
							return (fixture.GetFilterData().categoryBits == CATEGORY_TREE_TRUNK ||
									fixture.GetFilterData().categoryBits == CATEGORY_TREE_BRANCH);
						},
						mouseJoint.GetBodyB().GetPosition()
					);
					
					// Create joint with claw and intersecting tree geometry
					if (body)
					{
						var jd:b2RevoluteJointDef = new b2RevoluteJointDef();
						jd.Initialize(body, mouseJoint.GetBodyB(), mouseJoint.GetBodyB().GetPosition());
						mouseJoint.GetBodyB().SetUserData(world.CreateJoint(jd));
						body.SetAwake(true);
					}
					
					world.DestroyJoint(mouseJoint);
					mouseJoint = null;
				}
			}
			
			
			// mouse move
			if (mouseJoint)
			{
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys - mouseJoint.GetBodyB().GetPosition().x, 
					mouseYWorldPhys - mouseJoint.GetBodyB().GetPosition().y);
				var length:Number = p2.Length();
				p2.Normalize();
				p2.x *= Math.min(length, 1);
				p2.y *= Math.min(length, 1);
				mouseJoint.SetTarget(new b2Vec2(mouseJoint.GetBodyB().GetPosition().x + p2.x,
					mouseJoint.GetBodyB().GetPosition().y + p2.y));
			}
		}
				
		
		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:b2Vec2 = new b2Vec2();
		public function GetBodyAtMouse(f:Function):b2Body {
			// Make a small box.			
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			return GetBodyAtPoint(f, mousePVec);
		}
		
		
		public function GetBodyAtPoint(f:Function, p:b2Vec2):b2Body {
			// Make a small box.			
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(p.x - 0.001, p.y - 0.001);
			aabb.upperBound.Set(p.x + 0.001, p.y + 0.001);
			var body:b2Body = null;
			var fixture:b2Fixture;
			
			// Query the world for overlapping shapes.
			function GetBodyCallback(fixture:b2Fixture):Boolean
			{
				var shape:b2Shape = fixture.GetShape();
				var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), p);
				if (inside && f(fixture))
				{
					body = fixture.GetBody();
					return false;
				}
				return true;
			}
			world.QueryAABB(GetBodyCallback, aabb);
			return body;
		}
	}
}