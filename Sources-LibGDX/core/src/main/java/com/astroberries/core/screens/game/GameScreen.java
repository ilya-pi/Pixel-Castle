package com.astroberries.core.screens.game;


import com.astroberries.core.config.GameConfig;
import com.astroberries.core.config.GameLevel;
import com.astroberries.core.config.GlobalGameConfig;
import com.astroberries.core.screens.game.ai.AI;
import com.astroberries.core.screens.game.ai.AIFactory;
import com.astroberries.core.screens.game.bullet.Bullet;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.screens.game.castle.CastleImpl;
import com.astroberries.core.screens.game.level.CheckRectangle;
import com.astroberries.core.screens.game.physics.BulletContactListener;
import com.astroberries.core.screens.game.physics.GameUserData;
import com.astroberries.core.screens.game.physics.PhysicsManager;
import com.astroberries.core.screens.game.touch.MoveAndZoomListener;
import com.astroberries.core.screens.game.wind.Wind;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.InputMultiplexer;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.input.GestureDetector;
import com.badlogic.gdx.math.Matrix4;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.Body;
import com.badlogic.gdx.physics.box2d.Box2DDebugRenderer;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.Json;

import java.util.Timer;
import java.util.TimerTask;

import static com.astroberries.core.CastleGame.game;

public class GameScreen implements Screen {

    private final MoveAndZoomListener moveAndZoomListener;

    private final Stage stage;
    private final World world;

    public final PixelCamera camera;
    public final Castle castle1;
    public final Castle castle2;
    public final Wind wind;
    public final AI ai;

    private BitmapFont font = new BitmapFont(Gdx.files.internal("arial-15.fnt"), false);

    private Box2DDebugRenderer debugRenderer;
    private final Matrix4 fixedPosition = new Matrix4().setToOrtho2D(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

    public int levelHeight;
    public int levelWidth;

    public float viewPortHeight;

    //disposable
    private Texture level;
    private final Texture background;
    private final Texture sky;

    private final Pixmap bulletPixmap;
    public Bullet bullet;


    private final GameLevel gameLevelConfig;
    private final PhysicsManager physicsManager;


    //todo: split init to different functions
    public GameScreen(int setNumber, int levelNumber) {

        camera = new PixelCamera(this);
        world = new World(new Vector2(0, GlobalGameConfig.GRAVITY), true);


        debugRenderer = new Box2DDebugRenderer();

        Json json = new Json();
        GameConfig config = json.fromJson(GameConfig.class, Gdx.files.internal("configuration.json"));

        gameLevelConfig = config.getSets().get(setNumber).getLevels().get(levelNumber);
        ai = new AIFactory().getAi(gameLevelConfig.getAiVariant());
        wind = new Wind(world, gameLevelConfig);

        Pixmap.setBlending(Pixmap.Blending.None);
        Pixmap levelPixmap = new Pixmap(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/level.png"));
        levelWidth = levelPixmap.getWidth();
        levelHeight = levelPixmap.getHeight();

        castle1 = new CastleImpl(levelHeight, CastleImpl.Location.LEFT, gameLevelConfig, world);
        castle2 = new CastleImpl(levelHeight, CastleImpl.Location.RIGHT, gameLevelConfig, world);

        stage = new Stage();
        stage.addActor(castle1.getView());
        stage.addActor(castle2.getView());

        levelPixmap.drawPixmap(castle1.getCastlePixmap(), gameLevelConfig.getCastle1().getX(), gameLevelConfig.getCastle1().getY() - castle1.getCastlePixmap().getHeight());
        levelPixmap.drawPixmap(castle2.getCastlePixmap(), gameLevelConfig.getCastle2().getX(), gameLevelConfig.getCastle2().getY() - castle2.getCastlePixmap().getHeight());

        level = new Texture(levelPixmap);
        background = new Texture(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/background.png"));
        sky = new Texture(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/sky.png"));

        physicsManager = new PhysicsManager(world, levelPixmap, level);
        physicsManager.addRectToCheckPhysicsObjectsCreation(new CheckRectangle(0, 0, levelWidth, levelHeight));
        physicsManager.createPhysicsObjects();

        bulletPixmap = new Pixmap(Gdx.files.internal("bullets/11.png"));
        world.setContactListener(new BulletContactListener(physicsManager, bulletPixmap)); //todo: set bulletPixmap to bullet

        castle1.recalculateHealth(physicsManager);
        castle2.recalculateHealth(physicsManager);

        moveAndZoomListener = new MoveAndZoomListener(camera);

        InputMultiplexer processorsChain = new InputMultiplexer();
        processorsChain.addProcessor(stage);
        processorsChain.addProcessor(new GestureDetector(moveAndZoomListener));
        Gdx.input.setInputProcessor(processorsChain);
    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0, 0, 0.2f, 1);
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

        camera.update();
        game().spriteBatch.begin();

        game().spriteBatch.setProjectionMatrix(camera.combined);
        game().spriteBatch.draw(sky, camera.position.x * 0.6f - levelWidth / 2f * 0.6f, 0);
        game().spriteBatch.draw(background, camera.position.x * 0.4f - levelWidth / 2f * 0.4f, 0);
        game().spriteBatch.draw(level, 0, 0);

        game().spriteBatch.setProjectionMatrix(fixedPosition);
        font.draw(game().spriteBatch, "fps: " + Gdx.graphics.getFramesPerSecond(), 20, 30);

        game().spriteBatch.end();

        stage.act(delta);
        stage.draw();

        wind.render();

        world.step(1 / 30f, 6, 2); //todo: play with this values for performance


        game().shapeRenderer.setProjectionMatrix(camera.combined); //todo: is it necessary?

        renderOrDisposeBullet();

        physicsManager.sweepDeadBodies(); //todo: sweep bodies should be only after this mess with bullet which is bad. Refactor.
        physicsManager.createPhysicsObjects();

        //debugRenderer.render(world, camera.combined);
    }

    private void renderOrDisposeBullet() {
        if (game().state() == StateName.BULLET1 || game().state() == StateName.BULLET2) {
            if (bullet != null) {
                if (!bullet.isAlive() || bullet.getCoordinates().x < 0 || bullet.getCoordinates().x > levelWidth || bullet.getCoordinates().y < 0) {
                    Gdx.app.log("bullet:", "destroy bullet!!");
                    bullet.dispose();
                    bullet = null;
                    physicsManager.sweepBodyes = true;

                    castle1.recalculateHealth(physicsManager);
                    castle2.recalculateHealth(physicsManager);
                    if (castle1.getHealth() < CastleImpl.MIN_HEALTH) {
                        game().getStateMachine().transitionTo(StateName.PLAYER_1_LOST);
                    } else if (castle2.getHealth() < CastleImpl.MIN_HEALTH) {
                        game().getStateMachine().transitionTo(StateName.PLAYER_2_LOST);
                    } else if (game().state() == StateName.BULLET1) {
                        game().getStateMachine().transitionTo(StateName.CAMERA_MOVING_TO_PLAYER_2);
                    } else {
                        game().getStateMachine().transitionTo(StateName.CAMERA_MOVING_TO_PLAYER_1);
                    }
                }
            }
            if (bullet != null) {
                bullet.render();
            }
        }
    }

    @Override
    public void resize(int width, int height) {
        float ratio = (float) width / (float) height;
        viewPortHeight = levelWidth / ratio;
        moveAndZoomListener.setScrollRatio(levelWidth / (float) width);
        camera.setToOrtho(false, levelWidth, viewPortHeight);
        stage.setCamera(camera);
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
        background.dispose();
        sky.dispose();
        level.dispose();
        physicsManager.dispose();

        Array<Body> bodies = new Array<>();
        world.getBodies(bodies);
        for (Body body : bodies) {
            if (body != null) {
                GameUserData data = (GameUserData) body.getUserData();
                if (data != null) {
                    world.destroyBody(body);
                    body.setUserData(null);
                }
            }
        }
        world.dispose();
    }

    // Transitions
    public void mainMenuToOverview() {
        camera.to(PixelCamera.CameraState.OVERVIEW, null, null);
        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                game().getStateMachine().transitionTo(StateName.CAMERA_MOVING_TO_PLAYER_1);
            }
        }, GlobalGameConfig.LEVEL_INTRO_TIMEOUT);
    }


    public void toPlayer1() {
        camera.to(PixelCamera.CameraState.CASTLE1, null, StateName.PLAYER1);
    }

    public void player1ToAiming1() {
    }

    public void aiming1ToBullet1() {
        bullet = castle1.fire(gameLevelConfig.getVelocity(), camera, world);
        camera.to(PixelCamera.CameraState.BULLET, null, null);
    }

    public void toPlayer2() {
        camera.to(PixelCamera.CameraState.CASTLE2, null, StateName.PLAYER2);
    }

    public void toComputer2() {
        camera.to(PixelCamera.CameraState.CASTLE2, null, StateName.COMPUTER2);
    }

    public void player2ToAiming2() {
    }

    public void toBullet2() {
        camera.to(PixelCamera.CameraState.BULLET, null, null);
    }

    public void updateWind() {
        wind.update();
    }

    public void aiAimAndShoot() {
        bullet = castle2.fireAi(ai.nextAngle(), gameLevelConfig.getVelocity(), camera, world);
        game().getStateMachine().transitionTo(StateName.BULLET2);
    }

    public void setCameraFree() {
        camera.setFree();
    }
}
