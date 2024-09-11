function roimeans = readroi_20240817(path,rois)
    
    % Get information al time-stacks for each trial
    files_to_analyze = dir([path filesep '*_.tif']);
    
    % Fluorescence extraction information for each trial t-stack
    for file_counter = 1:length(files_to_analyze)
        
        disp(['file num ' num2str(file_counter) ' Extracting ROI Info'])
        filetoRead  = files_to_analyze(file_counter).name;
        s           = dir([path filesep filetoRead]);

        if s.bytes>12                                                      % check wheather the file is valid
            
            tiftag = imfinfo([path filesep filetoRead]);                   % contains image info
            nFrames=numel(tiftag);
    
            if file_counter==1
    
                [X,Y] = meshgrid(1:tiftag(1).Width,1:tiftag(1).Height);
                
                for rr=1:length(rois)
                
                    mask(:,:,rr)=inpolygon(X,Y,rois{rr}.mnCoordinates(:,1),rois{rr}.mnCoordinates(:,2));
                end
            end
            
            roimeans{file_counter}=zeros(nFrames,length(rois));
            
            for ii = 1:nFrames
                
                g = imread([path filesep filetoRead], ii);
                
                for rr=1:length(rois)
                    roimeans{file_counter}(ii,rr)=mean(g(mask(:,:,rr)));
                end      
            end                         
        end
    end
end