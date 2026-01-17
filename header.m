function header(authorName,emailAddress,CopyrightOrganization)
% Brief: inserts predefined header template into the active script
% Details:
%    This function inserts a standardized header template into the active
%    MATLAB script or function. It automatically parses the function or
%    class signature to populate the Syntax, Inputs, and Outputs sections
%    of the header. It also fills in author information and the creation
%    date. If the file already has comments following the signature, the
%    template insertion is skipped.
%
% Syntax:  header
%
%      call from command line with the target script open and active
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
%    headerTemplate={sprintf([...
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
%    no outputs

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

% Author: xingxingcui
% A matlab amateur, https://cuixing158.github.io/
% Email: cuixingxing150@gmail.com
% Created:                         13-Mar-2022
% Version history revision notes:
%     2022.3.16 Support ignoring comments on the next line of a function or class signature that starts with %
%     2022.3.27 Support multiple signature lines and Input and output parameter names are explicitly obtained
%
% Implementation In Matlab R2022a
% Copyright © 2022 xingxingcui.All Rights Reserved.
%
arguments
    authorName (1,:) char = "cuixingxing"
    emailAddress (1,:) char = "cuixingxing150@gmail.com"
    CopyrightOrganization (1,:) char = "xingxingcui"
end

% get current active script and convert text to cell array of lines
currentScript=matlab.desktop.editor.getActive;
assert(~isempty(currentScript),"this feature requires you to open the current m-file or mlx file to be valid.");
allOriLines=matlab.desktop.editor.textToLines(currentScript.Text);

pat = ["function","classdef"];% support function and classdef
cond1 = startsWith(strip(allOriLines,"left"),pat);
cond2 = endsWith(strip(allOriLines),'...');
if any(cond1)
    idxMuls = find(cond1);
    numIdxs = length(idxMuls);
    signatures = cell(numIdxs,1);
    idxSigs = cell(numIdxs,1);
    for i = 1:numIdxs
        if cond2(idxMuls(i))
            sigEndIdx = idxMuls(i)+1;
            while cond2(sigEndIdx)&&(sigEndIdx<length(cond2))% support multiple signature lines
                sigEndIdx= sigEndIdx+1;
            end
            signatures{i} = allOriLines(idxMuls(i):sigEndIdx);
            idxSigs{i} = idxMuls(i):sigEndIdx;
        else
            signatures{i} = allOriLines(idxMuls(i));
            idxSigs{i} = idxMuls(i);
        end
    end
else
    fprintf("%s\n","script comments other than ""function"" and ""classdef"" are not supported.");
    return;
end

% get basic syntax to update header template
allDstLines = [];
preIdx = 1;
preComment = "%    ";
postComment = " - [m,n] size,[double] type,Description";
for i = 1:numIdxs
    currentIdxs = idxSigs{i};
    %     startIdx = currentIdxs(1);
    endIdx = currentIdxs(end);
    preLines = allOriLines(preIdx:endIdx);

    if endIdx+1>length(allOriLines) % last line define "function"
        allOriLines = [allOriLines;" "];
    end
    nearSignatureLine = allOriLines(endIdx+1);
    if startsWith(strip(nearSignatureLine),"%")
        headerTemplate = [];
    else
        % process strings in cell array
        inputStr = preComment+"None";
        outputStr = preComment+"None";
        pat1 = "...";
        sigStr = string(signatures{i});
        currentSig = join(strip(replace(sigStr,pat1,"")),"");
        if startsWith(currentSig,"function")
            currentSig = erase(currentSig,"function ");
            inputArgs = extractBetween(currentSig,"(",")");
            if (~isempty(inputArgs)) && (inputArgs~="")
                inputStr = strip(strsplit(inputArgs,","));
                inputStr = preComment+inputStr+postComment;
                inputStr = join(inputStr,newline);
            end
            outputT = extractBefore(currentSig,"=");
            if (~isempty(outputT)) && (~ismissing(outputT))
                outputT = strip(outputT);
                outputArgs = extractBetween(outputT,"[","]");
                if ~isempty(outputArgs)
                    outputStr = strip(strsplit(outputArgs,","));
                    outputStr = preComment+outputStr+postComment;
                    outputStr = join(outputStr,newline);
                else
                    outputStr = preComment+outputT+postComment;
                end
            end
        else
            currentSig = erase(currentSig,"classdef ");
        end

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
            '%s\n',... % 2
            '%% \n',...
            '%% Outputs:\n',...
            '%s\n',... % 3
            '%% \n',...
            '%% Example: \n',...
            '%%    None\n',...
            '%% \n',...
            '%% See also: None\n',...
            '\n',...
            '%% Author:                          %s\n',... % 4
            '%% Email:                           %s\n',... % 5
            '%% Created:                         %s\n',... % 6
            '%% Version history revision notes:\n' ...
            '%%                                  None\n',...
            '%% Implementation In Matlab R%s\n',... % 7
            '%% Copyright © %s %s.All Rights Reserved.\n',...% 8,9
            '%%'], currentSig,inputStr,outputStr,authorName,emailAddress,...
            string(datetime('now','Format','dd-MMM-yyyy')),version('-release'),string(year(datetime)),...
            CopyrightOrganization)};% the current date is automatically added
    end
    % insert header template as the second cell in the array of text lines
    allDstLines=[allDstLines;preLines;headerTemplate];
    preIdx = endIdx+1;

end
if length(allOriLines)>endIdx
    allDstLines=[allDstLines;allOriLines(endIdx+1:end)];
end

% convert line array back to text and update the text of the current
% active script
allOriLines=matlab.desktop.editor.linesToText(allDstLines);
currentScript.Text=allOriLines;
