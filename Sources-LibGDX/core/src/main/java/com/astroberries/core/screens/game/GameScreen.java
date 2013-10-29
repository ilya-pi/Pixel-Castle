package com.astroberries.core.screens.game;

import com.astroberries.core.CastleGame;
import com.astroberries.core.config.GameConfig;
import com.astroberries.core.config.GameLevel;
import com.astroberries.core.screens.game.bullets.Bullet;
import com.astroberries.core.screens.game.bullets.SingleBullet;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.screens.game.level.CheckRectangle;
import com.astroberries.core.screens.game.physics.BulletContactListener;
import com.astroberries.core.screens.game.physics.GameUserData;
import com.astroberries.core.screens.game.physics.PhysicsManager;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.input.GestureDetector;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Matrix4;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.physics.box2d.Body;
import com.badlogic.gdx.physics.box2d.Box2DDebugRenderer;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.Json;

public class GameScreen implements Screen {

/*
    static final float WORLD_TO_BOX = 0.01f;
    static final float BOX_TO_WORLD = 100f;
*/


    static final float CANNON_PADDING = 4;

    private final CastleGame game;
    public final PixelCamera camera;
    private final World world;
    public final Castle castle1;
    public final Castle castle2;

    private Box2DDebugRenderer debugRenderer;
    private final Matrix4 fixedPosition = new Matrix4().setToOrtho2D(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

    private int displayWidth;
    private int displayHeight;

    public int levelHeight;
    public int levelWidth;

    public float viewPortHeight;
    private float scrollRatio;

    BitmapFont font = new BitmapFont(Gdx.files.internal("arial-15.fnt"), false);
//    BitmapFont font = new BitmapFont();

    //disposable
    private Texture level;
    private final Texture background;
    private final Texture sky;

    private final Pixmap transparentPixmap;
    private final Pixmap bulletPixmap;

    private boolean drawAim = false;
    private Vector3 unprojectedEnd = new Vector3(0, 0, 0);

    public Bullet bullet;

    private final GameLevel gameLevelConfig;

    private final PhysicsManager physicsManager;

/*
    private Body bulletBody;
    final public ArrayList<Body> bullets = new ArrayList<Body>();
*/

    private float lastInitialDistance = 0;
    private float lastCameraZoom = 1;
    private float newCameraZoom = 1;

    private static GameScreen instance;

    public static GameScreen geCreate(CastleGame game, int setNumber, int levelNumber) {
        if (GameScreen.instance == null) {
            synchronized (GameScreen.class) {
                GameScreen.instance = new GameScreen(game, setNumber, levelNumber);
            }
        }
        return GameScreen.instance;
    }

    public static GameScreen geCreate() {
        if (GameScreen.instance == null) {
            throw new Error(String.format("Cannot geCreate %s, should've been initializes prior " +
                    "to method calling with null parametres", GameScreen.class.getName()));
        }
        return GameScreen.instance;
    }

    //todo: split init to different functions
    private GameScreen(CastleGame game, int setNumber, int levelNumber) {
        this.game = game;
        camera = new PixelCamera();
        world = new World(new Vector2(0, -20), true); //todo: explain magic numbers


        debugRenderer = new Box2DDebugRenderer();

        Json json = new Json();
        GameConfig config = json.fromJson(GameConfig.class, Gdx.files.internal("configuration.json"));

        gameLevelConfig = config.getSets().get(setNumber).getLevels().get(levelNumber);


        Pixmap.setBlending(Pixmap.Blending.None);
        Pixmap levelPixmap = new Pixmap(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/level.png"));
        levelWidth = levelPixmap.getWidth();
        levelHeight = levelPixmap.getHeight();

        castle1 = new Castle(gameLevelConfig.getCastle1(), levelWidth, levelHeight);
        castle2 = new Castle(gameLevelConfig.getCastle2(), levelWidth, levelHeight);


        levelPixmap.drawPixmap(castle1.getCastlePixmap(), gameLevelConfig.getCastle1().getX(), gameLevelConfig.getCastle1().getY() - castle1.getCastlePixmap().getHeight());
        levelPixmap.drawPixmap(castle2.getCastlePixmap(), gameLevelConfig.getCastle2().getX(), gameLevelConfig.getCastle2().getY() - castle2.getCastlePixmap().getHeight());

        transparentPixmap = new Pixmap(Gdx.files.internal("transparent.png"));
        level = new Texture(levelPixmap);
        background = new Texture(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/background.png"));
        sky = new Texture(Gdx.files.internal("levels/" + gameLevelConfig.getPath() + "/sky.png"));

        physicsManager = new PhysicsManager(world, levelPixmap, level);
        physicsManager.addRectToCheckPhysicsObjectsCreation(new CheckRectangle(0, 0, levelWidth, levelHeight));
        physicsManager.createPhysicsObjects();

        bulletPixmap = new Pixmap(Gdx.files.internal("bullets/11.png"));
        world.setContactListener(new BulletContactListener(physicsManager, bulletPixmap)); //todo: set bulletPixmap to bullet


        Gdx.input.setInputProcessor(new GestureDetector(new GestureDetector.GestureListener() {
            @Override
            public boolean touchDown(float x, float y, int pointer, int button) {
                Vector3 unprojectedStart = new Vector3(x, y, 0);
                camera.unproject(unprojectedStart);
                //Gdx.app.log("touches", "pan " + x + " " + y);
                if (unprojectedStart.x < castle1.getCannon().x && unprojectedStart.y < castle1.getCannon().y) {
                    drawAim = true;
                    return false;
                }
                return false;
            }

            @Override
            public boolean tap(float x, float y, int count, int button) {
                return false;
            }

            @Override
            public boolean longPress(float x, float y) {
                return false;
            }

            @Override
            public boolean fling(float velocityX, float velocityY, int button) {
                return false;
            }

            @Override
            public boolean pan(float x, float y, float deltaX, float deltaY) {
                //Gdx.app.log("camera", " " + deltaX + " " + deltaY);
                if (drawAim) {
                    unprojectedEnd.x = x + deltaX;
                    unprojectedEnd.y = y + deltaY;
                    //Gdx.app.log("touches", "pan " + unprojectedEnd.x + " " + unprojectedEnd.y);
                    camera.unproject(unprojectedEnd);
                    return true;
                } else {
                    camera.translate(-deltaX * camera.zoom * scrollRatio, deltaY * camera.zoom * scrollRatio);
                    return true;
                }
            }

            @Override
            public boolean panStop(float x, float y, int pointer, int button) {
                Gdx.app.log("touches", "pan stop" + x + " " + y);
                if (drawAim && (bullet == null || !bullet.isAlive())) {
                    unprojectedEnd.x = x;
                    unprojectedEnd.y = y;
                    //Gdx.app.log("touches", "pan " + unprojectedEnd.x + " " + unprojectedEnd.y);
                    camera.unproject(unprojectedEnd);

                    float angle = MathUtils.atan2(unprojectedEnd.y - castle1.getCenter().y, unprojectedEnd.x - castle1.getCenter().x);
                    int impulse = gameLevelConfig.getImpulse();

                    bullet = new SingleBullet(camera, world, angle, impulse, castle1.getCannon().x, castle1.getCannon().y);
                    camera.to(PixelCamera.CameraState.BULLET, null); //todo: move to the state machine transition
                    bullet.fire();
                    drawAim = false;
                    return true;
                }
                return false;
            }

            @Override
            public boolean zoom(float initialDistance, float distance) {
                if (initialDistance != lastInitialDistance) {
                    //Gdx.app.log("camera", " " + initialDistance + " " + lastInitialDistance);
                    lastInitialDistance = initialDistance;
                    lastCameraZoom = camera.zoom;
                }
                newCameraZoom = lastCameraZoom * (initialDistance / distance);
                if (newCameraZoom > 1) {
                    newCameraZoom = 1;
                } else if (newCameraZoom < 0.2) {
                    newCameraZoom = 0.2f;
                }
                camera.zoom = newCameraZoom;
                return true;
            }

            @Override
            public boolean pinch(Vector2 initialPointer1, Vector2 initialPointer2, Vector2 pointer1, Vector2 pointer2) {
                //todo: implement this method rather then zoom to let user drag and zoom at the same time
                return false;
            }
        }));
    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0, 0, 0.2f, 1);
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
        camera.handle();

        game.spriteBatch.setProjectionMatrix(camera.combined);
        game.spriteBatch.begin();
        game.spriteBatch.draw(sky, camera.position.x * 0.6f - levelWidth / 2f * 0.6f, 0);
        game.spriteBatch.draw(background, camera.position.x * 0.4f - levelWidth / 2f * 0.4f, 0);
        game.spriteBatch.draw(level, 0, 0);


        //todo: only need it for debug
        game.spriteBatch.setProjectionMatrix(fixedPosition);
        font.draw(game.spriteBatch, "fps: " + Gdx.graphics.getFramesPerSecond(), 20, 30);
        //todo: end only need it for debug

        game.spriteBatch.end();

        if (drawAim) {
            game.shapeRenderer.setProjectionMatrix(camera.combined);
            game.shapeRenderer.identity();
            game.shapeRenderer.begin(ShapeRenderer.ShapeType.Line);
            game.shapeRenderer.line(castle1.getCenter().x, castle1.getCenter().y, unprojectedEnd.x, unprojectedEnd.y, Color.CYAN, Color.BLACK);
            game.shapeRenderer.end();
        }


        world.step(1 / 30f, 6, 2); //todo: play with this values


        game.shapeRenderer.setProjectionMatrix(camera.combined); //todo: is it necessary?

        //todo: refactor mess regarding bullet
        if (bullet != null) {
            if (!bullet.isAlive() || bullet.getCoordinates().x < 0 || bullet.getCoordinates().x > levelWidth || bullet.getCoordinates().y < 0) {
                Gdx.app.log("bullet:", "destroy bullet!!");
                bullet.dispose();
                bullet = null;
                physicsManager.sweepBodyes = true;
            }
        }
        if (bullet != null) {
            bullet.render(game.shapeRenderer);
        }

        physicsManager.sweepDeadBodies(); //todo: sweep bodies should be only after this mess with bullet which is bad. Refactor.
        physicsManager.createPhysicsObjects();


        //debugRenderer.render(world, camera.combined);

    }

    @Override
    public void resize(int width, int height) {
        displayWidth = width;
        displayHeight = height;
        float ratio = (float) width / (float) height;
        viewPortHeight = levelWidth / ratio;
        scrollRatio = levelWidth / (float) width;
        camera.setToOrtho(false, levelWidth, viewPortHeight);
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

        Array<Body> bodies = new Array<Body>();
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

}
