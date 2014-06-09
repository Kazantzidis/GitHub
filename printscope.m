function [ ] = printscope( )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

shh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','On')
set(gcf,'PaperPositionMode','auto')
set(gcf,'InvertHardcopy','off')
saveas(gcf,'mypic.jpg')
set(0,'ShowHiddenHandles',shh)
end

