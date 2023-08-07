clear all; close all; clc;

inputFile = input('Enter the path of the input audio file: ', 's');

uuid = char(java.util.UUID.randomUUID);
outputFile = ['cleaned_test_' uuid '.wav'];
jsonFile = ['statistics_' uuid '.json'];

[signal, samplingRate] = audioread(inputFile);
duration = length(signal) / samplingRate; 

n = 10; 
lowFreqCutoff = 300;  
highFreqCutoff = 3400;
Wn = [lowFreqCutoff highFreqCutoff] / (samplingRate/2); 
[b,a] = butter(n, Wn, 'bandpass'); 

cleaned_signal = filter(b, a, signal);
cleaned_signal = cleaned_signal / max(abs(cleaned_signal));

cleanedFolder = 'cleaned';
if ~exist(cleanedFolder, 'dir')
    mkdir(cleanedFolder);
end
audiowrite(fullfile(cleanedFolder, outputFile), cleaned_signal, samplingRate);

original_energy = sum(signal.^2);
cleaned_energy = sum(cleaned_signal.^2);
cleaning_rate = (original_energy - cleaned_energy) / original_energy * 100;

stats = struct();
stats.OriginalFileAddress = inputFile;
stats.Duration = duration;
stats.CleaningRate = cleaning_rate;
stats.CleanedFileAddress = fullfile(cleanedFolder, outputFile);

statisticsFolder = 'statistics';
if ~exist(statisticsFolder, 'dir')
    mkdir(statisticsFolder);
end
jsonString = jsonencode(stats);
fid = fopen(fullfile(statisticsFolder, jsonFile), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonString, 'char');
fclose(fid);
