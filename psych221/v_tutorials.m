% Script to make sure Psych 221 tutorials run
% 
ieInit;

%% Image Formation tutorials
ImageFormation_01a
ImageFormation_01b_OI
ImageFormation_01c_Airy
ImageFormation_01d_Diffraction
ImageFormation_01e_SIExamples
ImageFormation_01f_equalFnumber

%% Sensor Tutorials
Sensor_02a_Fundamentals
Sensor_02b_Estimation
Sensor_02c_Aliasing

%% Color Tutorials
Color_03a_Matching
Color_03b_ChromaticityPlots
Color_03c_Spectrum

%% Metrics Tutorials
Metrics_04a_Color
Metrics_04b_MTF

%% JPEG Tutorials
JPEG_05a_Monochrome
JPEG_05b_Color

%% Display Tutorials
Display_05a_Rendering
Display_05b_RGB2Radiance

%% Printing Tutorial
Printing_01a

%% Misc Tutorials
hwISETCam
photonsElectrons

%% Advanced: Requires other repos, so commented by default
TransferLearning_08a

%% Prior approach just looped through .mlx
%  which would also be fine, but doesn't allow for checking
%  individual sections. Code is here for reference:
%{
%% Run through all the MLX files in teach/psych221
%
% See also
%
%%
ieInit;
chdir(teachRootPath)

%%
fnames = dir('*.mlx');
for ii=1:numel(fnames)
    [~,thisName] = fileparts(fnames(ii).name);
    if ~isequal(thisName,'TransferLearning_08a')
        fprintf('\n\n  **** Checking %s **** \n\n',thisName);
        eval(thisName);
    end
end
%}
