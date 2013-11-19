package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.config.GameLevel;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.screens.game.castle.view.weapon.WeaponHud;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Group;

public class CastleView extends Group {

    private final WeaponHud weaponHud;

    public CastleView(Castle castle, GameLevel level, World world) {
        setPosition(castle.getPosition().x, castle.getPosition().y);
        AimAreaActor aimArea = new AimAreaActor(castle);
        AimActor aim = new AimActor(castle, aimArea.getAimEnd());
        addActor(aimArea);
        addActor(aim);
        weaponHud = new WeaponHud(castle, level);
        addActor(weaponHud);
        addActor(new DebugPathActor(aimArea.getAimEnd(), castle, level.getVelocity(), world)); //todo remove
        addActor(new HealthActor(castle));
    }

    public int getBulletVariant() {
        return weaponHud.getWeapon();
    }
}
