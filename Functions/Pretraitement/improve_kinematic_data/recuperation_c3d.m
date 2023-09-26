function [ VICON, data ] = recuperation_c3d(c3dfile )
VICON=[] ;
data = btk_loadc3d(c3dfile, 10);
VICON.Marqueurs=data.marker_data.Markers;
VICON.Time=data.marker_data.Time;
VICON.Info.frequence=data.marker_data.Info.frequency;
VICON.Info.NumFrames=data.marker_data.Info.NumFrames;
VICON.Info.unit=data.marker_data.Info.units.ALLMARKERS;

anim = 'off';
end
