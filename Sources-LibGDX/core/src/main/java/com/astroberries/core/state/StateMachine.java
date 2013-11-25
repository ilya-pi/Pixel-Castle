package com.astroberries.core.state;

import com.astroberries.core.state.internal.GameState;

public interface StateMachine {

    public StateName getCurrentState();

    public void transitionTo(StateName state);

    public void addState(GameState state);

    public StateName getPreviousState();
}
