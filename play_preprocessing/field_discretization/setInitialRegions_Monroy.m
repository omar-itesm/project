function regions = setInitialRegions_Monroy()


    % Defending (back) region
    region1.name = 'B';
    region1.x    = 0;
    region1.y    = 0;
    region1.w    = 75;
    region1.h    = 100;
    
    % Laterals
    region2.name = 'CC';
    region2.x    = 75;
    region2.y    = 0;
    region2.w    = 25;
    region2.h    = 20;

    region3.name = 'A';
    region3.x    = 75;
    region3.y    = 80;
    region3.w    = 25;
    region3.h    = 20;

    % DL
    region4.name = 'DLC';
    region4.x    = 75;
    region4.y    = 20;
    region4.w    = 8.5;
    region4.h    = 60/3;
    
    region5.name = 'DLM';
    region5.x    = 75;
    region5.y    = 20+1*(60/3);
    region5.w    = 8.5;
    region5.h    = 60/3;
    
    region6.name = 'DLA';
    region6.x    = 75;
    region6.y    = 20+2*(60/3);
    region6.w    = 8.5;
    region6.h    = 60/3;

    % AG
    region7.name = 'AGC';
    region7.x    = 75+8.5;
    region7.y    = 20;
    region7.w    = 11;
    region7.h    = 60/3;
   
    region8.name = 'AGM';
    region8.x    = 75+8.5;
    region8.y    = 20+1*(60/3);
    region8.w    = 11;
    region8.h    = 60/3;
    
    region9.name = 'AGA';
    region9.x    = 75+8.5;
    region9.y    = 20+2*(60/3);
    region9.w    = 11;
    region9.h    = 60/3;
    

    % Close to goal
    region10.name = 'CC2P';
    region10.x    = 94.5;
    region10.y    = 20;
    region10.w    = 5.5;
    region10.h    = 15;

    region11.name = '2P';
    region11.x    = 94.5;
    region11.y    = 35;
    region11.w    = 5.5;
    region11.h    = 30/3;
    
    region12.name = 'M';
    region12.x    = 94.5;
    region12.y    = 35 + 1*(30/3);
    region12.w    = 5.5;
    region12.h    = 30/3;
    
    region13.name = '1P';
    region13.x    = 94.5;
    region13.y    = 35 + 2*(30/3);
    region13.w    = 5.5;
    region13.h    = 30/3;
    
    region14.name = 'A1P';
    region14.x    = 94.5;
    region14.y    = 35 + 3*(30/3);
    region14.w    = 5.5;
    region14.h    = 15;
    
    regions = [region1, region2, region3, region4, region5, region6, region7, region8, region9, region10, region11, region12, region13, region14];
    
end