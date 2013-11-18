package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.screens.game.castle.view.weapon.WeaponHud;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Group;

public class CastleView extends Group {

    public CastleView(Castle castle, float bulletV, World world) {
        setPosition(castle.getPosition().x, castle.getPosition().y);
        AimAreaActor aimArea = new AimAreaActor(castle);
        AimActor aim = new AimActor(castle, aimArea.getAimEnd());
        addActor(aimArea);
        addActor(aim);
        addActor(new WeaponHud(castle));
        addActor(new DebugPathActor(aimArea.getAimEnd(), castle, bulletV, world)); //todo remove
        addActor(new HealthActor(castle));
    }
}
