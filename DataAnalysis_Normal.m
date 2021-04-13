%% Visualize the existing data
%Assuming tickrate and sample rate are in 10000 Hz
clc
clear all
%Load data
x = load('Crayfish_Extracelular_Rec_Tail_Stim.mat')
Fs = x.samplerate; %create sample frequency
ts = 0:1/x.samplerate(1):(length(x.data)-1)/x.samplerate(1); %time in s
ts = ts.*1000; %time in ms
ts = transpose(ts);

%length(ts) //for debugging
%length(x.data) //for debugging

V = transpose(x.data); %Voltage

close all

%raw
hold on
figure(1)
plot(ts,V,'b')
title(sprintf('Raw %s Signal: %s',x.titles,"Normal"))
xlabel('Time (ms)')
ylabel('Voltage (mV)')
hold off

%Zoomed plot
hold on
figure(2)
plot(ts,V,'b')
title(sprintf('Raw %s Signal: %s',x.titles,"Normal"))
xlabel('Time (ms)')
ylabel('Voltage (mV)')
xlim([50,450])
%xlim([50,950])
hold off

%% Peak Analysis
%index = [58571];% find a sample of the peaks
index = 1;
%index = [296000];

%Avoid outlier

ts = ts(index:end);

V = V(index:end);


t = ts;
V = V;


V_processed = sgolayfilt(V,7,21); %data filter

[Vpeak,tpeak]=findpeaks(V_processed,t,'MinPeakHeight',.01,'MinPeakProminence',.03,'MinPeakDistance',5);
[Vpeak2,tpeak2]=findpeaks(-(V_processed),t,'MinPeakHeight',.03,'MinPeakProminence',.03,'MinPeakDistance',10);


%% Test peak ID
figure()
hold on
plot(t,V,'k');
scatter(tpeak,Vpeak,'r',''); %max points
scatter(tpeak2,-Vpeak2,'b','o'); %min points
xlabel('Time (ms)')
ylabel('Voltage (mV)')
title(sprintf('%s Find Peaks: %s',x.titles,"Normal"))
xlim([50,450])
hold off

%% Compute amplitudes and Widths accurately
%ID the corresponding peaks 
paired_peak = tpeak2; 
paired_width = tpeak2;
Amplitude = [];
Width = [];
Original_Index = [];
for i = 1:length(tpeak) %find the pair to each peak - calculate amplitude
    a = abs(paired_peak-tpeak(i)); %find paired amplitudes
    index = find(a == min(a)); %return location of the peak in tpeak2
    
    if(i == round(length(tpeak)/2))%To test one point
        tpeak_val = i; %pick a tpeak value index
        matching_tpeak2 = index; %pick the chosen tpeak2 val index
    end
    
    Original_Index(i) = tpeak(i); %reference the top peak used; holds time
    Amplitude(i) = Vpeak(i)+Vpeak2(index(1));%set amplitude i
    Width(i) = a(index(1));
end
%% Verify Ampl. Difference (test one pair)
figure()
hold on
plot(t,V,'k');
scatter(tpeak(tpeak_val),Vpeak(tpeak_val),'r','*'); %time 1
scatter(tpeak2(matching_tpeak2),-Vpeak2(matching_tpeak2),'b','o'); %time 2
xlabel('Time (ms)')
ylabel('Voltage (mV)')
title('Find Sample Widths and Amps Location');
Min = min(tpeak(tpeak_val),tpeak2(matching_tpeak2));
Max = max(tpeak(tpeak_val),tpeak2(matching_tpeak2));
xlim([Min-20,Max+20]);
hold off
%% Find histograms
figure()
%hist(Vpeak,100)
histogram(Amplitude,200)
grid on
xlabel('Amplitude(mV)')
ylabel('Frequency of Occurrence')
title(sprintf('Histogram of Amplitudes (mV) %s Signal: %s',x.titles,"Normal"))

figure()
histogram(Width,200)
grid on
xlabel('Time (ms)')
ylabel('Frequency of Occurrence')
title(sprintf('Histogram of Widths (ms) %s Signal: %s',x.titles,"Normal"))

%% Plot separations (Visualize)
figure()
hold on
grid on
%G = findgroups(Width, Amplitude);
scatter(Width,Amplitude);
xlabel('Width (ms)')
ylabel('Amplitude (mV)')
title(sprintf('Visualize Width vs Amplitude %s Signal: %s',x.titles,"Normal"))


hold off
pause
close all
%% Set Thresholds, find average time differences for frequency
%find(threshold) where threshold<= && >=; return the index; set these
thresh1 = find(Amplitude>=0 & Amplitude<0.25);
thresh2 = find(Amplitude>=.25 & Amplitude<0.435);
thresh3 = find(Amplitude>=.435 & Amplitude<0.85);

%find their mean
Amplitude = transpose(Amplitude);
Width = transpose(Width);
thresh1 = transpose(thresh1);
thresh2 = transpose(thresh2);
thresh3 = transpose(thresh3);
X = [tpeak,Amplitude,Width];

X1 = X(thresh1,:);
X2 = X(thresh2,:);
X3 = X(thresh3,:);

mean(X1(:,2));
mean(X2(:,2));
mean(X3(:,2));

%find their time occurence
Group1 = mean(diff(X1(:,1))); %calc average time difference
Group2 = mean(diff(X2(:,1)));
Group3 = mean(diff(X3(:,1)));

%Find frequency 1/mean timedifference (in kHz)
sprintf("Frequency per Group in kHz")
Group1 = 1/Group1 %calc average time difference
Group2 = 1/Group2
Group3 = 1/Group3

%% Plot the grouped scatter plot
figure()
hold on
scatter(X(:,3),X(:,2),'k','o')
scatter(X1(:,3),X1(:,2),'b','o')
scatter(X2(:,3),X2(:,2),'g','o')
scatter(X3(:,3),X3(:,2),'m','o')
legend('Outliers','Type 1','Type 2','Type 3')
xlabel('Width (ms)')
ylabel('Amplitude (mV)')
title(sprintf('Visualize Width vs Amplitude %s Signal: %s',x.titles,"Normal"))
hold off

%% Identify Raw Signal APs

figure()

hold on
plot(ts,V,'k')

AP = ones(length(X1),1)*.4; %indicate APs at this height
scatter(X1(:,1),AP,'b','*');

AP = ones(length(X2),1)*.4; %indicate APs at this height
scatter(X2(:,1),AP,'m','*');

AP = ones(length(X3),1)*.4; %indicate APs at this height
scatter(X3(:,1),AP,'g','*');

legend('Signal','Type 1','Type 2','Type 3')

title(sprintf('Raw %s AP Classification: %s',x.titles,"Normal"))
xlabel('Time (ms)')
ylabel('Voltage (mV)')
hold off

%Zoomed plot

figure()
hold on
plot(ts,V,'k')

AP = ones(length(X1),1)*.4; %indicate APs at this height
scatter(X1(:,1),AP,'b','*');

AP = ones(length(X2),1)*.4; %indicate APs at this height
scatter(X2(:,1),AP,'g','*');

AP = ones(length(X3),1)*.4; %indicate APs at this height
scatter(X3(:,1),AP,'m','*');

title(sprintf('Raw %s AP Classification: %s',x.titles,"Normal"))
xlabel('Time (ms)')
ylabel('Voltage (mV)')
legend('Signal','Type 1','Type 2','Type 3')
xlim([50,450])
%xlim([50,950])
hold off
