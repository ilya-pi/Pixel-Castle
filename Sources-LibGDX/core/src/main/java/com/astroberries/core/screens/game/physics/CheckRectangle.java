package com.astroberries.core.screens.game.physics;

public class CheckRectangle {

    public int startX, startY, endX, endY;
    public boolean checked = false;

    public CheckRectangle(int startX, int startY, int endX, int endY) {
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
    }

}
