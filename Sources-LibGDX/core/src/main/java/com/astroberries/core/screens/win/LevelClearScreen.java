package com.astroberries.core.screens.win;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Table;

import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;

public class LevelClearScreen implements Screen {

    private final Stage stage;

    public LevelClearScreen() {
        stage = new Stage();
        Gdx.input.setInputProcessor(stage);
        Table table = new ButtonsTable();
        table.debug();
        StarsActor bigStar = new StarsActor(table.getPadBottom(), new Texture(Gdx.files.internal("win/big_star.png")));
        StarsActor smallStar = new StarsActor(table.getPadBottom(), new Texture(Gdx.files.internal("win/small_star.png")));

        stage.addActor(bigStar);
        stage.addActor(smallStar);
        stage.addActor(table);

        bigStar.addAction(forever(rotateBy(360, 120)));
        smallStar.addAction(forever(rotateBy(360, 100)));
    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1);
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
        //Table.drawDebug(stage);

        stage.act();
        stage.draw();
    }

    @Override
    public void resize(int width, int height) {
        //To change body of implemented methods use File | Settings | File Templates.
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
        //To change body of implemented methods use File | Settings | File Templates.
    }
}
