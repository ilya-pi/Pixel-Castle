package com.astroberries.core.screens.mainmenu;

import com.astroberries.core.screens.mainmenu.sub.GameTypeSubScreen;
import com.astroberries.core.screens.mainmenu.sub.MainMenuSubScreen;
import com.astroberries.core.screens.mainmenu.sub.SettingsSubScreen;
import com.astroberries.core.screens.mainmenu.sub.levels.SelectLevelSubScreen;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Table;

import java.util.HashMap;
import java.util.Map;

import static com.astroberries.core.CastleGame.game;

public class MainScreen implements Screen {

    private final Stage stage;

    public static enum Type {
        GAME_TYPE_SELECT, SELECT_LEVEL, MAIN_MENU, SETTINGS
    }

    private final Map<Type, Actor> subscreens = new HashMap<>();
    private Type current;

    public MainScreen() {
        stage = new Stage(Gdx.graphics.getWidth(), Gdx.graphics.getHeight(), false, game().fixedBatch);
        Gdx.input.setInputProcessor(stage);
        subscreens.put(Type.MAIN_MENU, new MainMenuSubScreen());
        subscreens.put(Type.GAME_TYPE_SELECT, new GameTypeSubScreen());
        subscreens.put(Type.SELECT_LEVEL, new SelectLevelSubScreen());
        subscreens.put(Type.SETTINGS, new SettingsSubScreen());

        Texture texture = new Texture(Gdx.files.internal("main/castle_splash.png"));
        float aspectRatio = texture.getWidth() / (float) texture.getHeight();
        float resizedWidth = Gdx.graphics.getHeight() * aspectRatio;
        stage.addActor(new MenuBackgroundActor(texture, resizedWidth, Gdx.graphics.getHeight()));
        stage.addActor(subscreens.get(Type.MAIN_MENU));
        current = Type.MAIN_MENU;
    }

    @Override
    public void render(float delta) {
/*
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1); //todo: do we need it?
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
*/

        stage.act(delta);
        stage.draw();
//        Table.drawDebug(stage); //todo: remove
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

    public void setSubScreen(Type type) {
        stage.getRoot().removeActor(subscreens.get(current));
        stage.addActor(subscreens.get(type));
        current = type;
    }

}
