function [description] = getPlayLabelDescription(LUT, label)
% Meant to be used with LUT_play_label
    label_index     = cell2mat(LUT.label) == label;
    description     = LUT(label_index, :).description;
end