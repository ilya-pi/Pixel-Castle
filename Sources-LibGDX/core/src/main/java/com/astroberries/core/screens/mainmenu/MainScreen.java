package com.astroberries.core.screens.mainmenu;

import com.astroberries.core.CastleGame;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;

public class MainScreen implements Screen {

    private final Skin skin = new Skin(Gdx.files.internal("uiskin.json"));
    private final Stage stage;

    /**
     * Running background image
     */
    private final Sprite bg;

    /**
     * Overlay with gradient
     */
    private final Sprite overlay;

    final private CastleGame game;

    /**
     * Top overlay color
     */
    private static float COLOR_A = new Color(236.0f / 255, 0.0f / 255, 140.0f / 255, 150.0f / 255).toFloatBits();
    /**
     * Bottom overlay color
     */
    private static float COLOR_B = new Color(255.0f / 255, 25.0f / 255, 170.0f / 255, 75.0f / 255).toFloatBits();

    private AbstractSubScreen subScreen;

    private static MainScreen instance;

    public static MainScreen geCreate(CastleGame game) {
        if (MainScreen.instance == null) {
            synchronized (MainScreen.class) {
                MainScreen.instance = new MainScreen(game);
            }
        }
        return MainScreen.instance;
    }

    private MainScreen(final CastleGame game) {
        this.game = game;

        this.stage = new Stage();
        Gdx.input.setInputProcessor(stage);

        Texture bgTexture = new Texture(Gdx.files.internal("main/castle_splash.png"));
        bgTexture.setWrap(Texture.TextureWrap.Repeat, Texture.TextureWrap.ClampToEdge);
        bg = new Sprite(bgTexture, 0, 0, bgTexture.getWidth(), bgTexture.getHeight());
        float scale = stage.getHeight() / bgTexture.getHeight();
        bg.setBounds(0, 0, bgTexture.getWidth() * scale, stage.getHeight());

        Pixmap pixmap = new Pixmap(1, 1, Pixmap.Format.RGBA8888);
        pixmap.setColor(Color.WHITE);
        pixmap.fill();
        overlay = new Sprite(new Texture(pixmap), 0, 0, bgTexture.getWidth(), bgTexture.getHeight());
        overlay.setBounds(0, 0, bgTexture.getWidth() * scale, stage.getHeight());

        this.subScreen = new MainMenuSubScreen(skin, game);
//        this.subScreen.getTable().debug();

        stage.addActor(this.subScreen.getTable());
    }

    private float scrollTimer = 0.0f;

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1);
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

        scrollTimer += Gdx.graphics.getDeltaTime() / 20;
        if (scrollTimer > 1.0f) {
            scrollTimer = 0.0f;
        }
        bg.setU(scrollTimer);
        bg.setU2(scrollTimer + 1);
        game.spriteBatch.begin();
        bg.draw(game.spriteBatch);
        float x = 0, y = 0, width = overlay.getWidth(), height = overlay.getHeight();
        game.spriteBatch.draw(overlay.getTexture(), new float[]{
                x, y, COLOR_B, overlay.getU(), overlay.getV2(),
                x, y + height, COLOR_A, overlay.getU(), overlay.getV(),
                x + width, y + height, COLOR_A, overlay.getU2(), overlay.getV(),
                x + width, y, COLOR_B, overlay.getU2(), overlay.getV2()}, 0, 20);
        game.spriteBatch.end();

        stage.act(Math.min(Gdx.graphics.getDeltaTime(), 1 / 30f));
        stage.draw();
//        Table.drawDebug(stage);
    }

    @Override
    public void resize(int width, int height) {
        this.stage.setViewport(width, height, false);
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
        this.stage.dispose();
        this.skin.dispose();
    }

}
