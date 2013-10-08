package com.astroberries.core.screens.game;

import com.badlogic.gdx.math.Vector2;


public class GameUserData {
    public enum Type {
        BRICK, BULLET
    }

    public boolean isFlaggedForDelete = false;
    public Vector2 position;
    public Type type;

    public static GameUserData createBulletData() {
        GameUserData data = new GameUserData();
        data.type = Type.BULLET;
        return data;
    }

    public static GameUserData createBrickData(int x, int y) {
        GameUserData data = new GameUserData();
        data.type = Type.BRICK;
        data.position = new Vector2(x, y);
        return data;
    }

}
