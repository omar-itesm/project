function [match_plays] = compensatePlayIndexes(match_plays, init_index)
% COMPENSATEPLAYINDEXES The function receives the set of indexes that
% correspond to the plays of a match and applies an index offset. The
% offset is needed to transalte indexes from match indexes into database
% indexes. The offset 'init_index' corresponds to the initial index of the
% match in the database.
    match_plays = match_plays + (init_index - 1);
end