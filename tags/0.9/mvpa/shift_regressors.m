function [subj] = shift_regressors(subj,old_regsname,runsname,nTimepoints,varargin)
% 
% [SUBJ] = SHIFT_REGRESSORS(SUBJ,OLD_REGSNAME,RUNSNAME,NTIMEPOINTS,...)
% 
% Shifts regressors ahead in time to account for hemodynamic lag.
% Modifies the regressors OLD_REGSNAME by shifting NTIMEPOINTS forward within
% each run specified by RUNSNAME. Those timepoints at the end of a run are
% deleted. Timepoints inserted at the beginning of each run default to 0.
%
% Adds the following objects:
% - new regressors object 
%
% NEW_REGSNAME (optional, default = OLD_REGSNAME + _shifted + NTIMEPOINTS)
%
% DO_PLOT (optional, default = false). Plot an imagesc of the old
% and new regressors to confirm that the shift looks right

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


defaults.new_regsname = sprintf('%s_shifted%i',old_regsname,nTimepoints);
defaults.do_plot = false;
args = propval(varargin,defaults);

% Load in the runs and regs
runs = get_mat(subj,'selector',runsname);
regs = get_mat(subj,'regressors',old_regsname);

% Error Check: Make sure the runs regressor has no rest
if length(find(runs == 0))
  error('Runs regressor includes 0s. Cannot identify ends of run');
end

% Identify the last nTimepoints timepoints in each run
% Finds the timepoints N, where run(TR) does not equal run(TR+n)
last_timepoints  = find(runs(1:end-nTimepoints) ~= runs(nTimepoints+1:end));

% When the regressor is shifted, these last timepoints from each run will
% become the first Timepoints from the next run. Set them to 0
regs(:,last_timepoints) = 0;

% Now shift the entire regressor by inserting zeros, and then lop
% off the final nTimepoints 
regs = cat(2, zeros(size(regs,1), nTimepoints), regs(:,1:end-nTimepoints));

% Now create a new regressors object to store the shifted regs
subj = duplicate_object(subj,'regressors',old_regsname,args.new_regsname);
subj = set_mat(subj,'regressors',args.new_regsname,regs);

created.function = mfilename;
created.dbstack = dbstack;
created.nTimepoints = nTimepoints;
created.args = args;
created.regsname = old_regsname;
created.runsname = runsname;
subj = add_created(subj,'regressors',args.new_regsname,created);

if args.do_plot
  old_regs = get_mat(subj,'regressors',old_regsname);
  figure
  subplot(2,1,1)
  imagesc(old_regs);
  subplot(2,1,2)
  imagesc(regs);
end

