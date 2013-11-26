package com.astroberries.core.screens.mainmenu.sub;

import com.astroberries.core.CastleGame;
import com.astroberries.core.screens.common.ButtonFactory;
import com.astroberries.core.screens.common.pause.SettingsWidget;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class SettingsSubScreen extends Group {

    private final Table buttons = new Table(game().getSkin());
    private final Actor back = ButtonFactory.getBackButton(StateName.MAINMENU);

    public SettingsSubScreen() {
        float ratio = game().getRatio();
        setBounds(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        final Label title = new Label("Options", game().getSkin(), CastleGame.TITLE_WHITE_STYLE);
        final TextButton credits = new TextButton("Credits", game().getSkin());
        credits.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                //todo: credits
            }
        });

        buttons.setFillParent(true);
        buttons.center();
        buttons.add(title).padBottom(16 * 2 * ratio);
        buttons.row();
        buttons.add(new SettingsWidget()).padBottom(16 * 2.5f * ratio);
        buttons.row();
        buttons.add(credits).width(35 * 7.5f * ratio).height(16 * 4.5f * ratio);
        //buttons.debug(); //todo: delete

        addActor(buttons);
        addActor(back);
    }
}
