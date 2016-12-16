import * as React from 'react';

export default class MenuBar extends React.Component{

  constructor(props){

    super(props);
    this['state'] = {

      open: false
    };
  }

  toggle(event){

    var open = (this['state']['open']) ? false : true;
    this.setState({ open: open });
  }

  closePanel(event){

    this.setState({ open: false });
  }

  logOut(event){

    this.setState({ open: false });
    this['props'].logOut();
  }

  renderUserMenu(){

    var userInfo = this['props']['userInfo'];
    if(userInfo['loginStatus'] && !userInfo['loginError']){

      var height = (this['state']['open']) ? 'auto' : '100%';
      var userDropdownGroupProps = {

        className: 'user-menu-dropdown-group',
        style: { height: height },
        onMouseLeave: this.closePanel.bind(this)
      };

      return (

        <div { ...userDropdownGroupProps } >

          <button className='user-menu-dropdown-btn' onClick={ this['toggle'].bind(this) } >

            { userInfo['userEmail'] }

            <div className='user-menu-arrow-group'>
              
              <span className='glyphicon glyphicon-triangle-bottom'></span>
            </div>
          </button>
          <div className='user-dropdown-menu'>

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

        { this.renderUserMenu() }
      </div>
    );
  } 
}