import * as React from 'react';

import TitleBar  from './nav/title-bar';
import MenuBar   from './nav/menu-bar';

import LoginPanelContainer from './auth/login-panel-container';
import UserPanelContainer from './user/user-panel-container';

export default class JanusUI extends React.Component{

  constructor(){

    super();
  }

  renderLoginView(){

    if(this['props']['janusState']['loginStatus']){

      return <UserPanelContainer />;
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
          <MenuBar />
        </div>
        <div className='logo-group'>

          <img src='/img/logo_dna_color_round.png' alt='' />
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