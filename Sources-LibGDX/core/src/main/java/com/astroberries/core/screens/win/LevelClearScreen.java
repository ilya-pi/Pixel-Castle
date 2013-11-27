package com.astroberries.core.screens.win;

import com.astroberries.core.screens.common.BlendBackgroundActor;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Table;

import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;

public class LevelClearScreen implements Screen {

    private final Stage stage;
    private final Texture smallStarTexture;
    private final Texture bigStarTexture;

    public LevelClearScreen(TextureRegion screenshot) {
        stage = new Stage();
        Gdx.input.setInputProcessor(stage);
        Table table = new ButtonsTable();
        table.debug();

        smallStarTexture = new Texture(Gdx.files.internal("win/small_star.png"));
        bigStarTexture = new Texture(Gdx.files.internal("win/big_star.png"));
        float x = Gdx.graphics.getWidth() / 2f;
        float y = Gdx.graphics.getHeight() / 2f + table.getPadBottom();

        StarsActor bigStar = new StarsActor(smallStarTexture, x, y);
        StarsActor smallStar = new StarsActor(bigStarTexture, x, y);

        stage.addActor(new BlendBackgroundActor(screenshot));
        stage.addActor(bigStar);
        stage.addActor(smallStar);
        stage.addActor(table);

        bigStar.addAction(forever(rotateBy(360, 120)));
        smallStar.addAction(forever(rotateBy(360, 100)));
    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1); //todo: do we need it?
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

        stage.act(delta);
        stage.draw();
        //Table.drawDebug(stage); //todo: remove
    }

    @Override
    public void resize(int width, int height) {
        stage.setViewport(width, height, false);
    }

    @Override
    public void show() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void hide() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void pause() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void resume() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void dispose() {
        stage.dispose();
        bigStarTexture.dispose();
        smallStarTexture.dispose();
    }
}
