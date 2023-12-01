# ExampleTestToolbox

In the ISET related programs (isetbio, isetcam, iset3d, isetcloud ...) we insert block comments with runnable examples. The functions in this toolbox reads and runs those examples, reporting on errors.

Examples are usually embedded near the top of the program, separated from the top comments.  The syntax for the example code is

```
% Examples:
%{
... first example code here ...
%}
%{
... next example code here ...
%}
```

## RunExamples

This function takes either a function or a directory as an argument.  RunExamples determines whether the input is a file or a directory and then invokes the functions **ExecuteExamplesInFunction** or **ExecuteExamplesInDirectory**.

## PrintExamples

This function prints the examples in a specific file (not in a directory).
