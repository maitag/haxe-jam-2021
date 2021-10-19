package core;

import core.Data.ElementKey;
import core.Wave.WaveStats;
import echo.Body;
import lime.math.Vector2;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import peote.view.Color;

using ob.pear.Delay.DelayExtensions;

class Player {
	public var lord(default, null):ShapePiece;

	var isFlippedX:Bool;
	var pear:Pear;
	var wave:Wave;
	var isWaveInProgress:Bool = false;

	public function new(pear_:Pear, position:Vector2, flipX:Bool) {
		pear = pear_;
		isFlippedX = flipX;
		lord = pear.initShape(ElementKey.LORD, Color.CYAN, {
			x: position.x + 100,
			y: position.y,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				// radius: size * 0.5,
				width: 270,
				height: 666,
				solid: false,
			}
		}, isFlippedX);
		lord.cloth.z = -30;
		// lord.setFlippedX(isFlippedX);
	}

	public function startWave(waveConfig:WaveStats, opponentTargets:Array<Body>) {
		wave = new Wave(pear, waveConfig, opponentTargets);
		isWaveInProgress = true;
	}

	public function update(dt:Float) {
		if (isWaveInProgress) {
			wave.update(dt);
		}
		// launcher.update(dt);
	}
}