import React, {
  useState,
  useEffect,
  useCallback,
  createContext,
  useContext
} from 'react';

import 'regenerator-runtime/runtime';

import Icon from 'etna-js/components/icon';
import {useReduxState} from 'etna-js/hooks/useReduxState';
import {selectUser} from 'etna-js/selectors/user-selector';
import {json_post, json_get} from 'etna-js/utils/fetch';
import {isSuperEditor} from 'etna-js/utils/janus';
import {updateProject} from './api/janus_api';
import useAsyncWork from 'etna-js/hooks/useAsyncWork';

import {makeStyles} from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import Checkbox from '@material-ui/core/Checkbox';

import SaveCancel from './save-cancel';
import { projectTypeFor } from './utils/project';


const Project = ({project}) => {
  const [changed, setChanged] = useState(false);
  const [isResource, setIsResource] = useState(project.resource);

  const {
    state: {projects},
    setProjects
  } = useContext(ProjectsContext);

  const handleOnCancel = useCallback(() => {
    setIsResource(project.resource);
    setChanged(false);
  }, [project.resource]);


  return (
    <TableRow key={project.project_name}>
      <TableCell>
        <a href={`/${project.project_name}`}>{project.project_name}</a>
      </TableCell>
      <TableCell>{project.project_name_full}</TableCell>
      <TableCell>
        { projectTypeFor(project) }
      </TableCell>
    </TableRow>
  );
};

const projectStyles = makeStyles( theme => ({
  table_container: {
    height: 'calc(100vh - 61px - 38px - 73px)',
    width: 'calc(100% - 2px)'
  }
}));

const Projects = ({projects}) => {
  const classes = projectStyles();

  return <div id='admin-projects'>
    <div className='title'>Projects</div>
    <TableContainer component={Paper} className={classes.table_container}>
      <Table aria-label='all projects'>
        <TableHead>
          <TableRow>
            <TableCell>Project Name</TableCell>
            <TableCell>Title</TableCell>
            <TableCell>Type</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {projects.sort((p1, p2) =>
              p1.project_name_full.localeCompare(p2.project_name_full)
            ).map((project) => (
              <Project key={project.project_name} project={project} />
            ))}
        </TableBody>
      </Table>
    </TableContainer>
  </div>
}

const postAddProject = (project) => json_post('/api/admin/add_project', project);

const NewProject = ({retrieveAllProjects}) => {
  let [newproject, setNewProject] = useState({});
  let [error, setError] = useState(null);

  const [_, addProject] = useAsyncWork(
    function addProject() {
      postAddProject(newproject)
        .then(() => {
          retrieveAllProjects();
          setNewProject({});
          setError(null);
        })
        .catch((e) => e.then(({error}) => setError(error)));
    },
    {cancelWhenChange: []}
  );

  return (
    <div id='new-project'>
      <div className='title'>New Project</div>
      {error && <div className='error'>Error: {error}</div>}
      <div className='item'>
        <div className='cell'>
          <TextField
            placeholder='project_name'
            value={newproject.project_name || ''}
            onChange={(e) =>
              setNewProject({...newproject, project_name: e.target.value})
            }
          />
        </div>
        <div className='cell'>
          <TextField
            placeholder='Project Title'
            value={newproject.project_name_full || ''}
            onChange={(e) =>
              setNewProject({...newproject, project_name_full: e.target.value})
            }
          />
        </div>
        <div className='cell submit'>
          <Icon className='approve' icon='magic' onClick={addProject} />
        </div>
      </div>
    </div>
  );
};

const ProjectsView = () => {
  let user = useReduxState((state) => selectUser(state));

  const {
    state: {projects},
    setProjects
  } = useContext(ProjectsContext);

  let retrieveAllProjects = useCallback(() => {
    json_get('/api/admin/projects').then(({projects}) => setProjects(projects));
  }, [setProjects]);

  useEffect(retrieveAllProjects, []);
  return (
    <>
      <Projects user={user} projects={projects} />
      {isSuperEditor(user) && (
        <NewProject retrieveAllProjects={retrieveAllProjects} />
      )}
    </>
  );
};

const ProjectsViewWrapper = () => {
  return (
    <ProjectsProvider>
      <ProjectsView />
    </ProjectsProvider>
  );
};

const defaultProjectsContext = {
  state: {
    projects: []
  }
};

const ProjectsContext = createContext(defaultProjectsContext);

const ProjectsProvider = (props) => {
  const [state, setState] = useState(
    props.state || defaultProjectsContext.state
  );

  const setProjects = useCallback(
    (projects) => {
      setState({
        ...state,
        projects: [...projects]
      });
    },
    [state]
  );

  return (
    <ProjectsContext.Provider
      value={{
        state,
        setProjects
      }}
    >
      {props.children}
    </ProjectsContext.Provider>
  );
};

export default ProjectsViewWrapper;
