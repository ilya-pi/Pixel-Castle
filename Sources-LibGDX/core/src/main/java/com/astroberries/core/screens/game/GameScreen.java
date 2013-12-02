package com.astroberries.core.screens.game;

import com.astroberries.core.config.GameConfig;
import com.astroberries.core.config.GameLevel;
import com.astroberries.core.config.GlobalGameConfig;
import com.astroberries.core.screens.common.ButtonFactory;
import com.astroberries.core.screens.game.ai.AI;
import com.astroberries.core.screens.game.ai.AIFactory;
import com.astroberries.core.screens.game.background.BackgroundActor;
import com.astroberries.core.screens.game.bullet.Bullet;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.screens.game.castle.CastleImpl;
import com.astroberries.core.screens.game.debug.DebugActor;
import com.astroberries.core.screens.game.physics.*;
import com.astroberries.core.screens.game.subscreens.PauseSubScreen;
import com.astroberries.core.screens.game.touch.MoveAndZoomListener;
import com.astroberries.core.screens.game.wind.Wind;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.InputMultiplexer;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.input.GestureDetector;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.Body;
import com.badlogic.gdx.physics.box2d.Box2DDebugRenderer;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.ImageButton;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.Disposable;
import com.badlogic.gdx.utils.Json;
import com.badlogic.gdx.utils.Timer;

import java.util.ArrayList;
import java.util.List;

import static com.astroberries.core.CastleGame.game;

public class GameScreen implements Screen {

    private final MoveAndZoomListener moveAndZoomListener;

    private final Stage resizableStage;
    private final Stage staticStage;
    private final World world;

    private final PixelCamera camera;
    public final Castle castle1;
    public final Castle castle2;
    private final Wind wind;
    private final AI ai;
    private ImageButton pauseButton;
    private Group pauseSubScreen;
    private Timer timer = new Timer();
    private boolean pvp = false;

    private Box2DDebugRenderer debugRenderer;

    public int levelHeight;
    public int levelWidth;

    public float viewPortHeight;

    //disposable
    private Pixmap levelPixmap;
    private final Texture level;
    private final Texture background;
    private final Texture sky;
    private boolean shuttingDown = false;

    public Bullet bullet;
    public final Particles particles;
    private boolean pause = false;

    private final GameLevel gameLevelConfig;
    private final PhysicsManager physicsManager;
    private final BulletContactListener bulletContactListener;

    public List<Disposable> disposables = new ArrayList<>();

    //todo: split init to different functions
    public GameScreen(int setNumber, int levelNumber, boolean pvp) {
        this.pvp = pvp;
        camera = new PixelCamera(this);
        particles = new Particles();
        world = new World(new Vector2(0, GlobalGameConfig.GRAVITY), true);
        disposables.add(world);

        Json json = new Json();
        GameConfig config = json.fromJson(GameConfig.class, Gdx.files.internal("configuration.json"));
        gameLevelConfig = config.getSets().get(setNumber).getLevels().get(levelNumber);

        ai = new AIFactory().getAi(gameLevelConfig.getAiVariant());
        wind = new Wind(world, gameLevelConfig);
        disposables.add(wind);

        Pixmap.setBlending(Pixmap.Blending.None);
        levelPixmap = new Pixmap(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/level.png"));
        disposables.add(levelPixmap);
        levelWidth = levelPixmap.getWidth();
        levelHeight = levelPixmap.getHeight();

        castle1 = new CastleImpl(levelHeight, CastleImpl.Location.LEFT, gameLevelConfig, world);
        castle2 = new CastleImpl(levelHeight, CastleImpl.Location.RIGHT, gameLevelConfig, world);
        disposables.add(castle1);
        disposables.add(castle2);

        levelPixmap.drawPixmap(castle1.getCastlePixmap(), gameLevelConfig.getCastle1().getX(), gameLevelConfig.getCastle1().getY() - castle1.getCastlePixmap().getHeight());
        levelPixmap.drawPixmap(castle2.getCastlePixmap(), gameLevelConfig.getCastle2().getX(), gameLevelConfig.getCastle2().getY() - castle2.getCastlePixmap().getHeight());

        level = new Texture(levelPixmap);
        background = new Texture(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/background.png"));
        sky = new Texture(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/sky.png"));
        disposables.add(level);
        disposables.add(background);
        disposables.add(sky);

        physicsManager = new PhysicsManager(world, levelPixmap, level, timer, this);
        physicsManager.addRectToCheckPhysicsObjectsCreation(new CheckRectangle(0, 0, levelWidth, levelHeight));
        physicsManager.createPhysicsObjects();
        disposables.add(physicsManager);

        bulletContactListener = new BulletContactListener(physicsManager);
        disposables.add(bulletContactListener);
        world.setContactListener(bulletContactListener);

        castle1.recalculateHealth(physicsManager);
        castle2.recalculateHealth(physicsManager);

        moveAndZoomListener = new MoveAndZoomListener(camera);

        pauseButton = ButtonFactory.getPauseButton(StateName.PAUSE);
        pauseSubScreen = new PauseSubScreen();
        pauseSubScreen.setVisible(false);

        resizableStage = new Stage();
        staticStage = new Stage(Gdx.graphics.getWidth(), Gdx.graphics.getHeight(), false, game().fixedBatch);
        disposables.add(resizableStage);
        disposables.add(staticStage);

        resizableStage.addActor(new BackgroundActor(level, background, sky, camera, levelWidth));
        resizableStage.addActor(castle1.getView());
        resizableStage.addActor(castle2.getView());
        resizableStage.addActor(particles);

        staticStage.addActor(wind);
        staticStage.addActor(pauseButton);
        staticStage.addActor(pauseSubScreen);
        staticStage.addActor(new DebugActor()); //todo: delete

        InputMultiplexer processorsChain = new InputMultiplexer();
        processorsChain.addProcessor(staticStage);
        processorsChain.addProcessor(resizableStage);
        processorsChain.addProcessor(new GestureDetector(moveAndZoomListener));
        Gdx.input.setInputProcessor(processorsChain);

        debugRenderer = new Box2DDebugRenderer(); //todo: delete
    }

    @Override
    public void render(float delta) {
        if (!shuttingDown) {
            Gdx.gl.glClearColor(0, 0, 0.2f, 1);
            Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

            if (!pause) {
                camera.update();
                resizableStage.act(delta);
            }
            resizableStage.draw();

            if (!pause) {
                world.step(1 / 30f, 6, 2); //todo: play with this values for better performance
            }

            renderOrDisposeBullet();
            staticStage.act();
            staticStage.draw();
            Table.drawDebug(staticStage);


            if (!shuttingDown) { //ugly double check to avoid exceptions
                physicsManager.sweepDeadBodies(); //todo: sweep bodies should be only after this mess with bullet which is bad. Refactor.
                physicsManager.createPhysicsObjects();
            }

            //debugRenderer.render(world, camera.combined);
        }
    }

    private void renderOrDisposeBullet() {
        if (game().state() == StateName.BULLET1 || game().state() == StateName.BULLET2 || game().state() == StateName.PAUSE) {
            if (bullet != null) {
                if (!bullet.isAlive()) {
                    Gdx.app.log("bullet:", "destroy bullet!!");
                    bullet.dispose();
                    bullet = null;
                    physicsManager.sweepBodyes = true;

                    castle1.recalculateHealth(physicsManager);
                    castle2.recalculateHealth(physicsManager);
                    if (castle1.getHealth() < CastleImpl.MIN_HEALTH) {
                        pauseButton.setVisible(false);
                        render(0);
                        if (pvp) {
                            game().getStateMachine().transitionTo(StateName.PVP_GAME_END);
                        } else {
                            game().getStateMachine().transitionTo(StateName.YOU_LOST);
                        }
                    } else if (castle2.getHealth() < CastleImpl.MIN_HEALTH) {
                        pauseButton.setVisible(false);
                        render(0);
                        if (pvp) {
                            game().getStateMachine().transitionTo(StateName.PVP_GAME_END);
                        } else {
                            game().getStateMachine().transitionTo(StateName.COMPUTER_LOST);
                        }
                    } else if (game().state() == StateName.BULLET1) {
                        if (pvp) {
                            timer.scheduleTask(new Timer.Task() {
                                @Override
                                public void run() {
                                    game().getStateMachine().transitionTo(StateName.CAMERA_MOVING_TO_PLAYER_2);
                                }
                            }, PhysicsManager.EXPLODE_TIME_SEC);
                        } else {
                            timer.scheduleTask(new Timer.Task() {
                                @Override
                                public void run() {
                                    game().getStateMachine().transitionTo(StateName.CAMERA_MOVING_TO_COMPUTER_2);
                                }
                            }, PhysicsManager.EXPLODE_TIME_SEC);
                        }
                    } else {
                        timer.scheduleTask(new Timer.Task() {
                            @Override
                            public void run() {
                                game().getStateMachine().transitionTo(StateName.CAMERA_MOVING_TO_PLAYER_1);
                            }
                        }, PhysicsManager.EXPLODE_TIME_SEC);
                    }
                }
            }
            if (bullet != null) {
                game().shapeRenderer.setProjectionMatrix(camera.combined);
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
        resizableStage.setCamera(camera);
        staticStage.setViewport(width, height, false);
    }

    @Override
    public void show() {
    }

    @Override
    public void hide() {
    }

    @Override
    public void pause() {
        if (game().state() != StateName.PAUSE) {
            game().getStateMachine().transitionTo(StateName.PAUSE);
        }
    }

    @Override
    public void resume() {
/*
        if (game().state() == StateName.PAUSE) {
            game().getStateMachine().transitionTo(game().getStateMachine().getPreviousState());
        }
*/
    }

    @Override
    public void dispose() {
        //todo: dig here: proper tear down
        shuttingDown = true;
        timer.clear();
        Array<Body> bodies = new Array<>();
        world.getBodies(bodies);
        for (Body body : bodies) {
            if (body != null) {
                GameUserData data = (GameUserData) body.getUserData();
                if (data != null) {
                    body.setUserData(null);
                    world.destroyBody(body);
                }
            }
        }
        for (Disposable disposable : disposables) {
            disposable.dispose();
        }
    }

    // Transitions
    public void toOverview() {
        camera.to(PixelCamera.CameraState.OVERVIEW, null, null);
        timer.scheduleTask(new Timer.Task() {
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
        bullet = castle1.fire(gameLevelConfig.getVelocity(), world, levelWidth, bulletContactListener);
        camera.to(PixelCamera.CameraState.BULLET, null, null);
    }

    public void aiming2ToBullet2() {
        bullet = castle2.fire(gameLevelConfig.getVelocity(), world, levelWidth, bulletContactListener);
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
        bullet = castle2.fireAi(gameLevelConfig.getVelocity(), world, levelWidth, bulletContactListener, ai.nextShoot(gameLevelConfig));
        game().getStateMachine().transitionTo(StateName.BULLET2);
    }

    public void setCameraFree() {
        camera.setFree();
    }

    public void intPause() {
        pause = true;
        pauseButton.setVisible(false);
        pauseSubScreen.setVisible(true);
        timer.stop();
        camera.pause();
    }

    public void intPlay() {
        pause = false;
        pauseButton.setVisible(true);
        pauseSubScreen.setVisible(false);
        timer.start();
        camera.unpause();
    }

    public TextureRegion getCurrentCastlePixmap(Castle castle) {
        int x = castle.getCastleConfig().getX();
        int y = castle.getCastleConfig().getY();
        int width = castle.getCastlePixmap().getWidth();
        int height = castle.getCastlePixmap().getHeight();
        Texture tmpLevel = new Texture(levelPixmap);
        return new TextureRegion(tmpLevel, x, y - height, width, height);
    }

}
