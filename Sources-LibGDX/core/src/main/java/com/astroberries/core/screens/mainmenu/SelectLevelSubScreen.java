package com.astroberries.core.screens.mainmenu;

import com.astroberries.core.CastleGame;
import com.astroberries.core.state.GameStates;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.*;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.badlogic.gdx.scenes.scene2d.utils.Drawable;
import com.badlogic.gdx.scenes.scene2d.utils.SpriteDrawable;

import java.util.ArrayList;
import java.util.List;

public class SelectLevelSubScreen extends AbstractSubScreen {

    public static final String TITLE_PNG = "title.png";
    public static final int TOTAL_LEVELS = 6;
    public static final String LEVEL_SELECT = "Level select";

    private List<Button> levelButtons = new ArrayList<Button>();


    private Table table = new Table();

    public SelectLevelSubScreen(final Skin skin, final CastleGame game) {

        this.table.setFillParent(true);
        Label caption = new Label(LEVEL_SELECT, skin);
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
                    game.getStateMachine().to(GameStates.LEVEL_OVERVIEW);
                }
            });
        }

        this.table.center();

        this.table.add(caption).colspan(TOTAL_LEVELS / 2).spaceBottom(50);
        this.table.row();
        for (int i = 0; i < levelButtons.size(); i++){
            if (i == TOTAL_LEVELS / 2){
                table.row();
            }
            Button tb = levelButtons.get(i);
            this.table.add(tb).width(50).height(50).pad(10, 25, 10, 25);
        }
    }

    @Override
    public Table getTable() {
        return this.table;
    }
}
