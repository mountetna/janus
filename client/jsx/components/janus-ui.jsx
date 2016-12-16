import * as React from 'react';

import TitleBar  from './nav/title-bar';
import MenuBarContainer   from './nav/menu-bar-container';
import LoginPanelContainer from './auth/login-panel-container';
import UserPanelContainer from './user/user-panel-container';

export default class JanusUI extends React.Component{

  constructor(){

    super();
  }

  routeUI(){

    return <UserPanelContainer />;
  }

  renderLoginView(){

    if(this['props']['userInfo']['loginStatus']){

      return this.routeUI();
    }
    else{

      return <LoginPanelContainer />;
    }
  }

  render(){

    return (

      <div id='janus-group'>

        <div id='header-group'>
          
          <TitleBar />
          <MenuBarContainer />
        </div>
        <div className='logo-group'>

          <img src='/img/logo_basic.png' alt='' />
        </div>
        <div id='left-column-group'>
        </div>
        <div id='user-info-group'>

          { this.renderLoginView() }
        </div>
      </div>
    );
  }
}