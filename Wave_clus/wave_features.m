function [inspk] = wave_features(spikes,par);
%Calculates the spike features
% 
% scales = handles.par.scales;
% feature = handles.par.features;
% inputs = handles.par.inputs;

scales = par.scales;
feature = par.features;
inputs = par.min_inputs;
nspk = size(spikes,1);
ls = size(spikes,2);
%set(handles.file_name,'string','Calculating spike features ...');

% CALCULATES FEATURES
switch feature
    case 'wav'
        cc=zeros(nspk,ls);
        if exist('wavedec')                             % Looks for Wavelets Toolbox
            for i=1:nspk                                % Wavelet decomposition
                [c,l]=wavedec(spikes(i,:),scales,'haar');
                cc(i,1:ls)=c(1:ls);
            end
        else
            for i=1:nspk                                % Replaces Wavelets Toolbox, if not available
                [c,l]=fix_wavedec(spikes(i,:),scales);
                cc(i,1:ls)=c(1:ls);
            end
        end
        for i=1:ls                                  % KS test for coefficient selection   
            thr_dist = std(cc(:,i)) * 3;
            thr_dist_min = mean(cc(:,i)) - thr_dist;
            thr_dist_max = mean(cc(:,i)) + thr_dist;
            aux = cc(find(cc(:,i)>thr_dist_min & cc(:,i)<thr_dist_max),i);
            if length(aux) > 10;
                [ksstat]=test_ks(aux);
                sd(i)=ksstat;
            else
                sd(i)=0;
            end
        end
        try
        [max ind]=sort(sd);
        coeff(1:inputs)=ind(ls:-1:ls-inputs+1);
        catch
        end
    case 'pca'
        [C,S,L] = princomp(spikes);
        cc = S;
%         inputs = 3; 
%         coeff(1:3)=[1 2 3];

%%%         inputs = handles.par.inputs;
        inputs = par.min_inputs;

        coeff(1:inputs) = 1:inputs;
end

%CREATES INPUT MATRIX FOR SPC
inspk=zeros(nspk,inputs);
for i=1:nspk
    for j=1:inputs
        inspk(i,j)=cc(i,coeff(j));
    end
end

