package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.screens.game.bullet.BigBullet;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class DebugPathActor extends Actor {

    private final Vector2 aimEnd;
    private final Castle castle;
    private final StateName aiming;
    private final StateName bullet;
    private final float bulletV;
    private final World world;

    public DebugPathActor(Vector2 aimEnd, Castle castle, float bulletV, World world) {
        this.bulletV = bulletV;
        this.aimEnd = aimEnd;
        this.castle = castle;
        this.world = world;
        aiming = castle.getAiming();
        bullet = castle.getBullet();
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        if (game().state() == aiming || game().state() == bullet) {
            batch.end();

            game().shapeRenderer.setProjectionMatrix(batch.getProjectionMatrix());
            game().shapeRenderer.setTransformMatrix(batch.getTransformMatrix());

            float angle = MathUtils.atan2(aimEnd.y - castle.getCannon().y, aimEnd.x - castle.getCannon().x);

            float vX = bulletV * MathUtils.cos(angle);
            float vY = bulletV * MathUtils.sin(angle);
            if (castle.getWeaponVariant() == 1) {
                vX *= BigBullet.VELOCITY_FACTOR;
                vY *= BigBullet.VELOCITY_FACTOR;
            }
            float aX = world.getGravity().x;
            float aY = world.getGravity().y;

            game().shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
            game().shapeRenderer.setColor(new Color(1, 0, 0, 0));
            float t = 0;
            while(t < 20) {
                float xTmp = castle.getCannon().x + vX * t + aX * t * t / 2;
                float yTmp = castle.getCannon().y + vY * t + aY * t * t / 2;
                t = t + 0.05f;
                game().shapeRenderer.rect(xTmp, yTmp, 1, 1);
            }
            game().shapeRenderer.end();

            batch.begin();
        }
    }
}
