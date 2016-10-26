import * as Redux from 'redux';

import JanusReducer from './janus-reducer';
import LastActionReducer from './last-action-reducer';

export default class JanusModel{

  constructor(){

    var janusState = new JanusReducer();
    var lastAction = new LastActionReducer();
    var reducer = Redux.combineReducers({

      janusState: janusState.reducer(),
      lastAction: lastAction.reducer()
    });

    var defaultState = {

      janusState: {

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