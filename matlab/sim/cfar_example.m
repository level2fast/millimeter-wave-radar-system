cfar2D = phased.CFARDetector2D('GuardBandSize',5,'TrainingBandSize',10,...
  'ProbabilityFalseAlarm',1e-5);

[resp,rngGrid,dopGrid] = helperRangeDoppler;

[~,rangeIndx] = min(abs(rngGrid-[1000 4000]));
[~,dopplerIndx] = min(abs(dopGrid-[-1e4 1e4]));
[columnInds,rowInds] = meshgrid(dopplerIndx(1):dopplerIndx(2),...
  rangeIndx(1):rangeIndx(2));
CUTIdx = [rowInds(:) columnInds(:)]';


detections = cfar2D(resp,CUTIdx);
helperDetectionsMap(resp,rngGrid,dopGrid,rangeIndx,dopplerIndx,detections)