function error = setNodesDataAt(this, pos, dataNode)
 % Return the data at the desired positions
	try
        this.data(pos) = dataNode;
        error = false;
    catch
        error = true;
    end
end