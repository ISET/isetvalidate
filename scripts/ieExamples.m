function result = ieExamples(repo,varargin)
% Run all the examples in the specified repo
%
% Syntax:
%     result = ieExamples(repo)
%
% Description:
%     Run all the examples in the repository tree, excep those that contain
%     a line of the form 
%          "% ETTBSkip"
%
% Inputs:
%   repo - name of repository, one of {'isetcam','isetbio', 'csfgenerator'}
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
%
% Examples:
%   The source file contains examples.
%
% See also:
%   ieValidate, ieRunTutorialsAll

% Examples: % ETTBSkip
%{
    ieExamples('isetbio');
%}
%{
    ieExamples('isetcam','select','all','print',true);
%}

% History:
%  07/25/23  dhb      Make header comment consistent with isetbio style.
%  12/15/23  dhb, fh  Add ISETBioCSFGenerator option

p = inputParser;
p.addRequired('repo',@(x)(ismember(ieParamFormat(x),{'isetcam','isetbio','csfgenerator'})));
p.addParameter('select','all',@ischar);
p.addParameter('print',true,@islogical);

p.parse(repo,varargin{:});
select = p.Results.select;

switch repo
    case 'isetbio'
        disp(select)
        [result.names, result.status ] = ExecuteExamplesInDirectory(isetbioRootPath,'verbose',false);
    case 'isetcam'
        disp(select)
        [result.names, result.status ] = ExecuteExamplesInDirectory(isetRootPath,'verbose',false);
    case 'csfgenerator'
        disp(select)
        [result.names, result.status ] = ExecuteExamplesInDirectory(csfgeneratorRootPath,'verbose',false);
    otherwise
        error('Not yet supported %s\n',repo);
end

if p.Results.print
    % Maybe make this a function like examplesResultsPrint
    names = result.names;
    status = result.status;
    goodNames = names(status > 0);
    goodStatus = status(status > 0);
    badNames  = names(status < 0);

    cprintf('Blue','\n\nSuccess cases (%d)\n',numel(goodNames));
    for ii=1:numel(goodNames)
        fprintf('%d examples suceeded for %s.\n',goodStatus(ii),goodNames{ii});
    end

    cprintf('Red','\n\nFailure cases (%d)\n',numel(badNames));
    for ii=1:numel(badNames)
        fprintf('At least one example failed for %s.\n',badNames{ii})
    end
end

%% END