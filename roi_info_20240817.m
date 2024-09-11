function [ROI,f1] = roi_info_20240817(roi_set,image_roi,num_roi) 
    
    % Get coordinate information for each ROI
    for nRoi = 1:num_roi
    
        rawRoi                      = roi_set{nRoi};
        ROI.refimage_x(nRoi,:)      = str2double(rawRoi.strName(1:4));
        ROI.refimage_y(nRoi,:)      = str2double(rawRoi.strName(6:9));
    
        ROI.roicoordinate(nRoi,:)   = rawRoi.vnRectBounds;
    end
    
    % Plot FOV witn ROIs
    f1 = figure(1);
        hold on
        imagesc(image_roi);
            colormap(gray);
            xlim([1 size(image_roi,2)]);
            ylim([1 size(image_roi,1)]);
            set(gca,'xtick',[])
            set(gca,'ytick',[])
    
            for nRoi = 1:num_roi
        
                roi_coord_x = roi_set{1,nRoi}.mnCoordinates(:,1);
                roi_coord_y = roi_set{1,nRoi}.mnCoordinates(:,2); 
        
                plot(roi_coord_x,roi_coord_y,'Color','yellow');
                    xlim([1 size(image_roi,2)]);
                    ylim([1 size(image_roi,1)]);
    
                clearvars roi_coord_x roi_coord_y
            end    
end