function [all_raw,responses] = toss_2024017(all_raw,responses,ro_info,tr_info,p_toss,int_toss)

    % Computes trial rejection criteria: if any trial has less than p_toss
    % of possible data points OR if it has a FOV loss length greater than
    % int_toss, then trial is deleted
    
    p_indx = tr_info(:,1) < p_toss;
    i_indx = tr_info(:,2) > int_toss;
    indx   = p_indx | i_indx;
    
    all_raw(:,:,indx)  = [];
    ro_info(indx,:) = [];
    
    % Computes roi rejection criteria: if an roi has a loss window greater
    % than int_toss across all trials, then it is tossed
    
    indx = any(ro_info > int_toss).';
    
    all_raw(:,indx,:) = [];
end
