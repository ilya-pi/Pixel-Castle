package com.astroberries.core;

import com.astroberries.core.screens.mainmenu.MainScreen;
import com.astroberries.core.screens.game.GameScreen;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.astroberries.core.state.StateMachine;
import com.astroberries.core.state.StateMashineBuilder;
import com.astroberries.core.state.StateName;
import com.astroberries.core.state.Transition;

import static com.astroberries.core.state.StateName.*;

public class CastleGame extends Game {


    public SpriteBatch spriteBatch;
    public ShapeRenderer shapeRenderer;
    private GameScreen gameScreen;

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
        Transition createGameScreen = new Transition() {
            @Override
            public void execute() {
                //todo: here we should set level and set number (set is a group of levels displayed on screen)
                gameScreen = GameScreen.geCreate(CastleGame.INSTANCE, 0, 0);
                CastleGame.INSTANCE.setScreen(gameScreen);
                MainScreen.geCreate(CastleGame.INSTANCE).dispose();
            }
        };
        Transition mainMenuToOverview = new Transition() {
            @Override
            public void execute() {
                gameScreen.mainMenuToOverview();
            }
        };
        Transition toCastle1 = new Transition() {
            @Override
            public void execute() {
                gameScreen.toCastle1();
            }
        };
        Transition player1ToAiming1 = new Transition() {
            @Override
            public void execute() {
                gameScreen.player1ToAiming1();
            }
        };
        Transition aiming1ToBullet1 = new Transition() {
            @Override
            public void execute() {
                gameScreen.aiming1ToBullet1();
            }
        };
        Transition toCastle2 = new Transition() {
            @Override
            public void execute() {
                gameScreen.toCastle2();
            }
        };
        Transition player2ToAiming2 = new Transition() {
            @Override
            public void execute() {
                gameScreen.player2ToAiming2();
            }
        };
        Transition aiming2ToBullet2 = new Transition() {
            @Override
            public void execute() {
                gameScreen.aiming2ToBullet2();
            }
        };
        Transition player1lost = new Transition() {
            @Override
            public void execute() {
                Gdx.app.log("state", "Show win/lost screen! 1st lost.");
            }
        };
        Transition player2lost = new Transition() {
            @Override
            public void execute() {
                Gdx.app.log("state", "Show win/lost screen! 2nd lost.");
            }
        };
        Transition updateWind = new Transition() {
            @Override
            public void execute() {
                gameScreen.updateWind();
            }
        };


        return new StateMashineBuilder()
                .from(NIL).to(MAINMENU).with(nilToMainMenu)
                .from(MAINMENU).to(CHOOSE_GAME).with(mainMenuToChooseGame)
                               .to(LEVEL_OVERVIEW).with(createGameScreen, mainMenuToOverview)

                .from(LEVEL_OVERVIEW).to(CAMERA_MOVING_TO_PLAYER_1).with(toCastle1)
                .from(CAMERA_MOVING_TO_PLAYER_1).to(PLAYER1).with(updateWind)
                .from(PLAYER1).to(AIMING1).with(player1ToAiming1)
                .from(AIMING1).to(BULLET1).with(aiming1ToBullet1)
                .from(BULLET1).to(CAMERA_MOVING_TO_PLAYER_2).with(toCastle2)
                              .to(PLAYER_2_LOST).with(player2lost)
                              .to(PLAYER_1_LOST).with(player1lost)
                .from(CAMERA_MOVING_TO_PLAYER_2).to(PLAYER2).with(updateWind)
                .from(PLAYER2).to(AIMING2).with(player2ToAiming2)
                .from(AIMING2).to(BULLET2).with(aiming2ToBullet2)
                .from(BULLET2).to(CAMERA_MOVING_TO_PLAYER_1).with(toCastle1)
                              .to(PLAYER_2_LOST).with(player2lost)
                              .to(PLAYER_1_LOST).with(player1lost)
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
