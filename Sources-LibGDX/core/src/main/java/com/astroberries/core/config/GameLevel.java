package com.astroberries.core.config;

public class GameLevel {

    private String name;
    private String path;
    private int number;
    private int impulse;
    private GameCastle castle1;
    private GameCastle castle2;

    public int getImpulse() {
        return impulse;
    }

    public void setImpulse(int impulse) {
        this.impulse = impulse;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }


    public void setName(String name) {
        this.name = name;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public void setCastle1(GameCastle castle1) {
        this.castle1 = castle1;
    }

    public void setCastle2(GameCastle castle2) {
        this.castle2 = castle2;
    }

    public String getName() {

        return name;
    }

    public int getNumber() {
        return number;
    }

    public GameCastle getCastle1() {
        return castle1;
    }

    public GameCastle getCastle2() {
        return castle2;
    }
}
