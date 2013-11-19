package com.astroberries.core.screens.game.bullet;

import com.astroberries.core.screens.game.physics.GameUserData;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.physics.box2d.*;

public class MultipleBullet extends AbstractBullet {

    public static final int BULLET_COUNT = 5;
    public static final float BULLET_SIZE = 1;
    public static final float VELOCITY_FACTOR = 1f;

    private Body tracer;

    public MultipleBullet(World world, float levelWidth, float angle, int velocity, Vector2 coordinates) {
        super(world, levelWidth, angle, velocity, coordinates, BULLET_SIZE, BULLET_COUNT, VELOCITY_FACTOR);
    }

    @Override
    public void fire() {
        super.fire();
        BodyDef bulletBodyDef = new BodyDef();
        bulletBodyDef.type = BodyDef.BodyType.DynamicBody;
        Vector3 unprojected = new Vector3(x, y, 0);

        bulletBodyDef.position.set(new Vector2(unprojected.x, unprojected.y));
        tracer = world.createBody(bulletBodyDef);
        tracer.setUserData(GameUserData.createTracerData());
        PolygonShape bulletBox = new PolygonShape();
        bulletBox.setAsBox(bulletSize, bulletSize);
        Fixture bulletFixture = tracer.createFixture(bulletBox, BULLET_DENSITY);
        bulletFixture.setSensor(true);
        bulletBox.dispose();
        tracer.setSleepingAllowed(false);
        float vX = finalVelocity * MathUtils.cos(initialAngle);
        float vY = finalVelocity * MathUtils.sin(initialAngle);

        tracer.setLinearVelocity(vX, vY);
    }

    @Override
    public Vector2 getCoordinates() {
        return tracer.getPosition();
    }

    @Override
    public void dispose() {
        super.dispose();
        ((GameUserData) tracer.getUserData()).isFlaggedForDelete = true;
    }
}
