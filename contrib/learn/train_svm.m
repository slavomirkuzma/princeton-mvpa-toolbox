function [scratch] = train_svm(trainpats,traintargs,in_args,cv_args)

% USAGE :
% [SCRATCH] = TRAIN_SVM(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS)
%
% This is a support vector machine training function. It train the
% classifier and makes is ready for testing. 
% NOTE : This classfier currently does only two category classification
% only. We have to implement the multi-class classification.
% Make sure you pass in only two regressors  
%
% You need to call TEST_SVM afterwards to assess how well this
% generalizes to the test data.
%
% This function internally uses the svm library generated by the
% Jaochims. This function is a wrapper script that converts the
% subj struture into the form required by this library.

% PATS = nFeatures x nTimepoints
% TARGS = nOuts x nTimepoints
%
% SCRATCH contains all the other information that you might need when
% analysing the network's output, most of which is specific to
% backprop. Some of this information is redundantly stored in multiple
% places. This gets referred to as SCRATCHPAD outside this function
%
% The classifier functions use a IN_ARGS structure to store possible
% arguments (rather than a varargin and property/value pairs). This
% tends to be easier to manage when lots of arguments are
% involved. xxx
%
% IN_ARGS are the various arguments that can be passed in for type
% of kernels used and the learning parameters.
%
% IN_ARGS: 
%  1] in_args.kernel_type = 0 'LINEAR'
%  2] in_args.kernel_type = 1 'POLYNOMIAL'
%  3] in_args.kernel_type = 2 'RBF (Radial Basis Function)'
%  4] in_args.kernel_type = 4 'SIGMOID'
%
%
%
% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SORT ARGUMENTS

defaults.temp='';

% Args contains the default args, unless the user has over-ridden them
args = add_struct_fields(in_args,defaults);
scratch.class_args = args;
[args.kernelstring] = make_kernel(in_args);
args = sanity_check(trainpats,traintargs,args);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING THINGS UP
% This classifier needs the two caterogies to in the form of +/- 1 
% in this step we will convert catergory 1 into all the 1 and
% category 2 into -1
[train_max_val train_max_idx]  = max(traintargs);
train_max_idx(train_max_idx == 1) = 1;
train_max_idx(train_max_idx == 2) = -1;
scratch.nOut = size(traintargs,1);
scratch.outidx = [1:scratch.nOut];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** TRAINING THE CLASSIFIER... ***

[scratch.model] = svmtrain(trainpats',train_max_idx',args.kernelstring);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [args] = sanity_check(trainpats,traintargs,args)

if size(trainpats,2)==1
  error('Can''t classify a single timepoint');
end

if size(trainpats,2) ~= size(traintargs,2)
  error('Different number of training pats and targs timepoints');
end

if size(traintargs,1) ~= 2 
  error('Cannot classify more than two categories');  
end 


[isbool isrest isoveractive] = check_1ofn_regressors(traintargs);
if ~isbool || isrest || isoveractive
  if ~args.ignore_1ofn
    warning('Not 1-of-n regressors');
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [kernelstring] = make_kernel(in_args);

kernelstring=[];

if isempty(in_args)
  warning('Please specify the kernel type or use default: LINEAR');
  kernelstring = sprintf('%s%d', '-t ', 0);  
  
else

  if ~isnumeric(in_args.kernel_type)
    error('Kernel Type has to be a number. Please see HELP');   
    
  elseif in_args.kernel_type>3
    error('Specify Kernel types between 0 to 3 only, See HELP');
    
  
  elseif in_args.kernel_type == 0  
    disp('LINEAR KERNEL');
    kernelstring = sprintf('%s%d', '-t ', in_args.kernel_type);      
    
  elseif in_args.kernel_type == 1
    disp('POLYNOMIAL KERNEL');  
    kernelstring = sprintf('%s%d', '-t ', in_args.kernel_type); 
    
  if ~isfield(in_args,'coef_lin')
    disp('Please specify the linear coefficient or use default');
  else  
    coef_lin_str =  sprintf('%s%f',' -s ',in_args.coef_lin);
    kernelstring = strcat( kernelstring ,coef_lin_str);
  end     
  
  if ~isfield(in_args,'coef_const')
    disp('Please specify the constant coefficient or use default');
  else  
    coef_const_str = sprintf('%s%f' ,' -r ',in_args.coef_const);
    kernelstring = strcat( kernelstring , coef_const_str);
  end     
  
  if ~isfield(in_args,'poly_degree')
    disp('Please specify the degree of the polynomial or use default');
  else  
    poly_degree_str = sprintf('%s%f',' -d ',in_args.poly_degree);
    kernelstring = strcat( kernelstring , poly_degree_str);
  end      
  
  elseif in_args.kernel_type == 2
    disp('RBF KERNEL');  
    kernelstring  = sprintf('%s%d','-t ', in_args.kernel_type);
    
    if ~isfield(in_args,'rbf_gamma')
      disp('Please specify the rbf gamma or use default');
    else  
      rbf_gamma_str = sprintf('%s%f',' -g ',in_args.rbf_gamma)
      kernelstring = strcat( kernelstring , rbf_gamma_str);   
    end   
    
  elseif in_args.kernel_type == 3
    disp('SIGMOID_KERNEL');  
    kernelstring = sprintf('%s%d', '-t ', in_args.kernel_type);
    
    if ~isfield(in_args,'coef_lin')
      disp('Please specify the linear coefficient or use default');
    else  
      coef_lin_str = sprintf('%s%f',' -s ',in_args.coef_lin);
      kernelstring = strcat( kernelstring ,coef_lin_str );
    end     
  
    if ~isfield(in_args,'coef_const')
      disp('Please specify the constant coefficient or use default');
    else  
      coef_const_str = sprintf('%s%f' ,' -r ',in_args.coef_const);
      kernelstring = strcat( kernelstring , coef_const_str);
    end  
  end  
end  

kernelstring
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
