export default class MetisReducer{

  reducer(){

    return (state = {}, action)=>{

      switch(action['type']){

        case 'LOG_IN':

          var nextState = Object.assign({}, state);
          nextState['userInfo']['userEmail'] = action['data']['email'];
          return nextState;
        case 'LOGGED_IN':

          var nextState = Object.assign({}, state);

          // Copy the new data from the auth server to the local Redux store.
          for(var key in action['data']){

            nextState['userInfo'][key] = action['data'][key];
          }

          nextState['loginStatus'] = true;
          nextState['loginError'] = false;
          return nextState;
        case 'LOGGED_OUT':

          var nextState = Object.assign({}, state);

          for(var key in nextState['userInfo']){

            nextState['userInfo'][key] = '';
          }

          nextState['loginStatus'] = false;
          nextState['logError'] = false;

          return nextState;
        case 'LOG_ERROR':

          var nextState = Object.assign({}, state);
          nextState['loginStatus'] = false;
          nextState['loginError'] = true;
          return nextState;
        default:

          var nextState = Object.assign({}, state);
          return nextState;
      }
    };
  }
}