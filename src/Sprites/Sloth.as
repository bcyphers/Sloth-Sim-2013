package Sprites 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.Math.*;
	
	/**
	 * ...
	 * @author Bennett Cyphers
	 */
	public class Sloth extends Sprite 
	{
		[Embed(source = "../../assets/sloth_arm.png")]
		private static const armImg:Class;
		
		[Embed(source = "../../assets/sloth_body.png")]
		private static const bodyImg:Class;
		
		[Embed(source = "../../assets/poop.png")]
		private static const poopImg:Class;
		
		private var world:b2World;
		private var arms:Array;
		private var body:b2Body;
		private var pooplets:Array;
		public static var Claws:Array = new Array();
		
		public function GetBody() : b2Body {
			return body;
		}
		
		private const body_width:Number = 1.5;
		private const body_height:Number = .6;
		private const arm_length:Number = .75;
		private const arm_width:Number = .25;
		private const max_arm_vel:Number = 0.5;
		private const hunger_threshold = 1000;
		private const tired_threshold = 1000;
		private const poop_threshold = 1000;
		
		private var starting_pos:b2Vec2 = new b2Vec2(10, 10);
		private const poop_height = 9
		
		public var IsPooping = false;
		public var Hungry:Number = hunger_threshold / 3;
		public var Tired:Number  = 0;
		public var Poop:Number = poop_threshold / 2;
		public var Alive:Boolean = true;
		
		private var time:Number = getTimer();
		
		public function Sloth(world:b2World, position:b2Vec2 = null) 
		{
			this.world = world;
			this.starting_pos = position == null ? starting_pos : position;
			
			addEventListener(Event.ENTER_FRAME, Update);
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		private function Init(e:Event) : void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, Init);			
			
			// Vars used to create bodies
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			var fixtureDef:b2FixtureDef;
			var jd:b2RevoluteJointDef = new b2RevoluteJointDef();
			var armSprites:Array = new Array();
			arms = new Array();
			pooplets = new Array();
			
			// Add the sloth's body
			bodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position = starting_pos;
			bodyDef.linearDamping = .5;
			bodyDef.angularDamping = 1;
			
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(body_width, body_height);
			fixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.density = 1;
			fixtureDef.friction = 0;
			fixtureDef.restitution = 0;
			fixtureDef.filter.categoryBits = GameplayScreen.CATEGORY_SLOTH_BODY;
			//fixtureDef.filter.maskBits = ~GameplayScreen.CATEGORY_SLOTH_BODY;
			
			/*bodyDef.userData = new PhysBox(); 
			bodyDef.userData.width = rX * 2 * 30; 
			bodyDef.userData.height = rY * 2 * 30; */
			body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			// -----------------------------
			// ******* Create arms *********
			// -----------------------------
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(arm_width, arm_length);
			fixtureDef.shape = boxShape;
			fixtureDef.isSensor = false;
			fixtureDef.filter.categoryBits = GameplayScreen.CATEGORY_SLOTH_ARMS;
			fixtureDef.filter.maskBits = ~(GameplayScreen.CATEGORY_SLOTH_ARMS +
										GameplayScreen.CATEGORY_SLOTH_BODY + 
										GameplayScreen.CATEGORY_TREE_TRUNK);
			
			// Lower back
			bodyDef.position.x -= body_width / 2;
			bodyDef.position.y -= (arm_length - arm_width);
			arms[0] = world.CreateBody(bodyDef);
			arms[0].CreateFixture(fixtureDef);
			arms[6] = world.CreateBody(bodyDef);
			arms[6].CreateFixture(fixtureDef);
			
			// Upper back
			bodyDef.position.y -= (arm_length - arm_width/2) * 2;
			arms[1] = world.CreateBody(bodyDef);
			arms[1].CreateFixture(fixtureDef);
			arms[7] = world.CreateBody(bodyDef);
			arms[7].CreateFixture(fixtureDef);
			
			// Lower front
			bodyDef.position.x += body_width;
			bodyDef.position.y += (arm_length - arm_width/2) * 2;
			arms[3] = world.CreateBody(bodyDef);
			arms[3].CreateFixture(fixtureDef);
			arms[9] = world.CreateBody(bodyDef);
			arms[9].CreateFixture(fixtureDef);
			
			// Upper front
			bodyDef.position.y -= (arm_length - arm_width/2) * 2;
			arms[4] = world.CreateBody(bodyDef);
			arms[4].CreateFixture(fixtureDef);
			arms[10] = world.CreateBody(bodyDef);
			arms[10].CreateFixture(fixtureDef);
			
			// Back claws
			bodyDef.position.x -= body_width;
			bodyDef.position.y -= arm_length - arm_width;			
			
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(arm_width, arm_width);
			fixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.density = 1;
			fixtureDef.filter.categoryBits = GameplayScreen.CATEGORY_SLOTH_CLAWS;
			fixtureDef.isSensor = true;
			
			arms[2] = world.CreateBody(bodyDef);
			arms[2].CreateFixture(fixtureDef);
			arms[8] = world.CreateBody(bodyDef);
			arms[8].CreateFixture(fixtureDef);
			
			// Front claws
			bodyDef.position.x += body_width;
			arms[5] = world.CreateBody(bodyDef);
			arms[5].CreateFixture(fixtureDef);
			arms[11] = world.CreateBody(bodyDef);
			arms[11].CreateFixture(fixtureDef);
			
			// -----------------------------
			// ******** Add Sprites ********
			// -----------------------------
			
			var bodyImg:Bitmap = new bodyImg();
			var bodySprite:Sprite = new Sprite();
			bodySprite.addChild(bodyImg);
			bodyImg.width = body_width * 2.7 * GameplayScreen.PHYSICS_SCALE;
			bodyImg.height = body_height * 2.7 * GameplayScreen.PHYSICS_SCALE;
			bodyImg.x -= bodyImg.width / 2;
			bodyImg.y -= bodyImg.height / 2;
			body.SetUserData(bodySprite);
			parent.addChild(bodySprite);
			
			for (var i:Number = 0; i < arms.length; i++) {
				if (i % 3 == 2)
					continue;
				
				var armImg:Bitmap = new armImg();
				var armSprite:Sprite = new Sprite();
				armSprite.addChild(armImg);
				armImg.width = arm_width * 2.7 * GameplayScreen.PHYSICS_SCALE;
				armImg.height = arm_length * 2.2 * GameplayScreen.PHYSICS_SCALE;
				armImg.x -= armImg.width / 2;
				armImg.y -= armImg.height / 2;
				arms[i].SetUserData(armSprite);
				if (i < 6)
					parent.addChildAt(armSprite, 0);
				else
					parent.addChild(armSprite);
			}
			
			// -----------------------------
			// ****** Create joints ********
			// -----------------------------
			jd.enableLimit = false;
			//jd.motorSpeed = 0;
			//jd.maxMotorTorque = 100;
			
			// Back shoulder L
			jd.Initialize(body, arms[0], new b2Vec2(body.GetPosition().x - body_width / 2, body.GetPosition().y));
			world.CreateJoint(jd);
			// Back shoulder R
			jd.Initialize(body, arms[6], new b2Vec2(body.GetPosition().x - body_width / 2, body.GetPosition().y));
			world.CreateJoint(jd);
			// Front shoulder L
			jd.Initialize(body, arms[3], new b2Vec2(body.GetPosition().x + body_width / 2, body.GetPosition().y));
			world.CreateJoint(jd);
			// Front shoulder R
			jd.Initialize(body, arms[9], new b2Vec2(body.GetPosition().x + body_width / 2, body.GetPosition().y));
			world.CreateJoint(jd);
			
			jd.enableLimit = true;
			jd.lowerAngle = Math.PI * -3 / 4;
			jd.upperAngle = Math.PI * 3 / 4;
			
			// Back elbow L
			jd.Initialize(arms[0], arms[1], new b2Vec2(body.GetPosition().x - body_width / 2, 
				body.GetPosition().y - (arm_length - arm_width/2) * 2));
			world.CreateJoint(jd);
			// Back elbow R
			jd.Initialize(arms[6], arms[7], new b2Vec2(body.GetPosition().x - body_width / 2, 
				body.GetPosition().y - (arm_length - arm_width/2) * 2));
			world.CreateJoint(jd);
			// Front elbow L
			jd.Initialize(arms[3], arms[4], new b2Vec2(body.GetPosition().x + body_width / 2, 
				body.GetPosition().y - (arm_length - arm_width/2) * 2));
			world.CreateJoint(jd);
			// Front elbow R
			jd.Initialize(arms[9], arms[10], new b2Vec2(body.GetPosition().x + body_width / 2, 
				body.GetPosition().y - (arm_length - arm_width/2) * 2));
			world.CreateJoint(jd);
			
			jd.upperAngle = 0;
			jd.lowerAngle = 0; // Wrist joints are fixed
			
			// Back wrist L
			jd.Initialize(arms[1], arms[2], new b2Vec2(body.GetPosition().x - body_width / 2,
				body.GetPosition().y - arm_length * 3 + arm_width * 2));
			world.CreateJoint(jd);
			// Back wrist R
			jd.Initialize(arms[7], arms[8], new b2Vec2(body.GetPosition().x - body_width / 2,
				body.GetPosition().y - arm_length * 3 + arm_width * 2));
			world.CreateJoint(jd);
			// Front wrist L
			jd.Initialize(arms[4], arms[5], new b2Vec2(body.GetPosition().x + body_width / 2,
				body.GetPosition().y - arm_length * 3 + arm_width * 2));
			world.CreateJoint(jd);
			// Front wrist R
			jd.Initialize(arms[10], arms[11], new b2Vec2(body.GetPosition().x + body_width / 2,
				body.GetPosition().y - arm_length * 3 + arm_width * 2));
			world.CreateJoint(jd);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, doPoop);
		}
		
		// Begin the pooping process
		public function doPoop(ke:KeyboardEvent) : void
		{
			if (Poop < 10 || body.GetWorldCenter().y < poop_height)
				return
			var timer:Timer = new Timer(60, (int)(this.Poop / 10));
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, poopHandler);
			IsPooping = true;
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(): void {
				this.IsPooping = false;
			});
		}
		
		// Create a single pooplet, with a small amount of random velocity.
		public function poopHandler(e:Event) : void
		{
			Poop -= poop_threshold / 100;
			
			var poopPos:b2Vec2 = new b2Vec2(this.GetBody().GetWorldCenter().x - Math.cos(body.GetAngle()) * body_width,
											this.GetBody().GetWorldCenter().y - Math.sin(body.GetAngle()) * body_width);
			var poopAngle:Number = body.GetAngle() + Math.random() * 0.6 - 0.3;
			var poopVel:b2Vec2 = new b2Vec2(-Math.cos(poopAngle) * 10 * Math.random(), 
											-Math.sin(poopAngle) * 10 * Math.random());
			
			// Add the poop to the physics world
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position = poopPos;
			bodyDef.linearDamping = .5;
			bodyDef.angularDamping = 1;
			bodyDef.linearVelocity = poopVel;
			
			var circleShape:b2CircleShape = new b2CircleShape(0.2);
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = circleShape;
			fixtureDef.density = 1;
			fixtureDef.friction = 1;
			fixtureDef.restitution = 0;
			fixtureDef.filter.categoryBits = GameplayScreen.CATEGORY_TREE_TRUNK;
			fixtureDef.filter.maskBits = ~(GameplayScreen.CATEGORY_SLOTH_BODY);
			
			var poopImg:Bitmap = new poopImg();
			var poopSprite:Sprite = new Sprite();
			poopSprite.addChild(poopImg);
			poopImg.width = poopImg.height = 0.5 * GameplayScreen.PHYSICS_SCALE;
			poopImg.x -= poopImg.width / 2;
			poopImg.y -= poopImg.height / 2;
			poopSprite.x = poopPos.x * GameplayScreen.PHYSICS_SCALE;
			poopSprite.y = poopPos.y * GameplayScreen.PHYSICS_SCALE;
			parent.addChild(poopSprite);
			
			var poopBody:b2Body = world.CreateBody(bodyDef);
			var poopImpulse:b2Vec2 = new b2Vec2(-poopVel.x, -poopVel.y);
			body.ApplyImpulse(poopImpulse, poopPos);
			poopBody.CreateFixture(fixtureDef);
			poopBody.SetUserData(poopSprite);
			pooplets.push(poopBody);
			if (pooplets.length > 100) {
				var oldPoop:b2Body = pooplets.shift();
				parent.removeChild(oldPoop.GetUserData() as Sprite);
				world.DestroyBody(oldPoop);
			}
		}
		
		public function Update(e:Event) : void 
		{
			// Get delta time
			var elapsed:Number = (getTimer() - time) / 1000;
			time = getTimer();
			
			if (Alive) {
				Hungry += elapsed;
				Tired += elapsed;
				Poop += elapsed;
				
				if (Hungry > hunger_threshold || Tired > tired_threshold || Poop > poop_threshold)
					Alive = false;
			}
		}
		
		public function ApplyDrag(bb:b2Body) {
			if (bb.GetFixtureList() != null && bb.GetFixtureList().GetFilterData().categoryBits == GameplayScreen.CATEGORY_SLOTH_CLAWS) 
			{
				bb.SetLinearVelocityFunction(
					function (vel) {
						var relVelX:Number = vel.x - body.GetLinearVelocity().x;
						var relVelY:Number = vel.y - body.GetLinearVelocity().y;
						var relVel:Number = Math.sqrt(vel.x ^ 2 + vel.y ^ 2);
						if (relVel > max_arm_vel) {
							return new b2Vec2(
								vel.x * (max_arm_vel / relVel),// + body.GetLinearVelocity().x,
								vel.y * (max_arm_vel / relVel));// + body.GetLinearVelocity().y);
						} else {
							return vel;
						}
					}
				);
			}
		}
	}
}