package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class AimActor extends Actor {

    private final Vector2 cannon;
    private final StateName aiming;
    private final Vector2 aimEnd;

    public AimActor(Castle castle, Vector2 aimEnd) {
        this.cannon = castle.getCannon();
        this.aiming = castle.getAiming();
        this.aimEnd = aimEnd;
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        if (game().state() == aiming) {
            batch.end();

            game().shapeRenderer.setProjectionMatrix(batch.getProjectionMatrix());
            game().shapeRenderer.setTransformMatrix(batch.getTransformMatrix());

            game().shapeRenderer.begin(ShapeRenderer.ShapeType.Line);
            game().shapeRenderer.line(cannon.x, cannon.y, aimEnd.x, aimEnd.y, Color.BLACK, Color.BLACK);
            game().shapeRenderer.end();

            batch.begin();
        }
    }
}
