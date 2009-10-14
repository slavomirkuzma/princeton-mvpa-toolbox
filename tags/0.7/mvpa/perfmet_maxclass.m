function [perfmet] = perfmet_maxclass(acts,targs,scratchpad,varargin)

% This is the most basic performance metric.
%
% [PERFMET] = PERFMET_MAXCLASS(ACTS,TARGS,SCRATCHPAD,...)
%
% The classifier is considered to guess correctly if its maximally
% active row (the unit that it guessed) corresponds to the most active
% row of the targs (the unit that was desired)
%
% ACTS = nUnits x nTimepoints
%
% TARGS = nUnits x nTimepoints
%
% SCRATCHPAD is required for perfmets, but not by this one
%
% ARGS - structure with the following optional arguments
%
% - IGNORE_1OFN (optional, default = false). If your regressors
% aren't boolean, contain rest or contain timepoints with multiple
% active fields, you should be using a more sophisticated
% performance metric. If you're feeling stubborn, and want to use
% this one anyway, set this to true.
%
% Returns a PERFMET struct, which contains the following fields:
%
% - GUESSES = vector indicating which unit was maximally active, i.e. which
% condition the classifier guessed
%
% - DESIREDS = vector indicating unit should have been maximally
% active, i.e. the active condition
%
% - CORRECTS = vector of whether GUESSES == DESIREDS, i.e. whether the
% classifier guessed right
%
% - PERF = scalar, proportion of the time that the classifier was
% correct, i.e. nCorrects/nTimepoints
%
% This perfmet doesn''t deal with ties very well. For that kind of
% situation, you'll need something more sophisticated. To create your
% own perfmet, just make sure your function definition is structured
% the same way as this and that the PERFMET.perf field exists.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if ~exist('scratchpad','var')
  scratchpad = [];
end

defaults.ignore_1ofn = false;
args = propval(varargin,defaults);

sanity_check(acts,targs,scratchpad,args);

[nUnits nTimepoints] = size(acts);

[yg guesses] = max(acts);

[yd desireds] = max(targs);

corrects = guesses == desireds;

perf = length(find(corrects)) / nTimepoints;

perfmet.guesses    = guesses;
perfmet.desireds   = desireds;
perfmet.corrects   = corrects;
perfmet.perf       = perf;
perfmet.scratchpad = [];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(acts,targs,scratchpad,args)

if isempty(acts) || isempty(targs)
  error('Acts or targs are empty');
end

if ~compare_size(acts,targs)
  error('Can''t calculate performance if acts and targs are different sizes');
end

[isbool isrest isoveractive] = check_1ofn_regressors(targs);
if ~isbool || isrest || isoveractive
  if ~args.ignore_1ofn
    warning('Not 1-of-n regressors');
  end
end

