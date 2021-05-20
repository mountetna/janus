import React, {useState, useEffect, useCallback} from 'react';
import Grid from '@material-ui/core/Grid';
import Button from '@material-ui/core/Button';
import {makeStyles} from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import InputAdornment from '@material-ui/core/InputAdornment';
import Search from '@material-ui/icons/Search';
import Input from '@material-ui/core/Input';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import Chip from '@material-ui/core/Chip';
import AddIcon from '@material-ui/icons/Add';
import RemoveIcon from '@material-ui/icons/Remove';
import IconButton from '@material-ui/core/IconButton';
import Tooltip from '@material-ui/core/Tooltip';

const useStyles = makeStyles((theme) => ({
  chips: {
    display: 'flex',
    flexWrap: 'wrap'
  },
  formControl: {
    margin: theme.spacing(1),
    minWidth: 120,
    maxWidth: 300
  },
  chip: {
    margin: 2
  },
  button: {
    margin: theme.spacing(1)
  }
}));

const ITEM_HEIGHT = 48;
const ITEM_PADDING_TOP = 8;
const MenuProps = {
  PaperProps: {
    style: {
      maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
      width: 250
    }
  }
};

function ChipSelector({
  options,
  label,
  onChange
}: {
  options: string[];
  label: string;
  onChange: (selection: string[]) => void;
}) {
  const [selected, setSelected] = useState([] as string[]);
  const classes = useStyles();

  function onSelect(selection: string[]) {
    setSelected(selection);
    onChange(selection);
  }

  return (
    <FormControl className={classes.formControl}>
      <InputLabel id={`${label}-filter-label`}>{label}</InputLabel>
      <Select
        labelId={`${label}-filter-label`}
        id={`${label}-filter`}
        multiple
        value={selected}
        onChange={(e) => onSelect(e.target.value as string[])}
        input={<Input id={`select-multiple-${label}`} />}
        renderValue={(selectedItems: any) => (
          <div className={classes.chips}>
            {selectedItems.map((value: string) => (
              <Chip key={value} label={value} className={classes.chip} />
            ))}
          </div>
        )}
        MenuProps={MenuProps}
      >
        {options.sort().map((option) => (
          <MenuItem key={option} value={option}>
            {option}
          </MenuItem>
        ))}
      </Select>
    </FormControl>
  );
}

const TableControls = ({
  onChangeSearch,
  onChangeProjects,
  onChangeFlags,
  flagOptions,
  projectOptions
}: {
  flagOptions: string[];
  projectOptions: string[];
  onChangeSearch: (search: string) => void;
  onChangeProjects: (projects: string[]) => void;
  onChangeFlags: (flags: string[]) => void;
}) => {
  const classes = useStyles();

  return (
    <Grid container xs={12}>
      <Grid item xs={3}>
        <TextField
          label='Search'
          variant='outlined'
          onChange={(e) => onChangeSearch(e.target.value as string)}
          InputLabelProps={{
            shrink: true
          }}
          InputProps={{
            startAdornment: (
              <InputAdornment position='start'>
                <Search />
              </InputAdornment>
            )
          }}
        />
      </Grid>
      <Grid item xs={3}>
        <ChipSelector
          options={projectOptions}
          onChange={onChangeProjects}
          label='Projects'
        />
      </Grid>
      <Grid item xs={3}>
        <ChipSelector
          options={flagOptions}
          onChange={onChangeFlags}
          label='Flags'
        />
      </Grid>
      <Grid item xs={3}>
        <Button
          variant='contained'
          color='primary'
          className={classes.button}
          startIcon={<AddIcon />}
        >
          Add Flag
        </Button>
        <Button
          variant='contained'
          color='secondary'
          className={classes.button}
          startIcon={<RemoveIcon />}
        >
          Remove Flag
        </Button>
      </Grid>
    </Grid>
  );
};

export default TableControls;
