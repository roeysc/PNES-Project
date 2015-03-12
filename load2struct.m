function struct = load2struct(filePath)
    % LOAD2STRUCT loads the struct in filePath to a variable,
    % without needing to know the original field name of this struct.
    struct = load(filePath);
    structFieldName = fieldnames(struct);
    eval(['struct = struct.' structFieldName{1} ';']);
end