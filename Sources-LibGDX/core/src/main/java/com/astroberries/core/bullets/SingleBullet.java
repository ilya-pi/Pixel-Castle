package com.astroberries.core.bullets;

import com.astroberries.core.screens.game.GameUserData;
import com.badlogic.gdx.graphics.Camera;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.physics.box2d.*;

public class SingleBullet implements Bullet {

    static final float BULLET_SIZE = 2;
    static final float BULLET_DENSITY = 0.3f;

    private Body bulletBody;
    private BodyDef bulletBodyDef;

    private final Camera camera;
    private final World world;
    private final float impulseX;
    private final float impulseY;
    private final float x;
    private final float y;

    public SingleBullet(Camera camera, World world, float impulseX, float impulseY, float x, float y) {
        this.camera = camera;
        this.world = world;
        this.impulseX = impulseX;
        this.impulseY = impulseY;
        this.x = x;
        this.y = y;
    }

    @Override
    public void fire() {
        bulletBodyDef = new BodyDef();
        bulletBodyDef.type = BodyDef.BodyType.DynamicBody;
        Vector3 unprojected = new Vector3(x, y, 0);
        camera.unproject(unprojected);

        bulletBodyDef.position.set(new Vector2(unprojected.x, unprojected.y));
        bulletBody = world.createBody(bulletBodyDef);
        bulletBody.setUserData(GameUserData.createBulletData());
        //bodies.add(bulletBody);
        PolygonShape bulletBox = new PolygonShape();
        bulletBox.setAsBox(BULLET_SIZE, BULLET_SIZE);
        Fixture bulletFixture = bulletBody.createFixture(bulletBox, BULLET_DENSITY);
        bulletFixture.setSensor(true);
        bulletBox.dispose();
        bulletBody.setSleepingAllowed(false);

        bulletBody.applyLinearImpulse(impulseX, impulseY, x, y, false);
    }

    @Override
    public Vector2 getCoordinates() {
        return bulletBody.getPosition();
    }

    @Override
    public void render(ShapeRenderer shapeRenderer) {
        if (bulletBody != null) {
            Vector2 position = bulletBody.getPosition();
            shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
            shapeRenderer.identity();
            shapeRenderer.translate(position.x, position.y, 0);
            shapeRenderer.rotate(0, 0, -1, -bulletBody.getAngle() * MathUtils.radiansToDegrees);
            shapeRenderer.rect(-BULLET_SIZE, -BULLET_SIZE, BULLET_SIZE * 2, BULLET_SIZE * 2);
            shapeRenderer.end();
        }
/*
        for (Body bulletBody : bullets) {
            if (bulletBody != null) {
                Vector2 position = bulletBody.getPosition();
                shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
                shapeRenderer.identity();
                shapeRenderer.translate(position.x, position.y, 0);
                shapeRenderer.rotate(0, 0, -1, -bulletBody.getAngle() * MathUtils.radiansToDegrees);
                shapeRenderer.rect(-BULLET_SIZE, -BULLET_SIZE, BULLET_SIZE * 2, BULLET_SIZE * 2);
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
        return bulletBody != null;
    }
}
