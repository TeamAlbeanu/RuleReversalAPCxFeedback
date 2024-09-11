function [tr_info, ro_info] = parse_2024017(data)

    % Nantyp is a matrix that has 0 if data is present, 1 if channel loss and
    % 2 if FOV loss
    
    nantyp = zeros(size(data));
    for trial = 1:size(data, 3)
        for tp = 1:size(data, 1)
            
            % mark channel loss
            for roi = 1:size(data, 2)
                if isnan(data(tp,roi,trial))
                    
                    nantyp(tp,roi,trial) = 1;
                    
                end
            end
            
            % mark FOV loss
            if all(isnan( data(tp,:,trial) ))
                nantyp(tp,:,trial) = 2;
            end
            
        end
    end
    
    
    % tr_info is a matrix (N_tr x 2) where the first column is the fill rate in
    % percentages associated to the trial and the second column is the max
    % FOV loss length per trial
    
    tr_info        = zeros(size(data,3),2);
    trfil_aux      = int8(nantyp == 0); %contains 1 if data is present
    data_per_trial = size(data,1) * size(data,2);
    
    for trial = 1:size(data,3)
        
        tr_info(trial,1) = sum(sum(trfil_aux(:,:,trial)))/data_per_trial * 100;
        tr_info(trial,2) = 0;
        coun             = 0;
        
        for timep = 1:size(data,1)
            
            if nantyp(timep,1,trial) == 2 % verify whether we are currently in a FOV window
                
                coun = coun + 1;
                if timep == size(data,1) && coun > tr_info(trial,2)
                    tr_info(trial,2) = coun;
                end
                
            else
                
                if coun ~= 0     % verify if we have exited the Nan window
                    if coun > tr_info(trial,2) % verify if the length of the window is greater than max
                        tr_info(trial,2) = coun;
                    end
                    coun = 0;
                end
            end
        end
    end
    
    
    % ro_info is a matrix (N_tr x N_roi) that contains the max nan window
    % length for each trial roi pair.
    % In order to use this properly, first do trial rejection
    
    ro_info = zeros(size(data,3),size(data,2));
    for trial = 1:size(data,3)
        for chan = 1:size(data,2)
            
            coun = 0;
            
            for timep = 1:size(data,1)
                
                if nantyp(timep,chan,trial) ~= 0 % verify whether we are currently in a Nan window
                    
                    coun = coun + 1;
                    if timep == size(data,1) && coun > ro_info(trial,chan)
                        ro_info(trial,chan) = coun;
                    end
                    
                else
                    
                    if coun ~= 0     % verify if we have exited the Nan window
                        if coun > ro_info(trial,chan) % verify if the length of the window is greater than max
                            ro_info(trial,chan) = coun;
                        end
                        coun = 0;
                    end
                end
            end
            
        end
    end
end