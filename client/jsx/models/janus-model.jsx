import * as Redux from 'redux';

import JanusReducer from './janus-reducer';
import LastActionReducer from './last-action-reducer';

export default class JanusModel{

  constructor(){

    var appState = new JanusReducer();
    var lastAction = new LastActionReducer();
    var reducer = Redux.combineReducers({

      appState: appState.reducer(),
      lastAction: lastAction.reducer()
    });

    var defaultState = {

      appState: {

        userInfo: {

          userEmail: '',
          authToken: '',
          firstName: '',
          lastName: ''
        },

        loginStatus: false,
        loginError: false
      }
    };

    this.store = Redux.createStore(reducer, defaultState);
  }
}