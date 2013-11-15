package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.screens.game.castle.Castle;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Group;

public class CastleView extends Group {

    public CastleView(Castle castle, float bulletV, Vector2 gravity) {
        setPosition(castle.getPosition().x, castle.getPosition().y);
        AimAreaActor aimArea = new AimAreaActor(castle);
        AimActor aim = new AimActor(castle, aimArea.getAimEnd());
        addActor(aimArea);
        addActor(aim);
        addActor(new WeaponHudActor());
        addActor(new DebugPathActor(aimArea.getAimEnd(), castle, bulletV, gravity)); //todo remove
        addActor(new HealthActor(castle));
    }
}
