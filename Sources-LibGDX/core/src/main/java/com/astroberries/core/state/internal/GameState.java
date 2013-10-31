package com.astroberries.core.state.internal;

import com.astroberries.core.state.StateName;
import com.astroberries.core.state.Transition;

import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class GameState {

    private StateName name;
    private Map<StateName, LinkedList<Transition>> toStates;

    public GameState(StateName name, Map<StateName, LinkedList<Transition>> toStates) {
        this.name = name;
        this.toStates = toStates;
    }

    public StateName getName() {
        return name;
    }

    public boolean isToStateExist(StateName toState) {
        return toStates.containsKey(toState);
    }

    public LinkedList<Transition> getTransitions(StateName toState) {
        return toStates.get(toState);
    }
}
