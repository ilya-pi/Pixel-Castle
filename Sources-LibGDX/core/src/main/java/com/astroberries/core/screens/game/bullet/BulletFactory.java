package com.astroberries.core.screens.game.bullet;

import com.astroberries.core.screens.game.physics.BulletContactListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.World;

public class BulletFactory {

    //todo: refactor static methods and move pixmaps to bullets
    static Pixmap[] pixmaps = new Pixmap[3];
    static {
        pixmaps[0] = new Pixmap(Gdx.files.internal("bullets/11.png"));
        pixmaps[1] = new Pixmap(Gdx.files.internal("bullets/15.png"));
        pixmaps[2] = new Pixmap(Gdx.files.internal("bullets/7.png"));
    }

    public static Bullet createBullet(BulletContactListener listener, World world, float levelWidth, float angle, int velocity, Vector2 coordinates, int num) {
        switch (num) {
            case 0:
                listener.setBulletPixmap(pixmaps[0]);
                return new SmallBullet(world, levelWidth, angle, velocity, coordinates);
            case 1:
                listener.setBulletPixmap(pixmaps[1]);
                return new BigBullet(world, levelWidth, angle, velocity, coordinates);
            case 2:
                listener.setBulletPixmap(pixmaps[2]);
                return new MultipleBullet(world, levelWidth, angle, velocity, coordinates);
        }
        throw new IllegalAccessError("no such bullet");
    }
}
