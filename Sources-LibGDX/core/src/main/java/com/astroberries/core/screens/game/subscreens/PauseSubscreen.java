package com.astroberries.core.screens.game.subscreens;

import com.astroberries.core.CastleGame;
import com.astroberries.core.screens.common.BlendBackgroundActor;
import com.astroberries.core.screens.common.ButtonFactory;
import com.astroberries.core.screens.common.pause.SettingsWidget;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class PauseSubScreen extends Group {

    private final Table buttons = new Table(game().getSkin());

    public PauseSubScreen() {
        float ratio = game().getRatio();
        setBounds(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
        addActor(new BlendBackgroundActor(new Color(20f / 255, 20f / 255, 20f / 255, 100.0f / 255))); //todo: pick correct color
        addActor(ButtonFactory.getPlayButton());

        final Label title = new Label("Pause", game().getSkin(), CastleGame.TITLE_WHITE_STYLE);
        final TextButton mainMenu = new TextButton("Back to main menu", game().getSkin());
        mainMenu.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.MAINMENU);
            }
        });

        buttons.setFillParent(true);
        buttons.center();
        buttons.add(title).padBottom(16 * 2 * ratio);
        buttons.row();
        buttons.add(new SettingsWidget()).padBottom(16 * 2.5f * ratio);
        buttons.row();
        buttons.add(mainMenu).width(35 * 12f * ratio).height(16 * 4.5f * ratio);
        //buttons.debug(); //todo: delete

        addActor(buttons);
    }

}
