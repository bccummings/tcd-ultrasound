function tcd_driver(dcm_dir, mat_dir)

  files = dir(dcm_dir);
  files = files([files.isdir] == 0);

  for iFile = 1:length(files)
    inFile = strcat(dcm_dir, '/', files(iFile).name);
    outFile = strcat(mat_dir, '/', files(iFile).name(1:end-4), '.mat');
    read_tcd_file(inFile, outFile);
  end

end


function data = read_tcd_file(inFn, outFn)

%% READTCD is a function which uses optical character recognition (OCR) to
% extract transcranial Doppler data from ultrasound images. It takes as its
% arguments:
%
% inFn: the pathname to a given ultrasound file
% outFn: a pathname to which the output is written.
%

%% FILE I/O
img  = dicomread(inFn);
info = dicominfo(inFn);

imgROI = img(190:470, 760:1000, :, :); % video is 4D tensor hxwxrgbxf
nFrames = size(imgROI, 4);
FsUS = 1/(info.FrameTime*0.001); % Frame time is period in ms

%% OCR data from each frame
for iFrame = 1:nFrames

  clear txt

  ocrtext = ocr(imgROI(:, :, :, iFrame));
  txt = {ocrtext.Text};

  txt = txt(~cellfun('isempty', txt));

  textstr = replace(txt, ' ', ''); % remove spaces which are usually faulty
  textcell = splitlines(textstr);
  textcell = textcell(~cellfun('isempty', textcell));

  try

    o.ps(iFrame, :) =     str2num(textcell{1}(isstrprop(textcell{1}, 'digit')))/100;
    o.ed(iFrame, :) =     str2num(textcell{2}(isstrprop(textcell{2}, 'digit')))/100;
    o.tamax(iFrame, :) =  str2num(textcell{3}(isstrprop(textcell{3}, 'digit')))/100;
    o.tamean(iFrame, :) = str2num(textcell{4}(isstrprop(textcell{4}, 'digit')))/100;
    o.pi(iFrame, :) =     str2num(textcell{5}(isstrprop(textcell{5}, 'digit')))/100;
    o.ri(iFrame, :) =     str2num(textcell{6}(isstrprop(textcell{6}, 'digit')))/100;
    o.sd(iFrame, :) =     str2num(textcell{7}(isstrprop(textcell{7}, 'digit')))/100;

    hr = textcell{8}(isstrprop(textcell{8}, 'digit'));
    o.hr(iFrame, :) = str2num(hr(1:end-1));

  catch

    o.ps(iFrame, :) = NaN;
    o.ed(iFrame, :) = NaN;
    o.tamax(iFrame, :) = NaN;
    o.tamean(iFrame, :) = NaN;
    o.pi(iFrame, :) = NaN;
    o.ri(iFrame, :) = NaN;
    o.sd(iFrame, :) = NaN;
    o.hr(iFrame, :) = NaN;

  end

end

  data = table(o.ps, o.ed, o.tamax, o.tamean, o.pi, o.ri, o.sd, o.hr);
  data.Properties.VariableNames = {'ps', 'ed', 'tamax', 'tamean', 'pi', 'ri', 'sd', 'hr'};
  data.Properties.VariableUnits = {'cm/s', 'cm/s', 'cm/s', 'cm/s', '', '', '', 'bpm'};
  data.Properties.UserData = FsUS;
  
  save(outFn, 'data');
  disp(sprintf('File %s completed successfully', outFn))
  
end
