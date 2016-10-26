import * as ReactRedux from 'react-redux';
import UserPanel from './user-panel';

const mapStateToProps = (state, ownProps)=>{

  // state == redux store
  return {

    janusState: state['janusState']
  };
}

const mapDispatchToProps = (dispatch, ownProps)=>{

  return {

    logOut: ()=>{

      var action = { type: 'LOG_OUT' };
      dispatch(action);
    }
  };
}

const UserPanelContainer = ReactRedux.connect(

  mapStateToProps,
  mapDispatchToProps,
)(UserPanel);

export default UserPanelContainer;