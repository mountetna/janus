export default class MetisReducer{

  reducer(){

    return (state = {}, action)=>{

      switch(action['type']){

        case 'START_LOGIN':

          var nextState = Object.assign({}, state);
          nextState['userInfo']['userEmail'] = action['data']['email'];
          return nextState;

        case 'LOGGED_IN':

          var nextState = Object.assign({}, state);
          nextState['userInfo']['authToken'] = action['data']['authToken'];
          nextState['loginStatus'] = true;
          nextState['loginError'] = false;
          return nextState;

        case 'LOG_ERROR':

          var nextState = Object.assign({}, state);
          nextState['loginStatus'] = false;
          nextState['loginError'] = true;
          return nextState
        default:

          var nextState = Object.assign({}, state);
          return nextState;
      }
    };
  }
}