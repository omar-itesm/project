function region_name = assignCustom5RegionEventPos(event_pos)
% The function assigns the event position to a given region in the field.
% First we start by defining the regions in the field.

    regions = setInitialRegions_Monroy();
    
    region_name = assignRegion(event_pos, regions);

    
    is_ok = sanityCheck(event_pos, regions);
    
    if ~is_ok
       error('Sanity check failed'); 
    end
    
    % Account for compound regions
    if region_name == "A1P"
        region_name = "AGA";
    elseif region_name == "CC2P"
        region_name = "AGC";
    end
    
end

function is_ok = sanityCheck(event_pos, regions)
% Receives a vector with all the checks and ensures that the event belongs
% at most to one region.

    region_cnt = 0;

    for i = 1:numel(regions)
        region = regions(i);
        belongs = belongsToRegion(event_pos, region);
        
        if belongs
            region_cnt = region_cnt + 1;
        end
    end

    if region_cnt == 1
        is_ok = true;
    else
        is_ok = false;
    end
    
end

function region_name = assignRegion(pos, regions)

    for i = 1:numel(regions)

       region = regions(i);

       belongs = belongsToRegion(pos, region);
       
       if belongs
          break; 
       end

    end

    region_name = region.name;
end


function belongs = belongsToRegion(pos, region)
    belongs = false;
    
    x = pos(1);
    y = pos(2);
    
    % Avoid errors when detecting the region for coordinates with 0 by
    % compensating the coordinates of the region when appropiate.
    if region.x == 0
        region.x = -1;
        region.w = region.w + 1;
    end
    
    if region.y == 0
        region.y = -1;
        region.h = region.h + 1;
    end
    
    if x > region.x && x <= (region.x + region.w)
       if y > region.y && y <= (region.y + region.h)
           belongs = true;
       end
    end
   
end