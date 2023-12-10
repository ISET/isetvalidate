function status = ieExamplesOne(theFunction,varargin)
% Run all the examples in a specified function
%
% Syntax:
%  status = ieExamplesOne(theFunction)
%
% Description:
%  Run all the examples in a function, except those that contain a line
%  of the form
%    "% ETTBSkip"
%
% Inputs:
%   theFunction - name of ISET function
%
% Outputs:
%    status
%     -1: Found examples but at least one crashed, or other
%         error such as unmatched block comment open and
%         close.
%     0: No examples found
%     N: With N > 0.  Number of examples run successfully,
%        with none failing.
%
% Optional key/value pairs
%    'print'  - Boolean. Print the results to the command line, showing the successes
%               and failures separately. Default true.
%
% See also:
%   ieExamples, ieValidate, ieRunTutorialsAll
%   ExampleTestToolbox:  ExecuteExamplesInFunction

%%
p = inputParser;
p.addRequired('func',@(x)(~isempty(which(x)))); 
p.addParameter('print',true,@islogical);

p.parse(theFunction,varargin{:});
% select = p.Results.select;

%%
theFunction = which(theFunction,'all');

if iscell(theFunction) 
    warning('Multiple functions with this name.\nEvaluating %s',theFunction{1});
    theFunction = theFunction{1};
end

status = ExecuteExamplesInFunction(theFunction);

switch status
    case -1
        fprintf('Found examples but at least one crashed.\n')
    case 0
        fprintf('No examples found.\n')
    otherwise
        fprintf('%d examples were tested. No errors reported.\n',status)
end

%% END