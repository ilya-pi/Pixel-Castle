package com.astroberries.core.screens.mainmenu.sub;

import com.astroberries.core.CastleGame;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.*;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.badlogic.gdx.scenes.scene2d.utils.SpriteDrawable;
import com.astroberries.core.state.StateName;

import java.util.ArrayList;
import java.util.List;

import static com.astroberries.core.CastleGame.game;

public class SelectLevelSubScreen extends Table {

    public static final int TOTAL_LEVELS = 6;
    public static final String LEVEL_SELECT = "Level select";

    private List<Button> levelButtons = new ArrayList<>();

    public SelectLevelSubScreen() {

        setFillParent(true);
        Label caption = new Label(LEVEL_SELECT, game().getSkin());
        caption.setFontScale(2.0f);

        SpriteDrawable regular = new SpriteDrawable(new Sprite(new Texture("ui/level_select_castle_current.png")));
        SpriteDrawable pressed = new SpriteDrawable(new Sprite(new Texture("ui/level_select_castle_current_pushed.png")));
        //todo ilya: select proper font here
        ImageTextButton.ImageTextButtonStyle castleButtonStyle =
                new ImageTextButton.ImageTextButtonStyle(regular, pressed, null, new BitmapFont());

        for (int i = 0; i < TOTAL_LEVELS; i++){
            ImageTextButton tb = new ImageTextButton(Integer.toString(i), castleButtonStyle);
            levelButtons.add(tb);
            tb.addListener(new ClickListener() {
                @Override
                public void clicked(InputEvent event, float x, float y) {
                    game().getStateMachine().transitionTo(StateName.LEVEL_OVERVIEW);
                }
            });
        }

        center();

        add(caption).colspan(TOTAL_LEVELS / 2).spaceBottom(50);
        row();
        for (int i = 0; i < levelButtons.size(); i++){
            if (i == TOTAL_LEVELS / 2){
                row();
            }
            Button tb = levelButtons.get(i);
            add(tb).width(50).height(50).pad(10, 25, 10, 25);
        }
    }
}
