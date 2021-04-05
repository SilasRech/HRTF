function [s_sofa] = miniSOFAloader(sofa_filepath, SHOW_INFO)
%MINISOFALOADER Extracts all Attributes and Variables from SOFA file
%
%   IN:     sofa_filepath:  string, pointing to file
%   OUT:    s_sofa:         struct, containing data
% CFH 2020

if nargin < 2
    SHOW_INFO = false;
end
if SHOW_INFO
    ncdisp(sofa_filepath)
end

s_in =  ncinfo(sofa_filepath);
s_sofa = struct;
% Extract Attributes
for field_idx = 1:length(s_in.Attributes)
    % Matlab doesn't allow '.' in field name
    field_name = strrep(s_in.Attributes(field_idx).Name, '.', '');
    s_sofa.(field_name) = s_in.Attributes(field_idx).Value;
end

% Extract Variables
for field_idx = 1:length(s_in.Variables)
    % Matlab doesn't allow '.' in field name
    field_name = strrep(s_in.Variables(field_idx).Name, '.', '');
    s_sofa.(field_name) = ...
        ncread(sofa_filepath, s_in.Variables(field_idx).Name);
end

end

