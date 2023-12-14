function result = ieExamplesDirectory(thisDir,varargin)
% Run all the examples in the specified directory and subdirectories.
%
% Syntax:
%     result = ieExamplesDirectory(repo)
%
% Description:
%     Run all the examples in a directory, except those that contain
%     a line of the form 
%          "% ETTBSkip"
%
% Inputs:
%   thisDir - full path to the directory.  Subdirectories will be
%             checked.
%
% Outputs:
%  result - describing the outcome
%      result.names   Names of the functions
%      result.status  What happened
%
% Optional key/value pairs
%    'select' - 'all' or 'one' (one not yet implemented).  Default 'all'.
%    'print'  - Boolean. Print the results to the command line, showing the successes
%               and failures separately. Default true.
%    'verbose' - Chatty output from ExecuteExamplesInDirectory
%
% Examples:
%   The source file contains examples.
%
% See also:
%   ieValidate, ieRunTutorialsAll

% Examples: 
%{
% ETTBSkip
ieExamplesDirectory(fullfile(isetRootPath,'fonts'));
%}
%{
% ETTBSkip
ieExamplesDirectory(fullfile(isetRootPath,'gui'),'verbose',true);
%}

% History:
%   07/25/23  dhb  Make header comment consistent with isetbio style.

p = inputParser;
p.addRequired('thisDir',@(x)(exist(x,'dir')));
p.addParameter('select','all',@ischar);
p.addParameter('print',true,@islogical);
p.addParameter('verbose',false,@islogical);

p.parse(thisDir,varargin{:});

[result.names, result.status ] = ExecuteExamplesInDirectory(thisDir,...
    'verbose',p.Results.verbose); 

if p.Results.print
    % Maybe make this a function like examplesResultsPrint
    names = result.names;
    status = result.status;
    goodNames = names(status > 0);
    goodStatus = status(status > 0);
    badNames  = names(status < 0);

    cprintf('Blue','\n\nSuccess cases (%d)\n',numel(goodNames));
    for ii=1:numel(goodNames)
        fprintf('%d:  %s.\n',goodStatus(ii),goodNames{ii});
    end

    if numel(badNames) > 0
        cprintf('Red','\n\nAt least one failure case (%d)\n',numel(badNames));
        for ii=1:numel(badNames)
            fprintf('%d:\t%s.\n',badNames{ii})
        end
    else
        fprintf('\nNo failure cases.\n');
    end
end

%% END