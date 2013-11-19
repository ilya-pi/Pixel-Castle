package com.astroberries.core.screens.game.ai;

public class AIResp {

    private int weaponVariant;
    private float angle;

    public AIResp(int weaponVariant, float angle) {
        this.weaponVariant = weaponVariant;
        this.angle = angle;
    }

    public int getWeaponVariant() {
        return weaponVariant;
    }

    public void setWeaponVariant(int weaponVariant) {
        this.weaponVariant = weaponVariant;
    }

    public float getAngle() {
        return angle;
    }

    public void setAngle(float angle) {
        this.angle = angle;
    }
}
