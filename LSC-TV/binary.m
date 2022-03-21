ann=anomaly;
ann(find(ann<0.02))=0;
imshow(ann);

colormap(jet);
