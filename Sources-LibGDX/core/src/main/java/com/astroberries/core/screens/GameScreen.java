package com.astroberries.core.screens;

import com.astroberries.core.BulletContactListener;
import com.astroberries.core.CastleGame;
import com.astroberries.core.CheckRectangle;
import com.astroberries.core.GameUserData;
import com.astroberries.core.bullets.Bullet;
import com.astroberries.core.bullets.SingleBullet;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.*;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.input.GestureDetector;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.*;
import com.badlogic.gdx.utils.Array;

public class GameScreen implements Screen {

/*
    static final float WORLD_TO_BOX = 0.01f;
    static final float BOX_TO_WORLD = 100f;
*/

    static final float BRICK_SIZE = 0.5f;
    static final float BULLET_SIZE = 2;

    final private CastleGame game;
    final private OrthographicCamera camera;
    final private World world;
    private ShapeRenderer shapeRenderer;
    private Box2DDebugRenderer debugRenderer;

    private int displayWidth;
    private int displayHeight;
    private int levelHeight;
    private int levelWidth;
    private float viewPortHeight;
    private float scrollRatio;

    BitmapFont font = new BitmapFont(Gdx.files.internal("arial-15.fnt"), false);
//    BitmapFont font = new BitmapFont();

    //disposable
    private Texture level;
    private final Texture background;
    private final Texture sky;
    private final Pixmap levelPixmap;
    private final Pixmap transparentPixmap;
    private final Pixmap bulletPixmap;

    private Bullet bullet;

/*
    private Body bulletBody;
    final public ArrayList<Body> bullets = new ArrayList<Body>();
*/

    private final Body[][] bricks;

    private float lastInitialDistance = 0;
    private float lastCameraZoom = 1;
    private float newCameraZoom = 1;

    private float currentAlpha;
    private float tmpAlpha;

    private CheckRectangle checkRectangle;

    //todo: split init to different functions
    public GameScreen(CastleGame game) {
        this.game = game;
        camera = new OrthographicCamera();
        world = new World(new Vector2(0, -20), true);
        world.setContactListener(new BulletContactListener(this));
        shapeRenderer = new ShapeRenderer();
        debugRenderer = new Box2DDebugRenderer();


        bulletPixmap = new Pixmap(Gdx.files.internal("bullets/11.png"));
        Pixmap.setBlending(Pixmap.Blending.None);
        levelPixmap = new Pixmap(Gdx.files.internal("levels/01/level.png"));
        levelWidth = levelPixmap.getWidth();
        levelHeight = levelPixmap.getHeight();
        transparentPixmap = new Pixmap(Gdx.files.internal("transparent.png"));
        level = new Texture(levelPixmap);
        background = new Texture(Gdx.files.internal("levels/01/background.png"));
        sky = new Texture(Gdx.files.internal("levels/01/sky.png"));
        bricks = new Body[levelWidth][levelHeight];

        createPhysicsObjects(0, 0, levelWidth, levelHeight);


        Gdx.input.setInputProcessor(new GestureDetector(new GestureDetector.GestureListener() {
            @Override
            public boolean touchDown(float x, float y, int pointer, int button) {
                return false;
            }

            @Override
            public boolean tap(float x, float y, int count, int button) {
                if (bullet == null || !bullet.isAlive()) {
                    //todo: create bullet instance
                    bullet = new SingleBullet(camera, world, 200, 200, x, y);
                    bullet.fire();
                }
                return true;
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
                camera.translate(-deltaX * camera.zoom * scrollRatio, deltaY * camera.zoom * scrollRatio);
                return true;
            }

            @Override
            public boolean panStop(float x, float y, int pointer, int button) {
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
                return false;
            }
        }));
    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0, 0, 0.2f, 1);
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
        //camera.zoom = 0.4f;
        if (bullet != null) {
            camera.position.y =  bullet.getCoordinates().y;
            camera.position.x =  bullet.getCoordinates().x;
        }
        if (camera.position.y > levelHeight - (viewPortHeight / 2f) * camera.zoom) {
            camera.position.y = levelHeight - (viewPortHeight / 2f) * camera.zoom;
        }
        if (camera.position.y < (viewPortHeight / 2f) * camera.zoom) {
            camera.position.y = viewPortHeight / 2f * camera.zoom;
        }
        if (camera.position.x > levelWidth - (levelWidth / 2f) * camera.zoom) {
            camera.position.x = levelWidth - (levelWidth / 2f) * camera.zoom;
        }
        if (camera.position.x < levelWidth / 2f * camera.zoom) {
            camera.position.x = levelWidth / 2f * camera.zoom;
        }
        camera.update();

        game.spriteBatch.setProjectionMatrix(camera.combined);
        game.spriteBatch.begin();
        game.spriteBatch.draw(sky, camera.position.x * 0.6f - levelWidth / 2f * 0.6f, 0);
        game.spriteBatch.draw(background, camera.position.x * 0.4f - levelWidth / 2f * 0.4f, 0);
        game.spriteBatch.draw(level, 0, 0);
        font.draw(game.spriteBatch, "fps: " + Gdx.graphics.getFramesPerSecond(), 20, 30);
        game.spriteBatch.end();

        world.step(1 / 30f, 6, 2);

        shapeRenderer.setProjectionMatrix(camera.combined); //todo: is it necessary?
        if (bullet != null) {
            if (bullet.getCoordinates().x < 0 || bullet.getCoordinates().x > levelWidth || bullet.getCoordinates().y < 0) {
                Gdx.app.log("bullet:", "destroy bullet!!");
                bullet.dispose();
                bullet = null;
            }
        }
        if (bullet != null) {
            bullet.render(shapeRenderer);
        }
        sweepDeadBodies();
        if (checkRectangle != null && !checkRectangle.checked) {
            createPhysicsObjects(checkRectangle.startX, checkRectangle.startY, checkRectangle.endX, checkRectangle.endY);
            checkRectangle.checked = true;
        }
        //debugRenderer.render(world, camera.combined);

    }

    public void sweepDeadBodies() {
        Array<Body> bodies = new Array<Body>();
        world.getBodies(bodies);
        for (Body body : bodies) {
            if (body != null) {
                GameUserData data = (GameUserData) body.getUserData();
                if (data != null && data.position != null && data.position.y == 247f) {
                    //Gdx.app.log("brick obj:", data.position.x + " " + data.position.y + " " + data.isFlaggedForDelete);
                }
                if (data != null && data.isFlaggedForDelete) {
                    //Gdx.app.log("bricks to del:", "!!!!!!" /*data.position.x + " " + data.position.y*/);
                    world.destroyBody(body);
                    body.setUserData(null);
                    body = null;
                }
            }
        }
        //Gdx.app.log("brick obj:","finished");
    }

    private void createPhysicsObjects(int xStart, int yStart, int endX, int endY) {
        for (int x = xStart; x < endX; x++) {
            for (int y = yStart; y < endY; y++) {
                //todo: instead of new Color() use the following:
/*                int value = pixmap.getPixel(x, y);
                int R = ((value & 0xff000000) >>> 24);
                int G = ((value & 0x00ff0000) >>> 16);
                int B = ((value & 0x0000ff00) >>> 8);
                int A = ((value & 0x000000ff));*/
                currentAlpha = new Color(levelPixmap.getPixel(x, y)).a;
                if (currentAlpha != 0f && bricks[x][y] == null) {
                    boolean stop = false;
                    int yInternal = y - 1; //todo: remove bottom and side lines of bodies
                    while (yInternal <= y + 1 && !stop) {
                        int xInternal = x - 1;
                        while (xInternal <= x + 1 && !stop) {
                            tmpAlpha = new Color(levelPixmap.getPixel(xInternal, yInternal)).a;
                            if (tmpAlpha == 0f) {
                                BodyDef groundBodyDef = new BodyDef();
                                groundBodyDef.type = BodyDef.BodyType.StaticBody;
                                groundBodyDef.position.set(new Vector2(x + BRICK_SIZE, levelHeight - y - BRICK_SIZE));
                                Body groundBody = world.createBody(groundBodyDef);
                                groundBody.setUserData(GameUserData.createBrickData(x, y));
                                bricks[x][y] = groundBody;
                                PolygonShape groundBox = new PolygonShape();
                                groundBox.setAsBox(BRICK_SIZE, BRICK_SIZE);
                                groundBody.createFixture(groundBox, 0.0f);
                                groundBox.dispose();
                                //Gdx.app.log("bricks", "created " + x + " " + y);

                                stop = true;
                            }
                            xInternal++;
                        }
                        yInternal++;
                    }
                }
            }
        }
    }

    public void calculateHit(GameUserData bulletData, GameUserData brickData) {
        if (bullet != null) {
            bullet.dispose();
            bullet = null;
        }
        bulletData.isFlaggedForDelete = true;

        int hitX = (int) brickData.position.x;
        int hitY = (int) brickData.position.y;
        int dx = (bulletPixmap.getWidth() - 1) / 2;
        int dy = (bulletPixmap.getHeight() - 1) / 2;

        int startX = hitX - dx;
        int endX = hitX + dx;
        int startY = hitY - dy;
        int endY = hitY + dy;

        int writeColor = 0;
        for (int x = 0; x <= bulletPixmap.getWidth(); x++) {
            for (int y = 0; y <= bulletPixmap.getHeight(); y++) {
                Color color = new Color(bulletPixmap.getPixel(x, y));
                //Gdx.app.log("pixel", color.a + "");
                if (color.a != 0f) {
                    int pixelX = x - dx + hitX;
                    int pixelY = y - dy + hitY;
                    if (pixelX < bricks.length && pixelY < bricks[1].length && pixelX >= 0 && pixelY >= 0) {
                        Body tmpBrick = bricks[pixelX][pixelY];
                        if (tmpBrick != null) {
                            //Gdx.app.log("pixel", "!!!!!! " + pixelX + " " + pixelY);
                            ((GameUserData) tmpBrick.getUserData()).isFlaggedForDelete = true;
                            bricks[pixelX][pixelY] = null;
                        }

                        if ((new Color(levelPixmap.getPixel(pixelX, pixelY)).a != 0f)) {
                            if (color.r == 0f && color.g == 0f && color.b == 0f) {
                                writeColor = Color.rgba8888(52 / 255f, 93 / 255f, 33 / 255f, 1);
                            } else {
                                writeColor = Color.rgba8888(0, 0, 0, 0);
                            }

                            levelPixmap.drawPixel(pixelX, pixelY, writeColor);
                        }
                    }
                }
            }
        }
        level = new Texture(levelPixmap);
        checkRectangle = new CheckRectangle(startX - 1, startY - 1, endX + 1, endY + 1);
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
        levelPixmap.dispose();
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
    }

}
