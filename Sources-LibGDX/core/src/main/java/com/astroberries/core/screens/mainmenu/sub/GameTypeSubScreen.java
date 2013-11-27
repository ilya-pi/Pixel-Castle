package com.astroberries.core.screens.mainmenu.sub;

import com.astroberries.core.CastleGame;
import com.astroberries.core.screens.common.ButtonFactory;
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

public class GameTypeSubScreen extends Group {

    public static final String CAMPAIGN = "Campaign";
    public static final String TWO_PLAYERS = "Two players";

    private final Table buttons = new Table(game().getSkin());
    private final Actor back = ButtonFactory.getBackButton(StateName.MAINMENU);

    public GameTypeSubScreen() {
        float ratio = game().getRatio();
        setBounds(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        final Label title = new Label("Choose game", game().getSkin(), CastleGame.HUGE_TITLE_WHITE_STYLE);
        final TextButton campaign = new TextButton(CAMPAIGN, game().getSkin());
        final TextButton twoPlayers = new TextButton(TWO_PLAYERS, game().getSkin());
        campaign.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.LEVEL_SELECT);
            }
        });
        twoPlayers.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.LEVEL_OVERVIEW);
            }
        });

        float padBottom = 16 * 4.5f * ratio;
        float buttonHeight = 16 * 4.5f * ratio;

        buttons.setFillParent(true);
        buttons.bottom().padBottom(padBottom);
        buttons.row();
        buttons.add(title).colspan(2).padBottom(16 * 18 * ratio);
        buttons.row();
        buttons.add(campaign).width(35 * 7.5f * ratio).height(buttonHeight).padRight(16 * 4 * ratio);
        buttons.add(twoPlayers).width(35 * 7.5f * ratio).height(buttonHeight);

        addActor(buttons);
        addActor(back);
    }

}
