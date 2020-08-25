function G = readpfm(filename_pfm)

%Quelle: https://github.com/mzhang94/stereo/blob/master/GF-Matlab/MatlabSDK/readpfm.m
	

	
fid = fopen(filename_pfm);
	

	
fscanf(fid,'%c',[1,3]);
	
cols = fscanf(fid,'%f',1);
	
rows = fscanf(fid,'%f',1);
	
fscanf(fid,'%f',1);
	
fscanf(fid,'%c',1);
	
G = fread(fid,[cols,rows],'single');
	
G(G == Inf) = 0;
	
G = rot90(G);
	
fclose(fid);
	
end
	

	
%open with 'imagesc' (scaled color)
%G=readpfm('disp0.pfm');
%imagesc(G)
%colormap(jet)