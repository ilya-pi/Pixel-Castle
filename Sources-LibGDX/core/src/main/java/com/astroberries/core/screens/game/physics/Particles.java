package com.astroberries.core.screens.game.physics;

import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.Body;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import static com.astroberries.core.CastleGame.game;

public class Particles {

    private final static Color PARTICLE_COLOR = new Color(1, 0, 0, 0); //todo: get real color
    private final static float particleSize = 1;
    private final List<Body> particles = new LinkedList<>();

    public void add(Body body) {
        particles.add(body);
    }

    public void render() {
        if (particles.size() != 0) {
            game().shapeRenderer.setColor(PARTICLE_COLOR);
            game().shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
            Iterator<Body> it = particles.iterator();
            while (it.hasNext()) {
                Body particleBody = it.next();
                if (particleBody != null)  {
                    if (particleBody.getUserData() != null &&
                        !((GameUserData) particleBody.getUserData()).isFlaggedForDelete) {
                        game().shapeRenderer.identity();
                        Vector2 position = particleBody.getPosition();
                        game().shapeRenderer.translate(position.x, position.y, 0);
                        game().shapeRenderer.rotate(0, 0, -1, -particleBody.getAngle() * MathUtils.radiansToDegrees);
                        game().shapeRenderer.rect(-particleSize, -particleSize, particleSize * 2, particleSize * 2);
                    } else {
                        if (particleBody.getUserData() != null) {
                            ((GameUserData) particleBody.getUserData()).isFlaggedForDelete = true;
                        }
                        it.remove();
                    }
                }
            }
            game().shapeRenderer.end();
        }
    }
}
