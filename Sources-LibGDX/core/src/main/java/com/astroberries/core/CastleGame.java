package com.astroberries.core;

import com.astroberries.core.config.GlobalGameConfig;
import com.astroberries.core.screens.mainmenu.MainScreen;
import com.astroberries.core.screens.game.GameScreen;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.astroberries.core.state.StateMachine;
import com.astroberries.core.state.StateMashineBuilder;
import com.astroberries.core.state.StateName;
import com.astroberries.core.state.Transition;

import java.util.Timer;
import java.util.TimerTask;

import static com.astroberries.core.state.StateName.*;
import static com.astroberries.core.state.StateName.BULLET2;
import static com.astroberries.core.state.StateName.PLAYER1;

public class CastleGame extends Game {


    public SpriteBatch spriteBatch;
    public ShapeRenderer shapeRenderer;

    private StateMachine stateMachine;

    public static CastleGame INSTANCE;

    public CastleGame() {
        super();
        CastleGame.INSTANCE = this;
    }

    @Override
    public void create() {
        spriteBatch = new SpriteBatch();
        shapeRenderer = new ShapeRenderer();
        Texture.setEnforcePotImages(false);
        this.stateMachine = initStateMachine();
        this.stateMachine.transitionTo(StateName.MAINMENU);
    }

    private StateMachine initStateMachine() {
        Transition nilToMainMenu = new Transition() {
            @Override
            public void execute() {
                CastleGame.INSTANCE.setScreen(MainScreen.geCreate(CastleGame.INSTANCE));
            }
        };
        Transition mainMenuToChooseGame = new Transition() {
            @Override
            public void execute() {
            }
        };
        Transition mainMenuToOverview = new Transition() {
            @Override
            public void execute() {
                //todo: here we should set level and set number (set is a group of levels displayed on screen)
                GameScreen gameScreen = GameScreen.geCreate(CastleGame.INSTANCE, 0, 0);
                CastleGame.INSTANCE.setScreen(gameScreen);
                gameScreen.camera.to(PixelCamera.CameraState.OVERVIEW, null);
                new Timer().schedule(new TimerTask() {
                    @Override
                    public void run() {
                        CastleGame.INSTANCE.getStateMachine().transitionTo(StateName.PLAYER1);
                    }
                }, GlobalGameConfig.LEVEL_INTRO_TIMEOUT);

                MainScreen.geCreate(CastleGame.INSTANCE).dispose();
            }
        };
        Transition levelOverviewToPlayer1 = new Transition() {
            @Override
            public void execute() {
                GameScreen.geCreate().camera.to(PixelCamera.CameraState.CASTLE1, null);
            }
        };
        Transition player1ToBullet1 = new Transition() {
            @Override
            public void execute() {
            }
        };
        Transition bullet1ToPlayer2 = new Transition() {
            @Override
            public void execute() {
            }
        };
        Transition player2ToBullet2 = new Transition() {
            @Override
            public void execute() {
            }
        };
        Transition bullet2ToPlayer1 = new Transition() {
            @Override
            public void execute() {
            }
        };

        return new StateMashineBuilder()
                .from(NIL).to(MAINMENU).with(nilToMainMenu)
                .from(MAINMENU).to(CHOOSE_GAME).with()
                .to(LEVEL_OVERVIEW).with(mainMenuToOverview)
                .from(LEVEL_OVERVIEW).to(PLAYER1).with(levelOverviewToPlayer1)
                .from(PLAYER1).to(BULLET1).with(player1ToBullet1)
                .from(BULLET1).to(PLAYER2).with(bullet1ToPlayer2)
                .from(PLAYER2).to(BULLET2).with(player2ToBullet2)
                .from(BULLET2).to(PLAYER1).with(bullet2ToPlayer1)
                .build();
    }

    @Override
    public void render() {
        super.render();
    }

    @Override
    public void dispose() {
        spriteBatch.dispose();
    }

    public StateMachine getStateMachine() {
        return stateMachine;
    }
}
