package com.astroberries.core.screens.game.bullet;

import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.World;

public class SmallBullet extends SingleBullet {

    public static final float BULLET_SIZE = 2;
    public static final float VELOCITY_FACTOR = 1f;

    public SmallBullet(World world, float angle, int velocity, Vector2 coordinates) {
        super(world, angle, velocity, coordinates, BULLET_SIZE, VELOCITY_FACTOR);
    }
}
