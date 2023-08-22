function compression = getCompression(this)
%% Get the compression ratio of the stored data
	
    fullData = full(this.data);                     % Get the full matrix version of the data
	fullData(2^this.getDepth():end)=[]; % Eliminate the non-used data from the full matrix
	data = this.data;                   % Get the sparse matrix data
	s = whos('fullData','data');                    % Get information about the variables
	
    compression = s(1).bytes/s(2).bytes;            % Calculate the compression rate
end