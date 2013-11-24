package com.astroberries.core.screens.mainmenu.sub.levels;

import com.astroberries.core.screens.common.BackButton;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.ui.Table;

public class SelectLevelSubScreen extends Group {

    public SelectLevelSubScreen() {
        setBounds(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        final Table levelIcons = new SelectLevelTable();
        final Actor back = new BackButton(StateName.CHOOSE_GAME);

        //levelIcons.debug(); //todo: delete

        addActor(levelIcons);
        addActor(back);
    }
}
