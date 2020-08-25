function [outputImage] = resizeToInitialSize(image,im_size)

%# Initializations:

                           %# The resolution scale factors: [rows columns]
oldSize = size(image);                   %# Get the size of your image
newSize = im_size;                       %# Compute the new image size
scale = [newSize(1)/oldSize(1) newSize(2)/oldSize(2)];

%# Compute an upsampled set of indices:

rowIndex = min(round(((1:newSize(1))-0.5)./scale(1)+0.5),oldSize(1));
colIndex = min(round(((1:newSize(2))-0.5)./scale(2)+0.5),oldSize(2));

%# Index old image to get new image:

outputImage = image(rowIndex,colIndex,:);

end

