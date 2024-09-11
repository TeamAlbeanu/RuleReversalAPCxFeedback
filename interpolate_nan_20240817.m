function ai = interpolate_nan_20240817(all_raw,nanlpt,thres_aki,thres_lin)

    ai = all_raw;
    n_trials = size(ai,3);
    n_roi    = size(ai,2);
    
    % Fill short periods with NaNs with data depending of the trace trend

    for trial = 1:n_trials
        for roi = 1 :n_roi
            lens   = nanlpt{trial,roi,2};
            starts = nanlpt{trial,roi,3};
            ends   = nanlpt{trial,roi,4};
            
            for win = 1:nanlpt{trial,roi,1}
                
                if starts(win) == 1 || ends(win) == size(all_raw,1)
                    continue
                end
                
                if lens(win)<thres_aki
                    
                    x = find(~isnan(ai(:,roi,trial)));
                    y = ai(x,roi,trial);
                    yy = akima(x,y, starts(win):ends(win));                   
                else
                    
                    if (ai(ends(win)+1,roi,trial)-ai(starts(win)-1,roi,trial))>thres_lin
                        
                        yy = ones(lens(win),1) * min([ai(starts(win)-1,roi,trial),ai(ends(win)+1,roi,trial)]) ;                       
                    else
                        
                        x = find(~isnan(ai(:,roi,trial)));
                        v = ai(x,roi,trial);
                        yy = interp1(x,v,starts(win):ends(win));                      
                    end
                end
                
                ai(starts(win):ends(win),roi,trial) = yy;
            end        
        end
    end
end  