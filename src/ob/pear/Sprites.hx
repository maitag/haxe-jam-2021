package ob.pear;

import peote.view.Texture;
import lime.graphics.Image;
import echo.data.Types.ShapeType;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;

class ShapeElement implements Element
{
	@color public var color:Color;
	@custom @varying public var radius:Float;
	@custom @varying public var sides:Float = 3.0;
	@posX @set("Position") public var x:Float;
	@posY @set("Position") public var y:Float;
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
	@pivotX public var pivotX:Float;
	@pivotY public var pivotY:Float;
	@rotation public var rotation:Float;
	@zIndex // max 0x3FFFFFFF , min -0xC0000000 
	public var z:Int = 0;

	public static var buffers(default, null):Map<Int, Buffer<ShapeElement>> = [];
	public static var programs(default, null):Map<Int, Program> = [];
	static public function init(display:Display, shape:ShapeType, key:Int, image:Image=null) {
		buffers[key] = new Buffer<ShapeElement>(100);
		programs[key] = new Program(buffers[key]);


		var fragmentShader = switch(shape){
			case CIRCLE: ShapeShaders.CIRCLE;
			case POLYGON: ShapeShaders.TRIANGLE;
			case _: "";
		}

		if(image != null){
			var texture = new Texture(image.width, image.height);
			texture.setImage(image, 0);
			programs[key].setTexture(texture, '_$key');
			programs[key].injectIntoFragmentShader("
				vec4 compose (vec4 c, float sides)
				{
					return texture2D(uTexture0, vTexCoord);
				}
			");
			programs[key].setColorFormula('compose(color, sides)');
		}
		else if(fragmentShader.length > 0){
			programs[key].injectIntoFragmentShader(fragmentShader);
			programs[key].setColorFormula('compose(color, sides)');
		}
		
		programs[key].alphaEnabled = true;
		display.addProgram(programs[key]);
	}

	public function new(key:Int, positionX:Float, positionY:Float, width:Float, height:Float, color:Color, shape:ShapeType, numSides:Float=3) {
		this.x = positionX;
		this.y = positionY;
		this.w = Std.int(width);
		this.h = Std.int(height);
		this.radius = w / 2;
		pivotX = this.w / 2;
		pivotY = this.h / 2;
		this.color = color;
		this.sides = numSides;
		buffers[key].addElement(this);
		#if debug
			trace('new element pos [${this.x}, ${this.y}]  dim [${this.w} (${this.radius}) * ${this.h}] pivot [${this.pivotX}, ${this.pivotY}] colour [${this.color}] sides [${this.sides}]');
		#end
	}	
}


class ShapeShaders{
	public static var CIRCLE:String = "
		float circle(in vec2 st, in float radius){
			vec2 dist = st-vec2(0.5);
			return 1.-smoothstep(radius-(radius*0.01),
									radius+(radius*0.01),
									dot(dist,dist)*4.0);
		}

		vec4 compose (vec4 c, float sides)
		{
			float a = circle(vTexCoord, 1.0) == 1.0 ? c.a : 0.0;
			return vec4(c.rgb, a);
		}
	";

	public static var TRIANGLE:String = "
		#define PI 3.14159265359
		#define TWO_PI 6.28318530718

		vec4 compose (vec4 c, float sides)
		{
			// Remap the coord for
			vec2 coord = vTexCoord;
			coord.y = (1.0 - coord.y);

			// Remap the space to -1. to 1.
			vec2 st = coord * 2.0-1.0;

			// Angle and radius from the current pixel
			float r = TWO_PI/sides;
			float a = atan(st.x,st.y) + PI;

			// Shaping function that modulate the distance
			float d = cos(floor(.5+a/r)*r-a)*length(st);

			float A = 1.0-smoothstep(.5,.51,d) == 1.0 ? c.a : 0.0;
			return vec4(c.rgb, A);
		}
	";

}
