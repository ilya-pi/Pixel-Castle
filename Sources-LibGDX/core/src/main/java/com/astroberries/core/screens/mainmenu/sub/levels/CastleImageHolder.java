package com.astroberries.core.screens.mainmenu.sub.levels;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;

import java.util.ArrayList;
import java.util.List;

public class CastleImageHolder {

    private final Texture accomplished;
    private final Texture accomplishedPushed;
    private final Texture current;
    private final Texture currentPushed;
    private final Texture locked;
    private final Texture lockedPushed;

    public CastleImageHolder() {
        List<Texture> buttons = new ArrayList<>();
        accomplished = new Texture(Gdx.files.internal("main/levels/level_select_castle_accomplished.png"));
        buttons.add(accomplished);
        accomplishedPushed = new Texture(Gdx.files.internal("main/levels/level_select_castle_accomplished_pushed.png"));
        buttons.add(accomplishedPushed);
        current = new Texture(Gdx.files.internal("main/levels/level_select_castle_current.png"));
        buttons.add(current);
        currentPushed = new Texture(Gdx.files.internal("main/levels/level_select_castle_current_pushed.png"));
        buttons.add(currentPushed);
        locked = new Texture(Gdx.files.internal("main/levels/level_select_castle_locked.png"));
        buttons.add(locked);
        lockedPushed = new Texture(Gdx.files.internal("main/levels/level_select_castle_locked_pushed.png"));
        buttons.add(lockedPushed);
        for (Texture button : buttons) {
            button.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        }
    }

    public Texture getAccomplished() {
        return accomplished;
    }

    public Texture getAccomplishedPushed() {
        return accomplishedPushed;
    }

    public Texture getCurrent() {
        return current;
    }

    public Texture getCurrentPushed() {
        return currentPushed;
    }

    public Texture getLocked() {
        return locked;
    }

    public Texture getLockedPushed() {
        return lockedPushed;
    }
}
