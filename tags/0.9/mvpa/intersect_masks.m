function [subj] = intersect_masks(subj,mask1name,mask2name,varargin)

% Creates a new mask that's an intersection of two masks
%
% [SUBJ] = INTERSECT_MASKS(SUBJ,MASK1NAME,MASK2NAME,...)
%
% Gets both masks, checks they're the same size, and then does an
% AND on them to create a new mask that's an intersection of them
% both
%
% xxx Need an alternative or extra argument for UNION
%
% NEW_MASKNAME (optional, default =
% sprintf('inters_%s_%s',mask1name,mask2name)


defaults.new_maskname = sprintf('inters_%s_%s',mask1name,mask2name);
args = propval(varargin,defaults);

mask1 = get_mat(subj,'mask',mask1name);
mask2 = get_mat(subj,'mask',mask2name);

if ~compare_size(mask1,mask2)
  error('The reference space sizes of mask1 and mask2 are different');
end

nVox1 = length(find(mask1));
nVox2 = length(find(mask2));

% Can't just use &, cos it returns logicals. Couldnt' figure out a
% better way of turning logicals into numerical 1s and 0s
% Is this ok? I think so
mask3 = zeros(size(mask1));
mask3(find(mask1 & mask2))= 1;

nVox3 = length(find(mask3));

subj = initset_object(subj,'mask',args.new_maskname,mask3, ...
		      'nvox',nVox3, ...
		      'thresh',NaN);		      

hist1 = sprintf('Created new mask, %s, containing %i voxels', ...
	       args.new_maskname,nVox3);
hist2 = sprintf('Intersection of %s (%i vox) and %s (%i vox)', ...
		mask1name,nVox1,mask2name,nVox2);

subj = add_history(subj,'mask',args.new_maskname,hist1);
subj = add_history(subj,'mask',args.new_maskname,hist2);

created.mask1name = mask1name;
created.mask2name = mask2name;
created.args = args;
subj = add_created(subj,'mask',args.new_maskname,created);


