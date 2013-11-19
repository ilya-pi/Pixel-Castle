package com.astroberries.core.screens.game.bullet;

import com.astroberries.core.screens.game.physics.GameUserData;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.physics.box2d.*;

import static com.astroberries.core.CastleGame.game;

public abstract class SingleBullet implements Bullet {

    public final float bulletSize;
    public final float velocityFactor;

    public static final float BULLET_DENSITY = 0.9f;
    public static final Color BULLET_COLOR = new Color(1, 1, 1, 1);

    private Body bulletBody;
    private BodyDef bulletBodyDef;

    private final World world;
    private final float vX;
    private final float vY;
    private final float x;
    private final float y;

    public SingleBullet(World world, float angle, int velocity, Vector2 coordinates, float bulletSize, float velocityFactor) {
        this.world = world;
        this.vX = velocity * MathUtils.cos(angle) * velocityFactor;
        this.vY = velocity * MathUtils.sin(angle) * velocityFactor;
        this.x = coordinates.x;
        this.y = coordinates.y;
        this.bulletSize = bulletSize;
        this.velocityFactor = velocityFactor;
    }

    @Override
    public void fire() {
        Gdx.app.log("bullet", "shoot!");
        bulletBodyDef = new BodyDef();
        bulletBodyDef.type = BodyDef.BodyType.DynamicBody;
        Vector3 unprojected = new Vector3(x, y, 0);

        bulletBodyDef.position.set(new Vector2(unprojected.x, unprojected.y));
        bulletBody = world.createBody(bulletBodyDef);
        bulletBody.setUserData(GameUserData.createBulletData());
        PolygonShape bulletBox = new PolygonShape();
        bulletBox.setAsBox(bulletSize, bulletSize);
        Fixture bulletFixture = bulletBody.createFixture(bulletBox, BULLET_DENSITY);
        bulletFixture.setSensor(true);
        bulletBox.dispose();
        bulletBody.setSleepingAllowed(false);
        bulletBody.setLinearVelocity(vX, vY);
    }

    @Override
    public Vector2 getCoordinates() {
        return bulletBody.getPosition();
    }

    @Override
    public void render() {
        if (bulletBody != null) {
            Vector2 position = bulletBody.getPosition();
            game().shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
            game().shapeRenderer.setColor(BULLET_COLOR);
            game().shapeRenderer.identity();
            game().shapeRenderer.translate(position.x, position.y, 0);
            game().shapeRenderer.rotate(0, 0, -1, -bulletBody.getAngle() * MathUtils.radiansToDegrees);
            game().shapeRenderer.rect(-bulletSize, -bulletSize, bulletSize * 2, bulletSize * 2);
            game().shapeRenderer.end();
        }
/*
        for (Body bulletBody : bullets) {
            if (bulletBody != null) {
                Vector2 position = bulletBody.getPosition();
                shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
                shapeRenderer.identity();
                shapeRenderer.translate(position.x, position.y, 0);
                shapeRenderer.rotate(0, 0, -1, -bulletBody.getAngle() * MathUtils.radiansToDegrees);
                shapeRenderer.rect(-bulletSize, -bulletSize, bulletSize * 2, bulletSize * 2);
                shapeRenderer.end();
            }
        }
*/
    }

    @Override
    public void dispose() {
        ((GameUserData) bulletBody.getUserData()).isFlaggedForDelete = true;
        bulletBody = null;
    }

    @Override
    public boolean isAlive() {
        return bulletBody != null && !((GameUserData) bulletBody.getUserData()).isFlaggedForDelete; //todo: performance?
    }
}
