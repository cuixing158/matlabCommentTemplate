function header(authorName,emailAddress,CopyrightOrganization)
% Brief: inserts predefined header template into the active script
% Detials:
%          None
%
% Syntax:  header
%
%      call from command line whith the target script open and active
%      template will be inserted after the first line
%
%
% Inputs:
%    authorName - (optional),default = "yourname"
%    emailAddress- (optional),default = "youremail@email.com"
%    CopyrightOrganization- (optional),default = "yourOrganization"
%
%    notes: template is defined as character array in lines 99-125
%    to change the template change the character array defined by
%    headerTemplate={sprntf([...
%                       'template'),...
%                       ]};
%    the published version adds your contact information (same as in this
%    header)
%
%    some parts are prepopulated:
%       -) function name (first word)
%       -) syntax - initialized as a copy of the first line of the function
%               [outputs]=functionName(inputs)
%       -) Date created  - current date
%
%
% Outputs:
%    no outpus

%
% See also: None
% this script was partially inspired by:
% [1] J. Benjamin Kacerovsky (2022). insertTemplateHeader (https://www.mathworks.com/matlabcentral/fileexchange/79903-inserttemplateheader), MATLAB Central File Exchange. Retrieved March 13, 2022.
% [2] David Legland (2022). Matlab Code Templates (https://github.com/mattools/matlab-templates/releases/tag/v1.0), GitHub. Retrieved March 13, 2022.
% [3] Jacob Bowen (2022). Template for creating verbose logs of script executions (https://www.mathworks.com/matlabcentral/fileexchange/76153-template-for-creating-verbose-logs-of-script-executions), MATLAB Central File Exchange. Retrieved March 13, 2022.
% [4] Pavel Trnka (2022). MATLAB Snippets (https://github.com/trnkap/matlab-snippets), GitHub. Retrieved March 13, 2022.
%
% header format is adapted from:
% J. Benjamin Kacerovsky (2022). insertTemplateHeader (https://www.mathworks.com/matlabcentral/fileexchange/79903-inserttemplateheader), MATLAB Central File Exchange. Retrieved March 13, 2022.

% Author: cuixingxing
% A matlab amateur, https://cuixing158.github.io/
% Email: cuixingxing150@gmail.com
% Created:                         13-Mar-2022
% Version history revision notes:
%                                  None
% Implementation In Matlab R2022a
% Copyright © 2022 cuixingxing.All Rights Reserved.
%
arguments
    authorName (1,:) char = "yourname"
    emailAddress (1,:) char = "youremail@email.com"
    CopyrightOrganization (1,:) char = "yourOrganization"
end

% get current active script and convert text to cell array of lines
currentScript=matlab.desktop.editor.getActive;
allOriLines=matlab.desktop.editor.textToLines(currentScript.Text);

pat = ["function","classdef"];% support function and classdef
cond1 = startsWith(strip(allOriLines,"left"),pat);
cond2 = endsWith(allOriLines,'...');
if any(cond1)
    idxMuls = find(cond1);
    numIdxs = length(idxMuls);
    signatures = cell(numIdxs,1);
    idxSigs = cell(numIdxs,1);
    for i = 1:numIdxs
        if cond2(idxMuls(i))
            signatures{i} = allOriLines(idxMuls(i):idxMuls(i)+1); % Assume no more than 2 lines
            idxSigs{i} = idxMuls(i):idxMuls(i)+1;
        else
            signatures{i} = allOriLines(idxMuls(i));
            idxSigs{i} = idxMuls(i);
        end
    end
else
    fprintf("%s\n","Script comments other than ""function"" and ""classdef"" are not supported");
    return;
end

% get basic syntax to update header template
allDstLines = [];
preIdx = 1;
for i = 1:numIdxs
    currentIdxs = idxSigs{i};
%     startIdx = currentIdxs(1);
    endIdx = currentIdxs(end);
    preLines = allOriLines(preIdx:endIdx);

    % process strings in cell array
    patN = ["function","classdef","..."," "];
    temp = string(replace(signatures{i},patN,""));
    currentSig = temp.strip().join();

    % create header template to be inserted
    % modify this string to change header template
    headerTemplate={sprintf([
        '%% Brief: One line description of what the function or class performs\n',...
        '%% Details:\n',...
        '%%    None\n',...
        '%% \n',...
        '%% Syntax:  \n',...
        '%%     %s\n',... % 1
        '%% \n',...
        '%% Inputs:\n',...
        '%%    input1 - [m,n] size,[double] type,Description\n',...
        '%%    input2 - [m,n] size,[double] type,Description\n',...
        '%%    input3 - [m,n] size,[double] type,Description\n',...
        '%% \n',...
        '%% Outputs:\n',...
        '%%    output1 - [m,n] size,[double] type,Description\n',...
        '%% \n',...
        '%% Example: \n',...
        '%%    None\n',...
        '%% \n',...
        '%% See also: None\n',...
        '\n',...
        '%% Author:                          %s\n',... % 2
        '%% Email:                           %s\n',... % 3
        '%% Created:                         %s\n',... % 4
        '%% Version history revision notes:\n' ...
        '%%                                  None\n',...
        '%% Implementation In Matlab R%s\n',... % 5
        '%% Copyright © %s %s.All Rights Reserved.\n',...% 6,7
        '%%'], currentSig,authorName,emailAddress,string(date),...
        version('-release'),string(year(date)),CopyrightOrganization)};% the current date is automatically added

    % insert header template as the second cell in the array of text lines
    allDstLines=[allDstLines;preLines;headerTemplate];
    preIdx = endIdx+1;
end
if length(allOriLines)>endIdx
    allDstLines=[allDstLines;allOriLines(endIdx+1:end)];
end

% convert line array bback to text and update the text of the current
% active script
allOriLines=matlab.desktop.editor.linesToText(allDstLines);
currentScript.Text=allOriLines;
