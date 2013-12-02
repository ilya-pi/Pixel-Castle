package com.astroberries.core.screens.game.physics;

import com.astroberries.core.screens.game.camera.PixelCamera;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.physics.box2d.Body;
import com.badlogic.gdx.scenes.scene2d.Group;

import static com.astroberries.core.CastleGame.game;

public class Particles extends Group {

    public void add(Body body) {
        addActor(new ParticleActor(body));
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        batch.end();

        Gdx.gl.glEnable(GL10.GL_BLEND);
        Gdx.gl.glBlendFunc(GL10.GL_SRC_ALPHA, GL10.GL_ONE_MINUS_SRC_ALPHA);
        game().shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
        super.draw(batch, parentAlpha);
        game().shapeRenderer.end();
        Gdx.gl.glDisable(GL10.GL_BLEND);

        batch.begin();
    }
}
