package com.astroberries.core.screens.game.bullet;

import com.astroberries.core.screens.game.physics.GameUserData;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.physics.box2d.*;

import java.util.*;

import static com.astroberries.core.CastleGame.game;

public abstract class AbstractBullet implements Bullet {

    public final static Vector2 DEFAULT_COORDS = new Vector2(0, 0);
    public static final float BULLET_DENSITY = 0.9f;
    public static final Color BULLET_COLOR = new Color(1, 1, 1, 1);
    public static final float ANGLE_SECTOR = 10 * MathUtils.degreesToRadians;

    private final float startAngle;
    private final float deltaAngle;
    protected final float bulletSize;
    private final float velocityFactor;
    private final int bulletCount;
    protected final float finalVelocity;
    private final float levelWidth;
    protected final float initialAngle;

    private final List<Body> bulletBodies = new LinkedList<>();
    //private final List<BodyDef> bulletBodyDefs;

    protected final World world;
    protected final float x;
    protected final float y;

    public AbstractBullet(World world, float levelWidth, float angle, int velocity, Vector2 coordinates, float bulletSize, int bulletCount, float velocityFactor) {
        this.world = world;
        this.bulletCount = bulletCount;
        this.levelWidth = levelWidth;
        this.initialAngle = angle;
        if (bulletCount == 1) {
            startAngle = angle;
            deltaAngle = 0;
        } else {
            startAngle = angle - ANGLE_SECTOR / 2;
            deltaAngle = ANGLE_SECTOR / (bulletCount - 1);
        }
        finalVelocity = velocity * velocityFactor;
        this.x = coordinates.x;
        this.y = coordinates.y;
        this.bulletSize = bulletSize;
        this.velocityFactor = velocityFactor;
    }

    @Override
    public void fire() {
        Gdx.app.log("bullet", "shoot!");
        for (int i = 0; i < bulletCount; i++) {
            BodyDef bulletBodyDef = new BodyDef();
            bulletBodyDef.type = BodyDef.BodyType.DynamicBody;
            Vector3 unprojected = new Vector3(x, y, 0);

            bulletBodyDef.position.set(new Vector2(unprojected.x, unprojected.y));
            //bulletBodyDefs.add(bulletBodyDef);
            Body bulletBody = world.createBody(bulletBodyDef);
            bulletBody.setUserData(GameUserData.createBulletData());
            PolygonShape bulletBox = new PolygonShape();
            bulletBox.setAsBox(bulletSize, bulletSize);
            Fixture bulletFixture = bulletBody.createFixture(bulletBox, BULLET_DENSITY);
            bulletFixture.setSensor(true);
            bulletBox.dispose();
            bulletBody.setSleepingAllowed(false);
            float vX = finalVelocity * MathUtils.cos(startAngle + deltaAngle * i);
            float vY = finalVelocity * MathUtils.sin(startAngle + deltaAngle * i);

            bulletBody.setLinearVelocity(vX, vY);
            bulletBodies.add(bulletBody);
        }

    }

    @Override
    public Vector2 getCoordinates() {
        for (Body bulletBody : bulletBodies) {
            if (bulletBody != null) {
                return bulletBody.getPosition();
            }
        }
        return DEFAULT_COORDS;
    }

    @Override
    public void render() {
        game().shapeRenderer.setColor(BULLET_COLOR);
        game().shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
        Iterator<Body> it = bulletBodies.iterator();
        while (it.hasNext()) {
            Body bulletBody = it.next();
            if (bulletBody != null)  {
                if (bulletBody.getUserData() != null &&
                    !((GameUserData) bulletBody.getUserData()).isFlaggedForDelete &&
                    isBulletOnScreen(bulletBody)) {
                        game().shapeRenderer.identity();
                        Vector2 position = bulletBody.getPosition();
                        game().shapeRenderer.translate(position.x, position.y, 0);
                        game().shapeRenderer.rotate(0, 0, -1, -bulletBody.getAngle() * MathUtils.radiansToDegrees);
                        game().shapeRenderer.rect(-bulletSize, -bulletSize, bulletSize * 2, bulletSize * 2);
                } else {
                    if (bulletBody.getUserData() != null) {
                        ((GameUserData) bulletBody.getUserData()).isFlaggedForDelete = true;
                    }
                    it.remove();
                }
            }
        }
        game().shapeRenderer.end();
    }

    @Override
    public void dispose() {
        Gdx.app.log("bullet", "dispose it");
        for (Body bulletBody : bulletBodies) {
            ((GameUserData) bulletBody.getUserData()).isFlaggedForDelete = true;
        }
        bulletBodies.clear();
    }

    @Override
    public boolean isAlive() {
        for (Body bulletBody : bulletBodies) {
            if(bulletBody != null &&
               bulletBody.getUserData() != null &&
               !((GameUserData) bulletBody.getUserData()).isFlaggedForDelete) { //todo: performance?
                return true;
            }
        }
        return false;
    }

    private boolean isBulletOnScreen(Body bulletBody) {
        return bulletBody.getPosition().x >= 0 &&
               bulletBody.getPosition().x <= levelWidth &&
               bulletBody.getPosition().y >= 0;

    }
}
