export default class JanusReducer{

  reducer(){

    return (state = {}, action)=>{

      switch(action['type']){

        case 'LOG_IN':

          var userInfo = Object.assign({}, state);
          userInfo['userEmail'] = action['data']['email'];
          return userInfo;
        case 'LOGGED_IN':

          var userInfo = Object.assign({}, state);
          
          // Copy the new data from the auth server to the local Redux store.
          for(var key in action['data']){

            userInfo[key] = action['data'][key];
          }

          userInfo['loginStatus'] = true;
          userInfo['loginError'] = false;
          return userInfo;
        case 'LOGGED_OUT':

          var userInfo = Object.assign({}, state);

          // Clear the local data.
          for(var key in userInfo){

            userInfo[key] = '';
          }

          userInfo['loginStatus'] = false;
          userInfo['logError'] = false;
          userInfo['loginErrorMsg'] = 'Invalid sign in.';
          return userInfo;
        case 'LOG_ERROR':

          var userInfo = Object.assign({}, state);
          userInfo['loginStatus'] = false;
          userInfo['loginError'] = true;
          return userInfo;
        default:

          var nextState = Object.assign({}, state);
          return nextState;
      }
    };
  }
}