package com.astroberries.core.screens.game.castle;

import com.astroberries.core.config.GameCastle;
import com.astroberries.core.config.GameLevel;
import com.astroberries.core.screens.game.bullet.Bullet;
import com.astroberries.core.screens.game.bullet.SingleBullet;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.castle.view.CastleView;
import com.astroberries.core.screens.game.physics.PhysicsManager;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.utils.Disposable;

public class CastleImpl implements Castle, Disposable {

    public static final int MIN_HEALTH = 10;
    public static final float CANNON_PADDING = 4;

    private final StateName player;
    private final StateName aiming;
    private final StateName bullet;

    private final Vector2 position;
    private final Vector2 cannon;
    private final Vector2 cannonAbsolute;
    private final Vector2 center;
    private final float size;

    private float angle;

    private final Group view;

    private final Pixmap castlePixmap;
    private final Location location;
    private final GameCastle castleConfig;
    private int health = 0;


    @Override
    public void dispose() {
        //todo: implement
    }

    public static enum Location {
        LEFT, RIGHT
    }

    public CastleImpl(int levelHeight, Location location, GameLevel levelConfig, World world) {
        this.location = location;
        float cannonX;
        if (location == Location.LEFT) {
            player = StateName.PLAYER1;
            aiming = StateName.AIMING1;
            bullet = StateName.BULLET1;
            castleConfig = levelConfig.getCastle1();
            castlePixmap = new Pixmap(Gdx.files.internal("castles/" + castleConfig.getImage()));
            cannonX = castlePixmap.getWidth() + CANNON_PADDING;
        } else {
            player = StateName.PLAYER2;
            aiming = StateName.AIMING2;
            bullet = StateName.BULLET2;
            castleConfig = levelConfig.getCastle2();
            castlePixmap = new Pixmap(Gdx.files.internal("castles/" + castleConfig.getImage()));
            cannonX = -CANNON_PADDING;
        }

        size = Math.max(castlePixmap.getHeight(), castlePixmap.getWidth());

        position = new Vector2(castleConfig.getX(), levelHeight - castleConfig.getY());
        float cannonY = castlePixmap.getHeight() + CANNON_PADDING;

        cannon = new Vector2(cannonX, cannonY);
        cannonAbsolute = new Vector2(position.x + cannonX, position.y + cannonY);

        float centerX = castleConfig.getX() + castlePixmap.getWidth() / 2;
        float centerY = levelHeight - (castleConfig.getY() - castlePixmap.getHeight() / 2);
        center = new Vector2(centerX, centerY);

        view = new CastleView(this, levelConfig, world);
    }

    @Override
    public float getBiggestSide() {
        return size;
    }

    @Override
    public StateName getPlayer() {
        return player;
    }

    @Override
    public StateName getAiming() {
        return aiming;
    }

    @Override
    public StateName getBullet() {
        return bullet;
    }

    @Override
    public Vector2 getCannon() {
        return cannon;
    }

    @Override
    public Vector2 getPosition() {
        return position;
    }

    @Override
    public void setAngle(float angle) {
        this.angle = angle;
    }

    @Override
    public Actor getView() {
        return view;
    }

    @Override
    public void recalculateHealth(PhysicsManager physicsManager) {
        Gdx.app.log("health", "health for " + location + " castle: " + health);
        health = physicsManager.calculateOpaquePixels(castleConfig.getX(), castleConfig.getY(), castlePixmap.getWidth(), castlePixmap.getHeight());
    }

    @Override
    public Pixmap getCastlePixmap() {
        return castlePixmap;
    }

    @Override
    public Vector2 getCenter() {
        return center;
    }

    @Override
    public int getHealth() {
        return health;
    }

    @Override
    public Bullet fire(int velocity, PixelCamera camera, World world) {
        Bullet bullet = new SingleBullet(world, angle, velocity, cannonAbsolute.x, cannonAbsolute.y);
        bullet.fire();
        return bullet;
    }

    @Override
    public Bullet fireAi(float aiAngle, int velocity, PixelCamera camera, World world) {
        Bullet bullet = new SingleBullet(world, aiAngle, velocity, cannonAbsolute.x, cannonAbsolute.y);
        bullet.fire();
        return bullet;
    }

}
