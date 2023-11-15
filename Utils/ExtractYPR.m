function [eul] = ExtractYPR(R)
    eul = zeros(3,1);
    eul(2) = -asin(R(3,1));
    croll = cos(eul(2));
    eul(3) = atan2( R(2,1)/croll, R(1,1)/croll );
    eul(1) = atan2( R(3,2)/croll, R(3,3)/croll );
end

