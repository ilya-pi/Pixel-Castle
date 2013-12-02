package com.astroberries.core.screens.game.physics;

import com.astroberries.core.screens.game.GameScreen;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.glutils.PixmapTextureData;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.Body;
import com.badlogic.gdx.physics.box2d.BodyDef;
import com.badlogic.gdx.physics.box2d.PolygonShape;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.Disposable;
import com.badlogic.gdx.utils.Timer;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

public class PhysicsManager implements Disposable {

    //static configuration.
    static final float BRICK_SIZE = 0.5f;
    public static final float EXPLODE_TIME_SEC = 0.7f;

    //private List<Coordinate> particlesToCreate = new LinkedList<>();
    private List<Explosion> explosions = new LinkedList<>();

    //temp values for optimization
    private float currentAlpha;
    private float tmpAlpha;
    private final int levelHeight;
    private final int levelWidth;

    //levelTexture data
    private final Body[][] bricks;
    private final Pixmap levelPixmap;
    private final Timer timer;
    private final GameScreen gameScreen;

    //levelTexture Texture which should be drawn in render cycle
    private final Texture levelTexture;

    private final World world;

    //triggers and queues
    public boolean sweepBodyes = false;
    private List<CheckRectangle> createPhysicsObjectsQueue = new ArrayList<CheckRectangle>();

    public PhysicsManager(World world, Pixmap levelPixmap, Texture levelTexture, Timer timer, GameScreen gameScreen) {
        this.world = world;
        this.timer = timer;
        this.gameScreen = gameScreen;
        this.levelPixmap = levelPixmap;
        this.levelTexture = levelTexture;
        levelWidth = levelPixmap.getWidth();
        levelHeight = levelPixmap.getHeight();
        bricks = new Body[levelWidth][levelHeight];
    }

    public void sweepDeadBodies() {
        if (sweepBodyes) {
            Array<Body> bodies = new Array<Body>();
            world.getBodies(bodies);
            for (Body body : bodies) {
                if (body != null) {
                    GameUserData data = (GameUserData) body.getUserData();
                    if (data != null && data.isFlaggedForDelete) {
                        world.destroyBody(body);
                        body.setUserData(null);
                    }
                }
            }
            sweepBodyes = false;
        }
    }

    public void createPhysicsObjects() {
        Iterator<CheckRectangle> it = createPhysicsObjectsQueue.listIterator();
        while (it.hasNext()) {
            CheckRectangle rectangle = it.next();
            int startX = rectangle.startX;
            int startY = rectangle.startY;
            int endX = rectangle.endX;
            int endY = rectangle.endY;

            for (int x = startX; x < endX; x++) {
                for (int y = startY; y < endY; y++) {
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
                                    bricks[x][y] = createBrick(x, y);
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
            it.remove();
        }

        if (explosions.size() != 0) {
            for (Explosion explosion : explosions) {
                float angle = explosion.getSpeed().angle() + 180;
                float dAngle = 90;
                float startAngle = angle - dAngle / 2;
                float endAngle = angle + dAngle / 2;
                float minSpeed = 10;
                float maxSpeed = 50;
                Vector2 tmp = Vector2.Zero;

                for (Coordinate coordinate : explosion.getParticlesToCreate()) {
                    final Body tmpBrick = createExplosionParticle(coordinate.x, coordinate.y);
                    gameScreen.particles.add(tmpBrick);
                    tmp.y = MathUtils.random(minSpeed, maxSpeed);
                    tmp.setAngle(MathUtils.random(startAngle, endAngle));
                    tmpBrick.setLinearVelocity(tmp);
                    timer.scheduleTask(new Timer.Task() {
                        @Override
                        public void run() {
                            ((GameUserData) tmpBrick.getUserData()).isFlaggedForDelete = true;
                        }
                    }, EXPLODE_TIME_SEC);
                }
            }
            explosions.clear();
        }
    }

    private Body createBrick(int x, int y) {
        return createPhysicalBody(x, y, false, GameUserData.createBrickData(x, y), BodyDef.BodyType.StaticBody);
    }

    private Body createPhysicalBody(int x, int y, boolean isSensor, GameUserData type, BodyDef.BodyType bodyType) {
        BodyDef groundBodyDef = new BodyDef();
        groundBodyDef.type = bodyType;
        groundBodyDef.position.set(new Vector2(x + BRICK_SIZE, levelHeight - y - BRICK_SIZE));
        Body body = world.createBody(groundBodyDef);
        body.setUserData(type);
        PolygonShape groundBox = new PolygonShape();
        groundBox.setAsBox(BRICK_SIZE, BRICK_SIZE);
        body.createFixture(groundBox, 0.0f).setSensor(isSensor);
        groundBox.dispose();
        return body;
    }

    private Body createExplosionParticle(int x, int y) {
        return createPhysicalBody(x, y, true, GameUserData.createExplosionData(), BodyDef.BodyType.DynamicBody);
    }

    //the following method is called from inside physics step, so no bodies manipulation here.
    public void calculateHit(GameUserData bulletData, GameUserData brickData, Pixmap bulletPixmap, Vector2 velocity) {
        bulletData.isFlaggedForDelete = true;
        Explosion explosion = new Explosion(velocity);

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
                                explosion.getParticlesToCreate().add(new Coordinate(pixelX, pixelY));
                                writeColor = Color.rgba8888(0, 0, 0, 0);
                            }
                            levelPixmap.drawPixel(pixelX, pixelY, writeColor);
                        }
                    }
                }
            }
        }
        levelTexture.load(new PixmapTextureData(levelPixmap, levelPixmap.getFormat(), false, false));
        addRectToCheckPhysicsObjectsCreation(new CheckRectangle(startX - 1, startY - 1, endX + 1, endY + 1));
        sweepBodyes = true;
        if (explosion.getParticlesToCreate().size() != 0) {
            explosions.add(explosion);
        }
    }

    public void addRectToCheckPhysicsObjectsCreation(CheckRectangle checkRectangle) {
        createPhysicsObjectsQueue.add(checkRectangle);
    }

    public int calculateOpaquePixels(int x, int y, int width, int height) {
        int pixels = 0;
        for (int xCur = x; xCur < x + width; xCur++) {
            for (int yCur = y - height; yCur < y; yCur++) {
                //levelPixmap.drawPixel(xCur, yCur, Color.rgba8888(255 / 255f, 255 / 255f, 0 / 255f, 1));
                //Gdx.app.log("alpha", "alpha " + new Color(levelPixmap.getPixel(xCur, yCur)).a);
                if ((new Color(levelPixmap.getPixel(xCur, yCur)).a != 0f)) {
                    //Gdx.app.log("health", "pixels " + pixels);
                    //levelPixmap.drawPixel(xCur, yCur, Color.rgba8888(255 / 255f, 255 / 255f, 0 / 255f, 1));
                    pixels++;
                }
            }
        }
        return pixels;
    }


    @Override
    public void dispose() {
        //nothing to do yet
    }
}
