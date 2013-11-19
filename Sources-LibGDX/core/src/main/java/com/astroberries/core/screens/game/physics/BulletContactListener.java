package com.astroberries.core.screens.game.physics;

import com.astroberries.core.screens.game.GameScreen;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.physics.box2d.*;

public class BulletContactListener implements ContactListener {

    private final PhysicsManager physicsManager;
    private Pixmap bulletPixmap;

    public BulletContactListener(PhysicsManager physicsManager) {
        this.physicsManager = physicsManager;
    }

    public void setBulletPixmap(Pixmap bulletPixmap) {
        this.bulletPixmap = bulletPixmap;
    }

    @Override
    public void beginContact(Contact contact) {
        Fixture f1=contact.getFixtureA();
        Body b1=f1.getBody();
        Fixture f2=contact.getFixtureB();
        Body b2=f2.getBody();
        GameUserData d1 = (GameUserData) b1.getUserData();
        GameUserData d2 = (GameUserData) b2.getUserData();
        if (d1 != null && d2 != null && !d1.isFlaggedForDelete && !d2.isFlaggedForDelete) {
//            Gdx.app.log("contact", "contact!!");
            if (d1.type == GameUserData.Type.BRICK && d2.type == GameUserData.Type.BULLET) {
                //1 - brick
                //2 - bullet
                physicsManager.calculateHit(d2, d1, bulletPixmap);
            } else if (d2.type == GameUserData.Type.BRICK && d1.type == GameUserData.Type.BULLET) {
                //1 - bullet
                //2 - brick
                physicsManager.calculateHit(d1, d2, bulletPixmap);
            } else {
                //do nothing
            }
        }
    }

    @Override
    public void endContact(Contact contact) {
    }

    @Override
    public void preSolve(Contact contact, Manifold manifold) {
    }

    @Override
    public void postSolve(Contact contact, ContactImpulse contactImpulse) {
    }

}
