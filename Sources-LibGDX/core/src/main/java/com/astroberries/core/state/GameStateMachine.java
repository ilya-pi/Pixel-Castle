package com.astroberries.core.state;

import java.util.Stack;

public class GameStateMachine {

    protected GameState currentState;
    protected Stack<GameStates> history = new Stack<GameStates>();

    private static int HISTORY_MAX_DEPTH = 10;

    public GameStateMachine(GameState currentState) {
        this.currentState = currentState;
    }

    public void to(GameStates target) {
        this.currentState.transitionTo(target);
        history.push(target);
        if (history.size() > HISTORY_MAX_DEPTH) {
            history.remove(0);
        }
        this.currentState = GameState.lookup(target);
    }

    public void back() {
        if (this.history.size() >= 0) {
            this.currentState.transitionTo(this.history.pop());
        }
    }
}
