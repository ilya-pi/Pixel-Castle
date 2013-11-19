package com.astroberries.core.screens.game.castle;

import com.astroberries.core.screens.game.ai.AIResp;
import com.astroberries.core.screens.game.bullet.Bullet;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.physics.BulletContactListener;
import com.astroberries.core.screens.game.physics.PhysicsManager;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Actor;

public interface Castle {

    //state: access from actors
    public float getBiggestSide();
    public StateName getPlayer();
    public StateName getAiming();
    public StateName getBullet();
    public Vector2 getCannon();
    public Vector2 getPosition();
    public void setAngle(float angle);
    public int getHealth();

    //access from game screen
    public Actor getView();
    public void recalculateHealth(PhysicsManager physicsManager);
    public Pixmap getCastlePixmap();
    public Vector2 getCenter();
    public Bullet fire(int velocity, World world, BulletContactListener listener);
    public Bullet fireAi(int velocity, World world, BulletContactListener listener, AIResp resp);
    public int getWeaponVariant();

}
