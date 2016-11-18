import * as React from 'react';

export default class MenuBar extends React.Component{

  constructor(props){

    super(props);

    this['state'] = {

      open: false
    }
  }

  toggle(event){

    var open = (this['state']['open']) ? false : true;
    this.setState({ open: open });
  }

  logOut(event){

    this.setState({ open: false });
    this['props'].logOut();
  }

  renderUserMenu(){

    var appState = this['props']['appState'];
    var userInfo = appState['userInfo'];
    if(appState['loginStatus'] && !appState['loginError']){

      var height = (this['state']['open']) ? 'auto' : '100%';
      return (

        <div className='user-menu-dropdown-group' style={{ height: height }}>

          <button className='user-menu-dropdown-btn' onClick={ this['toggle'].bind(this) } >

            { userInfo['userEmail'] }

            <div className='user-menu-arrow-group'>
              
              <span className='glyphicon glyphicon-triangle-bottom'></span>
            </div>
          </button>
          <div className='user-dropdown-menu'>

            <a href='/user' className='user-dropdown-menu-item'>
              
              { 'user settings' }
            </a>
            <a href='/admin' className='user-dropdown-menu-item'>

              { 'admin settings' }
            </a>
            <div className='user-dropdown-menu-item' onClick={ this['logOut'].bind(this) }>

              { 'log out' }
            </div>
          </div>
        </div>
      );
    }
    else{

      return ''
    }
  }

  render(){

    return (

      <div id='nav-menu'>

        {/*
        <div id='master-search-group'>

          <button id='master-search-button'>

            <span className='glyphicon glyphicon-search white-glyphicon'></span>
          </button>
        </div>
        <button className='nav-menu-btn'>

          { 'ACTIVITY' }
        </button>
        <button className='nav-menu-btn'>

          { 'DOCS' }
        </button>
        <button className='nav-menu-btn'>

          { 'PLOT' }
        </button>
        <a className='nav-menu-btn' href='./experiments.html'>

          { 'EXPERIMENTS' }
        </a>
        */}

        { this.renderUserMenu() }
      </div>
    );
  } 
}