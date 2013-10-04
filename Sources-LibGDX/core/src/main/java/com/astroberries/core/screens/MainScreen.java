package com.astroberries.core.screens;

import com.astroberries.core.CastleGame;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

public class MainScreen implements Screen {

    private final Skin skin;
    private final Stage stage;
    private final Sprite backSprite;

    final private CastleGame game;

    private float scrollTimer = 0.0f;

//    private final OrthographicCamera camera;

//    private final Texture background;
//    private ShapeRenderer shapeRenderer = new ShapeRenderer();

    final private MainScreen self;

    public MainScreen(final CastleGame game) {
        this.self = this;

        this.game = game;

        this.stage = new Stage();
        Gdx.input.setInputProcessor(stage);

        Texture backSpriteTexture = new Texture(Gdx.files.internal("main/castle_splash.png"));
        backSpriteTexture.setWrap(Texture.TextureWrap.Repeat, Texture.TextureWrap.Repeat);
        backSprite = new Sprite(backSpriteTexture, 0, 0, 64, 64);
        Gdx.app.log("fuck", "image " + backSpriteTexture.getWidth() + " " + backSpriteTexture.getHeight());
        Gdx.app.log("fuck", "view " + stage.getWidth() + " " + stage.getHeight());
        float backGroundRatio = backSpriteTexture.getWidth() / backSpriteTexture.getHeight();
        float scale = stage.getHeight() / backSpriteTexture.getHeight();


/*
        backSprite.setScale(yScale, yScale);
        backSprite.setSize(stage.getWidth(), stage.getHeight());
*/
        Gdx.app.log("fuck", "calc " + backSpriteTexture.getWidth() * scale + " " + stage.getHeight());
        backSprite.setBounds(0, 0, backSpriteTexture.getWidth() * scale, stage.getHeight());

        this.skin = new Skin();

        // Generate a 1x1 white texture and store it in the skin named "white".
        Pixmap pixmap = new Pixmap(1, 1, Pixmap.Format.RGBA8888);
        pixmap.setColor(Color.WHITE);
        pixmap.fill();
        skin.add("white", new Texture(pixmap));

        // Store the default libgdx font under the name "default".
        skin.add("default", new BitmapFont());

        // Configure a TextButtonStyle and name it "default". Skin resources are stored by type, so this doesn't overwrite the font.
        TextButton.TextButtonStyle textButtonStyle = new TextButton.TextButtonStyle();
        textButtonStyle.up = skin.newDrawable("white", Color.DARK_GRAY);
        textButtonStyle.down = skin.newDrawable("white", Color.DARK_GRAY);
        textButtonStyle.checked = skin.newDrawable("white", Color.BLUE);
        textButtonStyle.over = skin.newDrawable("white", Color.LIGHT_GRAY);
        textButtonStyle.font = skin.getFont("default");
        skin.add("default", textButtonStyle);

        // Create a table that fills the screen. Everything else will go inside this table.
        Table table = new Table();
//        table.debug();
        table.setFillParent(true);
        stage.addActor(table);

        // Create a button with the "default" TextButtonStyle. A 3rd parameter can be used to specify a name other than "default".
        final TextButton button = new TextButton("Single Player", skin);
        button.setWidth(300);
        table.add(button);

        button.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game.setScreen(new GameScreen(game));
                self.dispose();
            }
        });

        table.row();
        final TextButton button1 = new TextButton("Two Players", skin);
        table.add(button1).space(10);
    }


    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1);
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

        scrollTimer += Gdx.graphics.getDeltaTime() / 10;
        if (scrollTimer > 1.0f) {
            scrollTimer = 0.0f;
        }
        backSprite.setU(scrollTimer);
        backSprite.setU2(scrollTimer+1);
        game.spriteBatch.begin();
        backSprite.draw(game.spriteBatch);
        game.spriteBatch.end();

        stage.act(Math.min(Gdx.graphics.getDeltaTime(), 1 / 30f));
        stage.draw();
        Table.drawDebug(stage);
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
//        this.background.dispose();
    }

}
