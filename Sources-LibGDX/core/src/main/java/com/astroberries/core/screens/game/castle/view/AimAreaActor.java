package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.utils.DragListener;

import static com.astroberries.core.CastleGame.game;

public class AimAreaActor extends Actor {

    private static final Color AIM_BUTTON_COLOR = new Color(0, 0, 1, 0.1f);

    private final Vector2 aimEnd = new Vector2();
    private final float size;
    private final StateName player;
    private final StateName aiming;
    private final StateName bullet;

    public AimAreaActor(final Castle castle) {
        size = castle.getBiggestSide();
        player = castle.getPlayer();
        aiming = castle.getAiming();
        bullet = castle.getBullet();
        setBounds(0, 0, size, size);
        addListener(new DragListener() {
            @Override
            public void dragStart(InputEvent event, float x, float y, int pointer) {
                if (game().state() == player) {
                    game().getStateMachine().transitionTo(aiming);
                    aimEnd.x = x;
                    aimEnd.y = y;
                }
            }
            @Override
            public void drag(InputEvent event, float x, float y, int pointer) {
                if (game().state() == aiming) {
                    aimEnd.x = x;
                    aimEnd.y = y;
                }
            }
            @Override
            public void dragStop(InputEvent event, float x, float y, int pointer) {
                if (game().state() == aiming) {
                    aimEnd.x = x;
                    aimEnd.y = y;
                    float angle = MathUtils.atan2(y - castle.getCannon().y, x - castle.getCannon().x);
                    castle.setAngle(angle);
                    game().getStateMachine().transitionTo(bullet);
                }
            }
        });
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        if (game().state() == player) {
            batch.end();

            Gdx.gl.glEnable(GL10.GL_BLEND);
            Gdx.gl.glBlendFunc(GL10.GL_SRC_ALPHA, GL10.GL_ONE_MINUS_SRC_ALPHA);
            game().shapeRenderer.setProjectionMatrix(batch.getProjectionMatrix());
            game().shapeRenderer.setTransformMatrix(batch.getTransformMatrix());
            game().shapeRenderer.setColor(AIM_BUTTON_COLOR);

            game().shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
            game().shapeRenderer.rect(getX(), getY(), size, size);
            game().shapeRenderer.end();
            Gdx.gl.glDisable(GL10.GL_BLEND);

            batch.begin();
        }
    }

    public Vector2 getAimEnd() {
        return aimEnd;
    }
}
