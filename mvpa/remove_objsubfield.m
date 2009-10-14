function [subj] = remove_objsubfield(subj,objtype,objname,fieldname,subfieldname,newval)

% Removes the subfield from an object.
%
% SUBJ = REMOVE_SUBFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME,SUBFIELDNAME,NEWVAL)
% 
% See remove_objsubfield for more information


if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

field = get_objfield(subj,objtype,objname,fieldname);
field = rmfield(field,subfieldname);
subj = set_objfield(subj,objtype,objname,fieldname,field);

