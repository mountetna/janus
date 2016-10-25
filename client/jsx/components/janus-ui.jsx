import * as React from 'react'

import TitleBar  from './nav/title-bar';
import MenuBar   from './nav/menu-bar';

import LoginPanel from './auth/login-panel'

export default class JanusUI extends React.Component{

  constructor(){

    super();
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

          <LoginPanel callbacks={ this['props']['callbacks'] } />
        </div>
      </div>
    );
  }
}