package com.astroberries.core.screens.game.subscreens;

import com.astroberries.core.screens.common.BlendBackgroundActor;
import com.astroberries.core.screens.common.ButtonFactory;
import com.astroberries.core.screens.common.pause.SettingsWidget;
import com.badlogic.gdx.scenes.scene2d.Group;

public class PauseSubScreen extends Group {

    public PauseSubScreen() {
        addActor(new BlendBackgroundActor());
        addActor(ButtonFactory.getPlayButton());
        addActor(new SettingsWidget());
    }

}
