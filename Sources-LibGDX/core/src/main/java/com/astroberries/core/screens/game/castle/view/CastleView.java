package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.config.GameLevel;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.screens.game.castle.view.weapon.WeaponHud;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Group;

public class CastleView extends Group {

    public CastleView(Castle castle, GameLevel level, World world) {
        setPosition(castle.getPosition().x, castle.getPosition().y);
        AimAreaActor aimArea = new AimAreaActor(castle);
        AimActor aim = new AimActor(castle, aimArea.getAimEnd());
        addActor(aimArea);
        addActor(aim);
        addActor(new WeaponHud(castle, level));
        addActor(new DebugPathActor(aimArea.getAimEnd(), castle, level.getVelocity(), world)); //todo remove
        addActor(new HealthActor(castle));
    }
}
