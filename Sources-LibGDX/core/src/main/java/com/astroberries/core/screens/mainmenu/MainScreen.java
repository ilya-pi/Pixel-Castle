package com.astroberries.core.screens.mainmenu;

import com.astroberries.core.CastleGame;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;
import com.badlogic.gdx.scenes.scene2d.ui.Table;

import static com.astroberries.core.CastleGame.game;

public class MainScreen implements Screen {

    private final Texture texture = new Texture(Gdx.files.internal("main/castle_splash.png"));

    private final Stage stage;

    public MainScreen() {
        stage = new Stage();
        Gdx.input.setInputProcessor(stage);
        MainMenuSubScreen subScreen = new MainMenuSubScreen(game().getSkin());
//        this.subScreen = new SelectLevelSubScreen(skin, game);
        subScreen.getTable().debug(); //todo remove
        float aspectRatio = texture.getWidth() / (float) texture.getHeight();
        float resizedWidth = Gdx.graphics.getHeight() * aspectRatio;
        stage.addActor(new MenuBackgroundActor(texture, resizedWidth, Gdx.graphics.getHeight()));
        stage.addActor(subScreen.getTable());


    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1);
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
    }

    @Override
    public void hide() {
    }

    @Override
    public void pause() {
    }

    @Override
    public void resume() {
    }

    @Override
    public void dispose() {
        stage.dispose();
    }

}
