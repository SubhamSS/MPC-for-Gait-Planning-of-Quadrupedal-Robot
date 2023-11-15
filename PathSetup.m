%% Recursively add all subfolders to search path in the project directory
% Simulation code for "Inverse Optimal Robust Adaptive Controller for 
% Upper Limb Rehabilitation Exoskeletons with Inertia and Load Uncertainties"
% by Jiamin Wang (jmechw@vt.edu) and Oumar R. Barry (obarry@vt.edu)
% 
% This script recursively adds all subfolders to search path in the project 
% directory and clears workspace. (No Copyrigh Claimed)

clear classes; clear all; close all; clc; restoredefaultpath;
prjPath=pwd;
addpath(genpath(prjPath));