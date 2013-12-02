package com.astroberries.core.screens.game.physics;

import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Interpolation;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.Body;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;

public class ParticleActor extends Actor {

    private final static Color PARTICLE_COLOR_FROM = new Color(66 / 255f, 110 / 255f, 44 / 255f, 1); //todo: get real color
    private final static Color PARTICLE_COLOR_TO = new Color(66 / 255f, 110 / 255f, 44 / 255f, 0); //todo: get real color
    private final static float particleSize = 1;
    private final Body body;

    public ParticleActor(Body body) {
        this.body = body;
        setColor(PARTICLE_COLOR_FROM);
        addAction(color(PARTICLE_COLOR_TO, PhysicsManager.EXPLODE_TIME_SEC, Interpolation.exp10));
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        if (body != null)  {
            if (body.getUserData() != null &&
                    !((GameUserData) body.getUserData()).isFlaggedForDelete) {
                game().shapeRenderer.identity();
                game().shapeRenderer.setColor(getColor());
                Vector2 position = body.getPosition();
                game().shapeRenderer.translate(position.x, position.y, 0);
                game().shapeRenderer.rotate(0, 0, -1, -body.getAngle() * MathUtils.radiansToDegrees);
                game().shapeRenderer.rect(-particleSize, -particleSize, particleSize * 2, particleSize * 2);
            } else {
                if (body.getUserData() != null) {
                    ((GameUserData) body.getUserData()).isFlaggedForDelete = true;
                }
                remove();
            }
        }
    }
}
