function save_tiff_20240818(folder, image, filename)

    cd(folder)

    for k = 1:size(image, 3)

        slice = image(:, :, k);
        slice = uint16(slice); % Ensure it's uint16

        if k == 1

            imwrite(slice, filename, 'tiff');
        else

            imwrite(slice, filename, 'tiff', 'WriteMode', 'append');
        end
    end
end