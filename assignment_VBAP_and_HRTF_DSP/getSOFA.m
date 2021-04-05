function [sofa_file] = getSOFA(filename, url)
%GETSOFA Load SOFA file from PATH, otherwise download from URL.
%
%   See miniSOFAloader() for more info
% Example: sofa_file = getSOFA('HRIR_L2354.sofa', 'http://sofacoustics.org/data/database/thk/HRIR_L2354.sofa')
% CFH 2020

if nargin < 2
    url = '';
end

if exist(filename, 'file')
    sofa_file = miniSOFAloader(filename);
else
    warning('Could not find specified SOFA file, will try to download...')
    assert(~isempty(url), 'Please specify URL to download')
    websave(filename, url);
    sofa_file = miniSOFAloader(filename);
end
end

